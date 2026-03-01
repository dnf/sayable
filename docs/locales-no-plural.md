# Locales: No Plural Distinctions

Languages where all counts use the same word form. The plural function returns
`'other'` for every input.

**CLDR source:** https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

---

## True no-plural languages

These languages have no grammatical number distinction. Nouns do not change
form based on count. The CLDR defines only the `other` category.

### Japanese (`ja`)

**CLDR categories:** other

Japanese uses counter words (助数詞) rather than plural inflection. The unit
suffixes are single strings, not plural-form maps:

| Unit | Form | Example |
|------|------|---------|
| day | `{n}日` | 5日 |
| week | `{n}週` | 2週 |
| month | `{n}ヶ月` | 6ヶ月 |
| year | `{n}歳` | 3歳 |

**Half marker:** `{0}半` (postfix) — "3歳半" (3 and a half years old).

**Delimiter:** empty string — "2週3日" not "2週, 3日".

**Note:** `歳` (sai) is used for age rather than `年` (nen, which means
"year" as a time unit). This is the standard counter for human age in Japanese.

### Korean (`ko`)

**CLDR categories:** other

Korean does not inflect nouns for number. Like Japanese, it uses counters.

| Unit | Form | Example |
|------|------|---------|
| day | `{n}일` | 5일 |
| week | `{n}주` | 2주 |
| month | `{n}개월` | 6개월 |
| year | `{n}살` | 3살 |

**Half marker:** `{0} 반` — "3살 반" (3 and a half years old).

**Delimiter:** space — "2주 3일".

**Note:** `살` is the native Korean counter for age. `세` (Sino-Korean) is
used in formal/medical contexts but `살` is what parents say.

### Chinese (`zh`)

**CLDR categories:** other

Chinese (Simplified) has no plural morphology. Measure words serve a similar
role to Japanese counters.

| Unit | Form | Example |
|------|------|---------|
| day | `{n}天` | 5天 |
| week | `{n}周` | 2周 |
| month | `{n}个月` | 6个月 |
| year | `{n}岁` | 3岁 |

**Half marker:** `{0}半` (postfix) — "3岁半".

**Delimiter:** empty string — "2周3天".

**Note:** `岁` is the standard age counter. `年` means "year" as duration.

### Thai (`th`)

**CLDR categories:** other

Thai has no plural forms. Classifiers are used with numerals but the noun
itself does not change.

| Unit | Form | Example |
|------|------|---------|
| day | `{n} วัน` | 5 วัน |
| week | `{n} สัปดาห์` | 2 สัปดาห์ |
| month | `{n} เดือน` | 6 เดือน |
| year | `{n} ปี` | 3 ปี |

**Half marker:** `{0}ครึ่ง` (postfix, no space) — "3 ปีครึ่ง".

### Vietnamese (`vi`)

**CLDR categories:** other

Vietnamese is an analytic language with no inflectional morphology.

| Unit | Form | Example |
|------|------|---------|
| day | `{n} ngày` | 5 ngày |
| week | `{n} tuần` | 2 tuần |
| month | `{n} tháng` | 6 tháng |
| year | `{n} tuổi` | 3 tuổi |

**Half marker:** `{0} rưỡi` — "3 tuổi rưỡi".

**Note:** `tuổi` is used for age (literally "age/years old") rather than
`năm` (calendar year).

### Malay (`ms`)

**CLDR categories:** other

Malay does not mark grammatical number on nouns. Reduplication (e.g.,
*hari-hari*) expresses plurality in some contexts but is not used with
numerals.

| Unit | Form | Example |
|------|------|---------|
| day | `{n} hari` | 5 hari |
| week | `{n} minggu` | 2 minggu |
| month | `{n} bulan` | 6 bulan |
| year | `{n} tahun` | 3 tahun |

**Half marker:** `{0} setengah` — "3 tahun setengah".

### Javanese (`jv`)

**CLDR categories:** other

Javanese, like Malay, does not mark plural on nouns. The language uses a
complex system of speech levels (ngoko, madya, krama) but none affect
number agreement.

| Unit | Form | Example |
|------|------|---------|
| day | `{n} dino` | 5 dino |
| week | `{n} minggu` | 2 minggu |
| month | `{n} sasi` | 6 sasi |
| year | `{n} taun` | 3 taun |

**Half marker:** `{0} setengah` — "3 taun setengah".

---

## Simplified no-plural locales

These languages technically have CLDR plural categories but use single string
templates because their unit nouns do not change form in the specific context
of counting time units. The `plural` function returns `'other'` for all values.

### Basque (`eu`)

**CLDR categories:** one (n=1), other

**Implementation:** always returns `other`.

**Rationale:** Basque nouns do not inflect for number when preceded by a
numeral. "1 egun" and "5 egun" use the same noun form. While CLDR defines a
`one` category for Basque, the language's ergative-absolutive case system means
the singular/plural distinction applies to verb agreement and bare nouns, not
to numeral+noun phrases in the absolutive case.

### Hungarian (`hu`)

**CLDR categories:** one (n=1), other

**Implementation:** always returns `other`.

**Rationale:** Hungarian nouns after numerals take the singular form regardless
of count: "1 nap" (1 day), "5 nap" (5 days) — both use the bare stem. The
plural suffix `-k` is only used without a numeral (e.g., "a napok" = "the
days"). Since every unit form is identical for all counts, the `one` category
has no practical effect.

### Irish (`ga`)

**CLDR categories:** one (n=1), two (n=2), few (n=3..6), many (n=7..10), other

**Implementation:** always returns `other`.

**Rationale:** Irish has one of CLDR's most complex plural systems with 5
categories. However, implementing all 5 categories would require verified
native-speaker forms for every unit in every category. Irish noun plurals
involve initial mutations (séimhiú/urú), multiple declension classes, and
irregular forms that vary by dialect. The current implementation uses a single
form per unit that is grammatically acceptable as a general-purpose form.

This is a known simplification. If a native Irish speaker contributes verified
forms for all 5 plural categories, the `plural` function and unit forms should
be updated to match the full CLDR spec.
