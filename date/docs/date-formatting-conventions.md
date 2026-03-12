# Date Formatting Conventions

This document describes how sayable-date handles the variety of date formatting
conventions found across the world's languages. All locale data is sourced from
the Unicode CLDR (Common Locale Data Repository) and verified against
language-specific references.

## Three compactness levels

Every locale supports three output modes:

| Level | English example (March 15, 2025) | Description |
|-------|----------------------------------|-------------|
| **Normal** | "March 15th" or "next Thursday" | Full month names, ordinal days, weekday references |
| **Short** | "Mar 15" | Abbreviated month names, no ordinal suffix |
| **Compact** | "3/15" or "3/15/25" | Pure numeric |

## Relative date formatting

The most natural way to reference a date depends on how far away it is. sayable-date
uses proximity tiers to choose the right phrasing:

| Offset from today | Output | Example |
|--------------------|--------|---------|
| 0 | today | "today" |
| +1 / -1 | tomorrow / yesterday | "tomorrow" |
| +2 / -2 | day after/before (if locale has it) | "the day after tomorrow" |
| +3 to +6 / -3 to -6 | this/last weekday | "this Thursday" / "last Monday" |
| +7 to +13 | next weekday | "next Wednesday" |
| Beyond | Calendar format | "March 15th" or "March 15, 2025" |

When the date falls in a different calendar year, the year is always included.

In **compact mode**, weekday references are skipped entirely — the formatter goes
straight to numeric calendar format for anything beyond ±2 days.

### Day-after-tomorrow support

Most locales have words for "the day after tomorrow" and "the day before yesterday":

| Language | Day after tomorrow | Day before yesterday |
|----------|-------------------|---------------------|
| English | the day after tomorrow | the day before yesterday |
| German | übermorgen | vorgestern |
| Japanese | 明後日 (asatte) | 一昨日 (ototoi) |
| Russian | послезавтра | позавчера |
| Finnish | ylihuomenna | toissapäivänä |
| Tok Pisin | haptumora | asde bifo |
| Arabic | بعد غد | أول أمس |

Locales that lack these terms skip the ±2 tier and fall through to weekday references.

## Date pattern order

Languages differ in how they order month, day, and year:

### Month-day order (English, French, etc.)

```
"March 15th"          →  datePattern: "{month} {day}"
"March 15, 2025"      →  datePatternWithYear: "{month} {day}, {year}"
```

### Day-month order (German, Russian, Arabic, Finnish, etc.)

```
"15. März"            →  datePattern: "{day} {month}"
"15. März 2025"       →  datePatternWithYear: "{day} {month} {year}"
```

### Year-first order (Japanese, Chinese)

```
"3月15日"              →  datePattern: "{month}{day}"
"2025年3月15日"         →  datePatternWithYear: "{year}年{month}{day}"
```

Note that East Asian languages typically include the year *first* and use no spaces,
with unit markers (年, 月, 日) instead of separators.

## Ordinal day suffixes

The `dayFormat` field controls how day numbers are displayed:

| Language | Pattern | Example | Notes |
|----------|---------|---------|-------|
| English | `{n}th` + exceptions | "1st", "2nd", "3rd", "4th"... | Complex exceptions for 1st/2nd/3rd/21st/22nd/23rd/31st |
| German | `{n}.` | "1.", "2.", "15." | Trailing period (ordinal marker in German) |
| Finnish | `{n}.` | "1.", "15." | Same convention as German |
| Japanese | `{n}日` | "1日", "15日" | Kanji day marker |
| Chinese | `{n}日` | "1日", "15日" | Same as Japanese |
| Russian | `{n}` | "1", "15" | No suffix (case handled by month inflection) |
| Arabic | `{n}` | "١", "١٥" | No suffix |
| Tok Pisin | `{n}` | "1", "15" | No suffix |

English has the most complex ordinal system, requiring `dayFormatExceptions` to
handle the irregular suffixes (1st, 2nd, 3rd, 21st, 22nd, 23rd, 31st — all others
use "th").

## Grammatical case in month names

Some languages inflect month names depending on context. When a month appears in a
date phrase, it may need a different grammatical form than when listed in isolation.

**Russian** uses genitive case in dates:

| Nominative (listing) | Genitive (in date) | Example |
|---------------------|--------------------|---------|
| январь | января | "15 января" (January 15th) |
| февраль | февраля | "3 февраля" (February 3rd) |
| март | марта | "21 марта" (March 21st) |

**Finnish** uses partitive case:

| Nominative | Partitive (in date) |
|-----------|-------------------|
| tammikuu | tammikuuta |
| helmikuu | helmikuuta |
| maaliskuu | maaliskuuta |

These inflected forms are stored in the optional `monthsInDate` array. When present,
the formatter uses `monthsInDate` instead of `months` when rendering date patterns.
This is sourced from CLDR's `months.format.wide` vs `months.stand-alone.wide` data.

#### CLDR sources

- Russian months: [cldr-json/.../ru/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/ru/ca-gregorian.json)
- Finnish months: [cldr-json/.../fi/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/fi/ca-gregorian.json)

## Compact date format variations

Compact mode uses pure numeric formats. The order and separator vary by region:

| Convention | Locales | Pattern | Example |
|-----------|---------|---------|---------|
| Month/Day (US) | English, French | `{m}/{d}` | "3/15" |
| Day.Month. (European) | German, Finnish, Danish | `{d}.{m}.` | "15.3." |
| Day/Month | Russian, Arabic | `{d}/{m}` | "15/3" |
| Year/Month/Day (ISO-like) | Japanese, Chinese | `{yy}/{m}/{d}` | "25/3/15" |

With year included:

| Convention | Pattern | Example |
|-----------|---------|---------|
| US | `{m}/{d}/{yy}` | "3/15/25" |
| European | `{d}.{m}.{yy}` | "15.3.25" |
| Day-first | `{d}/{m}/{yy}` | "15/3/25" |
| Year-first | `{yy}/{m}/{d}` | "25/3/15" |

#### CLDR sources

- Date format patterns: [CLDR Date/Time Symbols](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table)
- Month names: `cldr-json/cldr-dates-full/main/{locale}/ca-gregorian.json` — `months.format.wide` and `months.format.abbreviated`
- Weekday names: Same file, `days.format.wide` and `days.format.abbreviated`

## Short mode abbreviations

Short mode uses abbreviated month and weekday names. These are typically 3 characters
in Latin-script languages but vary for others:

| Language | Full month | Short month | Full weekday | Short weekday |
|----------|-----------|-------------|-------------|--------------|
| English | January | Jan | Sunday | Sun |
| German | Januar | Jan. | Sonntag | So. |
| French | janvier | janv. | dimanche | dim. |
| Japanese | 1月 | 1月 | 日曜日 | 日 |
| Russian | январь | янв. | воскресенье | вс |
| Arabic | يناير | يناير | الأحد | أحد |

East Asian languages (Japanese, Chinese) don't abbreviate month names since they're
already numeric (1月, 2月, etc.). Short weekday names reduce to single characters.

## Adding or modifying locale data

1. Edit `locales/src/{code}.json`
2. Run `just generate locales` from the `date/` directory
3. Run `just test` to verify all implementations pass

When adding a new locale, verify against CLDR data at:
https://github.com/unicode-org/cldr-json/tree/main/cldr-json/cldr-dates-full/main

Key CLDR fields to check:
- `months.format.wide` — full month names (and `stand-alone.wide` if different)
- `months.format.abbreviated` — short month names
- `days.format.wide` / `days.format.abbreviated` — weekday names
- `dateFormats.short` — compact date pattern (day/month order)
