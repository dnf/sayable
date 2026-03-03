# CPU Benchmark Specification

## Overview

This benchmark measures the CPU performance of `format_age` and `format_stage` across
all language implementations. Every harness runs the same 15 scenarios with
identical inputs, producing comparable results.

## Configuration

| Parameter      | Value   |
| -------------- | ------- |
| Warmup calls   | 1,000   |
| Measured calls | 100,000 |
| Iterations     | 3       |
| Reported value | Median  |

## Scenarios

| ID  | Function     | DoB        | AsOf       | Locale | Code Path                |
| --- | ------------ | ---------- | ---------- | ------ | ------------------------ |
| B1  | format_age   | 2024-03-01 | 2024-03-04 | en     | Days tier (3 days)       |
| B2  | format_age   | 2024-01-15 | 2024-03-01 | en     | Weeks+days (6w3d)        |
| B3  | format_age   | 2024-01-15 | 2024-06-20 | en     | Months (5 months)        |
| B4  | format_age   | 2022-06-15 | 2024-09-20 | en     | Years+months (2y3m)      |
| B5  | format_age   | 2020-03-15 | 2024-09-20 | en     | Half-year (4½ years)     |
| B6  | format_age   | 2014-05-10 | 2024-09-20 | en     | Years (10 years)         |
| B7  | format_age   | 2024-01-15 | 2024-06-20 | ar     | Arabic plural (complex)  |
| B8  | format_age   | 2024-01-15 | 2024-06-20 | ja     | Japanese (other-only)    |
| B9  | format_age   | 2024-01-15 | 2024-06-20 | pl     | Polish plural (Slavic)   |
| B10 | format_age   | 2024-01-15 | 2024-06-20 | ru     | Russian plural (Slavic)  |
| B11 | format_age   | 2024-01-15 | 2024-06-20 | de     | German (one/other)       |
| B12 | format_age   | 2024-01-15 | 2024-06-20 | zh     | Chinese (other-only)     |
| B13 | format_stage | 2024-06-01 | 2024-07-15 | en     | Newborn stage            |
| B14 | format_stage | 2023-01-01 | 2024-09-20 | en     | Toddler stage            |
| B15 | format_stage | 2014-05-10 | 2024-09-20 | en     | Child stage              |

## Timing Requirements

- Use **monotonic clocks**, not wall clocks.
- JVM languages (Java, Kotlin, Scala, Clojure) need extra warmup for JIT compilation.
- BEAM languages (Erlang, Elixir) may benefit from warmup too.
- Each iteration times all `measured_calls` invocations and reports the total in milliseconds.

## Result Format

Each run writes a JSON file to `benchmarks/cpu/results/<lang>-<YYYYMMDD-HHMMSS>.json`.
See `benchmarks/README.md` for the full schema.
