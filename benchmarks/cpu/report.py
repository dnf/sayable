#!/usr/bin/env python3
"""Generate a Markdown comparison report with charts from benchmark results.

Usage:
    uv run --with matplotlib python3 benchmarks/cpu/report.py
"""
from __future__ import annotations

import json
import math
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

RESULTS_DIR = Path(__file__).parent / "results"
REPORTS_DIR = Path(__file__).parent / "reports"
CHARTS_DIR = REPORTS_DIR / "charts"

SCENARIOS = {
    "B1":  ("format_age",   "en", "Days tier (3 days)"),
    "B2":  ("format_age",   "en", "Weeks+days (6w3d)"),
    "B3":  ("format_age",   "en", "Months (5 months)"),
    "B4":  ("format_age",   "en", "Years+months (2y3m)"),
    "B5":  ("format_age",   "en", "Half-year (4\u00bd years)"),
    "B6":  ("format_age",   "en", "Years (10 years)"),
    "B7":  ("format_age",   "ar", "Arabic plural (complex)"),
    "B8":  ("format_age",   "ja", "Japanese (other-only)"),
    "B9":  ("format_age",   "pl", "Polish plural (Slavic)"),
    "B10": ("format_age",   "ru", "Russian plural (Slavic)"),
    "B11": ("format_age",   "de", "German (one/other)"),
    "B12": ("format_age",   "zh", "Chinese (other-only)"),
    "B13": ("format_stage", "en", "Newborn stage"),
    "B14": ("format_stage", "en", "Toddler stage"),
    "B15": ("format_stage", "en", "Child stage"),
}

SCENARIO_GROUPS = {
    "overall":    list(SCENARIOS.keys()),
    "english":    ["B1", "B2", "B3", "B4", "B5", "B6"],
    "i18n":       ["B7", "B8", "B9", "B10", "B11", "B12"],
    "stage":      ["B13", "B14", "B15"],
}

DISPLAY_NAMES = {
    "ada": "Ada", "c": "C", "clojure": "Clojure", "cobol": "COBOL",
    "cpp": "C++", "csharp": "C#", "dart": "Dart", "elixir": "Elixir",
    "erlang": "Erlang", "fortran": "Fortran", "fsharp": "F#",
    "gleam": "Gleam", "go": "Go", "groovy": "Groovy",
    "haskell": "Haskell", "java": "Java", "kotlin": "Kotlin",
    "lua": "Lua", "ocaml": "OCaml", "perl": "Perl", "php": "PHP",
    "python": "Python", "ruby": "Ruby", "rust": "Rust",
    "scala": "Scala", "swift": "Swift", "typescript": "TypeScript",
    "zig": "Zig",
}

ALL_LANGUAGES = sorted(DISPLAY_NAMES.keys())


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_latest_results() -> dict[str, dict]:
    """Scan results/*.json, group by language, pick the latest per language."""
    if not RESULTS_DIR.is_dir():
        return {}

    by_language: dict[str, list[tuple[str, Path]]] = {}
    for path in sorted(RESULTS_DIR.glob("*.json")):
        try:
            with open(path) as f:
                data = json.load(f)
        except (json.JSONDecodeError, OSError) as exc:
            print(f"warning: skipping {path.name}: {exc}", file=sys.stderr)
            continue

        lang = data.get("meta", {}).get("language", "")
        ts = data.get("meta", {}).get("timestamp", "")
        if not lang or not ts:
            print(f"warning: skipping {path.name}: missing meta fields", file=sys.stderr)
            continue

        by_language.setdefault(lang, []).append((ts, path))

    results = {}
    for lang, entries in by_language.items():
        entries.sort(key=lambda e: e[0])
        latest_path = entries[-1][1]
        with open(latest_path) as f:
            results[lang] = json.load(f)

    return results


def validate_system_info(results: dict[str, dict]) -> str | None:
    """Check all results came from the same machine. Return warning or None."""
    systems = set()
    for data in results.values():
        sys_info = data.get("meta", {}).get("system", {})
        key = (sys_info.get("cpu", ""), sys_info.get("os", ""), sys_info.get("arch", ""))
        systems.add(key)

    if len(systems) > 1:
        details = "; ".join(f"{cpu} / {os} / {arch}" for cpu, os, arch in sorted(systems))
        return f"Results come from different systems: {details}"
    return None


# ---------------------------------------------------------------------------
# Ranking computation
# ---------------------------------------------------------------------------

def compute_rankings(
    results: dict[str, dict],
    scenario_ids: list[str],
) -> list[dict]:
    """Compute mean median_ms across given scenarios per language, sorted fast to slow."""
    rankings = []
    for lang, data in results.items():
        scenario_map = {r["id"]: r for r in data.get("results", [])}
        values = []
        for sid in scenario_ids:
            entry = scenario_map.get(sid)
            if entry and entry.get("median_ms") is not None:
                values.append(entry["median_ms"])

        if not values:
            continue

        mean_ms = sum(values) / len(values)
        measured_calls = data.get("config", {}).get("measured_calls", 100_000)
        ops = int(measured_calls / (mean_ms / 1000)) if mean_ms > 0 else 0
        rankings.append({
            "language": lang,
            "display": DISPLAY_NAMES.get(lang, lang),
            "mean_ms": mean_ms,
            "ops_per_sec": ops,
            "scenarios_counted": len(values),
            "scenarios_total": len(scenario_ids),
        })

    rankings.sort(key=lambda r: r["mean_ms"])
    if rankings:
        fastest = rankings[0]["mean_ms"]
        for r in rankings:
            r["vs_fastest"] = r["mean_ms"] / fastest if fastest > 0 else 1.0
    return rankings


# ---------------------------------------------------------------------------
# Charts
# ---------------------------------------------------------------------------

def _rank_colors(n: int) -> list[tuple[float, float, float]]:
    """Generate a teal-to-red color gradient for n items (fast→slow)."""
    colors = []
    for i in range(n):
        t = i / max(n - 1, 1)
        r = 0.18 + 0.72 * t
        g = 0.70 - 0.45 * t
        b = 0.65 - 0.50 * t
        colors.append((r, g, b))
    return colors


def _format_ops(ops: int) -> str:
    """Format ops/sec for bar labels: '6.7M' or '512K'."""
    if ops >= 1_000_000:
        return f"{ops / 1_000_000:.1f}M"
    if ops >= 1_000:
        return f"{ops / 1_000:.0f}K"
    return str(ops)


def generate_bar_chart(
    rankings: list[dict],
    title: str,
    output_path: Path,
) -> None:
    """Horizontal bar chart, sorted fast→slow (fastest at top)."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    n = len(rankings)
    height = max(3.0, 0.45 * n + 1.5)
    fig, ax = plt.subplots(figsize=(10, height))

    labels = [r["display"] for r in reversed(rankings)]
    values = [r["mean_ms"] for r in reversed(rankings)]
    ops_labels = [_format_ops(r["ops_per_sec"]) for r in reversed(rankings)]
    colors = list(reversed(_rank_colors(n)))

    bars = ax.barh(range(n), values, color=colors, edgecolor="white", linewidth=0.5)
    ax.set_yticks(range(n))
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel("Mean time per 100K calls (ms)", fontsize=10)
    ax.set_title(title, fontsize=12, fontweight="bold", pad=12)
    ax.invert_yaxis()

    max_val = max(values) if values else 1
    for i, (bar, val, ops) in enumerate(zip(bars, values, ops_labels)):
        label = f" {val:.1f} ms ({ops} ops/s)"
        text_x = bar.get_width()
        if text_x < max_val * 0.6:
            ax.text(text_x + max_val * 0.01, i, label, va="center", fontsize=8)
        else:
            ax.text(text_x - max_val * 0.01, i, label, va="center", ha="right",
                    fontsize=8, color="white")

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    fig.tight_layout()
    fig.savefig(output_path, dpi=150, facecolor="white")
    plt.close(fig)


def generate_heatmap(
    results: dict[str, dict],
    ranking_order: list[str],
    output_path: Path,
) -> None:
    """Heatmap: scenarios (columns) × languages (rows), normalized per column."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.colors as mcolors

    scenario_ids = list(SCENARIOS.keys())
    langs = ranking_order

    grid: list[list[float | None]] = []
    for lang in langs:
        data = results.get(lang, {})
        scenario_map = {r["id"]: r for r in data.get("results", [])}
        row = []
        for sid in scenario_ids:
            entry = scenario_map.get(sid)
            row.append(entry["median_ms"] if entry and entry.get("median_ms") is not None else None)
        grid.append(row)

    col_min = []
    col_max = []
    for col in range(len(scenario_ids)):
        vals = [grid[row][col] for row in range(len(langs)) if grid[row][col] is not None]
        col_min.append(min(vals) if vals else 0)
        col_max.append(max(vals) if vals else 1)

    normalized: list[list[float]] = []
    for row in grid:
        norm_row = []
        for col, val in enumerate(row):
            if val is None:
                norm_row.append(float("nan"))
            else:
                span = col_max[col] - col_min[col]
                norm_row.append((val - col_min[col]) / span if span > 0 else 0.0)
        normalized.append(norm_row)

    n_langs = len(langs)
    n_scenarios = len(scenario_ids)
    cell_w, cell_h = 0.6, 0.4
    fig_w = max(10, n_scenarios * cell_w + 3)
    fig_h = max(4, n_langs * cell_h + 2)
    fig, ax = plt.subplots(figsize=(fig_w, fig_h))

    cmap = plt.cm.RdYlGn_r  # type: ignore[attr-defined]
    cmap.set_bad(color="lightgray")

    import numpy as np
    data_array = np.array(normalized)

    im = ax.imshow(data_array, aspect="auto", cmap=cmap, vmin=0, vmax=1)

    ax.set_xticks(range(n_scenarios))
    ax.set_xticklabels(scenario_ids, fontsize=8, rotation=45, ha="right")
    ax.set_yticks(range(n_langs))
    ax.set_yticklabels([DISPLAY_NAMES.get(l, l) for l in langs], fontsize=8)

    for row_i in range(n_langs):
        for col_i in range(n_scenarios):
            val = grid[row_i][col_i]
            if val is not None:
                norm = normalized[row_i][col_i]
                text_color = "white" if norm > 0.6 else "black"
                ax.text(col_i, row_i, f"{val:.1f}", ha="center", va="center",
                        fontsize=6, color=text_color)

    ax.set_title("Scenario Heatmap (ms per 100K calls)", fontsize=12, fontweight="bold", pad=12)
    cbar = fig.colorbar(im, ax=ax, fraction=0.02, pad=0.04)
    cbar.set_label("Relative (0=fastest, 1=slowest per scenario)", fontsize=8)

    fig.tight_layout()
    fig.savefig(output_path, dpi=150, facecolor="white")
    plt.close(fig)


# ---------------------------------------------------------------------------
# Markdown generation
# ---------------------------------------------------------------------------

def _format_number(n: int) -> str:
    """Format integer with comma separators."""
    return f"{n:,}"


def _ranking_table(rankings: list[dict]) -> str:
    """Build a Markdown table from ranking data."""
    lines = ["| Rank | Language | Mean (ms) | Throughput | vs Fastest |",
             "| ---: | -------- | --------: | ---------: | ---------: |"]
    for i, r in enumerate(rankings, 1):
        ops = _format_ops(r["ops_per_sec"])
        vs = f"{r['vs_fastest']:.1f}x"
        lines.append(
            f"| {i} | {r['display']} | {r['mean_ms']:.1f} | "
            f"{ops} ops/s | {vs} |"
        )
    return "\n".join(lines)


def _scenario_detail_table(results: dict[str, dict], ranking_order: list[str],
                           scenario_ids: list[str]) -> str:
    """Collapsible per-scenario detail table."""
    lines = ["<details>", "<summary>Per-scenario breakdown</summary>", ""]

    header = "| Language |"
    sep = "| -------- |"
    for sid in scenario_ids:
        header += f" {sid} |"
        sep += " ---: |"
    lines.append(header)
    lines.append(sep)

    for lang in ranking_order:
        data = results.get(lang, {})
        scenario_map = {r["id"]: r for r in data.get("results", [])}
        row = f"| {DISPLAY_NAMES.get(lang, lang)} |"
        for sid in scenario_ids:
            entry = scenario_map.get(sid)
            if entry and entry.get("median_ms") is not None:
                row += f" {entry['median_ms']:.1f} |"
            else:
                row += " — |"
        lines.append(row)

    lines.extend(["", "</details>"])
    return "\n".join(lines)


def generate_report(results: dict[str, dict]) -> str:
    """Build full Markdown report string."""
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    lang_count = len(results)

    # System info from first result
    first = next(iter(results.values()))
    sys_info = first.get("meta", {}).get("system", {})
    config = first.get("config", {})
    system_line = (f"{sys_info.get('cpu', 'Unknown')} · {sys_info.get('os', 'Unknown')} · "
                   f"{sys_info.get('arch', 'Unknown')} · {sys_info.get('cpu_cores', '?')} cores · "
                   f"{sys_info.get('memory_gb', '?')} GB RAM")

    lines = [
        f"# Benchmark Report",
        "",
        f"Generated: {now}  ",
        f"System: {system_line}  ",
        f"Languages: {lang_count}",
        "",
    ]

    # System mismatch warning
    warning = validate_system_info(results)
    if warning:
        lines.extend([
            "> **Warning:** " + warning,
            "> Results may not be directly comparable.",
            "",
        ])

    # Overall ranking
    overall = compute_rankings(results, SCENARIO_GROUPS["overall"])
    overall_order = [r["language"] for r in overall]
    lines.extend([
        "## Overall Ranking",
        "",
        "Mean across all 15 scenarios (B1–B15).",
        "",
        "![Overall Ranking](charts/overall-ranking.png)",
        "",
        _ranking_table(overall),
        "",
    ])

    # Group sections
    group_configs = [
        ("english", "format_age — English (B1–B6)",
         "English locale across all age tiers.",
         "format-age-english.png"),
        ("i18n", "format_age — Cross-Locale (B7–B12)",
         "Complex plural rules across 6 locales (Arabic, Japanese, Polish, Russian, German, Chinese).",
         "format-age-i18n.png"),
        ("stage", "format_stage (B13–B15)",
         "Stage lookup with English locale (newborn, toddler, child).",
         "format-stage.png"),
    ]

    for group_key, heading, description, chart_name in group_configs:
        scenario_ids = SCENARIO_GROUPS[group_key]
        group_rankings = compute_rankings(results, scenario_ids)
        group_order = [r["language"] for r in group_rankings]
        lines.extend([
            f"## {heading}",
            "",
            description,
            "",
            f"![{heading}](charts/{chart_name})",
            "",
            _ranking_table(group_rankings),
            "",
            _scenario_detail_table(results, group_order, scenario_ids),
            "",
        ])

    # Heatmap
    lines.extend([
        "## Scenario Heatmap",
        "",
        "All 15 scenarios × all languages. Colors normalized per column (green=fastest, red=slowest).",
        "",
        "![Scenario Heatmap](charts/scenario-heatmap.png)",
        "",
    ])

    # Configuration
    lines.extend([
        "## Configuration",
        "",
        "| Parameter | Value |",
        "| --------- | ----: |",
        f"| Warmup calls | {_format_number(config.get('warmup_calls', 0))} |",
        f"| Measured calls | {_format_number(config.get('measured_calls', 0))} |",
        f"| Iterations | {config.get('iterations', 0)} |",
        "",
    ])

    # Language versions
    lines.extend([
        "## Language Versions",
        "",
        "| Language | Version |",
        "| -------- | ------- |",
    ])
    for lang in overall_order:
        data = results[lang]
        version = data.get("meta", {}).get("language_version", "?")
        lines.append(f"| {DISPLAY_NAMES.get(lang, lang)} | {version} |")
    lines.append("")

    # Missing languages
    present = set(results.keys())
    missing = sorted(set(ALL_LANGUAGES) - present)
    if missing:
        lines.extend([
            "## Missing Languages",
            "",
            "No benchmark results found for:",
            "",
        ])
        for lang in missing:
            lines.append(f"- {DISPLAY_NAMES.get(lang, lang)}")
        lines.append("")

    # Footer
    lines.extend([
        "---",
        "",
        f"*Report generated by `benchmarks/cpu/report.py` on {now}.*",
        "",
    ])

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    results = load_latest_results()
    if not results:
        print("error: no benchmark results found in", RESULTS_DIR, file=sys.stderr)
        print("Run 'just benchmark cpu' first to generate results.", file=sys.stderr)
        sys.exit(1)

    lang_count = len(results)
    print(f"Loaded results for {lang_count} language{'s' if lang_count != 1 else ''}:")
    for lang in sorted(results.keys()):
        ts = results[lang]["meta"]["timestamp"]
        print(f"  {DISPLAY_NAMES.get(lang, lang):12s}  {ts}")

    warning = validate_system_info(results)
    if warning:
        print(f"\nwarning: {warning}", file=sys.stderr)

    CHARTS_DIR.mkdir(parents=True, exist_ok=True)

    overall = compute_rankings(results, SCENARIO_GROUPS["overall"])
    overall_order = [r["language"] for r in overall]

    print("\nGenerating charts...")
    generate_bar_chart(overall, "Overall Ranking (B1–B15)", CHARTS_DIR / "overall-ranking.png")

    for group_key, title, chart_name in [
        ("english", "format_age — English (B1–B6)", "format-age-english.png"),
        ("i18n", "format_age — Cross-Locale (B7–B12)", "format-age-i18n.png"),
        ("stage", "format_stage (B13–B15)", "format-stage.png"),
    ]:
        group_rankings = compute_rankings(results, SCENARIO_GROUPS[group_key])
        generate_bar_chart(group_rankings, title, CHARTS_DIR / chart_name)

    generate_heatmap(results, overall_order, CHARTS_DIR / "scenario-heatmap.png")
    print(f"  5 charts → {CHARTS_DIR}/")

    print("Generating report...")
    report = generate_report(results)
    report_path = REPORTS_DIR / "report.md"
    report_path.write_text(report)
    print(f"  report → {report_path}")

    print("Done.")


if __name__ == "__main__":
    main()
