#!/usr/bin/env bash
# Shared helpers for justfile recipes.
# Sourced (not executed) — provides shared functions and language lists.
# One entry per line for merge safety when adding new languages.

# ---------------------------------------------------------------------------
# Language lists (one per line, alphabetical)
# ---------------------------------------------------------------------------

# All 28 language implementations
_ALL_LANGS="
ada
c
clojure
cpp
csharp
dart
elixir
elm
erlang
fortran
fsharp
gleam
go
groovy
haskell
java
kotlin
lua
ocaml
perl
php
python
ruby
rust
scala
swift
typescript
zig
"

# Languages with a compiled build step (19)
_COMPILED_LANGS="
ada
c
cpp
csharp
elixir
erlang
fortran
fsharp
gleam
groovy
haskell
java
kotlin
ocaml
rust
scala
swift
typescript
zig
"

# Languages with build artifacts to clean (25 — excludes go, perl, php)
_CLEAN_LANGS="
ada
c
clojure
cpp
csharp
dart
elixir
elm
erlang
fortran
fsharp
gleam
groovy
haskell
java
kotlin
lua
ocaml
python
rust
scala
swift
typescript
zig
"

# Languages with standalone linters (12)
_LINT_LANGS="
csharp
dart
fsharp
go
java
lua
php
python
ruby
rust
swift
typescript
"

# Languages without a build step (for build help text)
_NO_BUILD_LANGS="
clojure
dart
elm
go
lua
perl
php
python
ruby
"

# ---------------------------------------------------------------------------
# Abbreviation maps (one entry per line for merge safety)
# ---------------------------------------------------------------------------

# Map abbreviation → full language name
_name() {
    case "$1" in
        ad)  echo ada ;;
        clj) echo clojure ;;
        c++) echo cpp ;;
        cs)  echo csharp ;;
        dt)  echo dart ;;
        el)  echo elm ;;
        erl) echo erlang ;;
        ex)  echo elixir ;;
        fs)  echo fsharp ;;
        ft)  echo fortran ;;
        gm)  echo gleam ;;
        gy)  echo groovy ;;
        hs)  echo haskell ;;
        kt)  echo kotlin ;;
        lu)  echo lua ;;
        ml)  echo ocaml ;;
        pl)  echo perl ;;
        py)  echo python ;;
        rb)  echo ruby ;;
        rs)  echo rust ;;
        sc)  echo scala ;;
        sw)  echo swift ;;
        ts)  echo typescript ;;
        zg)  echo zig ;;
        *)   echo "$1" ;;
    esac
}

# Map full language name → abbreviation
_abbr() {
    case "$1" in
        ada)        echo "ad" ;;
        clojure)    echo "clj" ;;
        cpp)        echo "c++" ;;
        csharp)     echo "cs" ;;
        dart)       echo "dt" ;;
        elixir)     echo "ex" ;;
        elm)        echo "el" ;;
        erlang)     echo "erl" ;;
        fortran)    echo "ft" ;;
        fsharp)     echo "fs" ;;
        gleam)      echo "gm" ;;
        groovy)     echo "gy" ;;
        haskell)    echo "hs" ;;
        kotlin)     echo "kt" ;;
        lua)        echo "lu" ;;
        ocaml)      echo "ml" ;;
        perl)       echo "pl" ;;
        python)     echo "py" ;;
        ruby)       echo "rb" ;;
        rust)       echo "rs" ;;
        scala)      echo "sc" ;;
        swift)      echo "sw" ;;
        typescript) echo "ts" ;;
        zig)        echo "zg" ;;
    esac
}

# ---------------------------------------------------------------------------
# Dependency maps (one entry per line for merge safety)
# ---------------------------------------------------------------------------

# Full dependency map (all languages + cli tool)
_dep() {
    case "$1" in
        ada)                       echo gnat ;;
        c|cli|cpp|fortran)         echo cmake ;;
        clojure)                   echo clojure ;;
        csharp|fsharp)             echo dotnet ;;
        dart)                      echo dart ;;
        elixir)                    echo mix ;;
        elm)                       echo elm ;;
        erlang)                    echo rebar3 ;;
        gleam)                     echo gleam ;;
        go)                        echo go ;;
        groovy|java|kotlin|scala)  echo java ;;
        haskell)                   echo cabal ;;
        lua)                       echo lua ;;
        ocaml)                     echo opam ;;
        perl)                      echo perl ;;
        php)                       echo php ;;
        python)                    echo uv ;;
        ruby)                      echo ruby ;;
        rust)                      echo cargo ;;
        swift)                     echo swift ;;
        typescript)                echo npm ;;
        zig)                       echo zig ;;
    esac
}

# Lint-specific dependency map (different tools for some languages)
_lint_dep() {
    case "$1" in
        csharp|fsharp)  echo dotnet ;;
        dart)           echo dart ;;
        go)             echo golangci-lint ;;
        java)           echo java ;;
        lua)            echo luacheck ;;
        php)            echo php ;;
        python)         echo uv ;;
        ruby)           echo ruby ;;
        rust)           echo cargo ;;
        swift)          echo swift ;;
        typescript)     echo npm ;;
    esac
}

# ---------------------------------------------------------------------------
# Environment setup for non-standard tool locations
# ---------------------------------------------------------------------------

# Add Alire-managed GNAT + GPRbuild to PATH (macOS installs via Alire).
# No-op on Linux (apt puts them on PATH) or if already found.
_ada_env() {
    command -v gprbuild >/dev/null 2>&1 && return
    local dir
    for dir in "$HOME/.local/share/alire/toolchains"/*/bin; do
        [ -d "$dir" ] && export PATH="$dir:$PATH"
    done
}

# ---------------------------------------------------------------------------
# Formatting helpers
# ---------------------------------------------------------------------------

# Format a one-per-line language list into a multi-column grid with abbreviations.
# Usage: _lang_grid "Languages" "$_ALL_LANGS"
_lang_grid() {
    local label="$1"
    local list="$2"
    local items=() lang abbr
    while read -r lang; do
        [ -z "$lang" ] && continue
        abbr=$(_abbr "$lang")
        if [ -n "$abbr" ]; then
            items+=("$lang ($abbr)")
        else
            items+=("$lang")
        fi
    done <<< "$list"
    local count=${#items[@]}
    echo "$label ($count):"
    local cols=5 col_w=16 i=0
    for item in "${items[@]}"; do
        if (( i % cols == 0 )); then printf "  "; fi
        printf "%-${col_w}s" "$item"
        i=$((i + 1))
        if (( i % cols == 0 )); then printf '\n'; fi
    done
    if (( i % cols != 0 )); then printf '\n'; fi
}

# Format a one-per-line language list as a comma-separated string.
# Usage: _lang_csv "$_NO_BUILD_LANGS"
_lang_csv() {
    local list="$1" result="" lang
    while read -r lang; do
        [ -z "$lang" ] && continue
        if [ -n "$result" ]; then
            result="$result, $lang"
        else
            result="$lang"
        fi
    done <<< "$list"
    echo "$result"
}

# ---------------------------------------------------------------------------
# Misspelling suggestions (one entry per line for merge safety)
# ---------------------------------------------------------------------------

_suggest() {
    local input; input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    case "$input" in
        adda|ade)
            echo ada ;;
        darrt|drt)
            echo dart ;;
        elixer|elixr|exlir|exilir)
            echo elixir ;;
        fortan|frotran|fortarn|fotran)
            echo fortran ;;
        groovie|grovy|grovvy)
            echo groovy ;;
        haskel|haskle|haslkell)
            echo haskell ;;
        closure|clojur|clojre|cojure)
            echo clojure ;;
        erland|erlng|earland|earlang)
            echo erlang ;;
        f-sharp|f-\#)
            echo fsharp ;;
        gleema|gleem|glam|gelam)
            echo gleam ;;
        typscript|tyepscript|typesript|tsc)
            echo typescript ;;
        golang|goland)
            echo go ;;
        scalar|scalla)
            echo scala ;;
        kotlint|koltin|kotln)
            echo kotlin ;;
        pyton|pyhton|pythn)
            echo python ;;
        phpp)
            echo php ;;
        rubby)
            echo ruby ;;
        swft|siwft)
            echo swift ;;
        ocmal|ocamal|ocmla)
            echo ocaml ;;
        *)
            if [ ${#input} -ge 3 ]; then
                for name in $_ALL_LANGS; do
                    if [[ "$name" == "$input"* || "$name" == *"$input" ]]; then
                        echo "$name"; return
                    fi
                done
            fi ;;
    esac
}

# Validate a language name (abbreviation or full), with fuzzy suggestion on miss.
# Usage: name=$(_check "$lang" "install")
_check() {
    local lang="$1" help_cmd="${2:-help}" name script suggest
    name=$(_name "$lang")
    script="scripts/installers/${name}.sh"
    if [ -f "$script" ]; then echo "$name"; return; fi
    suggest=$(_suggest "$lang")
    if [ -n "$suggest" ]; then
        if [ -t 0 ]; then
            read -rp "Unknown language '$lang'. Did you mean '$suggest'? [Y/n] " answer </dev/tty
            case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
                ""|y|yes) echo "$suggest"; return ;;
            esac
        else
            echo "Unknown language '$lang'. Did you mean '$suggest'?" >&2
        fi
    else
        echo "Unknown language: $lang (try 'just $help_cmd help')" >&2
    fi
    exit 1
}
