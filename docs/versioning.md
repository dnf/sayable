# Versioning

parent-time uses [Semantic Versioning](https://semver.org/) across all language implementations.

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
| Ada        | `src/ada/src/parenttime.ads`                    | `Version : constant String`                 |
| C          | `src/c/include/parenttime/parenttime.h`         | `#define PARENTTIME_VERSION "0.5.0"`        |
| C#         | `src/csharp/ParentTime/ParentTime.cs`           | `public const string Version`               |
| C++        | `src/cpp/include/parenttime/types.hpp`          | `constexpr const char* VERSION`             |
| Clojure    | `src/clojure/src/parenttime/formatter.clj`      | `(def version "0.5.0")`                     |
| COBOL      | `src/cobol/src/Types.cbl`                       | `01 PT-VERSION PIC X(10)`                   |
| Dart       | `src/dart/lib/src/format_age.dart`              | `const String version`                      |
| Elixir     | `src/elixir/lib/parent_time/formatter.ex`       | `@version` with `def version`               |
| Elm        | `src/elm/src/ParentTime/Formatter.elm`          | `version = "0.5.0"`                         |
| Erlang     | `src/erlang/include/parenttime.hrl`             | `-define(VERSION, "0.5.0").`                |
| F#         | `src/fsharp/ParentTime/Formatter.fs`            | `let [<Literal>] Version`                   |
| Fortran    | `src/fortran/src/parenttime.f90`                | `character(len=*), parameter :: PT_VERSION` |
| Gleam      | `src/gleam/src/parenttime/formatter.gleam`      | `pub const version`                         |
| Go         | `src/go/parenttime.go`                          | `const Version`                             |
| Groovy     | `src/groovy/src/.../ParentTime.groovy`          | `static final String VERSION`               |
| Haskell    | `src/haskell/src/ParentTime/Formatter.hs`       | `version :: String`                         |
| Java       | `src/java/src/main/java/.../ParentTime.java`    | `public static final String VERSION`        |
| Kotlin     | `src/kotlin/src/main/kotlin/.../ParentTime.kt`  | `const val VERSION`                         |
| Lua        | `src/lua/parenttime.lua`                        | `M.VERSION`                                 |
| OCaml      | `src/ocaml/lib/formatter.ml`                    | `let version`                               |
| Perl       | `src/perl/lib/ParentTime/Formatter.pm`          | `our $VERSION`                              |
| PHP        | `src/php/src/ParentTime.php`                    | `public const VERSION`                      |
| Python     | `src/python/src/parent_time/format_age.py`      | `__version__`                               |
| Ruby       | `src/ruby/lib/parent_time/version.rb`           | `VERSION`                                   |
| Rust       | `src/rust/src/formatter.rs`                     | `pub const VERSION: &str`                   |
| Scala      | `src/scala/src/main/scala/.../ParentTime.scala` | `val Version`                               |
| Swift      | `src/swift/Sources/ParentTime/ParentTime.swift` | `static let version`                        |
| TypeScript | `src/typescript/src/format-age.ts`              | `export const VERSION`                      |
| Zig        | `src/zig/src/parenttime.zig`                    | `pub const version`                         |

## Package Manifests

Languages with package manifests also carry the version:

| Language   | Manifest                            |
| ---------- | ----------------------------------- |
| C#         | `ParentTime.csproj`                 |
| Dart       | `pubspec.yaml`                      |
| Elixir     | `mix.exs`                           |
| F#         | `ParentTime.fsproj`                 |
| Gleam      | `gleam.toml`                        |
| Groovy     | `build.gradle`                      |
| Haskell    | `parent-time.cabal`                 |
| Java       | `build.gradle.kts`                  |
| Kotlin     | `build.gradle.kts`                  |
| OCaml      | `dune-project` / `parent_time.opam` |
| Python     | `pyproject.toml`                    |
| Ruby       | `parent_time.gemspec`               |
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

Each language's installer script (`scripts/installers/<lang>.sh`) has a `set-version` handler that knows which files and sed patterns to update for that language. The `just version` recipe orchestrates them all, plus handles cross-language files.

When adding a new language, implement the `set-version)` case arm in its installer script — the orchestrator picks it up automatically.

## License

See [LICENSE.md](../LICENSE.md).
