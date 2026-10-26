# Duration Formatting Conventions

This document describes how sayable-duration handles the variety of duration and
relative time formatting conventions found across the world's languages. Plural
rules are sourced from the Unicode CLDR (Common Locale Data Repository).

## Three compactness levels

Every locale supports three output modes:

| Level | English example (5400 seconds) | Description |
|-------|--------------------------------|-------------|
| **Normal** | "1 hour, 30 minutes" | Full unit names with proper pluralization |
| **Short** | "1 h, 30 min" | Abbreviated unit names |
| **Compact** | "1h30min" | Minimal, no delimiter |

## Duration tiers

The formatter automatically selects the right granularity based on the magnitude
of the duration. Larger durations drop smaller units for readability:

| Range | Primary unit | Secondary unit | Example |
|-------|-------------|----------------|---------|
| 0 seconds | — | — | "just now" |
| 1–59 seconds | seconds | — | "42 seconds" |
| 1–4 minutes | minutes | seconds | "3 minutes, 42 seconds" |
| 5–59 minutes | minutes | — | "15 minutes" |
| 1–5 hours | hours | minutes | "2 hours, 30 minutes" |
| 6–23 hours | hours | — | "8 hours" |
| 1 day | days | hours | "1 day, 12 hours" |
| 2–6 days | days | — | "4 days" |
| 1–4 weeks | weeks | days | "2 weeks, 3 days" |
| 1+ months | months | — | "3 months" |
| 1+ years | years | months | "2 years, 6 months" |

Month length uses the average Gregorian month (30.44 days = 2,629,744 seconds).

### Half values

When a secondary unit is exactly half the primary unit (e.g., 30 minutes in an
hour, 12 hours in a day), the formatter uses a half-marker instead:

| Language | Normal | With half marker |
|----------|--------|-----------------|
| English | "1 hour, 30 minutes" | "1½ hours" |
| German | "1 Stunde, 30 Minuten" | "1½ Stunden" |
| Finnish | "1 tunti, 30 minuuttia" | "1 ja puoli tuntia" |
| Japanese | "1時間30分" | "1時間半" |
| Russian | "1 час, 30 минут" | "1 с половиной часа" |
| Arabic | "ساعة واحدة و30 دقيقة" | "ساعة واحدة ونصف" |
| Tok Pisin | "1 aua, 30 minit" | "1 na hap aua" |

When the half marker is present, the plural category is forced to "other"
(e.g., "1½ hours" not "1½ hour").

## Plural rules

Duration formatting requires correct pluralization for every unit. sayable-duration
implements all 23 CLDR cardinal plural rules. Here are the most common patterns:

### Simple: one/other (English, German, French, Finnish, etc.)

Two forms — singular for exactly 1, plural for everything else:

```
1 → "1 second"    (one)
5 → "5 seconds"   (other)
```

### No distinction: other only (Japanese, Chinese, Tok Pisin, etc.)

One form for all counts — the language has no singular/plural distinction:

```
1 → "1秒"
5 → "5秒"
```

### Slavic: one/few/many/other (Russian, Ukrainian, etc.)

Four forms based on complex modular arithmetic:

```
1  → "1 секунда"    (one: n%10==1, n%100≠11)
2  → "2 секунды"    (few: n%10 in 2-4, n%100 not in 12-14)
5  → "5 секунд"     (many: n%10==0, or n%10 in 5-9, or n%100 in 11-14)
```

### Arabic: zero/one/two/few/many/other

Six forms — the most complex plural system in CLDR:

```
0   → "٠ ثانية"      (zero)
1   → "ثانية واحدة"   (one: special phrasing)
2   → "ثانيتان"       (two: dual form)
3   → "٣ ثوانٍ"       (few: 3-10)
11  → "١١ ثانية"      (many: 11-99)
100 → "١٠٠ ثانية"     (other: 100+)
```

#### CLDR source

All plural rules follow CLDR cardinal plural rules:
- [CLDR Language Plural Rules](https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html)
- [Source XML (plurals.xml)](https://github.com/unicode-org/cldr/blob/main/common/supplemental/plurals.xml)

## Relative time: ago and in future

The `format_since` and `format_until` functions wrap a formatted duration with
directional context:

| Language | Past template | Future template | Example |
|----------|--------------|-----------------|---------|
| English | `{0} ago` | `in {0}` | "3 hours ago" / "in 3 hours" |
| German | `vor {0}` | `in {0}` | "vor 3 Stunden" |
| French | `il y a {0}` | `dans {0}` | "il y a 3 heures" |
| Japanese | `{0}前` | `{0}後` | "3時間前" / "3時間後" |
| Russian | `{0} назад` | `через {0}` | "3 часа назад" |
| Arabic | `منذ {0}` | `بعد {0}` | "منذ ٣ ساعات" |
| Finnish | `{0} sitten` | `{0} kuluttua` | "3 tuntia sitten" |
| Tok Pisin | `{0} i go pinis` | `long {0}` | "3 aua i go pinis" |

The `{0}` placeholder is replaced with the formatted duration string.

## Delimiter conventions

Languages differ in how they join multiple time units:

| Language | Delimiter | Example |
|----------|-----------|---------|
| English | `", "` | "2 hours, 30 minutes" |
| German | `", "` | "2 Stunden, 30 Minuten" |
| Arabic | `" و"` | "ساعتان و30 دقيقة" (with Arabic conjunction) |
| Japanese | `""` (none) | "2時間30分" |
| Chinese | `""` (none) | "2小时30分钟" |

In compact mode, most locales remove the delimiter entirely.

## Short and compact unit abbreviations

Each locale provides abbreviated unit forms for short and compact modes:

| Language | Normal | Short | Compact |
|----------|--------|-------|---------|
| English | "3 minutes" | "3 min" | "3min" |
| German | "3 Minuten" | "3 Min." | "3 Min." |
| French | "3 minutes" | "3 min" | "3min" |
| Japanese | "3分" | "3 分" | "3m" |
| Russian | "3 минуты" | "3 мин" | "3 мин" |

Note that Japanese compact uses Latin single-letter abbreviations (`s`, `m`, `h`)
rather than kanji — a convention borrowed from international/technical contexts.

## Adding or modifying locale data

1. Edit the `duration` section of `locales/{code}.json` at the repository root (one file per language, shared by all four libraries)
2. Run `just generate locales` from the repository root (it regenerates every library's locale code and `docs/locales/{code}.md`)
3. Run `just check`, `just test cli` and the native suites to verify all implementations pass

See [`docs/adding-a-locale.md`](../../docs/adding-a-locale.md) for every field of the `duration` section.

When adding a new locale, verify plural rules against CLDR:
- [CLDR Cardinal Plural Rules](https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html)
- Identify which of the 23 existing plural rule patterns covers the language
- Use the `pluralRule` field to select the correct pattern

Key CLDR fields to check:
- `units.long` — full unit names with plural forms
- `units.short` — abbreviated unit names
- `units.narrow` — compact unit names
- `fields.*.relativeTime` — relative time patterns (ago/in future)
