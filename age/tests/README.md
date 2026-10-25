# Tests

The canonical test specification lives in [`config/tests.json`](../config/tests.json).

Every test case listed there must be implemented in every language. When adding
a new test, add it to `config/tests.json` first, then implement it in all
language test suites and regenerate the CLI harness
(`python3 cli/generate-test-harness.py`).

## Per-language test files

The native test implementations live under each language's directory:

```
age/impl/<lang>/tests/     # or test/, spec/, src/test_*.ext, depending on convention
```

Each language translates the canonical test cases into its native test
framework, annotating each test with its canonical ID (see `meta.annotationPatterns`
in `config/tests.json`).

## Don't trust the native suites alone

Native suites are hand-written per language and can drift from the spec. Two
checks verify the implementations independently of their own tests:

- **CLI harness** (`just test cli`): one harness generated from this spec drives
  every language's CLI through a single `--repl` process.
- **Fuzz test** (`just fuzz`): random requests sent to every language, which must
  all agree.

See [`docs/testing.md`](../../docs/testing.md) for the full approach.

## License

[MIT](../../LICENSE.md)
