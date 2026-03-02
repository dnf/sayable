#!/usr/bin/env bash
# Runs just recipes in parallel with live progress display.
# Usage: run-parallel.sh <name> "test typescript" "test python" "check" ...
# <name> is used for the log directory: .logs/<name>/
# Each subsequent argument is passed to `just` as a complete command.
# The label shown in output is the last word of each argument.
set -uo pipefail

if [ $# -lt 2 ]; then echo "Usage: $0 <name> 'cmd args'..." >&2; exit 1; fi

name="$1"; shift
logdir=".logs/$name"
mkdir -p "$logdir"

# Partition args into runnable commands and skipped entries
cmds=()
labels=()
skip_labels=()
for arg in "$@"; do
    if [[ "$arg" == skip:* ]]; then
        skip_labels+=("${arg#skip:}")
    else
        cmds+=("$arg")
        labels+=("${arg##* }")
    fi
done
n=${#labels[@]}

# Compute label column width from both runnable and skipped labels (min 6)
label_w=6
for label in ${labels[@]+"${labels[@]}"} ${skip_labels[@]+"${skip_labels[@]}"}; do
    (( ${#label} > label_w )) && label_w=${#label}
done

# Terminal width (default 80) — cap bar so lines never wrap
term_w=80
if [ -t 1 ] && command -v tput &>/dev/null; then
    term_w=$(tput cols 2>/dev/null || echo 80)
fi
# Layout: "  X <label> <dur>s <bar>"  →  2 + 1 + 1 + label_w + 1 + 4 + 1 = label_w + 10
prefix_w=$((label_w + 10))
max_bar=$((term_w - prefix_w))
(( max_bar < 10 )) && max_bar=10

# If all entries are skipped, print skip lines and exit early
if [ "$n" -eq 0 ]; then
    skip_n=${#skip_labels[@]}
    for label in "${skip_labels[@]}"; do
        if [ -t 1 ]; then
            printf "  \033[2m- %-${label_w}s not installed\033[0m\n" "$label"
        else
            printf "  - %-${label_w}s not installed\n" "$label"
        fi
    done
    echo ""
    echo "0/0 passed, $skip_n not installed"
    echo "Logs: $logdir/"
    exit 0
fi

blocks="████████████████████████████████████████████████████████████████"

bar() {
    local len=$1
    (( len > max_bar )) && len=$max_bar
    printf "%s" "${blocks:0:$len}"
}

cleanup() {
    printf "\033[?25h" 2>/dev/null
    kill $(jobs -p) 2>/dev/null
    wait 2>/dev/null
    for label in "${labels[@]}"; do rm -f "$logdir/$label.result"; done
}
trap cleanup EXIT
trap 'exit 130' INT

# Start all jobs
global_start=$SECONDS
pids=()
for i in "${!cmds[@]}"; do
    label="${labels[$i]}"
    (
        rc=0
        s=$SECONDS
        just ${cmds[$i]} > "$logdir/$label.log" 2>&1 || rc=$?
        echo "$((SECONDS - s)) $rc" > "$logdir/$label.result"
    ) &
    pids+=($!)
done

# --- Progress display ---
if [ -t 1 ]; then
    spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    frame=0
    done_flags=()
    done_durs=()
    done_rcs=()
    for i in "${!labels[@]}"; do
        echo
        done_flags[$i]=""
        done_durs[$i]=0
        done_rcs[$i]=0
    done

    printf "\033[?25l"  # hide cursor

    while true; do
        printf "\033[${n}A"  # move up N lines

        done_count=0
        for i in "${!labels[@]}"; do
            label="${labels[$i]}"

            if [ -z "${done_flags[$i]}" ] && [ -f "$logdir/$label.result" ]; then
                read -r done_durs[$i] done_rcs[$i] < "$logdir/$label.result"
                done_flags[$i]=1
            fi

            if [ -n "${done_flags[$i]}" ]; then
                done_count=$((done_count + 1))
                dur="${done_durs[$i]}"
                if [ "${done_rcs[$i]}" -eq 0 ]; then
                    printf "  \033[32m✓\033[0m %-${label_w}s %3ds \033[32m%s\033[0m\033[K\n" "$label" "$dur" "$(bar "$dur")"
                else
                    printf "  \033[31m✗\033[0m %-${label_w}s %3ds \033[31m%s\033[0m\033[K\n" "$label" "$dur" "$(bar "$dur")"
                fi
            else
                c="${spin:frame%${#spin}:1}"
                elapsed=$((SECONDS - global_start))
                printf "  \033[33m%s\033[0m %-${label_w}s %3ds \033[33m%s\033[0m\033[K\n" "$c" "$label" "$elapsed" "$(bar "$elapsed")"
            fi
        done

        [ "$done_count" -eq "$n" ] && break
        frame=$((frame + 1))
        sleep 0.08
    done

    printf "\033[?25h"  # restore cursor

    for label in ${skip_labels[@]+"${skip_labels[@]}"}; do
        printf "  \033[2m- %-${label_w}s not installed\033[0m\n" "$label"
    done
else
    # Non-interactive (CI, piped): wait then print
    for pid in "${pids[@]}"; do wait "$pid" || true; done

    for label in "${labels[@]}"; do
        read -r dur rc < "$logdir/$label.result"
        if [ "$rc" -eq 0 ]; then
            printf "  ✓ %-${label_w}s %3ds %s\n" "$label" "$dur" "$(bar "$dur")"
        else
            printf "  ✗ %-${label_w}s %3ds %s\n" "$label" "$dur" "$(bar "$dur")"
        fi
    done

    for label in ${skip_labels[@]+"${skip_labels[@]}"}; do
        printf "  - %-${label_w}s not installed\n" "$label"
    done
fi

# --- Summary ---
failed=0
wall=0
for label in "${labels[@]}"; do
    read -r dur rc < "$logdir/$label.result"
    (( dur > wall )) && wall=$dur
    [ "$rc" -ne 0 ] && failed=$((failed + 1))
done

passed=$(( n - failed ))
skip_n=${#skip_labels[@]}
skip_msg=""
if [ "$skip_n" -gt 0 ]; then
    skip_msg=", $skip_n not installed"
fi
echo ""
echo "$passed/$n passed${skip_msg} (${wall}s wall time)"
echo "Logs: $logdir/"

if [ "$failed" -gt 0 ]; then
    echo ""
    for label in "${labels[@]}"; do
        read -r dur rc < "$logdir/$label.result"
        if [ "$rc" -ne 0 ]; then
            echo "=== $label ==="
            cat "$logdir/$label.log"
            echo ""
        fi
    done
    exit 1
fi
