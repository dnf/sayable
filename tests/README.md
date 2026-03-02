# Tests

This directory holds the canonical test specification for parent-time.

## Contents

- **[testing.md](testing.md)** — the single source of truth for all 212 test cases

Every test case listed in `testing.md` must be implemented in every language.
When adding a new test, add it to `testing.md` first, then implement it in all
18 language test suites.

## Per-language test files

The actual test implementations live under each language's directory:

```
src/<lang>/tests/     # or src/<lang>/test/, depending on convention
```

Each language translates the canonical test cases into its native test
framework. See `testing.md` for the test ID annotation convention that links
each implementation back to the spec.

## License

[MIT](../LICENSE.md)
