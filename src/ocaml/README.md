# parent-time — OCaml

A thoughtful time formatting library that reflects how we think about little ones.

```ocaml
open Parent_time

Formatter.format_age_pure En.locale Types.Normal "2025-06-01" "2025-06-15"
(* Some "2 weeks" *)
```

## Setup

Dune project. Not published to opam — use as a local dependency.

```bash
cd src/ocaml
dune build
```

Requires OCaml >= 4.14 and dune >= 3.0. Zero external dependencies beyond `unix` (stdlib).

## Usage

```ocaml
open Parent_time

Formatter.format_age_pure En.locale Types.Normal "2025-01-15" "2025-07-15"
(* Some "6 months" *)

Formatter.format_stage_pure En.locale "2025-01-15" "2025-06-15" None
(* Some "Infant" *)
```

## Internationalization

```ocaml
open Parent_time

Formatter.format_age_pure Ja.locale Types.Normal "2025-01-01" "2025-07-15"
(* Some "6ヶ月" *)
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```ocaml
val format_age_pure   : Types.locale -> Types.compactness -> string -> string -> string option
val format_stage_pure : Types.locale -> string -> string -> Types.gender option -> string option

val format_age        : Types.locale -> Types.compactness -> string -> string option -> string option
val format_stage      : Types.locale -> string -> string option -> Types.gender option -> string option
```

The `_pure` variants take an explicit `as_of` date. The IO variants default to today.

**Parameters:**

- `locale` — A `Types.locale` value (e.g., `En.locale`).
- `compactness` — `Types.Normal`, `Types.Short`, or `Types.Compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `None` for empty strings.
- `as_of` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `string option` — `Some` formatted string, or `None` on invalid input.

## Development

```bash
dune runtest    # Run tests
dune build      # Build library
```

## License

[MIT](../../LICENSE.md)
