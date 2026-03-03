# Benchmarks

## CPU Benchmark

Measures per-call performance of `format_age` and `format_stage` across all
language implementations.

### Running

```bash
just benchmark cpu          # all languages in parallel
just benchmark cpu go       # single language
just benchmark cpu rs       # abbreviations work too
```

### Specification

See [`cpu/benchmark-spec.md`](cpu/benchmark-spec.md) for the full list of 15
scenarios, configuration, and timing requirements.

### Results

Each run writes a JSON file to `benchmarks/cpu/results/`:

```
benchmarks/cpu/results/go-20240920-143000.json
benchmarks/cpu/results/python-20240920-143005.json
```

Result files are machine-specific and not tracked in git.

### Result Schema

```json
{
  "meta": {
    "language": "go",
    "language_version": "1.22.0",
    "timestamp": "2024-09-20T14:30:00Z",
    "system": {
      "os": "Darwin 24.1.0",
      "arch": "arm64",
      "cpu": "Apple M2 Pro",
      "cpu_cores": 12,
      "memory_gb": 32
    }
  },
  "config": {
    "warmup_calls": 1000,
    "measured_calls": 100000,
    "iterations": 3
  },
  "results": [
    {
      "id": "B1",
      "function": "format_age",
      "locale": "en",
      "description": "Days tier (3 days)",
      "timings_ms": [45.2, 44.8, 45.1],
      "median_ms": 45.1,
      "ops_per_sec": 2217294
    }
  ],
  "summary": {
    "total_measured_calls": 1500000,
    "total_time_ms": 678.5
  }
}
```

### Comparing Results

Results from different machines are not directly comparable due to differences
in CPU, OS, and background load. To compare languages meaningfully:

1. Run all benchmarks on the same machine in a single session
2. Close other applications to reduce noise
3. Compare the `median_ms` values for each scenario
4. Use `ops_per_sec` for a quick throughput comparison

### Reports

Generate a Markdown comparison report with PNG charts from result files:

```bash
just benchmark report       # CPU report (default)
just benchmark report cpu   # explicit CPU report
```

Output is written to `benchmarks/cpu/reports/`:

```
benchmarks/cpu/reports/report.md          # Markdown report
benchmarks/cpu/reports/charts/*.png       # 5 chart images
```

The report includes overall rankings, per-group breakdowns (English, cross-locale,
stage), a scenario heatmap, and language version details. Charts require
[matplotlib](https://matplotlib.org/) — installed ephemerally via `uv run --with`.

Report files are machine-specific and not tracked in git.

### System Info

Each result file captures the system configuration automatically:

- **macOS**: CPU brand (`sysctl`), core count, OS version (`sw_vers`)
- **Linux**: CPU model (`/proc/cpuinfo`), core count, kernel version (`uname`)
- **Language version**: Captured via each language's version command

## Build Benchmark

Measures clean compilation time for the 20 compiled language implementations.

### Running

```bash
just benchmark build          # all compiled languages (serial by default)
just benchmark build zig      # single language
just benchmark build rs       # abbreviations work too
just benchmark build -j 4     # parallel (may distort timings)
```

Serial execution is the default (`-j 1`) because concurrent builds compete for
CPU and distort timings.

### Specification

See [`build/build-spec.md`](build/build-spec.md) for what's measured,
configuration, and timing methodology.

### Results

Each run writes a JSON file to `benchmarks/build/results/`:

```
benchmarks/build/results/zig-20260303-120000.json
benchmarks/build/results/rust-20260303-120500.json
```

Result files are machine-specific and not tracked in git.

### Result Schema

```json
{
  "meta": {
    "language": "rust",
    "language_version": "rustc 1.80.0",
    "timestamp": "2026-03-03T12:00:00Z",
    "system": {
      "os": "Darwin 15.3.0",
      "arch": "arm64",
      "cpu": "Apple M1 Max",
      "cpu_cores": 10,
      "memory_gb": 32
    }
  },
  "config": {
    "iterations": 3,
    "type": "clean_build"
  },
  "results": {
    "timings_s": [4.2, 4.1, 4.3],
    "median_s": 4.2,
    "min_s": 4.1,
    "max_s": 4.3
  }
}
```

Timings are in seconds (not milliseconds) since builds typically take 1–60+
seconds.

### Reports

Generate a Markdown comparison report with a PNG chart:

```bash
just benchmark report build
```

Output is written to `benchmarks/build/reports/`:

```
benchmarks/build/reports/report.md          # Markdown report
benchmarks/build/reports/charts/*.png       # 1 chart image
```

The report includes a build time ranking chart, configuration details, and
language version information.

### Comparing Results

Build times depend heavily on the machine. To compare:

1. Run all build benchmarks on the same machine in a single session
2. Close other applications to minimize interference
3. Use serial mode (the default) to avoid resource contention
4. Compare `median_s` values
