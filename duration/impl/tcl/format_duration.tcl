# format_duration.tcl — Human-friendly duration and relative time formatting.

package provide sayableduration 0.5.0

namespace eval ::sayableduration {
    variable VERSION "0.5.0"
    # 500 years, the same ceiling as sayable-age
    variable MAX_DURATION_MONTHS 6000
    variable _default_locale ""
    variable _registry_loaded 0
    variable _script_dir [file dirname [file normalize [info script]]]

    # --- Helpers ---

    proc _is_leap_year {y} {
        return [expr {($y % 4 == 0 && $y % 100 != 0) || $y % 400 == 0}]
    }

    proc _days_in_month {y m} {
        set days_table {0 31 28 31 30 31 30 31 31 30 31 30 31}
        set d [lindex $days_table $m]
        if {$m == 2 && [_is_leap_year $y]} {
            set d 29
        }
        return $d
    }

    proc _days_since_epoch {year month day} {
        # Calculate days since 2000-01-01
        set days 0
        if {$year >= 2000} {
            for {set y 2000} {$y < $year} {incr y} {
                if {[_is_leap_year $y]} {
                    incr days 366
                } else {
                    incr days 365
                }
            }
        } else {
            for {set y $year} {$y < 2000} {incr y} {
                if {[_is_leap_year $y]} {
                    incr days -366
                } else {
                    incr days -365
                }
            }
        }
        for {set m 1} {$m < $month} {incr m} {
            incr days [_days_in_month $year $m]
        }
        incr days [expr {$day - 1}]
        return $days
    }

    # YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
    variable TIMESTAMP {^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?$}

    proc _parse_iso_to_seconds {iso_str} {
        # Parse ISO datetime to epoch-like seconds for diffing; empty if malformed
        variable TIMESTAMP
        if {![regexp $TIMESTAMP $iso_str -> ys mos ds hs mins secs]} {
            return ""
        }
        if {$secs eq ""} {
            set secs 0
        }
        # scan reads leading zeros as decimal (expr would read 08 as octal)
        scan "$ys $mos $ds $hs $mins $secs" "%d %d %d %d %d %d" year month day hour minute second
        if {$month < 1 || $month > 12 || $day < 1 || $day > [_days_in_month $year $month]} {
            return ""
        }
        if {$hour > 23 || $minute > 59 || $second > 59} {
            return ""
        }

        set days [_days_since_epoch $year $month $day]
        return [expr {$days * 86400 + $hour * 3600 + $minute * 60 + $second}]
    }

    proc _is_plural_dict {unit_forms} {
        if {[catch {dict exists $unit_forms other} has_other]} {
            return 0
        }
        return $has_other
    }

    proc _resolve_unit {count unit_forms locale {half ""}} {
        set base_n $count
        if {$half ne "" && [string first "\{n\}" $half] >= 0} {
            set n [string map [list "\{n\}" $base_n] $half]
        } else {
            set n $base_n
        }

        if {[_is_plural_dict $unit_forms]} {
            set plural_proc [dict get $locale plural]
            if {$half ne ""} {
                set category "other"
            } else {
                set category [$plural_proc $count]
            }
            if {[dict exists $unit_forms $category]} {
                set template [dict get $unit_forms $category]
            } else {
                set template [dict get $unit_forms other]
            }
        } else {
            set template $unit_forms
        }

        set result [string map [list "\{n\}" $n] $template]
        if {$half ne "" && [string first "\{0\}" $half] >= 0} {
            set result [string map [list "\{0\}" $result] $half]
        }
        return $result
    }

    proc _pick {override attr default_val} {
        if {[dict size $override] > 0 && [dict exists $override $attr]} {
            return [dict get $override $attr]
        }
        return $default_val
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

        # Resolve units
        set units [dict create]
        foreach unit_name {second minute hour day week month year} {
            set base_unit [dict get [dict get $locale units] $unit_name]
            if {[dict size $ovr] > 0 && [dict exists $ovr units] && [dict exists [dict get $ovr units] $unit_name]} {
                set unit_val [dict get [dict get $ovr units] $unit_name]
            } else {
                set unit_val $base_unit
            }
            dict set units $unit_name $unit_val
        }

        set half [_pick $ovr half [dict get $locale half]]
        set delimiter [_pick $ovr delimiter [dict get $locale delimiter]]
        set just_now [dict get $locale just_now]
        set ago [_pick $ovr ago [dict get $locale ago]]
        set in_future [_pick $ovr in_future [dict get $locale in_future]]

        return [dict create \
            locale $locale \
            units $units \
            half $half \
            delimiter $delimiter \
            just_now $just_now \
            ago $ago \
            in_future $in_future \
        ]
    }

    proc _format_duration_seconds {formatter total} {
        set locale [dict get $formatter locale]
        set units [dict get $formatter units]
        set half [dict get $formatter half]
        set delimiter [dict get $formatter delimiter]
        set just_now [dict get $formatter just_now]

        # 0 seconds
        if {$total == 0} {
            return $just_now
        }

        # 1-59 seconds
        if {$total < 60} {
            return [_resolve_unit $total [dict get $units second] $locale]
        }

        set total_minutes [expr {$total / 60}]
        set remainder_seconds [expr {$total % 60}]

        # 1-4 minutes: minutes + seconds
        if {$total_minutes < 5} {
            set result [_resolve_unit $total_minutes [dict get $units minute] $locale]
            if {$remainder_seconds > 0} {
                append result $delimiter [_resolve_unit $remainder_seconds [dict get $units second] $locale]
            }
            return $result
        }

        # 5-59 minutes
        if {$total_minutes < 60} {
            return [_resolve_unit $total_minutes [dict get $units minute] $locale]
        }

        set total_hours [expr {$total / 3600}]
        set remainder_minutes [expr {($total % 3600) / 60}]

        # 1-5 hours: hours + minutes (with half marker)
        if {$total_hours <= 5} {
            if {$remainder_minutes == 30} {
                return [_resolve_unit $total_hours [dict get $units hour] $locale $half]
            }
            set result [_resolve_unit $total_hours [dict get $units hour] $locale]
            if {$remainder_minutes > 0} {
                append result $delimiter [_resolve_unit $remainder_minutes [dict get $units minute] $locale]
            }
            return $result
        }

        # 6-23 hours
        if {$total_hours < 24} {
            return [_resolve_unit $total_hours [dict get $units hour] $locale]
        }

        set total_days [expr {$total / 86400}]
        set remainder_hours [expr {($total % 86400) / 3600}]

        # 1-2 days: days + hours (with half marker)
        if {$total_days <= 2} {
            if {$remainder_hours == 12} {
                return [_resolve_unit $total_days [dict get $units day] $locale $half]
            }
            set result [_resolve_unit $total_days [dict get $units day] $locale]
            if {$remainder_hours > 0} {
                append result $delimiter [_resolve_unit $remainder_hours [dict get $units hour] $locale]
            }
            return $result
        }

        # 3-6 days
        if {$total_days < 7} {
            return [_resolve_unit $total_days [dict get $units day] $locale]
        }

        set total_weeks [expr {$total_days / 7}]
        set remainder_days [expr {$total_days % 7}]

        # 1-4 weeks: weeks + days
        if {$total_days < 30} {
            set result [_resolve_unit $total_weeks [dict get $units week] $locale]
            if {$remainder_days > 0} {
                append result $delimiter [_resolve_unit $remainder_days [dict get $units day] $locale]
            }
            return $result
        }

        # Approximate months (30.44 days average)
        set total_months [expr {round($total_days / 30.44)}]
        variable MAX_DURATION_MONTHS
        if {$total_months > $MAX_DURATION_MONTHS} {
            return ""
        }

        # 1-11 months
        if {$total_months < 12} {
            if {$total_months == 0} {
                set total_months 1
            }
            return [_resolve_unit $total_months [dict get $units month] $locale]
        }

        # 12+ months: years + months
        set total_years [expr {$total_months / 12}]
        set remainder_months [expr {$total_months % 12}]
        set result [_resolve_unit $total_years [dict get $units year] $locale]
        if {$remainder_months > 0} {
            append result $delimiter [_resolve_unit $remainder_months [dict get $units month] $locale]
        }
        return $result
    }

    proc format_duration {formatter value {end_val ""}} {
        # Handle integer (seconds) mode
        # Tcl 8.6 `string is integer` rejects values past 32 bits; durations
        # up to the 500-year ceiling need more, and expr handles big integers.
        if {[regexp {^-?[0-9]+$} $value]} {
            set seconds $value
            if {$seconds < 0} {
                return ""
            }
            return [_format_duration_seconds $formatter $seconds]
        }

        # Handle timestamp mode
        if {$value eq ""} {
            return ""
        }
        if {$end_val eq ""} {
            return ""
        }
        set s [_parse_iso_to_seconds $value]
        set e [_parse_iso_to_seconds $end_val]
        if {$s eq "" || $e eq ""} {
            return ""
        }
        set total [expr {abs($e - $s)}]
        return [_format_duration_seconds $formatter $total]
    }

    proc format_since {formatter start as_of} {
        if {$start eq "" || $as_of eq ""} {
            return ""
        }
        set s [_parse_iso_to_seconds $start]
        set a [_parse_iso_to_seconds $as_of]
        if {$s eq "" || $a eq ""} {
            return ""
        }
        set diff [expr {$a - $s}]
        if {$diff < 0} {
            return ""
        }
        if {$diff == 0} {
            return [dict get $formatter just_now]
        }
        set dur [_format_duration_seconds $formatter $diff]
        if {$dur eq ""} {
            return ""
        }
        set ago [dict get $formatter ago]
        return [string map [list "\{0\}" $dur] $ago]
    }

    proc format_until {formatter target as_of} {
        if {$target eq "" || $as_of eq ""} {
            return ""
        }
        set t [_parse_iso_to_seconds $target]
        set a [_parse_iso_to_seconds $as_of]
        if {$t eq "" || $a eq ""} {
            return ""
        }
        set diff [expr {$t - $a}]
        if {$diff < 0} {
            return ""
        }
        if {$diff == 0} {
            return [dict get $formatter just_now]
        }
        set dur [_format_duration_seconds $formatter $diff]
        if {$dur eq ""} {
            return ""
        }
        set in_future [dict get $formatter in_future]
        return [string map [list "\{0\}" $dur] $in_future]
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
            set _default_locale [new [sayableduration_get_locale "en"]]
        }
        return $_default_locale
    }

    proc duration {value {end_val ""}} {
        return [format_duration [_default_formatter] $value $end_val]
    }

    proc since {start as_of} {
        return [format_since [_default_formatter] $start $as_of]
    }

    proc until {target as_of} {
        return [format_until [_default_formatter] $target $as_of]
    }

    proc get_locale {code} {
        _ensure_registry
        return [sayableduration_get_locale $code]
    }
}
