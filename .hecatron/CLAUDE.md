# .hecatron

Sayable's configuration for [hecatron](https://github.com/dnf/hecatron), the
tool that installs, checks and repairs each language's toolchain and runs the
per-language commands (`just test`, `lint`, `build`, `clean`, `install`,
`doctor`, `add`... all delegate to it). Hecatron's design, command reference
and language definitions live in its repository; this directory holds only
what is specific to sayable.

```
.hecatron/
  config.json              # components, implPath, languages, tools, generated files, tasks, metadata
  local.json               # your disabled languages (gitignored; `just disable` / `just enable`)
  languages/<lang>/        # sayable's hooks for each language:
    test.sh                #   run one library's native suite
    lint.sh                #   lint one library (languages with a separate linter)
    build.sh, clean.sh     #   build one library / remove its build artifacts
    version.sh             #   set the version in source and manifests (`just version`)
    metadata.sh            #   update package metadata (`just metadata`), where manifests have it
    workflow.yml           #   this language's CI workflow, copied to .github/workflows/<lang>.yml
```

## Hooks

Hecatron runs `test.sh`, `lint.sh`, `build.sh` and `clean.sh` once per
library, from inside `<library>/impl/<lang>/` (the `implPath` in
`config.json`), with the library name as `$1` and `HECATRON_ROOT`,
`HECATRON_COMPONENT` and `HECATRON_LANG` set. Each library's run continues
after another fails, so one run reports them all. `-c <library>` limits a
run to one library. `clean.sh` removes build artifacts only, never installed
dependencies or tracked files.

`version.sh` and `metadata.sh` run from the project root and source
hecatron's shared helpers with
`source "${HECATRON_HOME}/languages/_common.sh"` (`_sed_i`, `log`, `has`...).

## Installers and definitions

Installers, doctors, Dockerfile snippets and each language's `config.json`
(abbreviation, dependency, detection) come from hecatron. To change one, fix
it in hecatron; to change it for sayable only, put a file with the same name
in `languages/<lang>/` here, which takes precedence.

## Generated files

`.github/workflows/<lang>.yml` (from each `workflow.yml`) and `age/Dockerfile`
(from hecatron's snippets) are generated: `just dockerfile` and `hecatron
workflows` regenerate them, `just add` / `just remove` do both, and `just
check` (`hecatron check`) verifies they're current and that every workflow
tests every library.

## Shell conventions

- **Brace-delimit all variables**: `${var}` not `$var` (exception: `$1`, `$?`, `$@`, etc.)
- **Brace-delimit before Unicode**: `${_s_pass}✓` not `$_s_pass✓` (Bash 3.2 treats Unicode as identifier chars)
- **shellcheck clean** at warning level (`just lint shell`); any `disable` carries a comment saying why.
