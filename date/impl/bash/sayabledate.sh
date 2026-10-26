#!/usr/bin/env bash
# sayabledate.sh — Human-friendly date formatting.
# Zero dependencies. Source this file to use format_date and format_relative.

# The locale variables (_half, _delimiter...) are set by the locale file a
# function loads at run time, which shellcheck can't follow.
# shellcheck disable=SC2154

_SAYABLEDATE_REGISTRY_LOADED=0
# Read by callers, not by this file.
# shellcheck disable=SC2034
SAYABLEDATE_VERSION="0.5.0"

# --- Date helpers ---

_sayabledate_to_jdn() {
    local y=$1 m=$2 d=$3
    local a=$(( (14 - m) / 12 ))
    local y1=$(( y + 4800 - a ))
    local m1=$(( m + 12 * a - 3 ))
    echo $(( d + (153 * m1 + 2) / 5 + 365 * y1 + y1 / 4 - y1 / 100 + y1 / 400 - 32045 ))
}

_sayabledate_weekday() {
    local y=$1 m=$2 d=$3
    local jdn
    jdn=$(_sayabledate_to_jdn "${y}" "${m}" "${d}")
    echo $(( (jdn + 1) % 7 ))
}

_sayabledate_days_in_month() {
    local y=$1 m=$2
    case "${m}" in
        4|6|9|11) echo 30 ;;
        2)
            if (( (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 )); then
                echo 29
            else
                echo 28
            fi
            ;;
        *) echo 31 ;;
    esac
}

# YYYY-MM-DD, optionally followed by T and a time (which is not read). The
# digit class is spelled out because a [0-9] range can match other characters
# in some locales.
_SAYABLEDATE_DATE_PATTERN='^([0123456789]{4})-([0123456789]{2})-([0123456789]{2})(T.*)?$'

# Parse a date naming a real calendar day, sets _pd_y _pd_m _pd_d.
# Returns 1 on failure.
_sayabledate_parse_date() {
    local datestr="$1"
    if ! [[ "${datestr}" =~ ${_SAYABLEDATE_DATE_PATTERN} ]]; then return 1; fi
    # 10# reads leading zeros as decimal, not octal
    _pd_y=$(( 10#${BASH_REMATCH[1]} ))
    _pd_m=$(( 10#${BASH_REMATCH[2]} ))
    _pd_d=$(( 10#${BASH_REMATCH[3]} ))
    if [ ${_pd_m} -lt 1 ] || [ ${_pd_m} -gt 12 ] || [ ${_pd_d} -lt 1 ]; then return 1; fi
    if [ ${_pd_d} -gt "$(_sayabledate_days_in_month "${_pd_y}" "${_pd_m}")" ]; then return 1; fi
    return 0
}

# --- Locale loading ---

_sayabledate_ensure_registry() {
    if [ ${_SAYABLEDATE_REGISTRY_LOADED} -eq 0 ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck disable=SC1091
        source "${script_dir}/locales/registry.sh"
        _SAYABLEDATE_REGISTRY_LOADED=1
    fi
}

# Clear all locale variables before loading a new locale
_sayabledate_clear_locale() {
    unset _months _weekdays _months_in_date 2>/dev/null || true
    unset _day_format _date_pattern _date_pattern_with_year 2>/dev/null || true
    unset _today _tomorrow _yesterday 2>/dev/null || true
    unset _day_after_tomorrow _day_before_yesterday 2>/dev/null || true
    unset _this_weekday _next_weekday _last_weekday 2>/dev/null || true
    # Clear day format exceptions
    local _i
    for _i in 1 2 3 21 22 23 31; do
        unset "_day_format_ex_${_i}" 2>/dev/null || true
    done
    # Clear short/compact overrides
    for _mode in short compact; do
        unset "_${_mode}_months" "_${_mode}_weekdays" 2>/dev/null || true
        unset "_${_mode}_day_format" "_${_mode}_date_pattern" "_${_mode}_date_pattern_with_year" 2>/dev/null || true
    done
}

# Load a locale by code. Returns 1 if not found.
sayabledate_get_locale() {
    local code="$1"
    _sayabledate_ensure_registry
    _sayabledate_clear_locale
    _sayabledate_load_locale "${code}"
}

# --- Formatting helpers ---

_sayabledate_format_day() {
    local day=$1
    local day_str="${day}"
    local fmt="${_sa_day_format}"
    # Check for exception (unless compactness overrode day_format, clearing exceptions)
    if [ "${_sa_clear_day_exceptions}" != "1" ]; then
        local ex_var="_day_format_ex_${day_str}"
        if [ -n "${!ex_var+x}" ]; then
            fmt="${!ex_var}"
        fi
    fi
    echo "${fmt//\{n\}/${day_str}}"
}

_sayabledate_format_absolute() {
    local year=$1 month=$2 day=$3 include_year=$4
    local formatted_day
    formatted_day=$(_sayabledate_format_day "${day}")

    # Pick month name (genitive form if available)
    local month_idx=$(( month - 1 ))
    local month_name
    if [ ${#_sa_months_in_date[@]} -gt 0 ] 2>/dev/null; then
        month_name="${_sa_months_in_date[${month_idx}]}"
    else
        month_name="${_sa_months[${month_idx}]}"
    fi

    local pattern
    if [ "${include_year}" = "1" ]; then
        pattern="${_sa_date_pattern_with_year}"
    else
        pattern="${_sa_date_pattern}"
    fi

    local result="${pattern//\{month\}/${month_name}}"
    result="${result//\{day\}/${formatted_day}}"
    result="${result//\{d\}/${day}}"
    result="${result//\{m\}/${month}}"
    if [ "${include_year}" = "1" ]; then
        result="${result//\{year\}/${year}}"
        local yy
        yy=$(printf "%02d" $(( year % 100 )))
        result="${result//\{yy\}/${yy}}"
    fi

    echo "${result}"
}

# --- Compactness resolution ---

_sayabledate_apply_compactness() {
    local compactness="$1"

    # Copy base values
    _sa_months=("${_months[@]}")
    _sa_weekdays=("${_weekdays[@]}")
    _sa_day_format="${_day_format}"
    _sa_date_pattern="${_date_pattern}"
    _sa_date_pattern_with_year="${_date_pattern_with_year}"
    _sa_today="${_today}"
    _sa_tomorrow="${_tomorrow}"
    _sa_yesterday="${_yesterday}"
    _sa_compactness="${compactness}"
    _sa_clear_day_exceptions=0

    # Copy months_in_date if set
    if [ -n "${_months_in_date+x}" ]; then
        _sa_months_in_date=("${_months_in_date[@]}")
    else
        _sa_months_in_date=()
    fi

    if [ "${compactness}" = "short" ]; then
        if [ -n "${_short_months+x}" ]; then _sa_months=("${_short_months[@]}"); fi
        if [ -n "${_short_weekdays+x}" ]; then _sa_weekdays=("${_short_weekdays[@]}"); fi
        if [ -n "${_short_day_format+x}" ]; then
            _sa_day_format="${_short_day_format}"
            # When short overrides day_format, clear exceptions
            _sa_clear_day_exceptions=1
        fi
        if [ -n "${_short_date_pattern+x}" ]; then _sa_date_pattern="${_short_date_pattern}"; fi
        if [ -n "${_short_date_pattern_with_year+x}" ]; then _sa_date_pattern_with_year="${_short_date_pattern_with_year}"; fi
    elif [ "${compactness}" = "compact" ]; then
        if [ -n "${_compact_months+x}" ]; then _sa_months=("${_compact_months[@]}"); fi
        if [ -n "${_compact_weekdays+x}" ]; then _sa_weekdays=("${_compact_weekdays[@]}"); fi
        if [ -n "${_compact_day_format+x}" ]; then
            _sa_day_format="${_compact_day_format}"
            _sa_clear_day_exceptions=1
        fi
        if [ -n "${_compact_date_pattern+x}" ]; then _sa_date_pattern="${_compact_date_pattern}"; fi
        if [ -n "${_compact_date_pattern_with_year+x}" ]; then _sa_date_pattern_with_year="${_compact_date_pattern_with_year}"; fi
    fi
}

# --- Public API ---

# sayabledate_format_date locale_code date [compactness]
# Outputs the formatted date string, or empty string on error.
sayabledate_format_date() {
    local locale_code="$1" date_str="$2" compactness="${3:-normal}"

    if [ -z "${date_str}" ]; then
        echo ""
        return
    fi

    if ! sayabledate_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayabledate_apply_compactness "${compactness}"

    if ! _sayabledate_parse_date "${date_str}"; then
        echo ""
        return
    fi

    _sayabledate_format_absolute ${_pd_y} ${_pd_m} ${_pd_d} 0
}

# sayabledate_format_date_with_year locale_code date [compactness]
sayabledate_format_date_with_year() {
    local locale_code="$1" date_str="$2" compactness="${3:-normal}"

    if [ -z "${date_str}" ]; then
        echo ""
        return
    fi

    if ! sayabledate_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayabledate_apply_compactness "${compactness}"

    if ! _sayabledate_parse_date "${date_str}"; then
        echo ""
        return
    fi

    _sayabledate_format_absolute ${_pd_y} ${_pd_m} ${_pd_d} 1
}

# sayabledate_format_relative locale_code date as_of [compactness]
sayabledate_format_relative() {
    local locale_code="$1" date_str="$2" as_of="$3" compactness="${4:-normal}"

    if [ -z "${date_str}" ] || [ -z "${as_of}" ]; then
        echo ""
        return
    fi

    if ! sayabledate_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    _sayabledate_apply_compactness "${compactness}"

    if ! _sayabledate_parse_date "${date_str}"; then
        echo ""
        return
    fi
    local dy=${_pd_y} dm=${_pd_m} dd=${_pd_d}

    if ! _sayabledate_parse_date "${as_of}"; then
        echo ""
        return
    fi
    local ay=${_pd_y} am=${_pd_m} ad=${_pd_d}

    local date_jdn asof_jdn
    date_jdn=$(_sayabledate_to_jdn "${dy}" "${dm}" "${dd}")
    asof_jdn=$(_sayabledate_to_jdn "${ay}" "${am}" "${ad}")
    local diff=$(( date_jdn - asof_jdn ))

    # Today
    if [ ${diff} -eq 0 ]; then
        echo "${_sa_today}"
        return
    fi

    # Tomorrow
    if [ ${diff} -eq 1 ]; then
        echo "${_sa_tomorrow}"
        return
    fi

    # Yesterday
    if [ ${diff} -eq -1 ]; then
        echo "${_sa_yesterday}"
        return
    fi

    local is_compact=0
    if [ "${_sa_compactness}" = "compact" ]; then
        is_compact=1
    fi

    # Day after tomorrow (optional)
    if [ ${diff} -eq 2 ] && [ -n "${_day_after_tomorrow+x}" ] && [ ${is_compact} -eq 0 ]; then
        echo "${_day_after_tomorrow}"
        return
    fi

    # Day before yesterday (optional)
    if [ ${diff} -eq -2 ] && [ -n "${_day_before_yesterday+x}" ] && [ ${is_compact} -eq 0 ]; then
        echo "${_day_before_yesterday}"
        return
    fi

    # Compact mode: skip weekday references, go straight to calendar date
    if [ ${is_compact} -eq 1 ]; then
        local include_year=0
        if [ ${dy} -ne ${ay} ]; then include_year=1; fi
        _sayabledate_format_absolute ${dy} ${dm} ${dd} ${include_year}
        return
    fi

    # This weekday (+2 to +6)
    if [ ${diff} -ge 2 ] && [ ${diff} -le 6 ] && [ -n "${_this_weekday+x}" ]; then
        local dow
        dow=$(_sayabledate_weekday "${dy}" "${dm}" "${dd}")
        local weekday_name="${_sa_weekdays[${dow}]}"
        echo "${_this_weekday//\{weekday\}/${weekday_name}}"
        return
    fi

    # Last weekday (-2 to -6)
    if [ ${diff} -ge -6 ] && [ ${diff} -le -2 ] && [ -n "${_last_weekday+x}" ]; then
        local dow
        dow=$(_sayabledate_weekday "${dy}" "${dm}" "${dd}")
        local weekday_name="${_sa_weekdays[${dow}]}"
        echo "${_last_weekday//\{weekday\}/${weekday_name}}"
        return
    fi

    # Next weekday (+7 to +13)
    if [ ${diff} -ge 7 ] && [ ${diff} -le 13 ] && [ -n "${_next_weekday+x}" ]; then
        local dow
        dow=$(_sayabledate_weekday "${dy}" "${dm}" "${dd}")
        local weekday_name="${_sa_weekdays[${dow}]}"
        echo "${_next_weekday//\{weekday\}/${weekday_name}}"
        return
    fi

    # Calendar fallback
    local include_year=0
    if [ ${dy} -ne ${ay} ]; then include_year=1; fi
    _sayabledate_format_absolute ${dy} ${dm} ${dd} ${include_year}
}
