# Config

Project-wide configuration files.

| File            | Purpose                                                    |
| --------------- | ---------------------------------------------------------- |
| `version.json`  | Single source of truth for the library version (semver)    |
| `metadata.json` | Project metadata (name, description, author, license, URL) |
| `tests.json`    | Canonical test specification for all implementations       |

## Usage

```bash
just version          # print current version
just version 1.0.0    # bump version across all implementations
just metadata         # interactively update metadata across all manifests
```

See [`docs/versioning.md`](../docs/versioning.md) and [`docs/metadata.md`](../docs/metadata.md) for details.

## License

[MIT](../LICENSE.md)
