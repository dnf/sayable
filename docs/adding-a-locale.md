# Adding a New Locale

A locale is one JSON file, `locales/<code>.json`, shared by all four libraries
(age, date, duration, time). You write that file; `just generate locales` turns it
into locale code for every library in every language implementation, plus the
example page `docs/locales/<code>.md` and a row in the [`locales/README.md`](../locales/README.md)
index. Never edit the generated files by hand.

This guide covers the file format, the 23 plural rules, generating and
verifying, and adding canonical tests.

## Before you start

1. Check [`locales/`](../locales/) to make sure the locale doesn't already exist.
2. Pick the code. Use the ISO 639-1 code when there is one (`sw` for Swahili),
   otherwise ISO 639-3 (`bci` for Baoulé, `kek` for Q'eqchi'). The file name,
   the `code` field and every generated identifier come from it.
3. Find the language's CLDR cardinal plural rule:
   https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
4. Gather CLDR data for the language: month and weekday names, date and time
   formats, unit names and relative-time patterns
   (https://github.com/unicode-org/cldr-json). The per-library convention docs
   explain which CLDR fields map to which keys:
   [age locales](../age/docs/locales.md),
   [date](../date/docs/date-formatting-conventions.md),
   [duration](../duration/docs/duration-formatting-conventions.md),
   [time](../time/docs/time-formatting-conventions.md).

## 1. Choose the plural rule

Age and duration pick a unit form by count, so the locale names one of 23
plural rules. Each rule's logic lives in code, once per target language, in
`age/codegen/targets/<lang>/plural_rules.py` and
`duration/codegen/targets/<lang>/plural_rules.py`; the JSON only names it.
Date and time don't use plurals.

| Rule                 | Categories it returns               | Locales using it today                         |
| -------------------- | ----------------------------------- | ---------------------------------------------- |
| `other_only`         | other                               | ja, ko, zh, th, vi, id, ms, hu, eu, and others |
| `one_other`          | one (n = 1), other                  | en, de, es, it, nl, sv, tr, sw, and others     |
| `one_other_zero_one` | one (n = 0 or 1), other             | fr, pt, hi, bn, fa, am, zu, and others         |
| `ar`                 | zero, one, two, few, many, other    | ar                                             |
| `br`                 | one, two, few, many, other          | br                                             |
| `cs_sk`              | one, few, other                     | cs, sk                                         |
| `cy`                 | zero, one, two, few, many, other    | cy                                             |
| `ga`                 | one, two, few, many, other          | ga                                             |
| `gd`                 | one, two, few, other                | gd                                             |
| `gv`                 | one, two, few, other                | gv                                             |
| `he`                 | one, two, other                     | he                                             |
| `kw`                 | zero, one, two, few, many, other    | kw                                             |
| `lt`                 | one, few, other                     | lt                                             |
| `lv`                 | zero, one, other                    | lv                                             |
| `mk`                 | one (ends in 1, not 11), other      | is, mk                                         |
| `mt`                 | one, two, few, many, other          | mt                                             |
| `pl`                 | one, few, many                      | pl                                             |
| `ro`                 | one, few, other                     | ro                                             |
| `ru_uk`              | one, few, many                      | be, ru, uk                                     |
| `shi`                | one, few, other                     | shi                                            |
| `sl`                 | one, two, few, other                | sl                                             |
| `slavic_bcs`         | one, few, other                     | bs, hr, sr                                     |
| `tzm`                | one, other                          | tzm                                            |

These cover every CLDR integer cardinal pattern, so your language's rule
matches one of them. Rules with the same categories differ in which numbers
fall in each (compare `cs_sk`, `lt`, `ro` and `slavic_bcs`), so match the CLDR
conditions, not just the category names. The exact conditions are in
`age/codegen/targets/python/plural_rules.py`. The full list of locales per rule
is in [`locales/README.md`](../locales/README.md).

If a language really needs a new rule, that is a code change, not a locale
change: add it to every target's `plural_rules.py` in both age and duration and
open an issue first.

## 2. Create `locales/<code>.json`

The file has the shared fields, then one section per library. Every section
is required: a locale exists in all four libraries or in none.

```json
{
  "code": "fr",
  "name": "French",
  "pluralRule": "one_other_zero_one",
  "age": { ... },
  "date": { ... },
  "duration": { ... },
  "time": { ... }
}
```

| Field        | Description                                                         |
| ------------ | ------------------------------------------------------------------- |
| `code`       | Locale code; must match the file name                               |
| `name`       | English name of the language, as shown in the docs                  |
| `pluralRule` | One of the 23 rule names above (used by age and duration)           |
| `review`     | Optional. Notes on data you are not sure of (see below)             |

### Review notes

If you are not confident in part of the data, say so in a `review` list instead
of leaving it silent. Each note names the section, a confidence (`low` or
`medium`) and what a native speaker should check:

```json
"review": [
  {
    "section": "time.clock",
    "confidence": "low",
    "note": "Additive '<hour> and <minutes>' form; unsure whether speakers use a 'to' idiom after :30."
  }
]
```

No library reads `review`. The docs generator shows the notes at the top of
`docs/locales/<code>.md` and collects them all in
[`docs/locales/README.md`](locales/README.md), where linguists look for work.
When the data has been checked and fixed, delete the note.

Each library's codegen sees the shared fields plus its own section
(`load_component_locales()` in `tools/codegen_util.py`), so within a
section the keys below are exactly what that library reads. Start by copying
the closest existing locale, a related language with the same plural rule,
and translate it. [`locales/fr.json`](../locales/fr.json) and
[`locales/en.json`](../locales/en.json) are good complete references.

### Templates and placeholders

Every text value is a template. Placeholders by library:

| Placeholder                    | Where                                    | Replaced with                            |
| ------------------------------ | ---------------------------------------- | ---------------------------------------- |
| `{n}`                          | age and duration `units`, `half`; date `dayFormat` | The number                     |
| `{0}`                          | `half`; duration `ago` / `inFuture`      | The whole formatted expression           |
| `{month}`, `{day}`, `{year}`   | date `datePattern*`                      | Month name, formatted day, 4-digit year  |
| `{d}`, `{m}`, `{yy}`           | date `datePattern*` (compact)            | Day number, month number, 2-digit year   |
| `{weekday}`                    | date `thisWeekday` / `nextWeekday` / `lastWeekday` | Weekday name                   |
| `{h}`, `{next_h}`              | time `clock.patterns`                    | This hour's / the next hour's name       |
| `{h}`, `{mm}`, `{ampm}`        | time `short` / `compact` `clock.format`  | Hour digits, 2-digit minutes, AM/PM label |

### Unit forms (age and duration)

A unit is either:

- a **string**, used for every count: `"month": "{n} mois"` (French months
  don't inflect), `"day": "{n}日"` (Japanese);
- an **object** keyed by plural category: `{"one": "{n} jour", "other": "{n} jours"}`.

Give a form for every category your rule can return, and **always include
`other`**: it is the fallback, and implementations require it even for rules
that never return it (`pl` and `ru_uk` return `many`, not `other`, but their
files still have `other`). A form may drop `{n}` when the language says the
count in the word itself, as Arabic does for one and two.

From [`locales/ar.json`](../locales/ar.json) (`ar` rule, six categories):

```json
"day": {
  "zero": "{n} يوم",
  "one": "يوم",
  "two": "يومان",
  "few": "{n} أيام",
  "many": "{n} يومًا",
  "other": "{n} يوم"
}
```

From [`locales/pl.json`](../locales/pl.json) (`pl` rule: one, few, many, plus the required `other`):

```json
"year": { "one": "{n} rok", "few": "{n} lata", "many": "{n} lat", "other": "{n} lat" }
```

### The half marker (age and duration)

`half` formats "and a half". It takes one of two placeholders:

- `{n}` modifies the number before the unit is applied: `"{n}½"` gives
  "3½ years"; Hindi `"साढ़े {n}"` gives "साढ़े 3 साल".
- `{0}` wraps the whole unit expression afterwards: `"{0} et demi"` gives
  "3 ans et demi"; Arabic `"{0} ونصف"`; Japanese `"{0}半"` gives "3歳半".

Age uses it for 3 to 6 years when 6 or more months have passed; the plural
form comes from the whole number of years. Duration uses it for 1 to 5 hours
plus exactly 30 minutes and for 1 or 2 days plus exactly 12 hours, and always
uses the `other` form there ("1½ hours", not "1½ hour").

### Short and compact overrides

Every library supports three compactness levels: normal, `short` and
`compact`. The `short` and `compact` objects inside a section override only the
keys they contain; anything left out falls back to the normal value (for
units, unit by unit). All 168 current locales give both objects in every
section; do the same. CLDR's `short` and `narrow` unit and date data are the
usual source.

### `age` section

Formats ages ("6 weeks", "14 months", "3½ years") and developmental stages.
Types: `AgeLocale` (in Python,
`age/impl/python/src/sayable_age/locale.py`).

| Key         | Required | Description                                                               |
| ----------- | -------- | ------------------------------------------------------------------------- |
| `units`     | yes      | `day`, `week`, `month`, `year`; each a unit form                          |
| `half`      | yes      | Half-year template (`{n}` or `{0}`)                                       |
| `delimiter` | yes      | Joins two parts: "2 weeks, 3 days", "2 years, 1 month"                     |
| `justBorn`  | yes      | Output for an age of 0 days                                               |
| `stages`    | yes      | `newborn`, `infant`, `toddler`, `child`, `teenager`, `adult`; each a label |
| `short`     | yes      | Overrides: `units`, `half`, `delimiter`, `justBorn`                       |
| `compact`   | yes      | Same keys as `short`; usually `delimiter: ""` and terse units             |

Output tiers, for reference when choosing forms: 0 days is `justBorn`; 1 to 6
days; weeks and days until 3 calendar months; months from 3 to 23; years and
months from 24 to 35 months; years with the half marker from 3 to 6; whole
years from 7.

**Stages** are labels for fixed age ranges, the same in every locale:
newborn under 2 months, infant 2 to 11 months, toddler 12 to 35 months, child
3 to 12 years, teenager 13 to 17 years, adult 18 and over. A label is a plain
string, or `{"m": ..., "f": ...}` when the language marks grammatical gender.
Callers pass a gender to `format_stage`; `f` picks the feminine form and
anything else the masculine one. Use the gendered form only where the language
needs it, and read [`age/docs/gender-and-stages.md`](../age/docs/gender-and-stages.md)
first. Polish genders only two stages:

```json
"stages": {
  "newborn": "Noworodek",
  "infant": "Niemowlę",
  "toddler": "Maluch",
  "child": "Dziecko",
  "teenager": { "m": "Nastolatek", "f": "Nastolatka" },
  "adult": { "m": "Dorosły", "f": "Dorosła" }
}
```

French `age` section, complete:

```json
"age": {
  "units": {
    "day": { "one": "{n} jour", "other": "{n} jours" },
    "week": { "one": "{n} semaine", "other": "{n} semaines" },
    "month": "{n} mois",
    "year": { "one": "{n} an", "other": "{n} ans" }
  },
  "half": "{0} et demi",
  "delimiter": ", ",
  "justBorn": "Nouveau-né",
  "stages": {
    "newborn": { "m": "Nouveau-né", "f": "Nouveau-née" },
    "infant": "Nourrisson",
    "toddler": "Tout-petit",
    "child": "Enfant",
    "teenager": { "m": "Adolescent", "f": "Adolescente" },
    "adult": "Adulte"
  },
  "short": {
    "units": { "day": "{n} j", "week": "{n} sem.", "month": "{n} m.", "year": { "one": "{n} an", "other": "{n} ans" } }
  },
  "compact": {
    "units": { "day": "{n}j", "week": "{n}sem.", "month": "{n}m.", "year": "{n}a" },
    "delimiter": "",
    "half": "{n}½"
  }
}
```

### `date` section

Formats calendar dates ("March 15th", "15. März") and picks relative
references ("tomorrow", "next Thursday"). Types: `DateLocale` (in Python,
`date/impl/python/src/sayable_date/locale.py`).

| Key                   | Required | Description                                                                   |
| --------------------- | -------- | ----------------------------------------------------------------------------- |
| `months`              | yes      | 12 month names, January first                                                 |
| `weekdays`            | yes      | 7 weekday names, **Sunday first**                                             |
| `dayFormat`           | yes      | Template for the day of the month: `"{n}"`, `"{n}."`, `"{n}th"`, `"{n}日"`    |
| `dayFormatExceptions` | no       | Day number → template, for ordinals: English `{"1": "{n}st", "2": "{n}nd", ...}`, French `{"1": "{n}er"}` |
| `datePattern`         | yes      | Date without year: `"{month} {day}"`, `"{day} {month}"`                       |
| `datePatternWithYear` | yes      | Date with year: `"{month} {day}, {year}"`                                     |
| `monthsInDate`        | no       | 12 month names used inside dates when they differ from `months` (genitive)    |
| `today`, `tomorrow`, `yesterday` | yes | Offsets 0, +1, −1                                                  |
| `dayAfterTomorrow`, `dayBeforeYesterday` | no | Offsets +2, −2; leave out if the language has no single word or common phrase |
| `thisWeekday`         | yes      | +2 to +6 days: `"this {weekday}"`                                             |
| `nextWeekday`         | yes      | +7 to +13 days: `"next {weekday}"`                                            |
| `lastWeekday`         | yes      | −2 to −6 days: `"last {weekday}"`                                             |
| `short`               | yes      | Overrides: `months`, `weekdays`, `dayFormat`, `datePattern`, `datePatternWithYear` |
| `compact`             | yes      | Overrides: `datePattern`, `datePatternWithYear` (numeric, with `{d}`, `{m}`, `{yy}`) |

Things to know:

- `format_relative` falls back to the calendar date beyond the weekday ranges,
  adding the year only when it differs from the reference date's. In compact
  mode it skips the +2/−2 and weekday phrases entirely.
- **`monthsInDate`** is for languages whose month inside a date takes another
  case: Polish `months` has "marzec" but dates say "15 marca". When present it
  is used in every compactness level, so `short.months` doesn't appear in
  dates for that locale (cs, fi, pl, ru, sk, uk and others keep the full
  genitive in short dates; see the date tests' "Short month names" section).
- Setting `short.dayFormat` without exceptions drops the exceptions in short
  mode, which is how English short dates read "Mar 1" rather than "Mar 1st".
- Weekday phrases use the short weekday names in short mode.

French `date` section (month and weekday lists shortened here):

```json
"date": {
  "months": ["janvier", "février", "mars", ..., "décembre"],
  "weekdays": ["dimanche", "lundi", "mardi", ..., "samedi"],
  "dayFormat": "{n}",
  "dayFormatExceptions": { "1": "{n}er" },
  "datePattern": "{day} {month}",
  "datePatternWithYear": "{day} {month} {year}",
  "today": "aujourd'hui",
  "tomorrow": "demain",
  "yesterday": "hier",
  "dayAfterTomorrow": "après-demain",
  "dayBeforeYesterday": "avant-hier",
  "thisWeekday": "ce {weekday}",
  "nextWeekday": "{weekday} prochain",
  "lastWeekday": "{weekday} dernier",
  "short": {
    "months": ["janv.", "févr.", "mars", ..., "déc."],
    "weekdays": ["dim", "lun", "mar", "mer", "jeu", "ven", "sam"],
    "dayFormat": "{n}",
    "datePattern": "{day} {month}",
    "datePatternWithYear": "{day} {month} {year}"
  },
  "compact": { "datePattern": "{d}/{m}", "datePatternWithYear": "{d}/{m}/{yy}" }
}
```

### `duration` section

Formats lengths of time ("3 minutes, 42 seconds", "2½ hours") and relative
time ("3 days ago", "in 2 hours"). Types: `DurationLocale` (in Python,
`duration/impl/python/src/sayable_duration/locale.py`).

| Key         | Required | Description                                                                      |
| ----------- | -------- | -------------------------------------------------------------------------------- |
| `units`     | yes      | `second`, `minute`, `hour`, `day`, `week`, `month`, `year`; each a unit form     |
| `half`      | yes      | Half template for hours and days (`{n}` or `{0}`)                                |
| `delimiter` | yes      | Joins two parts: "1 hour, 15 minutes"                                            |
| `justNow`   | yes      | Output for 0 seconds, in every compactness level                                 |
| `ago`       | yes      | Past wrapper around the duration: `"{0} ago"`, `"il y a {0}"`, `"منذ {0}"`       |
| `inFuture`  | yes      | Future wrapper: `"in {0}"`, `"dans {0}"`                                         |
| `short`     | yes      | Overrides: `units`, `half`, `delimiter`, `ago`, `inFuture`                       |
| `compact`   | yes      | Same keys as `short`                                                             |

Some existing files also carry a `clock` object inside `duration` (and inside
its `short`/`compact`). No duration code reads it; clock data belongs in the
`time` section, so don't add one.

English `duration` section (short units shortened here):

```json
"duration": {
  "units": {
    "second": { "one": "{n} second", "other": "{n} seconds" },
    "minute": { "one": "{n} minute", "other": "{n} minutes" },
    "hour": { "one": "{n} hour", "other": "{n} hours" },
    "day": { "one": "{n} day", "other": "{n} days" },
    "week": { "one": "{n} week", "other": "{n} weeks" },
    "month": { "one": "{n} month", "other": "{n} months" },
    "year": { "one": "{n} year", "other": "{n} years" }
  },
  "half": "{n}½",
  "delimiter": ", ",
  "justNow": "just now",
  "ago": "{0} ago",
  "inFuture": "in {0}",
  "short": { "units": { "second": "{n}s", "minute": "{n}m", ... }, "ago": "{0} ago", "inFuture": "in {0}" },
  "compact": { "units": { "second": "{n}s", "minute": "{n}m", ... }, "delimiter": "", "ago": "{0} ago", "inFuture": "in {0}" }
}
```

### `time` section

Tells clock time the way people say it ("a quarter past three") in normal
mode, and as digits in short and compact. Types: `TimeLocale` (in Python,
`time/impl/python/src/sayable_time/locale.py`).

| Key                  | Required | Description                                                                 |
| -------------------- | -------- | --------------------------------------------------------------------------- |
| `clock.hours`        | yes      | 12 hour names; index 0 is twelve (used for 00 and 12 o'clock)               |
| `clock.midnight`     | yes      | 00:00 (after rounding)                                                      |
| `clock.noon`         | yes      | 12:00 (after rounding)                                                      |
| `clock.patterns`     | yes      | Keys `"0"`, `"5"`, ... `"55"`: one template per 5-minute bucket, with `{h}` and `{next_h}` |
| `short.clock`        | yes      | Digital format: `use24h`, `format`, and `amPm` (two labels) when `use24h` is false |
| `compact.clock`      | yes      | Same keys as `short.clock`, usually terser                                  |

Minutes round to the nearest 5, so 14:58 reads as three o'clock. Use
`{next_h}` in patterns that count toward the next hour (English "a quarter to
{next_h}", Polish "piętnaście do {next_h}"); `{h}` is always the current hour,
so a "to" pattern written with `{h}` names the wrong hour. If the language counts
upward only, use `{h}` throughout. Hour names take whatever form the patterns need: Polish
uses ordinals ("trzecia"), and French puts the noun in each name ("une heure", "deux
heures") so hour one gets the singular.

The digital `format` follows CLDR's short time format: `"{h}:{mm}"` for most
24-hour locales, `"{h}.{mm}"` for Danish, Finnish and Indonesian.

Normal-mode patterns are always words, never digits. Where a language has no
"past/to" idiom, use the plain spoken "hour and minutes" form with the minutes
spelled out. If you aren't sure the phrasing is what speakers say, write your
best version and add a `review` note saying what to check. See
[`time/docs/time-formatting-conventions.md`](../time/docs/time-formatting-conventions.md).

French `time` section (hour list shortened here):

```json
"time": {
  "clock": {
    "hours": ["douze heures", "une heure", "deux heures", ..., "onze heures"],
    "midnight": "minuit",
    "noon": "midi",
    "patterns": {
      "0": "{h}", "5": "{h} cinq", "10": "{h} dix",
      "15": "{h} et quart", "20": "{h} vingt", "25": "{h} vingt-cinq",
      "30": "{h} et demie", "35": "{next_h} moins vingt-cinq", "40": "{next_h} moins vingt",
      "45": "{next_h} moins le quart", "50": "{next_h} moins dix", "55": "{next_h} moins cinq"
    }
  },
  "short": { "clock": { "use24h": true, "format": "{h}:{mm}" } },
  "compact": { "clock": { "use24h": true, "format": "{h}h{mm}" } }
}
```

English's 12-hour clock: `"short": { "clock": { "use24h": false, "amPm": ["AM", "PM"], "format": "{h}:{mm} {ampm}" } }`.

## 3. Generate

```bash
just generate locales
```

This runs each library's codegen (`<library>/codegen/generate.py`, which writes
`<library>/impl/<lang>/.../locales/` in every language) and then
`tools/generate_locale_docs.py`, which writes `docs/locales/<code>.md` and
updates `locales/README.md`. A missing section or required key fails here
with a `KeyError` naming it. A missing plural category doesn't, so check the
forms against the rule yourself.

Then open `docs/locales/<code>.md`. It shows real output from all four
libraries for your data, across all three compactness levels: this is the page
to review, and to send a native speaker. To try other inputs, use the Python
CLI, which runs from source:

```bash
cli/impl/python/sayable age 2020-06-15 -d 2025-01-01 -l <code>
cli/impl/python/sayable stage 2010-01-01 -d 2025-01-01 -l <code> -g f
cli/impl/python/sayable relative 2025-03-21 -d 2025-03-15 -l <code>
cli/impl/python/sayable duration 5400 -l <code> --short
cli/impl/python/sayable time 15:15 -l <code> --compact
```

A new locale also changes the language coverage maps. Run
`just generate geography` (it needs `uv`) and commit the result. If the
language isn't listed for the countries where it's spoken, add it to
`tools/geography/countries.json`.

## 4. Verify

```bash
just check         # generated code, locale docs, geography, Dockerfile, workflows all current
just test          # native suites (and codegen unit tests) in parallel
just test cli      # canonical tests for all four libraries, through every language's CLI
just fuzz          # random requests across all locales; every CLI must agree
just lint          # generated files must pass each language's linter
```

From the repository root, `just test` runs each language's age suite. The
date, duration and time suites run from their own directories
(`cd date && just test`) for the languages those justfiles list, and every
language's CI workflow (`.hecatron/languages/<lang>/workflow.yml`) runs all
four. `just test cli` and `just fuzz` cover all four libraries in every
language that has a CLI.

Long lines in generated locale files are expected and allowed. If a locale
code is a reserved word somewhere (`is` and `or` already are), the emitters
already rename it; a new clash shows up as a build or lint failure.

## 5. Add canonical tests

Tests are spec-first: a case goes into the library's `config/tests.json`
before any implementation:

- `age/config/tests.json`: section 29 ("Locale-specific edge cases — plural
  rules") is the place for a locale's plural forms, `justBorn`, half marker and
  gendered stages.
- `date/config/tests.json`: "Locale — <Language>" sections, for ordinals,
  genitive months and relative words.
- `duration/config/tests.json` and `time/config/tests.json`: "Locale —
  <Language>" sections.

Follow the shape of neighbouring cases (each has an `id`, `function` or
`method`, `input`, `locale`, `expected`, and optionally `compactness` and
`notes`), with explicit inputs and reference dates, never "today". Take
expected strings from a native speaker, not from the generated output.

For a complex plural rule, cover each category the rule can return with a
count that reaches it (for `pl`: 1, 2, 5, 22, 25), plus the half marker and
any gendered stage.

Then:

1. Regenerate the CLI harness: `python3 cli/generate-test-harness.py`, then
   `just test cli`. The new cases now run against every CLI.
2. Implement the new IDs in each language's native suite, annotated with
   their canonical ID (`// 29.40`), as for every other test.

A locale without new tests is acceptable; it is still covered by the fuzz test
and the generated example page. Widely spoken languages, complex plural rules
and locales with gendered stages should get tests.

## Native speaker policy

Locale contributions should come from, or be checked by, a native speaker.
If you are one, say so in your PR. If not, the PR will be tagged for native
speaker review before merging.

## Checklist

- [ ] Code confirmed (ISO 639-1, or 639-3 if there's no two-letter code)
- [ ] CLDR plural rule matched to one of the 23 rules
- [ ] `locales/<code>.json` created with `code`, `name`, `pluralRule` and the `age`, `date`, `duration` and `time` sections
- [ ] Every unit form has `other` and a form for each category the rule returns
- [ ] `short` and `compact` overrides given in every section
- [ ] Stage labels reviewed for gender (`age/docs/gender-and-stages.md`)
- [ ] `just generate locales` run; `docs/locales/<code>.md` reviewed
- [ ] `just generate geography` run (and `tools/geography/countries.json` updated if needed)
- [ ] `just check`, `just test`, `just test cli`, `just fuzz` and `just lint` pass
- [ ] Canonical tests added to the libraries' `config/tests.json` (if any), harness regenerated, native suites updated
- [ ] Native speaker verification (self or requested)
