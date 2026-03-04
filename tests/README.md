# Tests

The canonical test specification lives in [`config/tests.json`](../config/tests.json).

Every test case listed there must be implemented in every language. When adding
a new test, add it to `config/tests.json` first, then implement it in all
language test suites.

## Per-language test files

The actual test implementations live under each language's directory:

```
src/<lang>/tests/     # or src/<lang>/test/, depending on convention
```

Each language translates the canonical test cases into its native test
framework. See `config/tests.json` for the test ID annotation convention that
links each implementation back to the spec.

## License

[MIT](../LICENSE.md)
