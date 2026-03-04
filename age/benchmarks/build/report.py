#!/usr/bin/env python3
"""Generate a Markdown comparison report with charts from build benchmark results.

Usage:
    uv run --with matplotlib python3 benchmarks/build/report.py
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

RESULTS_DIR = Path(__file__).parent / "results"
REPORTS_DIR = Path(__file__).parent / "reports"
CHARTS_DIR = REPORTS_DIR / "charts"

DISPLAY_NAMES = {
    "ada": "Ada", "c": "C", "cobol": "COBOL",
    "cpp": "C++", "csharp": "C#", "elixir": "Elixir",
    "erlang": "Erlang", "fortran": "Fortran", "fsharp": "F#",
    "gleam": "Gleam", "groovy": "Groovy",
    "haskell": "Haskell", "java": "Java", "kotlin": "Kotlin",
    "ocaml": "OCaml", "rust": "Rust",
    "scala": "Scala", "swift": "Swift", "typescript": "TypeScript",
    "zig": "Zig",
}

ALL_COMPILED = sorted(DISPLAY_NAMES.keys())


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

        if "error" in data:
            print(f"warning: skipping {path.name}: build error recorded", file=sys.stderr)
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

def compute_rankings(results: dict[str, dict]) -> list[dict]:
    """Compute build time rankings, sorted fast to slow."""
    rankings = []
    for lang, data in results.items():
        res = data.get("results", {})
        median = res.get("median_s")
        if median is None:
            continue
        rankings.append({
            "language": lang,
            "display": DISPLAY_NAMES.get(lang, lang),
            "median_s": median,
            "min_s": res.get("min_s", median),
            "max_s": res.get("max_s", median),
        })

    rankings.sort(key=lambda r: r["median_s"])
    if rankings:
        fastest = rankings[0]["median_s"]
        for r in rankings:
            r["vs_fastest"] = r["median_s"] / fastest if fastest > 0 else 1.0
    return rankings


# ---------------------------------------------------------------------------
# Charts
# ---------------------------------------------------------------------------

def _rank_colors(n: int) -> list[tuple[float, float, float]]:
    """Generate a teal-to-red color gradient for n items (fast to slow)."""
    colors = []
    for i in range(n):
        t = i / max(n - 1, 1)
        r = 0.18 + 0.72 * t
        g = 0.70 - 0.45 * t
        b = 0.65 - 0.50 * t
        colors.append((r, g, b))
    return colors


def generate_bar_chart(rankings: list[dict], output_path: Path) -> None:
    """Horizontal bar chart of build times, sorted fast to slow (fastest at top)."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    n = len(rankings)
    height = max(3.0, 0.45 * n + 1.5)
    fig, ax = plt.subplots(figsize=(10, height))

    labels = [r["display"] for r in reversed(rankings)]
    values = [r["median_s"] for r in reversed(rankings)]
    colors = list(reversed(_rank_colors(n)))

    bars = ax.barh(range(n), values, color=colors, edgecolor="white", linewidth=0.5)
    ax.set_yticks(range(n))
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel("Clean build time (seconds)", fontsize=10)
    ax.set_title("Build Time Ranking", fontsize=12, fontweight="bold", pad=12)
    ax.invert_yaxis()

    max_val = max(values) if values else 1
    for i, (bar, val) in enumerate(zip(bars, values)):
        label = f" {val:.1f}s"
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


# ---------------------------------------------------------------------------
# Markdown generation
# ---------------------------------------------------------------------------

def _ranking_table(rankings: list[dict]) -> str:
    """Build a Markdown table from ranking data."""
    lines = [
        "| Rank | Language | Median | Min | Max | vs Fastest |",
        "| ---: | -------- | -----: | --: | --: | ---------: |",
    ]
    for i, r in enumerate(rankings, 1):
        vs = f"{r['vs_fastest']:.1f}x"
        lines.append(
            f"| {i} | {r['display']} | {r['median_s']:.1f}s | "
            f"{r['min_s']:.1f}s | {r['max_s']:.1f}s | {vs} |"
        )
    return "\n".join(lines)


def generate_report(results: dict[str, dict]) -> str:
    """Build full Markdown report string."""
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    lang_count = len(results)

    first = next(iter(results.values()))
    sys_info = first.get("meta", {}).get("system", {})
    config = first.get("config", {})
    system_line = (
        f"{sys_info.get('cpu', 'Unknown')} · {sys_info.get('os', 'Unknown')} · "
        f"{sys_info.get('arch', 'Unknown')} · {sys_info.get('cpu_cores', '?')} cores · "
        f"{sys_info.get('memory_gb', '?')} GB RAM"
    )

    lines = [
        "# Build Benchmark Report",
        "",
        f"Generated: {now}  ",
        f"System: {system_line}  ",
        f"Languages: {lang_count}",
        "",
    ]

    warning = validate_system_info(results)
    if warning:
        lines.extend([
            "> **Warning:** " + warning,
            "> Results may not be directly comparable.",
            "",
        ])

    rankings = compute_rankings(results)

    lines.extend([
        "## Build Time Ranking",
        "",
        "Clean build time (median of 3 iterations).",
        "",
        "![Build Time Ranking](charts/build-ranking.png)",
        "",
        _ranking_table(rankings),
        "",
    ])

    lines.extend([
        "## Configuration",
        "",
        "| Parameter | Value |",
        "| --------- | ----: |",
        f"| Iterations | {config.get('iterations', 0)} |",
        f"| Type | {config.get('type', 'clean_build')} |",
        "",
    ])

    lines.extend([
        "## Language Versions",
        "",
        "| Language | Version |",
        "| -------- | ------- |",
    ])
    for r in rankings:
        lang = r["language"]
        version = results[lang].get("meta", {}).get("language_version", "?")
        lines.append(f"| {r['display']} | {version} |")
    lines.append("")

    present = set(results.keys())
    missing = sorted(set(ALL_COMPILED) - present)
    if missing:
        lines.extend([
            "## Missing Languages",
            "",
            "No build benchmark results found for:",
            "",
        ])
        for lang in missing:
            lines.append(f"- {DISPLAY_NAMES.get(lang, lang)}")
        lines.append("")

    lines.extend([
        "---",
        "",
        f"*Report generated by `benchmarks/build/report.py` on {now}.*",
        "",
    ])

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    results = load_latest_results()
    if not results:
        print("error: no build benchmark results found in", RESULTS_DIR, file=sys.stderr)
        print("Run 'just benchmark build' first to generate results.", file=sys.stderr)
        sys.exit(1)

    lang_count = len(results)
    print(f"Loaded results for {lang_count} language{'s' if lang_count != 1 else ''}:")
    for lang in sorted(results.keys()):
        ts = results[lang]["meta"]["timestamp"]
        median = results[lang]["results"]["median_s"]
        print(f"  {DISPLAY_NAMES.get(lang, lang):12s}  {median:.1f}s  ({ts})")

    warning = validate_system_info(results)
    if warning:
        print(f"\nwarning: {warning}", file=sys.stderr)

    CHARTS_DIR.mkdir(parents=True, exist_ok=True)

    rankings = compute_rankings(results)

    print("\nGenerating chart...")
    generate_bar_chart(rankings, CHARTS_DIR / "build-ranking.png")
    print(f"  1 chart → {CHARTS_DIR}/")

    print("Generating report...")
    report = generate_report(results)
    report_path = REPORTS_DIR / "report.md"
    report_path.write_text(report)
    print(f"  report → {report_path}")

    print("Done.")


if __name__ == "__main__":
    main()
