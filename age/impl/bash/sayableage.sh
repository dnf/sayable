#!/usr/bin/env bash
# sayableage.sh — Human-friendly age formatting for young children.
# Zero dependencies. Source this file to use format_age and format_stage.

# The locale variables (_half, _delimiter...) are set by the locale file a
# function loads at run time, which shellcheck can't follow.
# shellcheck disable=SC2154

_SAYABLEAGE_MAX_AGE_MONTHS=6000
# Read by callers, not by this file.
# shellcheck disable=SC2034
SAYABLEAGE_VERSION="0.5.0"
_SAYABLEAGE_REGISTRY_LOADED=0

# --- Date helpers ---

_sayableage_is_leap_year() {
    local y=$1
    if (( y % 4 == 0 && y % 100 != 0 )) || (( y % 400 == 0 )); then
        return 0
    fi
    return 1
}

_sayableage_days_in_month() {
    local y=$1 m=$2
    case "${m}" in
        1|3|5|7|8|10|12) echo 31 ;;
        4|6|9|11)        echo 30 ;;
        2)
            if _sayableage_is_leap_year "${y}"; then
                echo 29
            else
                echo 28
            fi
            ;;
    esac
}

_sayableage_julian_day() {
    local y=$1 m=$2 d=$3
    local a=$(( (14 - m) / 12 ))
    local y1=$(( y + 4800 - a ))
    local m1=$(( m + 12 * a - 3 ))
    echo $(( d + (153 * m1 + 2) / 5 + 365 * y1 + y1 / 4 - y1 / 100 + y1 / 400 - 32045 ))
}

# Exactly YYYY-MM-DD. The digit class is spelled out because a [0-9] range
# can match other characters in some locales.
_SAYABLEAGE_DATE_PATTERN='^([0123456789]{4})-([0123456789]{2})-([0123456789]{2})$'

# Parse exactly YYYY-MM-DD naming a real calendar day, sets _pd_y _pd_m _pd_d.
# Returns 1 on failure.
_sayableage_parse_date() {
    local datestr="$1"
    if ! [[ "${datestr}" =~ ${_SAYABLEAGE_DATE_PATTERN} ]]; then return 1; fi
    # 10# reads leading zeros as decimal, not octal
    _pd_y=$(( 10#${BASH_REMATCH[1]} ))
    _pd_m=$(( 10#${BASH_REMATCH[2]} ))
    _pd_d=$(( 10#${BASH_REMATCH[3]} ))
    if [ ${_pd_m} -lt 1 ] || [ ${_pd_m} -gt 12 ] || [ ${_pd_d} -lt 1 ]; then return 1; fi
    if [ ${_pd_d} -gt "$(_sayableage_days_in_month "${_pd_y}" "${_pd_m}")" ]; then return 1; fi
    return 0
}

# Compute age. Sets _pa_months and _pa_diff_days. Returns 1 on failure.
_sayableage_parse_age() {
    local dob="$1" as_of="$2"

    if [ -z "${dob}" ]; then return 1; fi

    if ! _sayableage_parse_date "${dob}"; then return 1; fi
    local dob_y=${_pd_y} dob_m=${_pd_m} dob_d=${_pd_d}

    if [ -n "${as_of}" ]; then
        if ! _sayableage_parse_date "${as_of}"; then return 1; fi
    else
        local today
        today="$(date +%Y-%m-%d)"
        if ! _sayableage_parse_date "${today}"; then return 1; fi
    fi
    local ref_y=${_pd_y} ref_m=${_pd_m} ref_d=${_pd_d}

    local jd_ref jd_dob
    jd_ref=$(_sayableage_julian_day "${ref_y}" "${ref_m}" "${ref_d}")
    jd_dob=$(_sayableage_julian_day "${dob_y}" "${dob_m}" "${dob_d}")
    _pa_diff_days=$(( jd_ref - jd_dob ))
    if [ ${_pa_diff_days} -lt 0 ]; then return 1; fi

    local last_day
    last_day=$(_sayableage_days_in_month "${ref_y}" "${ref_m}")
    local clamped_birthday=${dob_d}
    if [ ${dob_d} -gt ${last_day} ]; then
        clamped_birthday=${last_day}
    fi
    _pa_months=$(( (ref_y - dob_y) * 12 + (ref_m - dob_m) ))
    if [ ${ref_d} -lt ${clamped_birthday} ]; then
        _pa_months=$(( _pa_months - 1 ))
    fi
    if [ ${_pa_months} -gt ${_SAYABLEAGE_MAX_AGE_MONTHS} ]; then return 1; fi

    return 0
}

_sayableage_stage_key() {
    local months=$1
    if [ ${months} -lt 2 ]; then echo "newborn"; return; fi
    if [ ${months} -lt 12 ]; then echo "infant"; return; fi
    if [ ${months} -lt 36 ]; then echo "toddler"; return; fi
    if [ ${months} -lt 156 ]; then echo "child"; return; fi
    if [ ${months} -lt 216 ]; then echo "teenager"; return; fi
    echo "adult"
}

# String replacement: replace all occurrences of $2 in $1 with $3
_sayableage_replace() {
    local str="$1" pattern="$2" replacement="$3"
    echo "${str//${pattern}/${replacement}}"
}

# Resolve a unit count to its display string.
# Uses variables from the current locale context.
# Args: count unit_name compactness half
_sayableage_resolve_unit() {
    local count=$1 unit_name=$2 compactness=$3 half="$4"

    local base_n="${count}"
    local n="${base_n}"
    if [ -n "${half}" ]; then
        case "${half}" in
            *'{n}'*)
                n="${half//\{n\}/${base_n}}"
                ;;
        esac
    fi

    # Determine the template: check compactness override first, then base
    local template=""
    local prefix=""

    # Select the right variable prefix based on compactness
    if [ "${compactness}" = "short" ]; then
        prefix="_short_unit_${unit_name}"
    elif [ "${compactness}" = "compact" ]; then
        prefix="_compact_unit_${unit_name}"
    fi

    # Try to get the override template
    if [ -n "${prefix}" ]; then
        # Check for simple (non-plural) override
        local simple_var="${prefix}"
        if [ -n "${!simple_var+x}" ]; then
            template="${!simple_var}"
        else
            # Check for plural override
            local category
            category=$(${_plural_func} "${count}")
            local cat_var="${prefix}_${category}"
            if [ -n "${!cat_var+x}" ]; then
                template="${!cat_var}"
            else
                local other_var="${prefix}_other"
                if [ -n "${!other_var+x}" ]; then
                    template="${!other_var}"
                fi
            fi
        fi
    fi

    # Fall back to base unit if no override found
    if [ -z "${template}" ]; then
        local base_prefix="_unit_${unit_name}"
        local base_simple="${base_prefix}"
        if [ -n "${!base_simple+x}" ]; then
            template="${!base_simple}"
        else
            local category
            category=$(${_plural_func} "${count}")
            local base_cat="${base_prefix}_${category}"
            if [ -n "${!base_cat+x}" ]; then
                template="${!base_cat}"
            else
                local base_other="${base_prefix}_other"
                template="${!base_other}"
            fi
        fi
    fi

    local result="${template//\{n\}/${n}}"

    if [ -n "${half}" ]; then
        case "${half}" in
            *'{0}'*)
                result="${half//\{0\}/${result}}"
                ;;
        esac
    fi

    echo "${result}"
}

_sayableage_resolve_stage() {
    local stage_key="$1" gender="$2"

    # Check for gendered variant
    local m_var="_stage_${stage_key}_m"
    if [ -n "${!m_var+x}" ]; then
        if [ "${gender}" = "f" ]; then
            local f_var="_stage_${stage_key}_f"
            echo "${!f_var}"
        else
            echo "${!m_var}"
        fi
    else
        local plain_var="_stage_${stage_key}"
        echo "${!plain_var}"
    fi
}

# --- Locale loading ---

_sayableage_ensure_registry() {
    if [ ${_SAYABLEAGE_REGISTRY_LOADED} -eq 0 ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck disable=SC1091
        source "${script_dir}/locales/registry.sh"
        _SAYABLEAGE_REGISTRY_LOADED=1
    fi
}

# Clear all locale variables before loading a new locale
_sayableage_clear_locale() {
    # Clear base units
    for _u in day week month year; do
        for _c in "" _zero _one _two _few _many _other; do
            unset "_unit_${_u}${_c}" 2>/dev/null || true
        done
        # Clear short/compact overrides
        for _mode in _short _compact; do
            unset "${_mode}_unit_${_u}" 2>/dev/null || true
            for _c in _zero _one _two _few _many _other; do
                unset "${_mode}_unit_${_u}${_c}" 2>/dev/null || true
            done
        done
    done
    unset _half _delimiter _just_born _plural_func 2>/dev/null || true
    for _s in newborn infant toddler child teenager adult; do
        unset "_stage_${_s}" "_stage_${_s}_m" "_stage_${_s}_f" 2>/dev/null || true
    done
    for _mode in _short _compact; do
        unset "${_mode}_half" "${_mode}_delimiter" "${_mode}_just_born" 2>/dev/null || true
    done
}

# Load a locale by code. Returns 1 if not found.
sayableage_get_locale() {
    local code="$1"
    _sayableage_ensure_registry
    _sayableage_clear_locale
    _sayableage_load_locale "${code}"
}

# --- Public API ---

# Set up compactness-resolved variables.
# After calling this, use _sa_* variables for formatting.
# Must be called after loading a locale.
_sayableage_apply_compactness() {
    local compactness="$1"

    # Copy base values
    _sa_half="${_half}"
    _sa_delimiter="${_delimiter}"
    _sa_just_born="${_just_born}"
    _sa_compactness="${compactness}"

    if [ "${compactness}" = "short" ]; then
        if [ -n "${_short_half+x}" ]; then _sa_half="${_short_half}"; fi
        if [ -n "${_short_delimiter+x}" ]; then _sa_delimiter="${_short_delimiter}"; fi
        if [ -n "${_short_just_born+x}" ]; then _sa_just_born="${_short_just_born}"; fi
    elif [ "${compactness}" = "compact" ]; then
        if [ -n "${_compact_half+x}" ]; then _sa_half="${_compact_half}"; fi
        if [ -n "${_compact_delimiter+x}" ]; then _sa_delimiter="${_compact_delimiter}"; fi
        if [ -n "${_compact_just_born+x}" ]; then _sa_just_born="${_compact_just_born}"; fi
    fi
}

# format_age locale_code date_of_birth [as_of] [compactness]
# Outputs the formatted age string, or empty string on error.
sayableage_format_age() {
    local locale_code="$1" dob="$2" as_of="${3:-}" compactness="${4:-normal}"

    if ! sayableage_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayableage_apply_compactness "${compactness}"

    if ! _sayableage_parse_age "${dob}" "${as_of}"; then
        echo ""
        return
    fi

    local months=${_pa_months} diff_days=${_pa_diff_days}

    # Tier 1: 0-6 days
    if [ ${diff_days} -eq 0 ]; then
        echo "${_sa_just_born}"
        return
    fi
    if [ ${diff_days} -lt 7 ]; then
        _sayableage_resolve_unit ${diff_days} "day" "${_sa_compactness}" ""
        return
    fi

    # Tier 2: weeks + days until 3 calendar months
    if [ ${months} -lt 3 ]; then
        local weeks=$(( diff_days / 7 ))
        local days=$(( diff_days % 7 ))
        local result
        result=$(_sayableage_resolve_unit ${weeks} "week" "${_sa_compactness}" "")
        if [ ${days} -gt 0 ]; then
            local day_part
            day_part=$(_sayableage_resolve_unit ${days} "day" "${_sa_compactness}" "")
            result="${result}${_sa_delimiter}${day_part}"
        fi
        echo "${result}"
        return
    fi

    # Tier 3: 3-23 months
    if [ ${months} -lt 24 ]; then
        _sayableage_resolve_unit ${months} "month" "${_sa_compactness}" ""
        return
    fi

    # Tier 4: 24-35 months → years + months
    if [ ${months} -lt 36 ]; then
        local years=$(( months / 12 ))
        local rem=$(( months % 12 ))
        if [ ${rem} -eq 0 ]; then
            _sayableage_resolve_unit ${years} "year" "${_sa_compactness}" ""
            return
        fi
        local result
        result=$(_sayableage_resolve_unit ${years} "year" "${_sa_compactness}" "")
        local month_part
        month_part=$(_sayableage_resolve_unit ${rem} "month" "${_sa_compactness}" "")
        echo "${result}${_sa_delimiter}${month_part}"
        return
    fi

    # Tier 5: 3-6 years → years with half marker
    if [ ${months} -lt 84 ]; then
        local years=$(( months / 12 ))
        local rem=$(( months % 12 ))
        if [ ${rem} -ge 6 ]; then
            _sayableage_resolve_unit ${years} "year" "${_sa_compactness}" "${_sa_half}"
            return
        fi
        _sayableage_resolve_unit ${years} "year" "${_sa_compactness}" ""
        return
    fi

    # Tier 6: 7+ years
    _sayableage_resolve_unit $(( months / 12 )) "year" "${_sa_compactness}" ""
}

# format_stage locale_code date_of_birth [as_of] [gender]
# Outputs the stage label, or empty string on error.
sayableage_format_stage() {
    local locale_code="$1" dob="$2" as_of="${3:-}" gender="${4:-}"

    if ! sayableage_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    if ! _sayableage_parse_age "${dob}" "${as_of}"; then
        echo ""
        return
    fi

    local stage_key
    stage_key=$(_sayableage_stage_key ${_pa_months})
    _sayableage_resolve_stage "${stage_key}" "${gender}"
}
