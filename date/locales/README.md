# sayable-date Locales

The `src/` directory contains 71 canonical locale JSON files — one per locale. These are the single source of truth for all date formatting data.

## Editing Locales

Edit the JSON files directly, then regenerate:

```bash
cd date && python -m codegen.generate
```

## Adding a Locale

1. Create `src/{code}.json` following the schema of `src/en.json`
2. Run `cd date && python -m codegen.generate`
3. Run tests to verify

## Locale Schema

See the plan document or `src/en.json` for the full schema reference.
