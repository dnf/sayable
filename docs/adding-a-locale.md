# Adding a New Locale

This guide covers everything needed to add a new locale to parent-time.
You create one JSON file and codegen generates all 11 language implementations.

## Before you start

1. Check `codegen/locales/` to make sure the locale doesn't already exist
2. Identify the ISO 639-1 code (e.g. `sw` for Swahili)
3. Determine the CLDR plural rule for the language:
   https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

## 1. Identify the plural rule

The project has 23 plural rule patterns. Find the one that matches your
language's CLDR integer plural categories:

| Rule name | Categories | Languages using it |
|-----------|-----------|-------------------|
| `ar` | zero, one, two, few, many, other | ar |
| `br` | one, two, few, many, other | br |
| `cs_sk` | one, few, other | cs, sk |
| `cy` | zero, one, two, few, many, other | cy |
| `ga` | one, two, few, many, other | ga |
| `gd` | one, two, few, other | gd |
| `gv` | one, two, few, other | gv |
| `he` | one, two, other | he |
| `kw` | zero, one, two, few, many, other | kw |
| `lt` | one, few, other | lt |
| `lv` | zero, one, other | lv |
| `mk` | one, other | mk |
| `mt` | one, two, few, many, other | mt |
| `one_other` | one, other | en, de, es, it, nl, bg, da, nb, sv, etc. |
| `one_other_zero_one` | one, other (0 and 1 are both "one") | fr, pt, hi, bn, fa, etc. |
| `other_only` | other | ja, ko, zh, th, vi, ms, jv, hu, eu |
| `pl` | one, few, many | pl |
| `ro` | one, few, other | ro |
| `ru_uk` | one, few, many | ru, uk |
| `shi` | one, few, other | shi |
| `sl` | one, two, few, other | sl |
| `slavic_bcs` | one, few, other | bs, hr, sr |
| `tzm` | one, other | tzm |

These 23 rules cover every CLDR cardinal plural pattern. Your language's
CLDR rule will match one of these — use that rule name.

## 2. Create the JSON file

Create `codegen/locales/{code}.json`. The structure depends on the plural
rule complexity.

### No-plural language (e.g. `other_only`)

Units are plain strings. Every count uses the same form.

```json
{
  "code": "ja",
  "name": "Japanese",
  "pluralRule": "other_only",
  "units": {
    "day": "{n}日",
    "week": "{n}週",
    "month": "{n}ヶ月",
    "year": "{n}歳"
  },
  "half": "{0}半",
  "delimiter": "",
  "justBorn": "新生児",
  "stages": {
    "newborn": "新生児",
    "infant": "乳児",
    "toddler": "幼児",
    "child": "児童",
    "teenager": "青少年",
    "adult": "成人"
  }
}
```

### Simple plural language (e.g. `one_other`)

Units with different singular/plural forms are objects with category keys.
Units that don't change by count can still be plain strings.

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "units": {
    "day": { "one": "{n} day", "other": "{n} days" },
    "week": { "one": "{n} week", "other": "{n} weeks" },
    "month": { "one": "{n} month", "other": "{n} months" },
    "year": { "one": "{n} year", "other": "{n} years" }
  },
  "half": "{n}½",
  "delimiter": ", ",
  "justBorn": "Newborn",
  "stages": {
    "newborn": "Newborn",
    "infant": "Infant",
    "toddler": "Toddler",
    "child": "Child",
    "teenager": "Teenager",
    "adult": "Adult"
  }
}
```

### Complex plural language (e.g. `ar`)

Provide a form for every category the plural rule can return:

```json
{
  "code": "ar",
  "name": "Arabic",
  "pluralRule": "ar",
  "units": {
    "day": {
      "zero": "{n} يوم",
      "one": "يوم",
      "two": "يومان",
      "few": "{n} أيام",
      "many": "{n} يومًا",
      "other": "{n} يوم"
    }
  }
}
```

### Field reference

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | ISO 639-1 language code |
| `name` | string | English name of the language |
| `pluralRule` | string | One of the 12 rule names (see table above) |
| `units` | object | `{day, week, month, year}` — each a string or category map |
| `half` | string | Half-year template (see below) |
| `delimiter` | string | Separator between parts (e.g. `", "`) |
| `justBorn` | string | Label for age 0 (born today) |
| `stages` | object | `{newborn, infant, toddler, child, teenager, adult}` |
| `short` | object? | Optional short-form overrides |
| `compact` | object? | Optional compact-form overrides |

### Units

Each unit (`day`, `week`, `month`, `year`) is either:
- A **string** — used for all counts (e.g. Japanese `"{n}日"`)
- An **object** — maps plural categories to strings (e.g. English
  `{"one": "{n} day", "other": "{n} days"}`)

Use `{n}` as the count placeholder. It gets replaced with the number.

Only include categories that the plural rule can actually return. For
`one_other`, you only need `one` and `other`.

### Half marker

The `half` field formats "3½ years". Two placeholder styles:
- `{n}` — modifies the number: `"{n}½"` produces "3½ years"
- `{0}` — wraps the full expression: `"{0} et demi"` produces "3 ans et demi"

Use `{n}` for compact affixes (½, ½). Use `{0}` when the half marker is a
separate word or phrase that goes after the unit.

### Stages

Stage labels map developmental stages to display names. They can be:
- A **string** — gender-neutral label (e.g. `"Child"`)
- An **object** with `m` and `f` — gendered labels (e.g.
  `{"m": "Adolescent", "f": "Adolescente"}`)

Use gendered labels when the language requires grammatical gender agreement.
See [`gender-and-stages.md`](gender-and-stages.md) for guidance.

The age boundaries for stages are fixed across all locales:
- Newborn: 0–1 months
- Infant: 2–11 months
- Toddler: 12–35 months
- Child: 36–155 months (3–12 years)
- Teenager: 156–215 months (13–17 years)
- Adult: 216+ months (18+ years)

### Short and compact overrides (optional)

These provide abbreviated forms. Only include the fields that differ from
the default. For example, English overrides only units (not stages or half):

```json
{
  "short": {
    "units": {
      "day": "{n} d",
      "week": "{n} wk",
      "month": "{n} mo",
      "year": "{n} yr"
    }
  },
  "compact": {
    "units": {
      "day": "{n}d",
      "week": "{n}w",
      "month": "{n}m",
      "year": "{n}y"
    },
    "delimiter": ""
  }
}
```

Many languages skip short/compact overrides entirely — that's fine.

## 3. Generate and verify

```bash
python -m codegen.generate          # generate all 11 languages
python -m codegen.generate --check  # verify no drift
just test                           # run all test suites
just lint                           # run all linters
```

The generated locale files must pass each language's linter. Long lines in
locale data are expected and acceptable.

## 4. Add tests (optional but encouraged)

For new locales in widely-spoken languages, add locale-specific test cases
to `docs/testing.md` and implement them in all 11 test suites. At minimum,
test that the locale produces correct output for a few representative counts
that exercise the plural rules.

## Native speaker policy

Locale contributions should come from (or be verified by) a native speaker.
If you're a native speaker, mention it in your PR. If not, the PR will be
tagged for native speaker review before merging.

## Checklist

- [ ] ISO 639-1 code confirmed
- [ ] CLDR plural rule identified (existing or new)
- [ ] `codegen/locales/{code}.json` created with all required fields
- [ ] Stage labels reviewed for gender (see `docs/gender-and-stages.md`)
- [ ] `python -m codegen.generate` succeeds
- [ ] `python -m codegen.generate --check` passes
- [ ] `just test` passes
- [ ] `just lint` passes
- [ ] Native speaker verification (self or requested)
