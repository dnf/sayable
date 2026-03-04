# sayable-date Tests

All test cases are defined in [`../config/tests.json`](../config/tests.json).

Every implementation must pass the full canonical test suite. Test files annotate each test with the corresponding ID from `tests.json`.

## Running Tests

```bash
# Python
cd date/impl/python && uv run --extra dev pytest tests/ -v

# TypeScript
cd date/impl/typescript && npx vitest run
```
