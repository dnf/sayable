#!/usr/bin/env bash
# Runs just recipes in parallel with live progress display.
# Usage: run-parallel.sh [-j N] [-s full|zoom] <name> "cmd" ...
# -j N limits concurrent jobs to N slots (0 or omitted = unlimited).
# -s MODE sets visualization: scroll (default), full, or zoom.
# <name> is used for the log directory: .logs/<name>/
# Each subsequent argument is passed to `just` as a complete command.
# The label shown in output is the last word of each argument.
# Entries prefixed with "skip:" are shown as "not installed" in their
# original position without launching a job.
set -uo pipefail

max_jobs=0
_viz_mode=scroll  # scroll (default), full, or zoom
_tick_ds=2        # base: 0.2s per column (for scroll/zoom modes)
_show_help() {
    cat <<'HELP'
Usage: run-parallel.sh [flags] <name> "cmd args" ...

Run just recipes in parallel with live progress display.

Arguments:
  <name>            Log directory name — output goes to .logs/<name>/
  "cmd args" ...    Commands passed to `just`. The last word of each becomes
                    the display label. Prefix with "skip:" to mark as
                    not installed (e.g. "skip:haskell").

Flags:
  -j N              Limit concurrent jobs to N slots (0 or omitted = unlimited)
  -s MODE           Visualization mode: scroll (default), full, or zoom
  -h, --help        Show this help and exit

Scheduling (slot-based, -j N where N > 0):
  Jobs are queued by predicted duration (longest first) with errors from
  the previous run promoted to the front. Slot 0 is the "fast slot" — it
  picks the shortest available job so quick jobs finish and report early.
  Duration predictions use the median of the last 5 runs from history.log.

Visualization modes:
  scroll    Fixed time scale, window scrolls right as time advances (default)
  full      Entire run fits in the terminal width, rescales every frame
  zoom      Fixed origin, time scale doubles when the chart would overflow

Output format:
  Interactive (tty)     Live-updating bar chart with spinner, color-coded bars,
                        and swim lane timeline (slot-based mode only)
  Non-interactive       Waits for completion, then prints a scaled bar chart

Log files:
  .logs/<name>/<label>.log       Captured stdout+stderr for each job
  .logs/<name>/<label>.result    "duration_ds return_code" (internal)
  .logs/<name>/history.log       Duration history for prediction (last 50 runs)

Requirements:
  bash 4+, perl (Time::HiRes for sub-second timing), tput (optional, for
  terminal width detection and cursor control)
HELP
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) _show_help ;;
        -j) max_jobs="${2:-0}"; shift 2 ;;
        -s) case "${2:-}" in
                full)    _viz_mode=full ;;
                scroll)  _viz_mode=scroll ;;
                zoom)    _viz_mode=zoom ;;
                *) echo "error: -s accepts full, scroll, or zoom (got '${2:-}')" >&2; exit 1 ;;
            esac; shift 2 ;;
        *) break ;;
    esac
done

if [ $# -lt 2 ]; then echo "Usage: $0 [-j N] [-s full|zoom] <name> 'cmd args'..." >&2; exit 1; fi

name="$1"; shift
logdir=".logs/$name"
mkdir -p "$logdir"

# Prevent concurrent runs of the same command
lockdir="$logdir/.lock"
if ! mkdir "$lockdir" 2>/dev/null; then
    # Clean up stale locks older than 2 minutes
    if find "$lockdir" -maxdepth 0 -mmin +2 2>/dev/null | grep -q .; then
        rmdir "$lockdir" 2>/dev/null
    fi
    if ! mkdir "$lockdir" 2>/dev/null; then
        echo "error: just $name is already running (lock: $lockdir)" >&2
        exit 1
    fi
fi

# Build unified ordered list — each entry is runnable, skipped, or a separator
all_labels=()
all_cmds=()   # empty string for skipped/separator entries
all_skip=()   # 1 = skipped/separator, 0 = runnable
all_sep=()    # 1 = separator (blank line), 0 = normal entry
run_n=0
skip_n=0
for arg in "$@"; do
    if [[ "$arg" == "---" ]]; then
        all_labels+=("---")
        all_cmds+=("")
        all_skip+=(1)
        all_sep+=(1)
    elif [[ "$arg" == skip:* ]]; then
        all_labels+=("${arg#skip:}")
        all_cmds+=("")
        all_skip+=(1)
        all_sep+=(0)
        skip_n=$((skip_n + 1))
    else
        all_labels+=("${arg##* }")
        all_cmds+=("$arg")
        all_skip+=(0)
        all_sep+=(0)
        run_n=$((run_n + 1))
    fi
done
total=${#all_labels[@]}

# Compute label column width (min 6)
label_w=6
for i in "${!all_labels[@]}"; do
    [ "${all_sep[$i]}" -eq 1 ] && continue
    (( ${#all_labels[$i]} > label_w )) && label_w=${#all_labels[$i]}
done

# Detect terminal width via multiple methods (tput alone often returns 80)
_term_width() {
    local w=0
    if [ -t 0 ]; then
        w=$(stty size 2>/dev/null | awk '{print $2}')
        [ "${w:-0}" -gt 0 ] 2>/dev/null && echo "$w" && return
    fi
    if command -v tput &>/dev/null; then
        w=$(tput cols 2>/dev/null)
        [ "${w:-0}" -gt 0 ] 2>/dev/null && echo "$w" && return
    fi
    [ "${COLUMNS:-0}" -gt 0 ] 2>/dev/null && echo "$COLUMNS" && return
    echo 80
}
term_w=$(_term_width)
# Layout: "  X label dur_str bar" → 2+1+1 + label_w + 1 + 6 + 1 = label_w + 12
prefix_w=$((label_w + 12))
max_bar=$((term_w - prefix_w))
(( max_bar < 10 )) && max_bar=10

# If all entries are skipped, print skip lines and exit early
if [ "$run_n" -eq 0 ]; then
    for i in "${!all_labels[@]}"; do
        if [ "${all_sep[$i]}" -eq 1 ]; then echo; continue; fi
        label="${all_labels[$i]}"
        if [ -t 1 ]; then
            printf "  \033[2m- %-${label_w}s    - not installed\033[0m\n" "$label"
        else
            printf "  - %-${label_w}s    - not installed\n" "$label"
        fi
    done
    echo ""
    echo "0/0 passed, $skip_n not installed"
    echo "Logs: $logdir/"
    rmdir "$lockdir" 2>/dev/null
    exit 0
fi

# Pre-built block string (wide enough for any terminal)
blocks=""
for (( _i=0; _i<512; _i++ )); do blocks+="█"; done

bar() {
    local len=$1
    (( len > max_bar )) && len=$max_bar
    (( len < 1 )) && len=1
    printf "%s" "${blocks:0:$len}"
}

# Decisecond timer (0.1s precision via perl Time::HiRes)
_now_ds() { perl -MTime::HiRes=time -e 'printf "%d\n", time*10'; }

# Format deciseconds as "X.Ys"
_fmt_ds() { echo "$((${1} / 10)).$((${1} % 10))s"; }

# Print a duration-scaled time axis above bar charts.
# $1 = max duration in deciseconds, $2 = 1 if interactive (adds \033[K)
_print_duration_axis() {
    local _max_ds=$1 _is_tty=${2:-0}
    (( _max_ds < 1 )) && _max_ds=1
    printf "%*s" "$prefix_w" ""
    local _max_sec=$(( (_max_ds + 9) / 10 ))
    local _interval _prev_end=0 _t _tick_col _pad
    if [ "$_max_sec" -le 5 ]; then _interval=1
    elif [ "$_max_sec" -le 20 ]; then _interval=5
    elif [ "$_max_sec" -le 60 ]; then _interval=10
    else _interval=30; fi
    for (( _t=0; _t<=_max_sec; _t+=_interval )); do
        _tick_col=$(( _t * 10 * max_bar / _max_ds ))
        if [ "$_tick_col" -ge "$_prev_end" ] && [ "$((_tick_col + ${#_t}))" -le "$max_bar" ]; then
            _pad=$((_tick_col - _prev_end))
            (( _pad > 0 )) && printf "%*s" "$_pad" ""
            printf "%d" "$_t"
            _prev_end=$((_tick_col + ${#_t}))
        fi
    done
    [ "$_is_tty" -eq 1 ] && printf "\033[K"
    echo
}

# Print a timeline axis for slot-based visualization.
# Reads globals: _viz_mode, _total_ds, _eff_tick_ds, _display_offset_ds, max_bar, prefix_w
_print_time_axis() {
    printf "%*s" "$prefix_w" ""
    local _prev_end=0 _t _label_interval _tick_col _pad
    if [ "$_viz_mode" = "full" ]; then
        local _total_sec=$((_total_ds / 10 + 1))
        if [ "$_total_sec" -lt 10 ]; then _label_interval=1
        elif [ "$_total_sec" -lt 60 ]; then _label_interval=5
        else _label_interval=30; fi
        for (( _t=0; _t<=_total_sec; _t+=_label_interval )); do
            _tick_col=$((_t * 10 * max_bar / _total_ds))
            if [ "$_tick_col" -ge "$_prev_end" ] && [ "$((_tick_col + ${#_t}))" -le "$max_bar" ]; then
                _pad=$((_tick_col - _prev_end))
                (( _pad > 0 )) && printf "%*s" "$_pad" ""
                printf "%d" "$_t"
                _prev_end=$((_tick_col + ${#_t}))
            fi
        done
    else
        if [ "$_eff_tick_ds" -le 2 ]; then _label_interval=1
        elif [ "$_eff_tick_ds" -le 10 ]; then _label_interval=5
        elif [ "$_eff_tick_ds" -le 50 ]; then _label_interval=30
        else _label_interval=60; fi
        local _first_sec=$(( (_display_offset_ds + 9) / 10 ))
        _first_sec=$(( (_first_sec + _label_interval - 1) / _label_interval * _label_interval ))
        local _last_ds=$((_display_offset_ds + max_bar * _eff_tick_ds))
        local _last_sec=$((_last_ds / 10))
        for (( _t=_first_sec; _t<=_last_sec; _t+=_label_interval )); do
            _tick_col=$(( (_t * 10 - _display_offset_ds) / _eff_tick_ds ))
            if [ "$_tick_col" -ge "$_prev_end" ] && [ "$((_tick_col + ${#_t}))" -le "$max_bar" ]; then
                _pad=$((_tick_col - _prev_end))
                (( _pad > 0 )) && printf "%*s" "$_pad" ""
                printf "%d" "$_t"
                _prev_end=$((_tick_col + ${#_t}))
            fi
        done
    fi
    if [ "$_prev_end" -lt "$max_bar" ]; then
        printf "%*s" "$((max_bar - _prev_end))" ""
    fi
    printf "\033[K\n"
}

# --- Swim lane color palette (256-color, 20 distinct) ---
_palette=(196 46 33 208 129 214 39 161 82 166 63 203 48 99 215 35 197 118 57 172)
_npal=${#_palette[@]}

# Render swim lane chart (supports full/scroll/zoom modes).
# Every line ends with \033[K for live-refresh compatibility.
# Expects: max_jobs, max_bar, _viz_mode, _total_ds, _eff_tick_ds,
#          _display_offset_ds, _max_ds, _lane_ci[], _slot_labels[],
#          _palette[], prefix_w, label_w, term_w
_render_lanes() {
    printf "\033[K\n"

    # Header rule line
    local _ri
    for (( _ri=0; _ri<term_w; _ri++ )); do printf "─"; done
    printf "\033[K\n"

    # Time axis
    _print_time_axis
    printf "\033[K\n"

    # Lane rows (label + color block aligned with bar chart labels)
    local _s _lt _ds
    for (( _s=0; _s<max_jobs; _s++ )); do
        if [ -n "${_slot_labels[$_s]}" ] && [ "${_slot_ci[$_s]}" -ge 0 ]; then
            printf "    \033[48;5;%dm  \033[0m %-${label_w}s        " "${_palette[${_slot_ci[$_s]}]}" "${_slot_labels[$_s]}"
        else
            printf "%*s" "$prefix_w" ""
        fi
        for (( _lt=0; _lt<max_bar; _lt++ )); do
            if [ "$_viz_mode" = "full" ]; then
                _ds=$((_lt * _total_ds / max_bar))
            else
                _ds=$((_display_offset_ds + _lt * _eff_tick_ds))
            fi
            if (( _ds >= _max_ds )); then
                printf " "
            else
                local ci="${_lane_ci[$((_s * _max_ds + _ds))]:--1}"
                if [ "$ci" -ge 0 ]; then
                    printf "\033[48;5;%dm \033[0m" "${_palette[$((ci % _npal))]}"
                else
                    printf "\033[48;5;236m \033[0m"
                fi
            fi
        done
        printf "\033[K\n"
    done
}

cleanup() {
    [ -t 1 ] && printf "\033[?25h" 2>/dev/null
    kill $(jobs -p) 2>/dev/null
    wait 2>/dev/null
    for i in "${!all_labels[@]}"; do
        [ "${all_skip[$i]}" -eq 0 ] && rm -f "$logdir/${all_labels[$i]}.result"
    done
    rmdir "$lockdir" 2>/dev/null
}
trap cleanup EXIT
trap 'exit 130' INT

# ===================================================================
# Job scheduling + progress display
# ===================================================================
global_start=$SECONDS
global_start_ds=$(_now_ds)
pids=()

if [ "$max_jobs" -gt 0 ]; then
    # --- Slot-based scheduling ---

    # Build queue of runnable job indices (alphabetical order initially)
    _run_queue=()
    for i in "${!all_labels[@]}"; do
        [ "${all_skip[$i]}" -eq 0 ] && _run_queue+=("$i")
    done

    # Color index per label: position in the queue (alphabetical, stable across sorts)
    _label_ci=()
    for _q in "${!_run_queue[@]}"; do
        _label_ci[${_run_queue[$_q]}]=$((_q % _npal))
    done

    # --- History-based duration prediction + error tracking ---
    _predicted_dur=()
    _error_last=()
    for i in "${!all_labels[@]}"; do
        _predicted_dur[$i]=0
        _error_last[$i]=0
    done
    _histfile="$logdir/history.log"
    if [ -f "$_histfile" ]; then
        _hist_lines=()
        while IFS= read -r _hl; do
            _hist_lines+=("$_hl")
        done < <(tail -5 "$_histfile")

        # Duration prediction (median of last 5 runs)
        for i in "${!all_labels[@]}"; do
            [ "${all_skip[$i]}" -eq 1 ] && continue
            label="${all_labels[$i]}"
            _durs=()
            for _hl in "${_hist_lines[@]}"; do
                for _pair in $_hl; do
                    if [[ "$_pair" == "${label}="* ]]; then
                        _val="${_pair#*=}"
                        _durs+=("${_val%%:*}")  # strip :rc if present
                    fi
                done
            done
            if [ ${#_durs[@]} -gt 0 ]; then
                IFS=$'\n' _sorted_d=($(sort -n <<<"${_durs[*]}")); unset IFS
                _predicted_dur[$i]=${_sorted_d[$(( ${#_sorted_d[@]} / 2 ))]}
            fi
        done

        # Error tracking (jobs that failed in the most recent run)
        _last_run="${_hist_lines[${#_hist_lines[@]}-1]}"
        for _pair in $_last_run; do
            _elabel="${_pair%%=*}"
            _edata="${_pair#*=}"
            _erc="${_edata#*:}"
            if [ "$_erc" != "$_edata" ] && [ "$_erc" -ne 0 ] 2>/dev/null; then
                for i in "${!all_labels[@]}"; do
                    [ "${all_labels[$i]}" = "$_elabel" ] && _error_last[$i]=1
                done
            fi
        done
    fi

    # Sort _run_queue: errors first, then by predicted duration descending
    # Composite key: error * 10000000 + predicted_dur
    for (( _i=1; _i<${#_run_queue[@]}; _i++ )); do
        _key=${_run_queue[$_i]}
        _kval=$(( ${_error_last[$_key]} * 10000000 + ${_predicted_dur[$_key]} ))
        _j=$((_i - 1))
        while [ "$_j" -ge 0 ] && [ "$(( ${_error_last[${_run_queue[$_j]}]} * 10000000 + ${_predicted_dur[${_run_queue[$_j]}]} ))" -lt "$_kval" ]; do
            _run_queue[$((_j + 1))]=${_run_queue[$_j]}
            _j=$((_j - 1))
        done
        _run_queue[$((_j + 1))]=$_key
    done

    # Slot tracking
    _slot_pids=()
    _slot_labels=()
    _slot_ci=()       # color index per slot (-1 = empty)
    _slot_job=()      # job index per slot (-1 = empty)
    for (( _s=0; _s<max_jobs; _s++ )); do
        _slot_pids[$_s]=0
        _slot_labels[$_s]=""
        _slot_ci[$_s]=-1
        _slot_job[$_s]=-1
    done

    # Job tracking
    _job_started=()
    _job_start_ds=()
    for i in "${!all_labels[@]}"; do
        _job_started[$i]=0
        _job_start_ds[$i]=0
    done

    # Timeline data: flat array [slot * _max_ds + decisecond] → color index
    _max_ds=6000  # 10 minutes at decisecond resolution
    _lane_ci=()

    # Adjust prefix width for color block in bar chart
    # "  X ██ label dur_str bar" → 2+1+1+2+1 + label_w + 1 + 6 + 1 = label_w + 15
    prefix_w=$((label_w + 15))
    max_bar=$((term_w - prefix_w))
    (( max_bar < 10 )) && max_bar=10

    _last_rec_ds=-1

    if [ -t 1 ]; then
        # --- Interactive slot-based loop with live swim lanes ---
        spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        frame=0
        done_flags=()
        done_durs=()
        done_rcs=()

        # Swim lane height: blank + header + axis + lane rows
        _swim_height=$((4 + max_jobs))
        _display_height=$((total + _swim_height + 2))

        for (( _i=0; _i<_display_height; _i++ )); do echo; done
        for i in "${!all_labels[@]}"; do
            done_flags[$i]=""
            done_durs[$i]=0
            done_rcs[$i]=0
        done

        printf "\033[?25l"  # hide cursor

        while true; do
            # Check for finished slots
            for (( _s=0; _s<max_jobs; _s++ )); do
                if [ "${_slot_pids[$_s]}" -ne 0 ] && ! kill -0 "${_slot_pids[$_s]}" 2>/dev/null; then
                    wait "${_slot_pids[$_s]}" 2>/dev/null || true
                    _slot_pids[$_s]=0
                    _slot_labels[$_s]=""
                    _slot_ci[$_s]=-1
                    _slot_job[$_s]=-1
                fi
            done

            # Launch new jobs into empty slots
            # Slot 0 is the "fast slot": picks shortest job (errors first)
            # Other slots pick longest job (errors first)
            for (( _s=0; _s<max_jobs; _s++ )); do
                [ "${_slot_pids[$_s]}" -ne 0 ] && continue

                _found_qi=-1
                if [ "$_s" -eq 0 ]; then
                    # Fast slot: prefer shortest error, then shortest non-error
                    _fallback=-1
                    for (( _fqi=${#_run_queue[@]}-1; _fqi>=0; _fqi-- )); do
                        _fq=${_run_queue[$_fqi]}
                        [ "${_job_started[$_fq]}" -eq 1 ] && continue
                        [ "$_fallback" -lt 0 ] && _fallback=$_fq
                        if [ "${_error_last[$_fq]}" -eq 1 ]; then
                            _found_qi=$_fq; break
                        fi
                    done
                    [ "$_found_qi" -lt 0 ] && _found_qi=$_fallback
                else
                    # Regular slot: pick first unstarted (errors first, longest first)
                    for _fq in "${_run_queue[@]}"; do
                        [ "${_job_started[$_fq]}" -eq 1 ] && continue
                        _found_qi=$_fq; break
                    done
                fi
                [ "$_found_qi" -lt 0 ] && continue

                qi=$_found_qi
                _job_started[$qi]=1
                label="${all_labels[$qi]}"
                (
                    rc=0; _st=$(_now_ds)
                    just ${all_cmds[$qi]} > "$logdir/$label.log" 2>&1 || rc=$?
                    _et=$(_now_ds)
                    echo "$((_et - _st)) $rc" > "$logdir/$label.result"
                ) &
                _slot_pids[$_s]=$!
                _slot_labels[$_s]="$label"
                _slot_ci[$_s]=${_label_ci[$qi]}
                _slot_job[$_s]=$qi
                _job_start_ds[$qi]=$(_now_ds)
                pids+=($!)
            done

            # Record timeline (decisecond resolution)
            _frame_ds=$(_now_ds)
            _cur_ds=$((_frame_ds - global_start_ds))
            if [ "$_cur_ds" -gt "$_last_rec_ds" ] && [ "$_cur_ds" -lt "$_max_ds" ]; then
                for (( _rd=_last_rec_ds+1; _rd<=_cur_ds && _rd<_max_ds; _rd++ )); do
                    for (( _s=0; _s<max_jobs; _s++ )); do
                        if [ "${_slot_ci[$_s]}" -ge 0 ]; then
                            _lane_ci[$((_s * _max_ds + _rd))]=${_slot_ci[$_s]}
                        fi
                    done
                done
                _last_rec_ds=$_cur_ds
            fi

            # Check for results
            done_count=0
            for i in "${!all_labels[@]}"; do
                [ "${all_skip[$i]}" -eq 1 ] && continue
                label="${all_labels[$i]}"
                if [ -z "${done_flags[$i]}" ] && [ -f "$logdir/$label.result" ]; then
                    read -r done_durs[$i] done_rcs[$i] < "$logdir/$label.result"
                    done_flags[$i]=1
                fi
                [ -n "${done_flags[$i]}" ] && done_count=$((done_count + 1))
            done

            # Dynamic terminal width
            _old_tw=$term_w
            term_w=$(_term_width)
            max_bar=$((term_w - prefix_w))
            (( max_bar < 10 )) && max_bar=10
            if (( term_w < _old_tw )); then
                printf "\033[2J\033[H"  # clear screen, cursor to top-left
                for (( _i=0; _i<_display_height; _i++ )); do echo; done
            fi

            # Display parameters (per-frame, based on visualization mode)
            _display_offset_ds=0
            case "$_viz_mode" in
                full)
                    _total_ds=$((_cur_ds + 1))
                    (( _total_ds < 1 )) && _total_ds=1
                    ;;
                scroll)
                    _eff_tick_ds=$_tick_ds
                    if [ $((_cur_ds / _eff_tick_ds)) -ge "$max_bar" ]; then
                        _display_offset_ds=$(( (_cur_ds / _eff_tick_ds - max_bar + 1) * _eff_tick_ds ))
                    fi
                    ;;
                zoom)
                    _eff_tick_ds=$_tick_ds
                    while [ $((_cur_ds / _eff_tick_ds)) -ge "$max_bar" ]; do
                        _eff_tick_ds=$((_eff_tick_ds * 2))
                    done
                    ;;
            esac

            # Render: bar chart + swim lanes (full redraw)
            printf "\033[${_display_height}A"
            _print_time_axis
            printf "\033[K\n"
            for i in "${!all_labels[@]}"; do
                label="${all_labels[$i]}"
                if [ "${all_sep[$i]}" -eq 1 ]; then
                    printf "\033[K\n"; continue
                fi
                if [ "${all_skip[$i]}" -eq 1 ]; then
                    printf "  \033[2m-    %-${label_w}s      - not installed\033[0m\033[K\n" "$label"
                    continue
                fi
                ci=${_label_ci[$i]}
                if [ -n "${done_flags[$i]}" ]; then
                    dur_ds="${done_durs[$i]}"
                    dur_str=$(_fmt_ds "$dur_ds")
                    if [ "${done_rcs[$i]}" -eq 0 ]; then
                        printf "  \033[32m✓\033[0m \033[48;5;%dm  \033[0m \033[32m%-${label_w}s %6s\033[0m " "${_palette[$ci]}" "$label" "$dur_str"
                    else
                        printf "  \033[31m✗\033[0m \033[48;5;%dm  \033[0m \033[31m%-${label_w}s %6s\033[0m " "${_palette[$ci]}" "$label" "$dur_str"
                    fi
                    _ws_ds=$((_job_start_ds[$i] - global_start_ds))
                    _we_ds=$((_ws_ds + dur_ds))
                    if [ "$_viz_mode" = "full" ]; then
                        _col_s=$((_ws_ds * max_bar / _total_ds))
                        _col_e=$((_we_ds * max_bar / _total_ds))
                    else
                        if [ "$_we_ds" -le "$_display_offset_ds" ]; then
                            printf "%*s" "$max_bar" ""
                            printf "\033[K\n"
                            continue
                        fi
                        _col_s=$(((_ws_ds - _display_offset_ds) / _eff_tick_ds))
                        _col_e=$(((_we_ds - _display_offset_ds + _eff_tick_ds - 1) / _eff_tick_ds))
                    fi
                    (( _col_s < 0 )) && _col_s=0
                    (( _col_e > max_bar )) && _col_e=$max_bar
                    (( _col_e <= _col_s )) && _col_e=$((_col_s + 1))
                    (( _col_e > max_bar )) && _col_e=$max_bar
                    (( _col_s > 0 )) && printf "%*s" "$_col_s" ""
                    _blen=$((_col_e - _col_s))
                    printf "\033[38;5;%dm%s\033[0m" "${_palette[$ci]}" "${blocks:0:$_blen}"
                    _rem=$((max_bar - _col_e))
                    (( _rem > 0 )) && printf "%*s" "$_rem" ""
                    printf "\033[K\n"
                elif [ "${_job_start_ds[$i]}" -gt 0 ]; then
                    # Running
                    c="${spin:frame%${#spin}:1}"
                    elapsed_ds=$((_frame_ds - _job_start_ds[$i]))
                    dur_str=$(_fmt_ds "$elapsed_ds")
                    printf "  \033[93m%s\033[0m \033[48;5;%dm  \033[0m \033[93m%-${label_w}s %6s\033[0m " "$c" "${_palette[$ci]}" "$label" "$dur_str"
                    _ws_ds=$((_job_start_ds[$i] - global_start_ds))
                    if [ "$_viz_mode" = "full" ]; then
                        _col_s=$((_ws_ds * max_bar / _total_ds))
                        _col_e=$((_cur_ds * max_bar / _total_ds + 1))
                    else
                        _col_s=$(((_ws_ds - _display_offset_ds) / _eff_tick_ds))
                        _col_e=$(((_cur_ds - _display_offset_ds) / _eff_tick_ds + 1))
                    fi
                    (( _col_s < 0 )) && _col_s=0
                    (( _col_e > max_bar )) && _col_e=$max_bar
                    (( _col_e <= _col_s )) && _col_e=$((_col_s + 1))
                    (( _col_e > max_bar )) && _col_e=$max_bar
                    (( _col_s > 0 )) && printf "%*s" "$_col_s" ""
                    _blen=$((_col_e - _col_s))
                    printf "\033[38;5;%dm%s\033[0m" "${_palette[$ci]}" "${blocks:0:$_blen}"
                    _rem=$((max_bar - _col_e))
                    (( _rem > 0 )) && printf "%*s" "$_rem" ""
                    printf "\033[K\n"
                else
                    # Queued (not yet launched)
                    printf "  \033[2m◌\033[0m \033[48;5;%dm  \033[0m \033[2m%-${label_w}s\033[0m       " "${_palette[$ci]}" "$label"
                    printf "%*s" "$max_bar" ""
                    printf "\033[K\n"
                fi
            done
            _render_lanes

            [ "$done_count" -eq "$run_n" ] && break
            frame=$((frame + 1))
            sleep 0.1
        done

        printf "\033[?25h"  # restore cursor
    else
        # --- Non-interactive slot-based loop (CI / piped) ---
        while true; do
            # Check for finished slots
            for (( _s=0; _s<max_jobs; _s++ )); do
                if [ "${_slot_pids[$_s]}" -ne 0 ] && ! kill -0 "${_slot_pids[$_s]}" 2>/dev/null; then
                    wait "${_slot_pids[$_s]}" 2>/dev/null || true
                    _slot_pids[$_s]=0
                    _slot_labels[$_s]=""
                    _slot_job[$_s]=-1
                fi
            done

            # Launch new jobs into empty slots (same fast-slot logic as interactive)
            for (( _s=0; _s<max_jobs; _s++ )); do
                [ "${_slot_pids[$_s]}" -ne 0 ] && continue

                _found_qi=-1
                if [ "$_s" -eq 0 ]; then
                    _fallback=-1
                    for (( _fqi=${#_run_queue[@]}-1; _fqi>=0; _fqi-- )); do
                        _fq=${_run_queue[$_fqi]}
                        [ "${_job_started[$_fq]}" -eq 1 ] && continue
                        [ "$_fallback" -lt 0 ] && _fallback=$_fq
                        if [ "${_error_last[$_fq]}" -eq 1 ]; then
                            _found_qi=$_fq; break
                        fi
                    done
                    [ "$_found_qi" -lt 0 ] && _found_qi=$_fallback
                else
                    for _fq in "${_run_queue[@]}"; do
                        [ "${_job_started[$_fq]}" -eq 1 ] && continue
                        _found_qi=$_fq; break
                    done
                fi
                [ "$_found_qi" -lt 0 ] && continue

                qi=$_found_qi
                _job_started[$qi]=1
                label="${all_labels[$qi]}"
                (
                    rc=0; _st=$(_now_ds)
                    just ${all_cmds[$qi]} > "$logdir/$label.log" 2>&1 || rc=$?
                    _et=$(_now_ds)
                    echo "$((_et - _st)) $rc" > "$logdir/$label.result"
                ) &
                _slot_pids[$_s]=$!
                _slot_labels[$_s]="$label"
                _slot_job[$_s]=$qi
                pids+=($!)
            done

            done_count=0
            for i in "${!all_labels[@]}"; do
                [ "${all_skip[$i]}" -eq 1 ] && continue
                [ -f "$logdir/${all_labels[$i]}.result" ] && done_count=$((done_count + 1))
            done
            [ "$done_count" -eq "$run_n" ] && break
            sleep 0.2
        done

        # Re-check width before printing (terminal may have been resized)
        term_w=$(_term_width)
        max_bar=$((term_w - prefix_w))
        (( max_bar < 10 )) && max_bar=10

        # Print results (scaled bars: longest job fills max_bar)
        _max_dur_ds=1
        for i in "${!all_labels[@]}"; do
            [ "${all_skip[$i]}" -eq 1 ] && continue
            read -r dur_ds _rc < "$logdir/${all_labels[$i]}.result"
            (( dur_ds > _max_dur_ds )) && _max_dur_ds=$dur_ds
        done
        _print_duration_axis "$_max_dur_ds"
        for i in "${!all_labels[@]}"; do
            label="${all_labels[$i]}"
            if [ "${all_sep[$i]}" -eq 1 ]; then
                echo; continue
            fi
            if [ "${all_skip[$i]}" -eq 1 ]; then
                printf "  - %-${label_w}s      - not installed\n" "$label"
            else
                read -r dur_ds rc < "$logdir/$label.result"
                dur_str=$(_fmt_ds "$dur_ds")
                bar_len=$(( dur_ds * max_bar / _max_dur_ds ))
                (( bar_len < 1 )) && bar_len=1
                if [ "$rc" -eq 0 ]; then
                    printf "  ✓ %-${label_w}s %6s %s\n" "$label" "$dur_str" "$(bar "$bar_len")"
                else
                    printf "  ✗ %-${label_w}s %6s %s\n" "$label" "$dur_str" "$(bar "$bar_len")"
                fi
            fi
        done
    fi
else
    # --- Unlimited parallelism (existing behavior) ---

    # Start jobs for runnable entries only
    for i in "${!all_labels[@]}"; do
        [ "${all_skip[$i]}" -eq 1 ] && continue
        label="${all_labels[$i]}"
        (
            rc=0
            _st=$(_now_ds)
            just ${all_cmds[$i]} > "$logdir/$label.log" 2>&1 || rc=$?
            _et=$(_now_ds)
            echo "$((_et - _st)) $rc" > "$logdir/$label.result"
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
        echo  # axis line placeholder
        for i in "${!all_labels[@]}"; do
            echo
            done_flags[$i]=""
            done_durs[$i]=0
            done_rcs[$i]=0
        done

        printf "\033[?25l"  # hide cursor

        while true; do
            # Dynamic terminal width
            _old_tw=$term_w
            term_w=$(_term_width)
            max_bar=$((term_w - prefix_w))
            (( max_bar < 10 )) && max_bar=10
            if (( term_w < _old_tw )); then
                printf "\033[2J\033[H"  # clear screen, cursor to top-left
                for (( _i=0; _i<total+1; _i++ )); do echo; done
            fi

            printf "\033[%dA" "$((total + 1))"  # move up N+1 lines (axis + entries)

            _frame_ds=$(_now_ds)
            # Find max duration for scaling (completed jobs or current elapsed)
            _max_dur_ds=1
            elapsed_ds=$((_frame_ds - global_start_ds))
            for i in "${!all_labels[@]}"; do
                [ "${all_skip[$i]}" -eq 1 ] && continue
                if [ -n "${done_flags[$i]}" ]; then
                    (( done_durs[$i] > _max_dur_ds )) && _max_dur_ds=${done_durs[$i]}
                else
                    (( elapsed_ds > _max_dur_ds )) && _max_dur_ds=$elapsed_ds
                fi
            done

            _print_duration_axis "$_max_dur_ds" 1
            done_count=0
            for i in "${!all_labels[@]}"; do
                label="${all_labels[$i]}"

                if [ "${all_sep[$i]}" -eq 1 ]; then
                    printf "\033[K\n"; continue
                fi
                if [ "${all_skip[$i]}" -eq 1 ]; then
                    printf "  \033[2m- %-${label_w}s      - not installed\033[0m\033[K\n" "$label"
                    continue
                fi

                if [ -z "${done_flags[$i]}" ] && [ -f "$logdir/$label.result" ]; then
                    read -r done_durs[$i] done_rcs[$i] < "$logdir/$label.result"
                    done_flags[$i]=1
                fi

                if [ -n "${done_flags[$i]}" ]; then
                    done_count=$((done_count + 1))
                    dur_ds="${done_durs[$i]}"
                    dur_str=$(_fmt_ds "$dur_ds")
                    bar_len=$(( dur_ds * max_bar / _max_dur_ds ))
                    (( bar_len < 1 )) && bar_len=1
                    if [ "${done_rcs[$i]}" -eq 0 ]; then
                        printf "  \033[32m✓ %-${label_w}s %6s %s\033[0m\033[K\n" "$label" "$dur_str" "$(bar "$bar_len")"
                    else
                        printf "  \033[31m✗ %-${label_w}s %6s %s\033[0m\033[K\n" "$label" "$dur_str" "$(bar "$bar_len")"
                    fi
                else
                    elapsed_ds=$((_frame_ds - global_start_ds))
                    dur_str=$(_fmt_ds "$elapsed_ds")
                    bar_len=$(( elapsed_ds * max_bar / _max_dur_ds ))
                    (( bar_len < 1 )) && bar_len=1
                    c="${spin:frame%${#spin}:1}"
                    printf "  \033[93m%s %-${label_w}s %6s %s\033[0m\033[K\n" "$c" "$label" "$dur_str" "$(bar "$bar_len")"
                fi
            done

            [ "$done_count" -eq "$run_n" ] && break
            frame=$((frame + 1))
            sleep 0.1
        done

        printf "\033[?25h"  # restore cursor
    else
        # Non-interactive (CI, piped): wait then print
        for pid in "${pids[@]}"; do wait "$pid" || true; done

        # Re-check width before printing (terminal may have been resized)
        term_w=$(_term_width)
        max_bar=$((term_w - prefix_w))
        (( max_bar < 10 )) && max_bar=10

        # Find max duration for scaling
        _max_dur_ds=1
        for i in "${!all_labels[@]}"; do
            [ "${all_skip[$i]}" -eq 1 ] && continue
            read -r dur_ds _rc < "$logdir/${all_labels[$i]}.result"
            (( dur_ds > _max_dur_ds )) && _max_dur_ds=$dur_ds
        done

        _print_duration_axis "$_max_dur_ds"
        for i in "${!all_labels[@]}"; do
            label="${all_labels[$i]}"
            if [ "${all_sep[$i]}" -eq 1 ]; then
                echo; continue
            fi
            if [ "${all_skip[$i]}" -eq 1 ]; then
                printf "  - %-${label_w}s      - not installed\n" "$label"
            else
                read -r dur_ds rc < "$logdir/$label.result"
                dur_str=$(_fmt_ds "$dur_ds")
                bar_len=$(( dur_ds * max_bar / _max_dur_ds ))
                (( bar_len < 1 )) && bar_len=1
                if [ "$rc" -eq 0 ]; then
                    printf "  ✓ %-${label_w}s %6s %s\n" "$label" "$dur_str" "$(bar "$bar_len")"
                else
                    printf "  ✗ %-${label_w}s %6s %s\n" "$label" "$dur_str" "$(bar "$bar_len")"
                fi
            fi
        done
    fi
fi

# --- Summary ---
failed=0
wall_ds=0
for i in "${!all_labels[@]}"; do
    [ "${all_skip[$i]}" -eq 1 ] && continue
    label="${all_labels[$i]}"
    read -r dur_ds rc < "$logdir/$label.result"
    (( dur_ds > wall_ds )) && wall_ds=$dur_ds
    [ "$rc" -ne 0 ] && failed=$((failed + 1))
done

passed=$(( run_n - failed ))
# When using slot-based scheduling, wall time is total elapsed (not max individual)
if [ "$max_jobs" -gt 0 ]; then
    wall_ds=$(($(_now_ds) - global_start_ds))
fi
wall_str=$(_fmt_ds "$wall_ds")
skip_msg=""
if [ "$skip_n" -gt 0 ]; then
    skip_msg=", $skip_n not installed"
fi
echo ""
echo "$passed/$run_n passed${skip_msg} ($wall_str wall time)"
echo "Logs: $logdir/"

# --- Write run history (for duration prediction) ---
_hist_line=""
for i in "${!all_labels[@]}"; do
    [ "${all_skip[$i]}" -eq 1 ] && continue
    label="${all_labels[$i]}"
    read -r dur_ds _rc < "$logdir/$label.result"
    _hist_line="${_hist_line}${_hist_line:+ }${label}=${dur_ds}:${_rc}"
done
echo "$_hist_line" >> "$logdir/history.log"
# Keep last 50 runs
if [ -f "$logdir/history.log" ]; then
    tail -50 "$logdir/history.log" > "$logdir/history.log.tmp" && \
        mv "$logdir/history.log.tmp" "$logdir/history.log"
fi

if [ "$failed" -gt 0 ]; then
    echo ""
    for i in "${!all_labels[@]}"; do
        [ "${all_skip[$i]}" -eq 1 ] && continue
        label="${all_labels[$i]}"
        read -r dur_ds rc < "$logdir/$label.result"
        if [ "$rc" -ne 0 ]; then
            echo "=== $label ==="
            cat "$logdir/$label.log"
            echo ""
        fi
    done
    exit 1
fi
