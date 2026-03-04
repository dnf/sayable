# Versioning

sayable-age uses [Semantic Versioning](https://semver.org/) across all language implementations.

## Source of Truth

The canonical version lives in `config/version.json`:

```json
{
  "version": "0.5.0"
}
```

All language implementations and package manifests must match this version.

## Version Constants

Every implementation exposes a version constant using the idiomatic pattern for that language:

| Language   | File                                            | Pattern                                     |
| ---------- | ----------------------------------------------- | ------------------------------------------- |
| Ada        | `src/ada/src/sayableage.ads`                    | `Version : constant String`                 |
| C          | `src/c/include/sayableage/sayableage.h`         | `#define SAYABLEAGE_VERSION "0.5.0"`        |
| C#         | `src/csharp/SayableAge/SayableAge.cs`           | `public const string Version`               |
| C++        | `src/cpp/include/sayableage/types.hpp`          | `constexpr const char* VERSION`             |
| Clojure    | `src/clojure/src/sayableage/formatter.clj`      | `(def version "0.5.0")`                     |
| COBOL      | `src/cobol/src/Types.cbl`                       | `01 PT-VERSION PIC X(10)`                   |
| Dart       | `src/dart/lib/src/format_age.dart`              | `const String version`                      |
| Elixir     | `src/elixir/lib/sayable_age/formatter.ex`       | `@version` with `def version`               |
| Elm        | `src/elm/src/SayableAge/Formatter.elm`          | `version = "0.5.0"`                         |
| Erlang     | `src/erlang/include/sayableage.hrl`             | `-define(VERSION, "0.5.0").`                |
| F#         | `src/fsharp/SayableAge/Formatter.fs`            | `let [<Literal>] Version`                   |
| Fortran    | `src/fortran/src/sayableage.f90`                | `character(len=*), parameter :: PT_VERSION` |
| Gleam      | `src/gleam/src/sayableage/formatter.gleam`      | `pub const version`                         |
| Go         | `src/go/sayableage.go`                          | `const Version`                             |
| Groovy     | `src/groovy/src/.../SayableAge.groovy`          | `static final String VERSION`               |
| Haskell    | `src/haskell/src/SayableAge/Formatter.hs`       | `version :: String`                         |
| Java       | `src/java/src/main/java/.../SayableAge.java`    | `public static final String VERSION`        |
| Kotlin     | `src/kotlin/src/main/kotlin/.../SayableAge.kt`  | `const val VERSION`                         |
| Lua        | `src/lua/sayableage.lua`                        | `M.VERSION`                                 |
| OCaml      | `src/ocaml/lib/formatter.ml`                    | `let version`                               |
| Perl       | `src/perl/lib/SayableAge/Formatter.pm`          | `our $VERSION`                              |
| PHP        | `src/php/src/SayableAge.php`                    | `public const VERSION`                      |
| Python     | `src/python/src/sayable_age/format_age.py`      | `__version__`                               |
| Ruby       | `src/ruby/lib/sayable_age/version.rb`           | `VERSION`                                   |
| Rust       | `src/rust/src/formatter.rs`                     | `pub const VERSION: &str`                   |
| Scala      | `src/scala/src/main/scala/.../SayableAge.scala` | `val Version`                               |
| Swift      | `src/swift/Sources/SayableAge/SayableAge.swift` | `static let version`                        |
| TypeScript | `src/typescript/src/format-age.ts`              | `export const VERSION`                      |
| Zig        | `src/zig/src/sayableage.zig`                    | `pub const version`                         |

## Package Manifests

Languages with package manifests also carry the version:

| Language   | Manifest                            |
| ---------- | ----------------------------------- |
| C#         | `SayableAge.csproj`                 |
| Dart       | `pubspec.yaml`                      |
| Elixir     | `mix.exs`                           |
| F#         | `SayableAge.fsproj`                 |
| Gleam      | `gleam.toml`                        |
| Groovy     | `build.gradle`                      |
| Haskell    | `sayable-age.cabal`                 |
| Java       | `build.gradle.kts`                  |
| Kotlin     | `build.gradle.kts`                  |
| OCaml      | `dune-project` / `sayable_age.opam` |
| Python     | `pyproject.toml`                    |
| Ruby       | `sayable_age.gemspec`               |
| Rust       | `Cargo.toml`                        |
| Scala      | `build.gradle.kts`                  |
| TypeScript | `package.json`                      |

## Bumping the Version

```
just version 1.0.0
```

This single command updates all 48+ files:

1. `config/version.json` (source of truth)
2. Version constants in all 29 implementations
3. All package manifests listed above
4. The C `#define` in `codegen/targets/c/emitter.py`
5. Regenerates the C header and locale docs via `just generate locales`
6. Lock files for Python (`uv.lock`), Rust (`Cargo.lock`), and TypeScript (`package-lock.json`)
7. Version references in `docs/versioning.md`

After running, verify with `just test` and commit.

### How it works

Each language has a `version.sh` script (`.hecatron/languages/<lang>/version.sh`) that takes a version string as `$1` and knows which files and sed patterns to update for that language. The `just version` recipe orchestrates them all, plus handles cross-language files.

When adding a new language, create its `version.sh` script — the orchestrator picks it up automatically.

## License

See [LICENSE.md](../LICENSE.md).
