# Config

Project-wide configuration files.

| File            | Purpose                                                    |
| --------------- | ---------------------------------------------------------- |
| `metadata.json` | Project metadata (name, description, author, license, URL) |
| `tests.json`    | Canonical test specification for all implementations       |
| `version.json`  | Single source of truth for the library version (semver)    |

## Usage

```bash
just version          # print current version
just version 1.0.0    # bump version across all implementations
just metadata         # interactively update metadata across all manifests
just add go rust      # add languages to the active set
just remove go        # remove a language from the active set
just list languages   # list active languages
```

See [`docs/versioning.md`](../docs/versioning.md) and [`docs/metadata.md`](../docs/metadata.md) for details.

Language management config has moved to [`.hecatron/config/languages.json`](../.hecatron/config/languages.json)
(active set, disabled set, tools) with per-language data in `.hecatron/languages/<lang>/config.json`.

## License

[MIT](../LICENSE.md)
