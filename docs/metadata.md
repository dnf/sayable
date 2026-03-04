# Metadata

Project metadata (description, author, license, repository URL) is stored in `config/metadata.json` and propagated to all language-specific package manifests via `just metadata`.

## Source of truth

`config/metadata.json`:

```json
{
  "name": "parent-time",
  "description": "A thoughtful time formatting library that reflects how we think about little ones",
  "author": "Don Neufeld",
  "license": "MIT",
  "repository": "https://github.com/dnf/parent-time"
}
```

## Usage

```bash
just metadata
```

The command is interactive — it shows current values, prompts for changes (press Enter to keep the current value), and updates all manifests.

## Fields

| Field       | Key           | Description                               |
| ----------- | ------------- | ----------------------------------------- |
| Name        | `name`        | Canonical hyphenated form (`parent-time`) |
| Description | `description` | One-line library description              |
| Author      | `author`      | Primary author name                       |
| License     | `license`     | SPDX license identifier                   |
| Repository  | `repository`  | GitHub repository URL                     |

The `name` field stores the canonical hyphenated form. Each language derives its own convention: `parent_time` (Ruby, Dart, OCaml), `parenttime` (Gleam, Erlang, Zig), `ParentTime` (C#, Swift).

## Manifests updated

| Language   | File                  | Fields                                                 |
| ---------- | --------------------- | ------------------------------------------------------ |
| C++        | `CMakeLists.txt`      | description, homepage_url                              |
| Dart       | `pubspec.yaml`        | description                                            |
| Erlang     | `parenttime.app.src`  | description, licenses                                  |
| Gleam      | `gleam.toml`          | description, licences                                  |
| Groovy     | `build.gradle`        | description, POM (url, developer name, scm)            |
| Haskell    | `parent-time.cabal`   | license                                                |
| Java       | `build.gradle.kts`    | description, POM (url, developer name, scm)            |
| Kotlin     | `build.gradle.kts`    | description, POM (url, developer name, scm)            |
| OCaml      | `parent_time.opam`    | synopsis, maintainer                                   |
| PHP        | `composer.json`       | description, license, author, homepage                 |
| Python     | `pyproject.toml`      | description, license, author, repository URL           |
| Ruby       | `parent_time.gemspec` | summary, license, author, homepage                     |
| Rust       | `Cargo.toml`          | description, license, author, repository, homepage     |
| Scala      | `build.gradle.kts`    | description, POM (url, developer name, scm)            |
| TypeScript | `package.json`        | description, author, license, repository url, homepage |

Languages without manifest metadata fields (Ada, C, COBOL, Clojure, C#, Elixir, Elm, F#, Fortran, Go, Lua, Perl, Swift, Zig) are no-ops.

## How it works

1. `.hecatron/tools/metadata/set.sh` reads `config/metadata.json` and prompts for changes
2. Updated values are written back to `config/metadata.json`
3. Both old (`PT_OLD_*`) and new (`PT_*`) values are exported as env vars
4. Each installer's `set-metadata)` case arm performs targeted replacements
5. JSON manifests (PHP, TypeScript) use `python3` for reliable updates; all others use `_sed_i`

## Relationship to `just version`

`just version` and `just metadata` are separate commands with separate sources of truth (`config/version.json` and `config/metadata.json`). They have different change frequencies and different side effects — `just version` triggers codegen regeneration and lockfile updates, while `just metadata` only patches manifest files.
