# format_time.tcl — Human-friendly clock time formatting.

package provide sayabletime 0.5.0

namespace eval ::sayabletime {
    variable VERSION "0.5.0"
    variable _default_locale ""
    variable _registry_loaded 0
    variable _script_dir [file dirname [file normalize [info script]]]

    # --- Helpers ---

    # A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
    # suffix, which is ignored), alone or after the T of an ISO datetime.
    variable CLOCK_TIME {^(?:([0-9]{4})-([0-9]{2})-([0-9]{2})T)?([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?$}

    proc _is_real_date {y m d} {
        if {$m < 1 || $m > 12 || $d < 1} {
            return 0
        }
        if {$m == 2} {
            set last [expr {(($y % 4 == 0 && $y % 100 != 0) || $y % 400 == 0) ? 29 : 28}]
        } else {
            set last [expr {$m in {4 6 9 11} ? 30 : 31}]
        }
        return [expr {$d <= $last}]
    }

    proc _parse_time {input_str} {
        # Parse a clock time or ISO datetime to list {hour minute} or empty
        variable CLOCK_TIME
        if {![regexp $CLOCK_TIME $input_str -> ys ms ds hs mins secs]} {
            return {}
        }
        # scan reads leading zeros as decimal (expr would read 08 as octal)
        if {$ys ne ""} {
            scan "$ys $ms $ds" "%d %d %d" y m d
            if {![_is_real_date $y $m $d]} {
                return {}
            }
        }
        if {$secs eq ""} {
            set secs 0
        }
        scan "$hs $mins $secs" "%d %d %d" hour minute second
        if {$hour > 23 || $minute > 59 || $second > 59} {
            return {}
        }
        return [list $hour $minute]
    }

    proc _round_to_5 {minute} {
        return [expr {(($minute + 2) / 5) * 5}]
    }

    # --- Public API ---

    proc new {locale {compactness "normal"}} {
        if {$compactness eq "short"} {
            set ovr [dict get $locale short]
        } elseif {$compactness eq "compact"} {
            set ovr [dict get $locale compact]
        } else {
            set ovr [dict create]
        }

        return [dict create \
            locale $locale \
            compactness $compactness \
            short_clock $ovr \
        ]
    }

    proc _format_natural {formatter hour minute} {
        set locale [dict get $formatter locale]
        set clock [dict get $locale clock]
        set rounded [_round_to_5 $minute]
        set h $hour
        if {$rounded == 60} {
            set rounded 0
            set h [expr {($h + 1) % 24}]
        }
        if {$rounded == 0} {
            if {$h == 0} {
                return [dict get $clock midnight]
            }
            if {$h == 12} {
                return [dict get $clock noon]
            }
        }
        set h12 [expr {$h % 12}]
        set next_h12 [expr {($h + 1) % 12}]
        set hours [dict get $clock hours]
        set h_name [lindex $hours $h12]
        set next_h_name [lindex $hours $next_h12]
        set patterns [dict get $clock patterns]
        if {[dict exists $patterns $rounded]} {
            set pattern [dict get $patterns $rounded]
        } elseif {[dict exists $patterns 0]} {
            set pattern [dict get $patterns 0]
        } else {
            set pattern "\{h\}"
        }
        set result [string map [list "\{h\}" $h_name "\{next_h\}" $next_h_name] $pattern]
        return $result
    }

    proc _format_digital {formatter hour minute} {
        set sc [dict get $formatter short_clock]
        set clock_cfg [dict get $sc clock]
        set use24h [dict get $clock_cfg use24h]
        set fmt [dict get $clock_cfg format]
        set am_str [dict get $clock_cfg am]
        set pm_str [dict get $clock_cfg pm]

        if {$use24h} {
            set result [string map [list "\{h\}" $hour "\{mm\}" [format "%02d" $minute]] $fmt]
            return $result
        }

        set h12 [expr {$hour % 12}]
        if {$h12 == 0} {
            set h12 12
        }
        if {$am_str eq "" && $pm_str eq ""} {
            set ampm [expr {$hour < 12 ? "AM" : "PM"}]
        } else {
            set ampm [expr {$hour < 12 ? $am_str : $pm_str}]
        }
        set result [string map [list "\{h\}" $h12 "\{mm\}" [format "%02d" $minute] "\{ampm\}" $ampm] $fmt]
        return $result
    }

    proc format_time {formatter input_str} {
        if {$input_str eq ""} {
            return ""
        }
        set parsed [_parse_time $input_str]
        if {[llength $parsed] == 0} {
            return ""
        }
        lassign $parsed hour minute

        set compactness [dict get $formatter compactness]
        set sc [dict get $formatter short_clock]
        if {$compactness ne "normal" && [dict size $sc] > 0} {
            return [_format_digital $formatter $hour $minute]
        }
        return [_format_natural $formatter $hour $minute]
    }

    # --- Convenience functions with default English locale ---

    proc _ensure_registry {} {
        variable _registry_loaded
        variable _script_dir
        if {!$_registry_loaded} {
            source [file join $_script_dir locales registry.tcl]
            set _registry_loaded 1
        }
    }

    proc _default_formatter {} {
        variable _default_locale
        if {$_default_locale eq ""} {
            _ensure_registry
            set _default_locale [new [sayabletime_get_locale "en"]]
        }
        return $_default_locale
    }

    proc time_fmt {input_str} {
        return [format_time [_default_formatter] $input_str]
    }

    proc get_locale {code} {
        _ensure_registry
        return [sayabletime_get_locale $code]
    }
}
