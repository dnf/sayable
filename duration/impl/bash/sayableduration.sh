#!/usr/bin/env bash
# sayableduration.sh — Human-friendly duration and relative time formatting.
# Zero dependencies. Source this file to use format_duration, format_since, format_until.

# The locale variables (_half, _delimiter...) are set by the locale file a
# function loads at run time, which shellcheck can't follow.
# shellcheck disable=SC2154

_SAYABLEDURATION_REGISTRY_LOADED=0
# Read by callers, not by this file.
# shellcheck disable=SC2034
SAYABLEDURATION_VERSION="0.5.0"
_SAYABLEDURATION_MAX_MONTHS=6000  # 500 years, the same ceiling as sayable-age

# --- Date/time helpers ---

_sayableduration_is_leap_year() {
    local y=$1
    if (( y % 4 == 0 && y % 100 != 0 )) || (( y % 400 == 0 )); then
        return 0
    fi
    return 1
}

_sayableduration_days_in_month() {
    local y=$1 m=$2
    case "${m}" in
        1|3|5|7|8|10|12) echo 31 ;;
        4|6|9|11)        echo 30 ;;
        2)
            if _sayableduration_is_leap_year "${y}"; then
                echo 29
            else
                echo 28
            fi
            ;;
    esac
}

_sayableduration_days_since_epoch() {
    local year=$1 month=$2 day=$3
    local days=0
    local y m
    if [ ${year} -ge 2000 ]; then
        for (( y=2000; y<year; y++ )); do
            if _sayableduration_is_leap_year "${y}"; then
                days=$(( days + 366 ))
            else
                days=$(( days + 365 ))
            fi
        done
    else
        for (( y=year; y<2000; y++ )); do
            if _sayableduration_is_leap_year "${y}"; then
                days=$(( days - 366 ))
            else
                days=$(( days - 365 ))
            fi
        done
    fi
    for (( m=1; m<month; m++ )); do
        days=$(( days + $(_sayableduration_days_in_month "${year}" "${m}") ))
    done
    days=$(( days + day - 1 ))
    echo "${days}"
}

# YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored). The
# digit class is spelled out because a [0-9] range can match other characters
# in some locales.
_SAYABLEDURATION_D='[0123456789]'
_SAYABLEDURATION_TIMESTAMP_PATTERN="^(${_SAYABLEDURATION_D}{4})-(${_SAYABLEDURATION_D}{2})-(${_SAYABLEDURATION_D}{2})T(${_SAYABLEDURATION_D}{1,2}):(${_SAYABLEDURATION_D}{2})(:(${_SAYABLEDURATION_D}{2})(\\.${_SAYABLEDURATION_D}+)?)?(Z|[+-]${_SAYABLEDURATION_D}{2}:${_SAYABLEDURATION_D}{2})?$"
_SAYABLEDURATION_INTEGER_PATTERN="^-?${_SAYABLEDURATION_D}+$"

# Parse ISO datetime to epoch-ish seconds. Sets _pts_result. Returns 1 on failure.
_sayableduration_parse_iso() {
    local iso_str="$1"
    if ! [[ "${iso_str}" =~ ${_SAYABLEDURATION_TIMESTAMP_PATTERN} ]]; then return 1; fi

    # 10# reads leading zeros as decimal, not octal
    local year=$(( 10#${BASH_REMATCH[1]} )) month=$(( 10#${BASH_REMATCH[2]} )) day=$(( 10#${BASH_REMATCH[3]} ))
    local hour=$(( 10#${BASH_REMATCH[4]} )) minute=$(( 10#${BASH_REMATCH[5]} ))
    local second=$(( 10#${BASH_REMATCH[7]:-0} ))
    if [ ${month} -lt 1 ] || [ ${month} -gt 12 ] || [ ${day} -lt 1 ]; then return 1; fi
    if [ ${day} -gt "$(_sayableduration_days_in_month "${year}" "${month}")" ]; then return 1; fi
    if [ ${hour} -gt 23 ] || [ ${minute} -gt 59 ] || [ ${second} -gt 59 ]; then return 1; fi

    local days
    days=$(_sayableduration_days_since_epoch "${year}" "${month}" "${day}")
    _pts_result=$(( days * 86400 + hour * 3600 + minute * 60 + second ))
    return 0
}

# Parse a whole number of seconds into _ps_seconds. Returns 1 when it has no
# value: negative, or more digits than any count under the 500-year ceiling
# (bash arithmetic would overflow on them).
_sayableduration_parse_seconds() {
    local input="$1"
    local magnitude="${input#-}"
    magnitude="${magnitude#"${magnitude%%[!0]*}"}"
    if [ -z "${magnitude}" ]; then
        _ps_seconds=0
        return 0
    fi
    if [ "${input:0:1}" = "-" ] || [ ${#magnitude} -gt 15 ]; then return 1; fi
    _ps_seconds=$(( 10#${magnitude} ))
    return 0
}

# --- Locale loading ---

_sayableduration_ensure_registry() {
    if [ ${_SAYABLEDURATION_REGISTRY_LOADED} -eq 0 ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck disable=SC1091
        source "${script_dir}/locales/registry.sh"
        _SAYABLEDURATION_REGISTRY_LOADED=1
    fi
}

_sayableduration_clear_locale() {
    for _u in second minute hour day week month year; do
        for _c in "" _zero _one _two _few _many _other; do
            unset "_unit_${_u}${_c}" 2>/dev/null || true
        done
        for _mode in _short _compact; do
            unset "${_mode}_unit_${_u}" 2>/dev/null || true
            for _c in _zero _one _two _few _many _other; do
                unset "${_mode}_unit_${_u}${_c}" 2>/dev/null || true
            done
        done
    done
    unset _half _delimiter _just_now _ago _in_future _plural_func 2>/dev/null || true
    for _mode in _short _compact; do
        unset "${_mode}_half" "${_mode}_delimiter" "${_mode}_ago" "${_mode}_in_future" 2>/dev/null || true
    done
}

sayableduration_get_locale() {
    local code="$1"
    _sayableduration_ensure_registry
    _sayableduration_clear_locale
    _sayableduration_load_locale "${code}"
}

# --- Unit resolution ---

_sayableduration_resolve_unit() {
    local count=$1 unit_name=$2 half="$3"

    local base_n="${count}"
    local n="${base_n}"
    if [ -n "${half}" ]; then
        case "${half}" in
            *'{n}'*)
                n="${half//\{n\}/${base_n}}"
                ;;
        esac
    fi

    local template=""
    local prefix=""

    # Select the right variable prefix based on compactness
    if [ "${_sa_compactness}" = "short" ]; then
        prefix="_short_unit_${unit_name}"
    elif [ "${_sa_compactness}" = "compact" ]; then
        prefix="_compact_unit_${unit_name}"
    fi

    # Try to get the override template
    if [ -n "${prefix}" ]; then
        local simple_var="${prefix}"
        if [ -n "${!simple_var+x}" ]; then
            template="${!simple_var}"
        else
            local category
            if [ -n "${half}" ]; then
                category="other"
            else
                category=$(${_plural_func} "${count}")
            fi
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
            if [ -n "${half}" ]; then
                category="other"
            else
                category=$(${_plural_func} "${count}")
            fi
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

# --- Compactness resolution ---

_sayableduration_apply_compactness() {
    local compactness="$1"

    _sa_half="${_half}"
    _sa_delimiter="${_delimiter}"
    _sa_just_now="${_just_now}"
    _sa_ago="${_ago}"
    _sa_in_future="${_in_future}"
    _sa_compactness="${compactness}"

    if [ "${compactness}" = "short" ]; then
        if [ -n "${_short_half+x}" ]; then _sa_half="${_short_half}"; fi
        if [ -n "${_short_delimiter+x}" ]; then _sa_delimiter="${_short_delimiter}"; fi
        if [ -n "${_short_ago+x}" ]; then _sa_ago="${_short_ago}"; fi
        if [ -n "${_short_in_future+x}" ]; then _sa_in_future="${_short_in_future}"; fi
    elif [ "${compactness}" = "compact" ]; then
        if [ -n "${_compact_half+x}" ]; then _sa_half="${_compact_half}"; fi
        if [ -n "${_compact_delimiter+x}" ]; then _sa_delimiter="${_compact_delimiter}"; fi
        if [ -n "${_compact_ago+x}" ]; then _sa_ago="${_compact_ago}"; fi
        if [ -n "${_compact_in_future+x}" ]; then _sa_in_future="${_compact_in_future}"; fi
    fi
}

# --- Duration formatting ---

_sayableduration_format_seconds() {
    local total=$1

    # 0 seconds
    if [ ${total} -eq 0 ]; then
        echo "${_sa_just_now}"
        return
    fi

    # 1-59 seconds
    if [ ${total} -lt 60 ]; then
        _sayableduration_resolve_unit ${total} "second" ""
        return
    fi

    local total_minutes=$(( total / 60 ))
    local remainder_seconds=$(( total % 60 ))

    # 1-4 minutes: minutes + seconds
    if [ ${total_minutes} -lt 5 ]; then
        local result
        result=$(_sayableduration_resolve_unit ${total_minutes} "minute" "")
        if [ ${remainder_seconds} -gt 0 ]; then
            local sec_part
            sec_part=$(_sayableduration_resolve_unit ${remainder_seconds} "second" "")
            result="${result}${_sa_delimiter}${sec_part}"
        fi
        echo "${result}"
        return
    fi

    # 5-59 minutes
    if [ ${total_minutes} -lt 60 ]; then
        _sayableduration_resolve_unit ${total_minutes} "minute" ""
        return
    fi

    local total_hours=$(( total / 3600 ))
    local remainder_minutes=$(( (total % 3600) / 60 ))

    # 1-5 hours: hours + minutes (with half marker)
    if [ ${total_hours} -le 5 ]; then
        if [ ${remainder_minutes} -eq 30 ]; then
            _sayableduration_resolve_unit ${total_hours} "hour" "${_sa_half}"
            return
        fi
        local result
        result=$(_sayableduration_resolve_unit ${total_hours} "hour" "")
        if [ ${remainder_minutes} -gt 0 ]; then
            local min_part
            min_part=$(_sayableduration_resolve_unit ${remainder_minutes} "minute" "")
            result="${result}${_sa_delimiter}${min_part}"
        fi
        echo "${result}"
        return
    fi

    # 6-23 hours
    if [ ${total_hours} -lt 24 ]; then
        _sayableduration_resolve_unit ${total_hours} "hour" ""
        return
    fi

    local total_days=$(( total / 86400 ))
    local remainder_hours=$(( (total % 86400) / 3600 ))

    # 1-2 days: days + hours (with half marker)
    if [ ${total_days} -le 2 ]; then
        if [ ${remainder_hours} -eq 12 ]; then
            _sayableduration_resolve_unit ${total_days} "day" "${_sa_half}"
            return
        fi
        local result
        result=$(_sayableduration_resolve_unit ${total_days} "day" "")
        if [ ${remainder_hours} -gt 0 ]; then
            local hour_part
            hour_part=$(_sayableduration_resolve_unit ${remainder_hours} "hour" "")
            result="${result}${_sa_delimiter}${hour_part}"
        fi
        echo "${result}"
        return
    fi

    # 3-6 days
    if [ ${total_days} -lt 7 ]; then
        _sayableduration_resolve_unit ${total_days} "day" ""
        return
    fi

    local total_weeks=$(( total_days / 7 ))
    local remainder_days=$(( total_days % 7 ))

    # 1-4 weeks: weeks + days (up to 29 days)
    if [ ${total_days} -lt 30 ]; then
        local result
        result=$(_sayableduration_resolve_unit ${total_weeks} "week" "")
        if [ ${remainder_days} -gt 0 ]; then
            local day_part
            day_part=$(_sayableduration_resolve_unit ${remainder_days} "day" "")
            result="${result}${_sa_delimiter}${day_part}"
        fi
        echo "${result}"
        return
    fi

    # Approximate months (30.44 days average)
    # Use integer rounding: (total_days * 100 + 1522) / 3044
    local total_months=$(( (total_days * 100 + 1522) / 3044 ))
    if [ ${total_months} -gt ${_SAYABLEDURATION_MAX_MONTHS} ]; then
        echo ""
        return
    fi

    # 1-11 months
    if [ ${total_months} -lt 12 ]; then
        if [ ${total_months} -eq 0 ]; then total_months=1; fi
        _sayableduration_resolve_unit ${total_months} "month" ""
        return
    fi

    # 12+ months: years + months
    local total_years=$(( total_months / 12 ))
    local remainder_months=$(( total_months % 12 ))
    local result
    result=$(_sayableduration_resolve_unit ${total_years} "year" "")
    if [ ${remainder_months} -gt 0 ]; then
        local month_part
        month_part=$(_sayableduration_resolve_unit ${remainder_months} "month" "")
        result="${result}${_sa_delimiter}${month_part}"
    fi
    echo "${result}"
}

# --- Public API ---

# sayableduration_format_duration locale_code seconds_or_start [end] [compactness]
sayableduration_format_duration() {
    local locale_code="$1" input="$2" end="${3:-}" compactness="${4:-normal}"

    if [ -z "${input}" ] || [ "${input}" = "null" ]; then
        echo ""
        return
    fi

    if ! sayableduration_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayableduration_apply_compactness "${compactness}"

    local total_seconds

    # Check if input is a number (seconds)
    if [[ "${input}" =~ ${_SAYABLEDURATION_INTEGER_PATTERN} ]]; then
        if ! _sayableduration_parse_seconds "${input}"; then
            echo ""
            return
        fi
        total_seconds=${_ps_seconds}
    else
        # ISO datetime pair
        if [ -z "${end}" ]; then
            echo ""
            return
        fi
        local s_val e_val
        if ! _sayableduration_parse_iso "${input}"; then
            echo ""
            return
        fi
        s_val=${_pts_result}
        if ! _sayableduration_parse_iso "${end}"; then
            echo ""
            return
        fi
        e_val=${_pts_result}
        total_seconds=$(( e_val - s_val ))
        if [ ${total_seconds} -lt 0 ]; then
            total_seconds=$(( -total_seconds ))
        fi
    fi

    _sayableduration_format_seconds ${total_seconds}
}

# sayableduration_format_since locale_code start as_of [compactness]
sayableduration_format_since() {
    local locale_code="$1" start="$2" as_of="$3" compactness="${4:-normal}"

    if [ -z "${start}" ] || [ -z "${as_of}" ]; then
        echo ""
        return
    fi

    if ! sayableduration_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayableduration_apply_compactness "${compactness}"

    local s_val a_val
    if ! _sayableduration_parse_iso "${start}"; then
        echo ""
        return
    fi
    s_val=${_pts_result}
    if ! _sayableduration_parse_iso "${as_of}"; then
        echo ""
        return
    fi
    a_val=${_pts_result}

    local diff=$(( a_val - s_val ))
    if [ ${diff} -lt 0 ]; then
        echo ""
        return
    fi
    if [ ${diff} -eq 0 ]; then
        echo "${_sa_just_now}"
        return
    fi

    local dur
    dur=$(_sayableduration_format_seconds ${diff})
    if [ -z "${dur}" ]; then
        echo ""
        return
    fi
    echo "${_sa_ago//\{0\}/${dur}}"
}

# sayableduration_format_until locale_code target as_of [compactness]
sayableduration_format_until() {
    local locale_code="$1" target="$2" as_of="$3" compactness="${4:-normal}"

    if [ -z "${target}" ] || [ -z "${as_of}" ]; then
        echo ""
        return
    fi

    if ! sayableduration_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayableduration_apply_compactness "${compactness}"

    local t_val a_val
    if ! _sayableduration_parse_iso "${target}"; then
        echo ""
        return
    fi
    t_val=${_pts_result}
    if ! _sayableduration_parse_iso "${as_of}"; then
        echo ""
        return
    fi
    a_val=${_pts_result}

    local diff=$(( t_val - a_val ))
    if [ ${diff} -lt 0 ]; then
        echo ""
        return
    fi
    if [ ${diff} -eq 0 ]; then
        echo "${_sa_just_now}"
        return
    fi

    local dur
    dur=$(_sayableduration_format_seconds ${diff})
    if [ -z "${dur}" ]; then
        echo ""
        return
    fi
    echo "${_sa_in_future//\{0\}/${dur}}"
}
