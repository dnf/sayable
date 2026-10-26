#!/usr/bin/env bash
# sayabletime.sh — Human-friendly clock time formatting.
# Zero dependencies. Source this file to use format_time.

# The locale variables (_half, _delimiter...) are set by the locale file a
# function loads at run time, which shellcheck can't follow.
# shellcheck disable=SC2154

_SAYABLETIME_REGISTRY_LOADED=0
# Read by callers, not by this file.
# shellcheck disable=SC2034
SAYABLETIME_VERSION="0.5.0"

# --- Time parsing ---

# A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
# suffix, which is ignored), alone or after the T of an ISO datetime. The
# digit class is spelled out because a [0-9] range can match other characters
# in some locales.
_SAYABLETIME_D='[0123456789]'
_SAYABLETIME_CLOCK_PATTERN="^((${_SAYABLETIME_D}{4})-(${_SAYABLETIME_D}{2})-(${_SAYABLETIME_D}{2})T)?(${_SAYABLETIME_D}{1,2}):(${_SAYABLETIME_D}{2})(:(${_SAYABLETIME_D}{2})(\\.${_SAYABLETIME_D}+)?)?(Z|[+-]${_SAYABLETIME_D}{2}:${_SAYABLETIME_D}{2})?$"

_sayabletime_is_real_date() {
    local y=$1 m=$2 d=$3 last=31
    if [ "${m}" -lt 1 ] || [ "${m}" -gt 12 ] || [ "${d}" -lt 1 ]; then return 1; fi
    case "${m}" in
        4|6|9|11) last=30 ;;
        2)
            last=28
            if (( (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 )); then last=29; fi
            ;;
    esac
    [ "${d}" -le "${last}" ]
}

# Parse a clock time or ISO datetime to hour and minute.
# Sets _pt_hour and _pt_minute. Returns 1 on failure.
_sayabletime_parse_time() {
    local input_str="$1"
    if ! [[ "${input_str}" =~ ${_SAYABLETIME_CLOCK_PATTERN} ]]; then return 1; fi

    # 10# reads leading zeros as decimal, not octal
    if [ -n "${BASH_REMATCH[1]}" ]; then
        if ! _sayabletime_is_real_date $(( 10#${BASH_REMATCH[2]} )) $(( 10#${BASH_REMATCH[3]} )) $(( 10#${BASH_REMATCH[4]} )); then
            return 1
        fi
    fi
    _pt_hour=$(( 10#${BASH_REMATCH[5]} ))
    _pt_minute=$(( 10#${BASH_REMATCH[6]} ))
    local second=$(( 10#${BASH_REMATCH[8]:-0} ))

    if [ ${_pt_hour} -gt 23 ] || [ ${_pt_minute} -gt 59 ] || [ ${second} -gt 59 ]; then return 1; fi

    return 0
}

_sayabletime_round_to_5() {
    local minute=$1
    echo $(( ((minute + 2) / 5) * 5 ))
}

# --- Locale loading ---

_sayabletime_ensure_registry() {
    if [ ${_SAYABLETIME_REGISTRY_LOADED} -eq 0 ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck disable=SC1091
        source "${script_dir}/locales/registry.sh"
        _SAYABLETIME_REGISTRY_LOADED=1
    fi
}

_sayabletime_clear_locale() {
    unset _clock_hours _clock_midnight _clock_noon 2>/dev/null || true
    local _k
    for _k in 0 5 10 15 20 25 30 35 40 45 50 55; do
        unset "_clock_pattern_${_k}" 2>/dev/null || true
    done
    for _mode in short compact; do
        unset "_${_mode}_clock_use24h" "_${_mode}_clock_format" 2>/dev/null || true
        unset "_${_mode}_clock_am" "_${_mode}_clock_pm" 2>/dev/null || true
    done
}

sayabletime_get_locale() {
    local code="$1"
    _sayabletime_ensure_registry
    _sayabletime_clear_locale
    _sayabletime_load_locale "${code}"
}

# --- Formatting ---

_sayabletime_format_natural() {
    local hour=$1 minute=$2
    local rounded
    rounded=$(_sayabletime_round_to_5 "${minute}")
    local h=${hour}

    if [ ${rounded} -eq 60 ]; then
        rounded=0
        h=$(( (h + 1) % 24 ))
    fi

    if [ ${rounded} -eq 0 ]; then
        if [ ${h} -eq 0 ]; then
            echo "${_clock_midnight}"
            return
        fi
        if [ ${h} -eq 12 ]; then
            echo "${_clock_noon}"
            return
        fi
    fi

    local h12=$(( h % 12 ))
    local next_h12=$(( (h + 1) % 12 ))
    local h_name="${_clock_hours[${h12}]}"
    local next_h_name="${_clock_hours[${next_h12}]}"

    local pattern_var="_clock_pattern_${rounded}"
    local pattern
    if [ -n "${!pattern_var+x}" ]; then
        pattern="${!pattern_var}"
    else
        local zero_var="_clock_pattern_0"
        if [ -n "${!zero_var+x}" ]; then
            pattern="${!zero_var}"
        else
            pattern="{h}"
        fi
    fi

    local result="${pattern//\{h\}/${h_name}}"
    result="${result//\{next_h\}/${next_h_name}}"
    echo "${result}"
}

_sayabletime_format_digital() {
    local hour=$1 minute=$2 mode=$3
    local use24h_var="_${mode}_clock_use24h"
    local format_var="_${mode}_clock_format"
    local use24h="${!use24h_var}"
    local fmt="${!format_var}"

    local mm
    mm=$(printf "%02d" "${minute}")

    if [ "${use24h}" = "1" ]; then
        local result="${fmt//\{h\}/${hour}}"
        result="${result//\{mm\}/${mm}}"
        echo "${result}"
        return
    fi

    local h12=$(( hour % 12 ))
    if [ ${h12} -eq 0 ]; then h12=12; fi

    local ampm_str
    local am_var="_${mode}_clock_am"
    local pm_var="_${mode}_clock_pm"
    if [ ${hour} -lt 12 ]; then
        ampm_str="${!am_var:-AM}"
    else
        ampm_str="${!pm_var:-PM}"
    fi

    local result="${fmt//\{h\}/${h12}}"
    result="${result//\{mm\}/${mm}}"
    result="${result//\{ampm\}/${ampm_str}}"
    echo "${result}"
}

# --- Public API ---

# sayabletime_format_time locale_code time [compactness]
sayabletime_format_time() {
    local locale_code="$1" time_str="$2" compactness="${3:-normal}"

    if [ -z "${time_str}" ]; then
        echo ""
        return
    fi

    if ! sayabletime_get_locale "${locale_code}"; then
        echo ""
        return
    fi

    if ! _sayabletime_parse_time "${time_str}"; then
        echo ""
        return
    fi

    local hour=${_pt_hour} minute=${_pt_minute}

    if [ "${compactness}" != "normal" ]; then
        local use24h_var="_${compactness}_clock_use24h"
        if [ -n "${!use24h_var+x}" ]; then
            _sayabletime_format_digital ${hour} ${minute} "${compactness}"
            return
        fi
    fi

    _sayabletime_format_natural ${hour} ${minute}
}
