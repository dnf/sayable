#!/usr/bin/env python3
"""Generate locale coverage maps and documentation.

Usage:
    uv run --with geopandas --with matplotlib python3 tools/geography/generate.py
    uv run --with geopandas --with matplotlib python3 tools/geography/generate.py --check
"""

from __future__ import annotations

import json
import os
import sys

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
_COUNTRIES_JSON = os.path.join(_TOOLS_DIR, "countries.json")
_GEOJSON = os.path.join(_TOOLS_DIR, "data", "ne_110m.geojson")
_DOCS_DIR = os.path.join(_ROOT, "docs", "geography")
_ASSETS_DIR = os.path.join(_DOCS_DIR, "assets")

_COMPONENTS = ["age", "date", "duration", "time"]
_LOCALE_SUBDIR = os.path.join("locales", "src")

# ---------------------------------------------------------------------------
# GeoJSON ISO code overrides (Natural Earth quirks)
# ---------------------------------------------------------------------------

# Some features have -99 or non-standard ISO_A2 codes.  We resolve them
# by checking ISO_A2_EH first, then falling back to a name-based table.
_ISO_OVERRIDES: dict[str, str] = {
    "France": "FR",
    "Norway": "NO",
    "Kosovo": "XK",
    "Northern Cyprus": "CY",  # treat as Cyprus
    "Somaliland": "SO",  # treat as Somalia
    "Taiwan": "TW",
}

# ---------------------------------------------------------------------------
# Color scheme (5-bin discrete)
# ---------------------------------------------------------------------------

_BINS = [
    (0.00, 0.00, "#e0e0e0", "No coverage"),
    (0.01, 0.25, "#c7e9c0", "Minimal (1–25%)"),
    (0.26, 0.50, "#74c476", "Partial (26–50%)"),
    (0.51, 0.75, "#31a354", "Good (51–75%)"),
    (0.76, 1.00, "#006d2c", "High (76–100%)"),
]

_NO_DATA_COLOR = "#ffffff"

# ---------------------------------------------------------------------------
# Continent zoom extents (lon_min, lon_max, lat_min, lat_max)
# ---------------------------------------------------------------------------

_CONTINENT_BOUNDS: dict[str, tuple[float, float, float, float]] = {
    "Africa": (-25, 55, -37, 40),
    "Asia": (25, 150, -12, 55),
    "Europe": (-25, 50, 34, 72),
    "North America": (-170, -50, 5, 85),
    "South America": (-90, -30, -58, 15),
    "Oceania": (100, 180, -50, 5),
}

_CONTINENT_SLUGS: dict[str, str] = {
    "Africa": "africa",
    "Asia": "asia",
    "Europe": "europe",
    "North America": "north-america",
    "South America": "south-america",
    "Oceania": "oceania",
}


# ---------------------------------------------------------------------------
# 1. Discover supported locales across all components
# ---------------------------------------------------------------------------

def _discover_locales() -> dict[str, set[str]]:
    """Return {component: set of locale codes} for each component."""
    result: dict[str, set[str]] = {}
    for comp in _COMPONENTS:
        locale_dir = os.path.join(_ROOT, comp, _LOCALE_SUBDIR)
        if os.path.isdir(locale_dir):
            codes = set()
            for f in os.listdir(locale_dir):
                if f.endswith(".json"):
                    codes.add(f.removesuffix(".json"))
            result[comp] = codes
        else:
            result[comp] = set()
    return result


def _all_supported_codes(locales: dict[str, set[str]]) -> set[str]:
    """Union of all locale codes across components."""
    codes: set[str] = set()
    for s in locales.values():
        codes |= s
    return codes


# ---------------------------------------------------------------------------
# 2. Load country data
# ---------------------------------------------------------------------------

def _load_countries() -> dict[str, dict]:
    """Load countries.json and return {ISO: country_dict}."""
    with open(_COUNTRIES_JSON, encoding="utf-8") as f:
        data = json.load(f)
    return data["countries"]


# ---------------------------------------------------------------------------
# 3. Coverage calculation
# ---------------------------------------------------------------------------

def _coverage(country: dict, supported: set[str]) -> float:
    """Fraction of population covered (capped at 1.0)."""
    total = sum(
        lang["proportion"]
        for lang in country["languages"]
        if lang["code"] in supported
    )
    return min(total, 1.0)


def _coverage_bin(value: float) -> tuple[str, str]:
    """Return (color, label) for a coverage value."""
    for lo, hi, color, label in _BINS:
        if lo <= value <= hi:
            return color, label
    return _BINS[-1][1], _BINS[-1][2]


# ---------------------------------------------------------------------------
# 4. GeoJSON loading + coverage join
# ---------------------------------------------------------------------------

def _resolve_iso(props: dict) -> str:
    """Resolve a feature's ISO code from Natural Earth properties."""
    iso = props.get("ISO_A2", "")
    if iso not in ("-99", "CN-TW"):
        return iso
    # Try ISO_A2_EH
    iso_eh = props.get("ISO_A2_EH", "")
    if iso_eh not in ("-99", ""):
        return iso_eh
    # Fall back to name-based override
    admin = props.get("ADMIN", "")
    return _ISO_OVERRIDES.get(admin, "")


def _load_geodata(countries: dict[str, dict], supported: set[str]):
    """Load GeoJSON into a GeoDataFrame with coverage column."""
    import geopandas as gpd

    gdf = gpd.read_file(_GEOJSON)

    # Add resolved ISO and coverage columns
    isos = []
    coverages = []
    for _, row in gdf.iterrows():
        iso = _resolve_iso(row)
        isos.append(iso)
        if iso in countries:
            coverages.append(_coverage(countries[iso], supported))
        else:
            coverages.append(None)

    gdf["iso_resolved"] = isos
    gdf["coverage"] = coverages
    return gdf


# ---------------------------------------------------------------------------
# 5. Map rendering
# ---------------------------------------------------------------------------

def _render_map(
    gdf,
    output_path: str,
    bounds: tuple[float, float, float, float] | None = None,
    figsize: tuple[int, int] = (16, 8),
    title: str | None = None,
):
    """Render a choropleth PNG."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Patch
    import numpy as np

    fig, ax = plt.subplots(1, 1, figsize=figsize, facecolor="white")

    # Draw countries with no data (white)
    no_data = gdf[gdf["coverage"].isna()]
    if not no_data.empty:
        no_data.plot(ax=ax, color=_NO_DATA_COLOR, edgecolor="#cccccc", linewidth=0.3)

    # Draw countries by coverage bin
    has_data = gdf[gdf["coverage"].notna()].copy()
    if not has_data.empty:
        colors = []
        for val in has_data["coverage"]:
            color, _ = _coverage_bin(val)
            colors.append(color)
        has_data = has_data.copy()
        has_data["fill_color"] = colors
        has_data.plot(ax=ax, color=has_data["fill_color"], edgecolor="#999999", linewidth=0.3)

    # Zoom to bounds
    if bounds:
        ax.set_xlim(bounds[0], bounds[1])
        ax.set_ylim(bounds[2], bounds[3])

    # Legend
    legend_elements = [
        Patch(facecolor=color, edgecolor="#999999", label=label)
        for _, _, color, label in _BINS
    ]
    legend_elements.append(
        Patch(facecolor=_NO_DATA_COLOR, edgecolor="#cccccc", label="No data")
    )
    ax.legend(
        handles=legend_elements,
        loc="lower left",
        fontsize=8,
        framealpha=0.9,
    )

    if title:
        ax.set_title(title, fontsize=14, fontweight="bold", pad=10)

    ax.set_axis_off()
    fig.tight_layout(pad=0.5)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    fig.savefig(output_path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)


# ---------------------------------------------------------------------------
# 6. Markdown generation
# ---------------------------------------------------------------------------

def _pct(value: float | None) -> str:
    """Format a coverage value as a percentage string."""
    if value is None:
        return "—"
    return f"{value * 100:.0f}%"


def _covered_languages(country: dict, supported: set[str]) -> str:
    """List covered languages with proportions."""
    parts = []
    for lang in country["languages"]:
        if lang["code"] in supported:
            parts.append(f"{lang['name']} ({lang['proportion'] * 100:.0f}%)")
    return ", ".join(parts) if parts else "—"


def _uncovered_languages(country: dict, supported: set[str]) -> str:
    """List uncovered languages with proportions."""
    parts = []
    for lang in country["languages"]:
        if lang["code"] not in supported:
            parts.append(f"{lang['name']} ({lang['proportion'] * 100:.0f}%)")
    return ", ".join(parts) if parts else "—"


def _generate_readme(
    countries: dict[str, dict],
    supported: set[str],
    locales: dict[str, set[str]],
) -> str:
    """Generate docs/geography/README.md content."""
    lines: list[str] = []
    lines.append("<!-- Generated by tools/geography/generate.py — do not edit by hand -->\n")
    lines.append("\n")
    lines.append("# Locale Coverage\n")
    lines.append("\n")
    lines.append("How well do Sayable's locales cover the world's languages?\n")
    lines.append("\n")
    lines.append("![World locale coverage](assets/world.png)\n")
    lines.append("\n")

    # Compute global stats
    coverages = {
        iso: _coverage(c, supported) for iso, c in countries.items()
    }
    total = len(coverages)
    full = sum(1 for v in coverages.values() if v >= 1.0)
    high = sum(1 for v in coverages.values() if v >= 0.76)
    good = sum(1 for v in coverages.values() if v >= 0.51)
    some = sum(1 for v in coverages.values() if v > 0)
    none = sum(1 for v in coverages.values() if v == 0)

    lines.append("## Global Summary\n")
    lines.append("\n")
    lines.append("| Metric | Count |\n")
    lines.append("|--------|------:|\n")
    lines.append(f"| Countries tracked | {total} |\n")
    lines.append(f"| 100% coverage | {full} |\n")
    lines.append(f"| 76–100% (high) | {high} |\n")
    lines.append(f"| 51–75% (good) | {good} |\n")
    lines.append(f"| 1–50% (some) | {some - good} |\n")
    lines.append(f"| 0% (none) | {none} |\n")
    lines.append("\n")

    # Continent summary
    continents: dict[str, list[tuple[str, float]]] = {}
    for iso, country in countries.items():
        continent = country["continent"]
        if continent not in _CONTINENT_SLUGS:
            continue
        continents.setdefault(continent, []).append((iso, coverages[iso]))

    lines.append("## By Continent\n")
    lines.append("\n")
    lines.append("| Continent | Countries | Avg Coverage | Details |\n")
    lines.append("|-----------|----------:|-------------:|--------:|\n")
    for continent in sorted(_CONTINENT_SLUGS.keys()):
        if continent not in continents:
            continue
        pairs = continents[continent]
        count = len(pairs)
        avg = sum(v for _, v in pairs) / count if count else 0
        slug = _CONTINENT_SLUGS[continent]
        lines.append(
            f"| {continent} | {count} | {avg * 100:.0f}% | [{continent}]({slug}.md) |\n"
        )
    lines.append("\n")

    # Locale inventory
    all_codes = sorted(supported)
    lines.append(f"## Supported Locales ({len(all_codes)})\n")
    lines.append("\n")

    # Read locale names from JSON files
    locale_names: dict[str, str] = {}
    for comp in _COMPONENTS:
        locale_dir = os.path.join(_ROOT, comp, _LOCALE_SUBDIR)
        if os.path.isdir(locale_dir):
            for code in all_codes:
                if code in locale_names:
                    continue
                path = os.path.join(locale_dir, f"{code}.json")
                if os.path.exists(path):
                    with open(path, encoding="utf-8") as f:
                        data = json.load(f)
                    locale_names[code] = data.get("name", code)

    # Which components have each locale
    lines.append("| Code | Name | Components |\n")
    lines.append("|------|------|------------|\n")
    for code in all_codes:
        name = locale_names.get(code, code)
        comps = [c for c in _COMPONENTS if code in locales.get(c, set())]
        comp_str = ", ".join(comps)
        lines.append(f"| `{code}` | {name} | {comp_str} |\n")
    lines.append("\n")

    lines.append("---\n")
    lines.append("\n")
    lines.append("*Generated by `tools/geography/generate.py` from data in "
                 "`tools/geography/countries.json`.*\n")

    return "".join(lines)


def _generate_continent(
    continent: str,
    countries: dict[str, dict],
    supported: set[str],
) -> str:
    """Generate a continent detail markdown file."""
    slug = _CONTINENT_SLUGS[continent]
    lines: list[str] = []
    lines.append("<!-- Generated by tools/geography/generate.py — do not edit by hand -->\n")
    lines.append("\n")
    lines.append(f"# {continent}\n")
    lines.append("\n")
    lines.append("[Back to Locale Coverage](README.md)\n")
    lines.append("\n")
    lines.append(f"![{continent} locale coverage](assets/{slug}.png)\n")
    lines.append("\n")

    # Filter countries for this continent
    continent_countries = {
        iso: c for iso, c in countries.items()
        if c["continent"] == continent
    }

    coverages = {
        iso: _coverage(c, supported) for iso, c in continent_countries.items()
    }

    count = len(continent_countries)
    avg = sum(coverages.values()) / count if count else 0

    lines.append("## Summary\n")
    lines.append("\n")
    lines.append(f"- **Countries**: {count}\n")
    lines.append(f"- **Average coverage**: {avg * 100:.0f}%\n")
    lines.append("\n")

    # Country table sorted by name
    sorted_countries = sorted(
        continent_countries.items(), key=lambda x: x[1]["name"]
    )

    lines.append("## Countries\n")
    lines.append("\n")
    lines.append("| Country | Coverage | Covered Languages | Uncovered Languages |\n")
    lines.append("|---------|:--------:|-------------------|---------------------|\n")
    for iso, country in sorted_countries:
        cov = coverages[iso]
        covered = _covered_languages(country, supported)
        uncovered = _uncovered_languages(country, supported)
        lines.append(
            f"| {country['name']} | {_pct(cov)} | {covered} | {uncovered} |\n"
        )
    lines.append("\n")

    lines.append("---\n")
    lines.append("\n")
    lines.append("*Generated by `tools/geography/generate.py`.*\n")

    return "".join(lines)


# ---------------------------------------------------------------------------
# 7. Main
# ---------------------------------------------------------------------------

def _check_markdown(expected: str, path: str) -> bool:
    """Return True if the file matches expected content."""
    if not os.path.exists(path):
        print(f"MISSING: {os.path.relpath(path, _ROOT)}")
        return False
    with open(path, encoding="utf-8") as f:
        actual = f.read()
    if actual != expected:
        print(f"OUT OF DATE: {os.path.relpath(path, _ROOT)}")
        return False
    return True


def main() -> None:
    check = "--check" in sys.argv

    # 1. Discover locales
    locales = _discover_locales()
    supported = _all_supported_codes(locales)
    print(f"Found {len(supported)} locale codes across {len(locales)} components")

    # 2. Load country data
    countries = _load_countries()
    print(f"Loaded {len(countries)} countries")

    # 3. Compute coverage
    coverages = {iso: _coverage(c, supported) for iso, c in countries.items()}
    avg = sum(coverages.values()) / len(coverages) if coverages else 0
    print(f"Global average coverage: {avg * 100:.0f}%")

    if check:
        # Check mode: verify markdown files exist and are current,
        # and that PNG files exist
        ok = True

        readme_content = _generate_readme(countries, supported, locales)
        readme_path = os.path.join(_DOCS_DIR, "README.md")
        if not _check_markdown(readme_content, readme_path):
            ok = False

        for continent in sorted(_CONTINENT_SLUGS.keys()):
            content = _generate_continent(continent, countries, supported)
            slug = _CONTINENT_SLUGS[continent]
            path = os.path.join(_DOCS_DIR, f"{slug}.md")
            if not _check_markdown(content, path):
                ok = False

        # Check PNGs exist
        for name in ["world"] + list(_CONTINENT_SLUGS.values()):
            png_path = os.path.join(_ASSETS_DIR, f"{name}.png")
            if not os.path.exists(png_path):
                print(f"MISSING: {os.path.relpath(png_path, _ROOT)}")
                ok = False

        if ok:
            print("Geography docs are up to date.")
        else:
            print("\nRun the following to update:")
            print("  uv run --with geopandas --with matplotlib "
                  "python3 tools/geography/generate.py")
            sys.exit(1)
        return

    # 4. Load GeoJSON and join coverage
    print("Loading GeoJSON and computing coverage...")
    gdf = _load_geodata(countries, supported)

    # 5. Render maps
    os.makedirs(_ASSETS_DIR, exist_ok=True)

    print("Rendering world map...")
    _render_map(
        gdf,
        os.path.join(_ASSETS_DIR, "world.png"),
        title="Sayable Locale Coverage",
    )

    for continent, slug in sorted(_CONTINENT_SLUGS.items()):
        print(f"Rendering {continent}...")
        bounds = _CONTINENT_BOUNDS[continent]
        _render_map(
            gdf,
            os.path.join(_ASSETS_DIR, f"{slug}.png"),
            bounds=bounds,
            figsize=(12, 8),
            title=f"{continent} — Locale Coverage",
        )

    # 6. Generate markdown
    os.makedirs(_DOCS_DIR, exist_ok=True)

    readme_content = _generate_readme(countries, supported, locales)
    readme_path = os.path.join(_DOCS_DIR, "README.md")
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(readme_content)
    print(f"Generated {os.path.relpath(readme_path, _ROOT)}")

    for continent in sorted(_CONTINENT_SLUGS.keys()):
        content = _generate_continent(continent, countries, supported)
        slug = _CONTINENT_SLUGS[continent]
        path = os.path.join(_DOCS_DIR, f"{slug}.md")
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Generated {os.path.relpath(path, _ROOT)}")

    print("Done.")


if __name__ == "__main__":
    main()
