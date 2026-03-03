# Build Benchmark Specification

## Overview

This benchmark measures the clean compilation time for each of the 20 compiled
language implementations. Unlike the CPU benchmark (which measures per-call
throughput with in-process timing), build timing is orchestrated externally by a
single Python script that shells out to `just clean` + `just build`.

## What Is Measured

Each iteration performs:

1. `just clean <lang>` — remove all build artifacts
2. `just build <lang>` — full clean build, timed with `time.perf_counter()`

The clock starts immediately before the build subprocess and stops when it
exits. This captures the full end-to-end compilation time including compiler
startup, linking, and any code generation.

## Configuration

| Parameter  | Value       |
| ---------- | ----------- |
| Iterations | 3           |
| Type       | clean_build |
| Reported   | Median      |

## Compiled Languages (20)

Ada, C, COBOL, C++, C#, Elixir, Erlang, Fortran, F#, Gleam, Groovy, Haskell,
Java, Kotlin, OCaml, Rust, Scala, Swift, TypeScript, Zig

## Timing Methodology

- **Monotonic clock** (`time.perf_counter()`) for accuracy — not affected by
  system clock adjustments.
- **Clean build only** — `just clean` removes all artifacts before each
  iteration, ensuring no incremental build caching.
- **Serial execution recommended** — concurrent builds compete for CPU and
  distort timings. The default parallel dispatch uses `-j 1`.
- **Timings in seconds** — builds typically take 1–60+ seconds, so seconds
  (not milliseconds) are the natural unit.

## Result Format

Each run writes a JSON file to `benchmarks/build/results/<lang>-<YYYYMMDD-HHMMSS>.json`.
See `benchmarks/README.md` for the full schema.
