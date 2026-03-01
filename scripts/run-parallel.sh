#!/usr/bin/env bash
# Runs just recipes in parallel with live progress display.
# Usage: run-parallel.sh [--logs] "test typescript" "test python" "check" ...
# Each argument is passed to `just` as a complete command.
# The label shown in output is the last word of each argument.
# With --logs, preserves the log directory and prints its path.
set -uo pipefail

keep_logs=false
if [ "${1:-}" = "--logs" ]; then keep_logs=true; shift; fi
if [ $# -eq 0 ]; then echo "Usage: $0 [--logs] 'cmd args'..." >&2; exit 1; fi

logdir=$(mktemp -d)

cmds=("$@")
labels=()
for cmd in "${cmds[@]}"; do labels+=("${cmd##* }"); done
n=${#labels[@]}

# 60 block characters — one per second of elapsed time
blocks="████████████████████████████████████████████████████████████████"

bar() { printf "%s" "${blocks:0:$1}"; }

cleanup() {
    printf "\033[?25h" 2>/dev/null
    kill $(jobs -p) 2>/dev/null
    wait 2>/dev/null
    if [ "$keep_logs" = false ]; then rm -rf "$logdir"; fi
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
                    printf "  \033[32m✓\033[0m %-12s %2ds \033[32m%s\033[0m\033[K\n" "$label" "$dur" "$(bar "$dur")"
                else
                    printf "  \033[31m✗\033[0m %-12s %2ds \033[31m%s\033[0m\033[K\n" "$label" "$dur" "$(bar "$dur")"
                fi
            else
                c="${spin:frame%${#spin}:1}"
                elapsed=$((SECONDS - global_start))
                printf "  \033[33m%s\033[0m %-12s %2ds \033[33m%s\033[0m\033[K\n" "$c" "$label" "$elapsed" "$(bar "$elapsed")"
            fi
        done

        [ "$done_count" -eq "$n" ] && break
        frame=$((frame + 1))
        sleep 0.08
    done

    printf "\033[?25h"  # restore cursor
else
    # Non-interactive (CI, piped): wait then print
    for pid in "${pids[@]}"; do wait "$pid" || true; done

    for label in "${labels[@]}"; do
        read -r dur rc < "$logdir/$label.result"
        if [ "$rc" -eq 0 ]; then
            printf "  ✓ %-12s %2ds %s\n" "$label" "$dur" "$(bar "$dur")"
        else
            printf "  ✗ %-12s %2ds %s\n" "$label" "$dur" "$(bar "$dur")"
        fi
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
echo ""
echo "$passed/$n passed (${wall}s wall time)"

if [ "$keep_logs" = true ]; then
    echo "Logs: $logdir"
fi

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
