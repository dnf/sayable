# sayableage.tcl — Human-friendly age formatting for young children.

package provide sayableage 0.5.0

namespace eval ::sayableage {
    variable VERSION "0.5.0"
    variable MAX_AGE_MONTHS 6000
    variable _default_locale ""
    variable _registry_loaded 0

    # --- Date helpers ---

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

    proc _julian_day {y m d} {
        # Compute Julian Day Number for a date
        set a [expr {(14 - $m) / 12}]
        set y1 [expr {$y + 4800 - $a}]
        set m1 [expr {$m + 12 * $a - 3}]
        return [expr {$d + (153 * $m1 + 2) / 5 + 365 * $y1 + $y1 / 4 - $y1 / 100 + $y1 / 400 - 32045}]
    }

    proc _parse_date {datestr} {
        # Parse YYYY-MM-DD string, return list {year month day} or empty
        if {$datestr eq ""} {
            return {}
        }
        set parts [split $datestr "-"]
        if {[llength $parts] != 3} {
            return {}
        }
        set y [scan [lindex $parts 0] %d]
        set m [scan [lindex $parts 1] %d]
        set d [scan [lindex $parts 2] %d]
        if {$y eq "" || $m eq "" || $d eq ""} {
            return {}
        }
        return [list $y $m $d]
    }

    proc _parse_age {date_of_birth as_of} {
        # Returns list {months diff_days} or empty on error
        variable MAX_AGE_MONTHS

        if {$date_of_birth eq ""} {
            return {}
        }

        set dob [_parse_date $date_of_birth]
        if {[llength $dob] != 3} {
            return {}
        }
        lassign $dob dob_y dob_m dob_d

        if {$as_of eq ""} {
            set now [clock seconds]
            set ref_y [clock format $now -format %Y]
            set ref_m [clock format $now -format %m]
            set ref_d [clock format $now -format %d]
            # Remove leading zeros
            scan $ref_y %d ref_y
            scan $ref_m %d ref_m
            scan $ref_d %d ref_d
        } else {
            set ref [_parse_date $as_of]
            if {[llength $ref] != 3} {
                return {}
            }
            lassign $ref ref_y ref_m ref_d
        }

        set diff_days [expr {[_julian_day $ref_y $ref_m $ref_d] - [_julian_day $dob_y $dob_m $dob_d]}]
        if {$diff_days < 0} {
            return {}
        }

        set last_day [_days_in_month $ref_y $ref_m]
        set clamped_birthday [expr {min($dob_d, $last_day)}]
        set months [expr {($ref_y - $dob_y) * 12 + ($ref_m - $dob_m)}]
        if {$ref_d < $clamped_birthday} {
            incr months -1
        }
        if {$months > $MAX_AGE_MONTHS} {
            return {}
        }

        return [list $months $diff_days]
    }

    proc _stage_key {months} {
        if {$months < 2} { return "newborn" }
        if {$months < 12} { return "infant" }
        if {$months < 36} { return "toddler" }
        if {$months < 156} { return "child" }
        if {$months < 216} { return "teenager" }
        return "adult"
    }

    proc _is_plural_dict {unit_forms} {
        # Detect if unit_forms is a plural dict (has "other" key) vs a plain template
        if {[catch {dict exists $unit_forms other} has_other]} {
            return 0
        }
        return $has_other
    }

    proc _resolve_unit {count unit_forms locale {half ""}} {
        # Resolve a unit count to its display string
        set base_n $count
        if {$half ne "" && [string first "\{n\}" $half] >= 0} {
            set n [string map [list "\{n\}" $base_n] $half]
        } else {
            set n $base_n
        }

        if {[_is_plural_dict $unit_forms]} {
            # Dict of plural forms
            set plural_proc [dict get $locale plural]
            set category [$plural_proc $count]
            if {[dict exists $unit_forms $category]} {
                set template [dict get $unit_forms $category]
            } else {
                set template [dict get $unit_forms other]
            }
        } else {
            # Simple string template
            set template $unit_forms
        }

        set result [string map [list "\{n\}" $n] $template]
        if {$half ne "" && [string first "\{0\}" $half] >= 0} {
            set result [string map [list "\{0\}" $result] $half]
        }
        return $result
    }

    proc _is_dict {value} {
        # Check if a value looks like a dict (even number of elements > 0)
        if {[catch {dict size $value} size]} {
            return 0
        }
        return [expr {$size > 0}]
    }

    proc _resolve_stage {label {gender ""}} {
        if {[_is_dict $label] && [dict exists $label m]} {
            if {$gender eq "f"} {
                return [dict get $label f]
            }
            return [dict get $label m]
        }
        return $label
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

        # Resolve units
        set units [dict create]
        foreach unit_name {day week month year} {
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
        set just_born [_pick $ovr just_born [dict get $locale just_born]]

        return [dict create \
            locale $locale \
            units $units \
            half $half \
            delimiter $delimiter \
            just_born $just_born \
        ]
    }

    proc format_age {formatter date_of_birth {as_of ""}} {
        set parsed [_parse_age $date_of_birth $as_of]
        if {[llength $parsed] == 0} {
            return ""
        }
        lassign $parsed months diff_days
        set locale [dict get $formatter locale]
        set units [dict get $formatter units]
        set half [dict get $formatter half]
        set delimiter [dict get $formatter delimiter]
        set just_born [dict get $formatter just_born]

        # Tier 1: 0-6 days
        if {$diff_days == 0} {
            return $just_born
        }
        if {$diff_days < 7} {
            return [_resolve_unit $diff_days [dict get $units day] $locale]
        }

        # Tier 2: weeks + days until 3 calendar months
        if {$months < 3} {
            set weeks [expr {$diff_days / 7}]
            set days [expr {$diff_days % 7}]
            set result [_resolve_unit $weeks [dict get $units week] $locale]
            if {$days > 0} {
                append result $delimiter [_resolve_unit $days [dict get $units day] $locale]
            }
            return $result
        }

        # Tier 3: 3-23 months
        if {$months < 24} {
            return [_resolve_unit $months [dict get $units month] $locale]
        }

        # Tier 4: 24-35 months -> years + months
        if {$months < 36} {
            set years [expr {$months / 12}]
            set rem [expr {$months % 12}]
            if {$rem == 0} {
                return [_resolve_unit $years [dict get $units year] $locale]
            }
            set result [_resolve_unit $years [dict get $units year] $locale]
            append result $delimiter [_resolve_unit $rem [dict get $units month] $locale]
            return $result
        }

        # Tier 5: 3-6 years -> years with half marker
        if {$months < 84} {
            set years [expr {$months / 12}]
            set rem [expr {$months % 12}]
            if {$rem >= 6} {
                return [_resolve_unit $years [dict get $units year] $locale $half]
            }
            return [_resolve_unit $years [dict get $units year] $locale]
        }

        # Tier 6: 7+ years
        return [_resolve_unit [expr {$months / 12}] [dict get $units year] $locale]
    }

    proc format_stage {formatter date_of_birth {as_of ""} {gender ""}} {
        set parsed [_parse_age $date_of_birth $as_of]
        if {[llength $parsed] == 0} {
            return ""
        }
        lassign $parsed months diff_days
        set locale [dict get $formatter locale]
        set stage_key [_stage_key $months]
        set stage_label [dict get [dict get $locale stages] $stage_key]
        return [_resolve_stage $stage_label $gender]
    }

    # --- Convenience functions with default English locale ---

    proc _ensure_registry {} {
        variable _registry_loaded
        if {!$_registry_loaded} {
            set script_dir [file dirname [info script]]
            source [file join $script_dir locales registry.tcl]
            set _registry_loaded 1
        }
    }

    proc _default_formatter {} {
        variable _default_locale
        if {$_default_locale eq ""} {
            _ensure_registry
            set _default_locale [new [sayableage_get_locale "en"]]
        }
        return $_default_locale
    }

    proc age {date_of_birth {as_of ""}} {
        return [format_age [_default_formatter] $date_of_birth $as_of]
    }

    proc stage {date_of_birth {as_of ""} {gender ""}} {
        return [format_stage [_default_formatter] $date_of_birth $as_of $gender]
    }

    proc get_locale {code} {
        _ensure_registry
        return [sayableage_get_locale $code]
    }
}
