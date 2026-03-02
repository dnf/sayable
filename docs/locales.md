# Locale Configuration

This document describes the 71 built-in locales in parent-time: how their
plural rules work, why specific choices were made, and how the implementation
relates to the authoritative CLDR (Unicode Common Locale Data Repository) data.

## Canonical source

All locale data is maintained in `locales/*.json` — one JSON file per
locale. These are the single source of truth. The locale files in each language
implementation (e.g. `typescript/src/locales/fr.ts`) are generated from these
JSON definitions by `codegen/generate.py`. See [`codegen/README.md`](../codegen/README.md)
for details on the generator.

To modify a locale, edit its JSON file and run `python -m codegen.generate`.

## Sources

All plural rules are based on CLDR cardinal plural rules:

- **Reference:** https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html
- **Source XML:** https://github.com/unicode-org/cldr/blob/main/common/supplemental/plurals.xml

Stage labels (newborn, infant, toddler, child, teenager, adult) follow
AAP/CDC developmental stage boundaries translated into each target language.

## How plural rules work in parent-time

Each locale provides a `plural(n)` function that takes an integer count and
returns a CLDR plural category: `zero`, `one`, `two`, `few`, `many`, or
`other`. The category selects the correct unit form:

```
plural(1) → 'one'  → "1 year"
plural(5) → 'other' → "5 years"
```

### Integer-only simplification

CLDR plural rules are defined for all real numbers, including decimals. Since
parent-time only ever passes integer counts (days, weeks, months, years), some
CLDR categories that only trigger for decimal values are unreachable and can be
safely simplified:

- **`many` for Czech/Slovak** — CLDR: `v != 0` (only decimals). For integers,
  the catch-all is `other`.
- **`many` for Catalan/Spanish/French/Italian/Portuguese** — CLDR: compact
  decimal notation (`e != 0..5`). Not applicable to integer counts.
- **`other` for Polish/Russian/Ukrainian** — CLDR's `other` category for these
  languages only applies to decimal values. For integers, `many` covers all
  values not matched by `one` or `few`, making the default return of `many`
  functionally correct.

### The `{n}` and `{0}` template system

Unit forms use `{n}` as the count placeholder: `"{n} days"` → `"5 days"`.

The half-year marker supports two placeholder styles:
- `{n}` — modifies the number before unit substitution: `"{n}½"` → `"3½ years"`
- `{0}` — wraps the complete expression after unit substitution: `"{0}半"` →
  `"3歳半"`, `"{0} et demi"` → `"3 ans et demi"`

## Summary table

| Language                | Code  | Categories                  | Plural rule (integers)                                                                                                      | Half marker         |
| ----------------------- | ----- | --------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| Albanian                | `sq`  | one/other                   | n=1→one                                                                                                                     | `{0} e gjysmë`      |
| Amharic                 | `am`  | one/other                   | n∈{0,1}→one                                                                                                                 | `{0} ተኩል`           |
| Arabic                  | `ar`  | zero/one/two/few/many/other | n=0→zero, n=1→one, n=2→two, n%100∈3..10→few, n%100∈11..99→many, else other                                                  | `{0} ونصف`          |
| Azerbaijani             | `az`  | one/other                   | n=1→one                                                                                                                     | `{n} yarım`         |
| Basque                  | `eu`  | other                       | always other (see notes)                                                                                                    | `{0} eta erdi`      |
| Bengali                 | `bn`  | one/other                   | n∈{0,1}→one                                                                                                                 | `সাড়ে {n}`         |
| Bosnian                 | `bs`  | one/few/other               | Slavic: i%10=1,i%100≠11→one; i%10∈2..4,i%100∉12..14→few                                                                     | `{0} i po`          |
| Breton                  | `br`  | one/two/few/many/other      | n%10=1∧n%100∉{11,71,91}→one; n%10=2∧n%100∉{12,72,92}→two; n%10∈{3,4,9}∧n%100∉10..19,70..79,90..99→few; n≠0∧n%1000000=0→many | `{0} hag un hanter` |
| Bulgarian               | `bg`  | one/other                   | n=1→one                                                                                                                     | `{0} и половина`    |
| Burmese                 | `my`  | other                       | always other                                                                                                                | `{0}ခွဲ`            |
| Catalan                 | `ca`  | one/other                   | n=1→one                                                                                                                     | `{n} i mig`         |
| Central Atlas Tamazight | `tzm` | one/other                   | n∈0..1∨n∈11..99→one                                                                                                         | `{0} d uzgen`       |
| Chinese                 | `zh`  | other                       | always other                                                                                                                | `{0}半`              |
| Cornish                 | `kw`  | zero/one/two/few/many/other | n=0→zero, n=1→one, n%100∈{2,22,42,62,82}→two, n%100∈{3,23,43,63,83}→few, n≠1∧n%100∈{1,21,41,61,81}→many                     | `{0} hag hanter`    |
| Croatian                | `hr`  | one/few/other               | Slavic (same as bs)                                                                                                         | `{0} i pol`         |
| Czech                   | `cs`  | one/few/other               | n=1→one, n∈2..4→few                                                                                                         | `{n}½`              |
| Danish                  | `da`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Dutch                   | `nl`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| English                 | `en`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Estonian                | `et`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Filipino                | `fil` | other                       | always other                                                                                                                | `{0} at kalahati`   |
| Finnish                 | `fi`  | one/other                   | n=1→one                                                                                                                     | `{n} ja puoli`      |
| French                  | `fr`  | one/other                   | n∈{0,1}→one                                                                                                                 | `{0} et demi`       |
| Georgian                | `ka`  | one/other                   | n=1→one                                                                                                                     | `{0} და ნახევარი`   |
| German                  | `de`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Greek                   | `el`  | one/other                   | n=1→one                                                                                                                     | `{0} και μισό`      |
| Gujarati                | `gu`  | one/other                   | n∈{0,1}→one                                                                                                                 | `સાડા {n}`          |
| Hebrew                  | `he`  | one/two/other               | n=1→one, n=2→two                                                                                                            | `{0} וחצי`          |
| Hindi                   | `hi`  | one/other                   | n∈{0,1}→one                                                                                                                 | `साढ़े {n}`         |
| Hungarian               | `hu`  | other                       | always other (see notes)                                                                                                    | `{n} és fél`        |
| Indonesian              | `id`  | other                       | always other                                                                                                                | `{0} setengah`      |
| Irish                   | `ga`  | one/two/few/many/other      | n=1→one, n=2→two, n∈3..6→few, n∈7..10→many                                                                                  | `{0} go leith`      |
| Italian                 | `it`  | one/other                   | n=1→one                                                                                                                     | `{0} e mezzo`       |
| Japanese                | `ja`  | other                       | always other                                                                                                                | `{0}半`              |
| Javanese                | `jv`  | other                       | always other                                                                                                                | `{0} setengah`      |
| Kazakh                  | `kk`  | one/other                   | n=1→one                                                                                                                     | `{n} жарым`         |
| Khmer                   | `km`  | other                       | always other                                                                                                                | `{0}កន្លះ`          |
| Korean                  | `ko`  | other                       | always other                                                                                                                | `{0} 반`             |
| Latvian                 | `lv`  | zero/one/other              | n%10=0 or n%100∈11..19→zero; n%10=1,n%100≠11→one                                                                            | `{n}½`              |
| Lithuanian              | `lt`  | one/few/other               | n%10=1,n%100∉11..19→one; n%10∈2..9,n%100∉11..19→few                                                                         | `{n}½`              |
| Macedonian              | `mk`  | one/other                   | n%10=1,n%100≠11→one                                                                                                         | `{0} и пол`         |
| Malay                   | `ms`  | other                       | always other                                                                                                                | `{0} setengah`      |
| Maltese                 | `mt`  | one/two/few/many/other      | n=1→one, n=2→two, n=0∨n%100∈3..10→few, n%100∈11..19→many                                                                    | `{0} u nofs`        |
| Manx                    | `gv`  | one/two/few/other           | n%10=1→one, n%10=2→two, n%100∈{0,20,40,60,80}→few                                                                           | `{0} as lieh`       |
| Marathi                 | `mr`  | one/other                   | n=1→one                                                                                                                     | `साडे {n}`          |
| Nepali                  | `ne`  | one/other                   | n=1→one                                                                                                                     | `साढे {n}`          |
| Norwegian               | `nb`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Persian                 | `fa`  | one/other                   | n∈{0,1}→one                                                                                                                 | `{0} و نیم`         |
| Polish                  | `pl`  | one/few/many                | n=1→one; n%10∈2..4,n%100∉12..14→few; else many                                                                              | `{n} i pół`         |
| Portuguese              | `pt`  | one/other                   | n∈{0,1}→one                                                                                                                 | `{0} e meio`        |
| Punjabi                 | `pa`  | one/other                   | n∈{0,1}→one                                                                                                                 | `ਸਾਢੇ {n}`          |
| Romanian                | `ro`  | one/few/other               | n=1→one; n=0 or n%100∈1..19→few                                                                                             | `{0} și jumătate`   |
| Russian                 | `ru`  | one/few/many                | Slavic: i%10=1,i%100≠11→one; i%10∈2..4,i%100∉12..14→few; else many                                                          | `{n} с половиной`   |
| Scottish Gaelic         | `gd`  | one/two/few/other           | n∈{1,11}→one, n∈{2,12}→two, n∈3..10∪13..19→few                                                                              | `{0} gu leth`       |
| Serbian                 | `sr`  | one/few/other               | Slavic (same as bs/hr)                                                                                                      | `{0} и по`          |
| Sinhala                 | `si`  | one/other                   | n∈{0,1}→one                                                                                                                 | `{0}යි භාගයයි`      |
| Slovak                  | `sk`  | one/few/other               | n=1→one, n∈2..4→few                                                                                                         | `{n}½`              |
| Slovenian               | `sl`  | one/two/few/other           | i%100=1→one, i%100=2→two, i%100∈3..4→few                                                                                    | `{0} in pol`        |
| Spanish                 | `es`  | one/other                   | n=1→one                                                                                                                     | `{n} y medio`       |
| Swahili                 | `sw`  | one/other                   | n=1→one                                                                                                                     | `{0} na nusu`       |
| Swedish                 | `sv`  | one/other                   | n=1→one                                                                                                                     | `{n}½`              |
| Tachelhit               | `shi` | one/few/other               | n∈{0,1}→one, n∈2..10→few                                                                                                    | `{0} d uzgen`       |
| Tamil                   | `ta`  | one/other                   | n=1→one                                                                                                                     | `{0}ரை`             |
| Telugu                  | `te`  | one/other                   | n=1→one                                                                                                                     | `{0}న్నర`           |
| Thai                    | `th`  | other                       | always other                                                                                                                | `{0}ครึ่ง`          |
| Turkish                 | `tr`  | one/other                   | n=1→one                                                                                                                     | `{n} buçuk`         |
| Ukrainian               | `uk`  | one/few/many                | Slavic (same as ru)                                                                                                         | `{n} з половиною`   |
| Urdu                    | `ur`  | one/other                   | n=1→one                                                                                                                     | `ساڑھے {n}`         |
| Uzbek                   | `uz`  | one/other                   | n=1→one                                                                                                                     | `{n} yarim`         |
| Vietnamese              | `vi`  | other                       | always other                                                                                                                | `{0} rưỡi`          |
| Welsh                   | `cy`  | zero/one/two/few/many/other | n=0→zero, n=1→one, n=2→two, n=3→few, n=6→many                                                                               | `{0} a hanner`      |

For the full quick-reference table (with speaker counts, countries, and plural rule
details), see **[locale-reference.md](locale-reference.md)**.

## Locale details by plural family

Detailed documentation for each locale, grouped by plural rule complexity:

- **[No plural distinctions](locales-no-plural.md)** — Japanese, Javanese,
  Korean, Malay, Thai, Vietnamese, Chinese (+ Basque, Hungarian)
- **[Simple one/other](locales-simple-plural.md)** — 21 languages with binary
  singular/plural
- **[Complex plural rules](locales-complex-plural.md)** — Slavic languages,
  Arabic, Romanian, Lithuanian, Latvian, Slovenian, Celtic languages (Welsh,
  Irish, Scottish Gaelic, Manx, Breton, Cornish), Maltese, Berber languages
  (Tachelhit, Central Atlas Tamazight)
