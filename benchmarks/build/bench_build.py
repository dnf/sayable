#!/usr/bin/env python3
"""Build-time benchmark for parent-time compiled language implementations.

Measures clean compilation time by running `just clean <lang>` then timing
`just build <lang>` with a monotonic clock. Each language is built multiple
times and the median is reported.

Usage:
    python3 benchmarks/build/bench_build.py [lang ...]

With no arguments, benchmarks all compiled languages.
"""
from __future__ import annotations

import json
import os
import platform
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ITERATIONS = 3

COMPILED_LANGS = [
    "ada",
    "c",
    "cobol",
    "cpp",
    "csharp",
    "elixir",
    "erlang",
    "fortran",
    "fsharp",
    "gleam",
    "groovy",
    "haskell",
    "java",
    "kotlin",
    "ocaml",
    "rust",
    "scala",
    "swift",
    "typescript",
    "zig",
]

VERSION_COMMANDS: dict[str, list[str]] = {
    "ada": ["gnat", "--version"],
    "c": ["cmake", "--version"],
    "cobol": ["cobc", "--version"],
    "cpp": ["cmake", "--version"],
    "csharp": ["dotnet", "--version"],
    "elixir": ["mix", "--version"],
    "erlang": ["erl", "-noshell", "-eval", "io:format(erlang:system_info(otp_release)),halt()."],
    "fortran": ["cmake", "--version"],
    "fsharp": ["dotnet", "--version"],
    "gleam": ["gleam", "--version"],
    "groovy": ["groovy", "--version"],
    "haskell": ["cabal", "--version"],
    "java": ["java", "--version"],
    "kotlin": ["java", "--version"],
    "ocaml": ["ocamlfind", "ocamlopt", "-version"],
    "rust": ["rustc", "--version"],
    "scala": ["java", "--version"],
    "swift": ["swift", "--version"],
    "typescript": ["npx", "tsc", "--version"],
    "zig": ["zig", "version"],
}


def collect_system_info() -> dict:
    """Collect system information for the result metadata."""
    system = platform.system()
    arch = platform.machine()
    cpu = "unknown"
    cpu_cores = os.cpu_count() or 0
    memory_gb = 0

    if system == "Darwin":
        try:
            cpu = subprocess.check_output(
                ["sysctl", "-n", "machdep.cpu.brand_string"], text=True
            ).strip()
        except (subprocess.SubprocessError, FileNotFoundError):
            pass
        try:
            ver = subprocess.check_output(
                ["sw_vers", "-productVersion"], text=True
            ).strip()
            os_version = f"Darwin {ver}"
        except (subprocess.SubprocessError, FileNotFoundError):
            os_version = f"Darwin {platform.release()}"
        try:
            mem_bytes = int(
                subprocess.check_output(
                    ["sysctl", "-n", "hw.memsize"], text=True
                ).strip()
            )
            memory_gb = mem_bytes // (1024 * 1024 * 1024)
        except (subprocess.SubprocessError, FileNotFoundError, ValueError):
            pass
    else:
        os_version = f"Linux {platform.release()}"
        try:
            with open("/proc/cpuinfo") as f:
                for line in f:
                    if line.startswith("model name"):
                        cpu = line.split(":", 1)[1].strip()
                        break
        except FileNotFoundError:
            pass
        try:
            with open("/proc/meminfo") as f:
                for line in f:
                    if line.startswith("MemTotal"):
                        kb = int(line.split()[1])
                        memory_gb = kb // (1024 * 1024)
                        break
        except FileNotFoundError:
            pass

    return {
        "os": os_version,
        "arch": arch,
        "cpu": cpu,
        "cpu_cores": cpu_cores,
        "memory_gb": memory_gb,
    }


def find_project_root() -> Path:
    """Walk up from this file to find the project root (contains justfile)."""
    d = Path(__file__).resolve().parent
    while d != d.parent:
        if (d / "justfile").exists():
            return d
        d = d.parent
    return Path.cwd()


def get_language_version(lang: str) -> str:
    """Run the version command for a language and return the first line."""
    cmd = VERSION_COMMANDS.get(lang)
    if not cmd:
        return "unknown"
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30
        )
        output = (result.stdout or result.stderr).strip()
        return output.split("\n")[0] if output else "unknown"
    except (subprocess.SubprocessError, FileNotFoundError):
        return "unknown"


def run_build_benchmark(lang: str, root: Path) -> list[float]:
    """Clean and build a language multiple times, returning a list of build times in seconds."""
    timings = []
    for i in range(ITERATIONS):
        # Clean first
        clean_result = subprocess.run(
            ["just", "clean", lang],
            capture_output=True,
            text=True,
            cwd=root,
        )
        if clean_result.returncode != 0:
            print(f"  warning: clean failed for {lang} (iteration {i + 1}), attempting build anyway",
                  file=sys.stderr)

        # Time the build
        start = time.perf_counter()
        build_result = subprocess.run(
            ["just", "build", lang],
            capture_output=True,
            text=True,
            cwd=root,
        )
        elapsed = time.perf_counter() - start

        if build_result.returncode != 0:
            stderr_tail = (build_result.stderr or "").strip().split("\n")[-3:]
            raise RuntimeError(
                f"build failed for {lang} (iteration {i + 1}): {' '.join(stderr_tail)}"
            )

        timings.append(round(elapsed, 3))
        print(f"  iteration {i + 1}/{ITERATIONS}: {elapsed:.3f}s")

    return timings


def benchmark_language(lang: str, root: Path) -> dict:
    """Orchestrate benchmarking for one language: version, timings, write JSON."""
    print(f"\n{'=' * 50}")
    print(f"Benchmarking: {lang}")
    print(f"{'=' * 50}")

    version = get_language_version(lang)
    print(f"  version: {version}")

    now = datetime.now(tz=timezone.utc)

    try:
        timings = run_build_benchmark(lang, root)
        median = round(statistics.median(timings), 3)
        result = {
            "meta": {
                "language": lang,
                "language_version": version,
                "timestamp": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "system": collect_system_info(),
            },
            "config": {
                "iterations": ITERATIONS,
                "type": "clean_build",
            },
            "results": {
                "timings_s": timings,
                "median_s": median,
                "min_s": min(timings),
                "max_s": max(timings),
            },
        }
        print(f"  median: {median:.3f}s  min: {min(timings):.3f}s  max: {max(timings):.3f}s")
    except RuntimeError as exc:
        result = {
            "meta": {
                "language": lang,
                "language_version": version,
                "timestamp": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "system": collect_system_info(),
            },
            "config": {
                "iterations": ITERATIONS,
                "type": "clean_build",
            },
            "error": str(exc),
        }
        print(f"  error: {exc}", file=sys.stderr)

    # Write JSON
    out_dir = root / "benchmarks" / "build" / "results"
    out_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{lang}-{now.strftime('%Y%m%d-%H%M%S')}.json"
    out_path = out_dir / filename

    with open(out_path, "w") as f:
        json.dump(result, f, indent=2)
        f.write("\n")

    print(f"  result: {out_path}")
    return result


def main() -> None:
    root = find_project_root()
    langs = sys.argv[1:] if len(sys.argv) > 1 else COMPILED_LANGS

    # Validate requested languages
    for lang in langs:
        if lang not in COMPILED_LANGS:
            print(f"error: '{lang}' is not a compiled language", file=sys.stderr)
            print(f"Compiled languages: {', '.join(COMPILED_LANGS)}", file=sys.stderr)
            sys.exit(1)

    print(f"Build benchmark: {len(langs)} language{'s' if len(langs) != 1 else ''}, {ITERATIONS} iterations each")

    results = []
    for lang in langs:
        result = benchmark_language(lang, root)
        results.append(result)

    # Summary
    print(f"\n{'=' * 50}")
    print("Summary")
    print(f"{'=' * 50}")
    print(f"{'Language':<14s} {'Median':>8s} {'Min':>8s} {'Max':>8s}")
    print(f"{'-' * 14} {'-' * 8} {'-' * 8} {'-' * 8}")
    for r in results:
        lang = r["meta"]["language"]
        if "error" in r:
            print(f"{lang:<14s} {'ERROR':>8s}")
        else:
            res = r["results"]
            print(f"{lang:<14s} {res['median_s']:7.3f}s {res['min_s']:7.3f}s {res['max_s']:7.3f}s")


if __name__ == "__main__":
    main()
