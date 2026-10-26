# format_date.tcl — Human-friendly date formatting.

package provide sayabledate 0.5.0

namespace eval ::sayabledate {
    variable VERSION "0.5.0"
    variable _default_locale ""
    variable _registry_loaded 0
    variable _script_dir [file dirname [file normalize [info script]]]

    # --- Date helpers ---

    proc _days_in_month {y m} {
        if {$m == 2} {
            return [expr {(($y % 4 == 0 && $y % 100 != 0) || $y % 400 == 0) ? 29 : 28}]
        }
        return [expr {$m in {4 6 9 11} ? 30 : 31}]
    }

    proc _parse_date {datestr} {
        # Parse YYYY-MM-DD naming a real calendar day, optionally followed by
        # T and a time (which is not read); return {year month day} or empty
        if {![regexp {^([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T|$)} $datestr -> ys ms ds]} {
            return {}
        }
        # scan reads leading zeros as decimal (expr would read 08 as octal)
        scan "$ys $ms $ds" "%d %d %d" y m d
        if {$m < 1 || $m > 12 || $d < 1 || $d > [_days_in_month $y $m]} {
            return {}
        }
        return [list $y $m $d]
    }

    proc _julian_day {y m d} {
        set a [expr {(14 - $m) / 12}]
        set y1 [expr {$y + 4800 - $a}]
        set m1 [expr {$m + 12 * $a - 3}]
        return [expr {$d + (153 * $m1 + 2) / 5 + 365 * $y1 + $y1 / 4 - $y1 / 100 + $y1 / 400 - 32045}]
    }

    proc _weekday {y m d} {
        # Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday
        set jdn [_julian_day $y $m $d]
        return [expr {($jdn + 1) % 7}]
    }

    proc _pick {override attr default_val} {
        if {[dict size $override] > 0 && [dict exists $override $attr]} {
            return [dict get $override $attr]
        }
        return $default_val
    }

    # --- Public API ---

    proc new {locale {compactness "normal"}} {
        # Create a formatter dict with resolved settings
        if {$compactness eq "short"} {
            set ovr [dict get $locale short]
        } elseif {$compactness eq "compact"} {
            set ovr [dict get $locale compact]
        } else {
            set ovr [dict create]
        }

        set months [_pick $ovr months [dict get $locale months]]
        set weekdays [_pick $ovr weekdays [dict get $locale weekdays]]
        set day_format [_pick $ovr day_format [dict get $locale day_format]]

        # Day format exceptions handling: if override specifies day_format
        # but not day_format_exceptions, clear the exceptions
        if {[dict size $ovr] > 0 && [dict exists $ovr day_format] && ![dict exists $ovr day_format_exceptions]} {
            set day_format_exceptions [dict create]
        } else {
            set day_format_exceptions [_pick $ovr day_format_exceptions [dict get $locale day_format_exceptions]]
        }

        set date_pattern [_pick $ovr date_pattern [dict get $locale date_pattern]]
        set date_pattern_with_year [_pick $ovr date_pattern_with_year [dict get $locale date_pattern_with_year]]
        set today [dict get $locale today]
        set tomorrow [dict get $locale tomorrow]
        set yesterday [dict get $locale yesterday]

        # Optional months_in_date (genitive forms)
        set months_in_date [_pick $ovr months_in_date [dict get $locale months_in_date]]

        return [dict create \
            locale $locale \
            compactness $compactness \
            months $months \
            weekdays $weekdays \
            day_format $day_format \
            day_format_exceptions $day_format_exceptions \
            date_pattern $date_pattern \
            date_pattern_with_year $date_pattern_with_year \
            today $today \
            tomorrow $tomorrow \
            yesterday $yesterday \
            months_in_date $months_in_date \
        ]
    }

    proc _format_absolute {formatter year month day include_year} {
        set day_str $day
        set day_format_exceptions [dict get $formatter day_format_exceptions]
        if {[dict size $day_format_exceptions] > 0 && [dict exists $day_format_exceptions $day_str]} {
            set fmt [dict get $day_format_exceptions $day_str]
        } else {
            set fmt [dict get $formatter day_format]
        }
        set formatted_day [string map [list "\{n\}" $day_str] $fmt]

        # Pick month name (genitive if available)
        set months_in_date [dict get $formatter months_in_date]
        if {$months_in_date ne ""} {
            set month_name [lindex $months_in_date [expr {$month - 1}]]
        } else {
            set month_name [lindex [dict get $formatter months] [expr {$month - 1}]]
        }

        if {$include_year} {
            set pattern [dict get $formatter date_pattern_with_year]
        } else {
            set pattern [dict get $formatter date_pattern]
        }

        set result [string map [list "\{month\}" $month_name] $pattern]
        set result [string map [list "\{day\}" $formatted_day] $result]
        set result [string map [list "\{d\}" $day] $result]
        set result [string map [list "\{m\}" $month] $result]
        if {$include_year} {
            set result [string map [list "\{year\}" $year] $result]
            set yy [format "%02d" [expr {$year % 100}]]
            set result [string map [list "\{yy\}" $yy] $result]
        }

        return $result
    }

    proc format_date {formatter date} {
        if {$date eq ""} {
            return ""
        }
        set parsed [_parse_date $date]
        if {[llength $parsed] == 0} {
            return ""
        }
        lassign $parsed year month day
        return [_format_absolute $formatter $year $month $day 0]
    }

    proc format_date_with_year {formatter date} {
        if {$date eq ""} {
            return ""
        }
        set parsed [_parse_date $date]
        if {[llength $parsed] == 0} {
            return ""
        }
        lassign $parsed year month day
        return [_format_absolute $formatter $year $month $day 1]
    }

    proc format_relative {formatter date as_of} {
        if {$date eq "" || $as_of eq ""} {
            return ""
        }
        set parsed_date [_parse_date $date]
        set parsed_as_of [_parse_date $as_of]
        if {[llength $parsed_date] == 0 || [llength $parsed_as_of] == 0} {
            return ""
        }
        lassign $parsed_date dy dm dd
        lassign $parsed_as_of ay am ad

        set date_jdn [_julian_day $dy $dm $dd]
        set asof_jdn [_julian_day $ay $am $ad]
        set diff [expr {$date_jdn - $asof_jdn}]

        # Today
        if {$diff == 0} {
            return [dict get $formatter today]
        }

        # Tomorrow
        if {$diff == 1} {
            return [dict get $formatter tomorrow]
        }

        # Yesterday
        if {$diff == -1} {
            return [dict get $formatter yesterday]
        }

        set locale [dict get $formatter locale]
        set compactness [dict get $formatter compactness]
        set is_compact [expr {$compactness eq "compact"}]

        # Day after tomorrow (optional)
        if {$diff == 2 && !$is_compact} {
            set dat [dict get $locale day_after_tomorrow]
            if {$dat ne ""} {
                return $dat
            }
        }

        # Day before yesterday (optional)
        if {$diff == -2 && !$is_compact} {
            set dby [dict get $locale day_before_yesterday]
            if {$dby ne ""} {
                return $dby
            }
        }

        # Compact mode: skip weekday references
        if {$is_compact} {
            set include_year [expr {$dy != $ay}]
            return [_format_absolute $formatter $dy $dm $dd $include_year]
        }

        # This weekday (+2 to +6)
        if {$diff >= 2 && $diff <= 6} {
            set tw [dict get $locale this_weekday]
            if {$tw ne ""} {
                set dow [_weekday $dy $dm $dd]
                set weekday_name [lindex [dict get $formatter weekdays] $dow]
                return [string map [list "\{weekday\}" $weekday_name] $tw]
            }
        }

        # Last weekday (-2 to -6)
        if {$diff >= -6 && $diff <= -2} {
            set lw [dict get $locale last_weekday]
            if {$lw ne ""} {
                set dow [_weekday $dy $dm $dd]
                set weekday_name [lindex [dict get $formatter weekdays] $dow]
                return [string map [list "\{weekday\}" $weekday_name] $lw]
            }
        }

        # Next weekday (+7 to +13)
        if {$diff >= 7 && $diff <= 13} {
            set nw [dict get $locale next_weekday]
            if {$nw ne ""} {
                set dow [_weekday $dy $dm $dd]
                set weekday_name [lindex [dict get $formatter weekdays] $dow]
                return [string map [list "\{weekday\}" $weekday_name] $nw]
            }
        }

        # Calendar fallback
        set include_year [expr {$dy != $ay}]
        return [_format_absolute $formatter $dy $dm $dd $include_year]
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
            set _default_locale [new [sayabledate_get_locale "en"]]
        }
        return $_default_locale
    }

    proc date {date_val} {
        return [format_date [_default_formatter] $date_val]
    }

    proc relative {date_val as_of} {
        return [format_relative [_default_formatter] $date_val $as_of]
    }

    proc get_locale {code} {
        _ensure_registry
        return [sayabledate_get_locale $code]
    }
}
