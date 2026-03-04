# Locales: Complex Plural Rules

Languages with three or more plural categories. These require special plural
functions that examine the count modulo 10 and/or modulo 100 to select the
correct grammatical form.

**CLDR source:** https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

---

## Arabic (`ar`) — 6 categories

Arabic has the most complex plural system of any language in the CLDR, using
all six categories: zero, one, two, few, many, other.

**CLDR rule:**
```
zero:  n = 0
one:   n = 1
two:   n = 2
few:   n % 100 = 3..10
many:  n % 100 = 11..99
other: (everything else — n ≥ 100 where n%100 ∈ {0,1,2})
```

| Unit  | zero    | one   | two     | few        | many        | other     |
| ----- | ------- | ----- | ------- | ---------- | ----------- | --------- |
| day   | 0 يوم   | يوم   | يومان   | {n} أيام   | {n} يومًا   | {n} يوم   |
| week  | 0 أسبوع | أسبوع | أسبوعان | {n} أسابيع | {n} أسبوعًا | {n} أسبوع |
| month | 0 شهر   | شهر   | شهران   | {n} أشهر   | {n} شهرًا   | {n} شهر   |
| year  | 0 سنة   | سنة   | سنتان   | {n} سنوات  | {n} سنة     | {n} سنة   |

**Key features:**
- **Dual form** (`two`): Arabic has a grammatical dual number. "2 days" =
  "يومان" (yawmān), not "2 أيام".
- **Broken plural** (`few`): Counts 3–10 use the "broken plural" (جمع التكسير),
  an internal vowel change: يوم → أيام, شهر → أشهر.
- **Accusative singular** (`many`): Counts 11–99 use the accusative singular
  with tanwin: يومًا (yawman), أسبوعًا (usbū'an).
- **Delimiter:** ` و` (space + waw) — the Arabic conjunction "and".

**Half marker:** `{0} ونصف` — "3 سنوات ونصف".

---

## South Slavic: Bosnian, Croatian, Serbian

These three languages share identical plural rules (CLDR groups them together).
They have three integer categories: `one`, `few`, `other`.

**CLDR rule (integers):**
```
one:   i % 10 = 1 and i % 100 ≠ 11
few:   i % 10 = 2..4 and i % 100 ∉ 12..14
other: (everything else)
```

**Pattern:** Numbers ending in 1 (except 11) are singular. Numbers ending in
2–4 (except 12–14) take the "few" form. Everything else (0, 5–20, 25–30, etc.)
takes the general plural. The "teen exception" (11–14 → `other`) exists because
these numbers historically used a different grammatical construction.

### Bosnian (`bs`)

| Unit  | one       | few         | other       |
| ----- | --------- | ----------- | ----------- |
| day   | 1 dan     | {n} dana    | {n} dana    |
| week  | 1 sedmica | {n} sedmice | {n} sedmica |
| month | 1 mjesec  | {n} mjeseca | {n} mjeseci |
| year  | 1 godina  | {n} godine  | {n} godina  |

**Half:** `{0} i po` — "3 godine i po".

### Croatian (`hr`)

| Unit  | one      | few         | other       |
| ----- | -------- | ----------- | ----------- |
| day   | 1 dan    | {n} dana    | {n} dana    |
| week  | 1 tjedan | {n} tjedna  | {n} tjedana |
| month | 1 mjesec | {n} mjeseca | {n} mjeseci |
| year  | 1 godina | {n} godine  | {n} godina  |

**Half:** `{0} i pol` — "3 godine i pol".

**Note:** Croatian uses "tjedan" for week (cf. Bosnian "sedmica", Serbian
"недеља"). The three languages are mutually intelligible but use different
vocabulary for some common words.

### Serbian (`sr`)

Written in Cyrillic script.

| Unit  | one      | few        | other      |
| ----- | -------- | ---------- | ---------- |
| day   | 1 дан    | {n} дана   | {n} дана   |
| week  | 1 недеља | {n} недеље | {n} недеља |
| month | 1 месец  | {n} месеца | {n} месеци |
| year  | 1 година | {n} године | {n} година |

**Half:** `{0} и по` — "3 године и по".

---

## West Slavic: Czech, Slovak

Czech and Slovak share the same integer plural rule: `one` for 1, `few` for
2–4, `other` for everything else. This is simpler than the South/East Slavic
modular pattern.

**CLDR rule (integers):**
```
one:   i = 1
few:   i = 2..4
other: (everything else)
```

**Note:** CLDR also defines a `many` category for Czech/Slovak that only
applies to decimal values (`v != 0`). Since sayable-age only uses integers,
this category is unreachable and not implemented.

### Czech (`cs`)

| Unit  | one     | few        | other      |
| ----- | ------- | ---------- | ---------- |
| day   | 1 den   | {n} dny    | {n} dní    |
| week  | 1 týden | {n} týdny  | {n} týdnů  |
| month | 1 měsíc | {n} měsíce | {n} měsíců |
| year  | 1 rok   | {n} roky   | {n} let    |

**Half:** `{n}½` — "3½ let".

**Note:** The `other` form for "year" is "let" (genitive plural), a suppletive
form unrelated to the singular "rok". This is similar to how Russian uses
"лет" (let) for years.

### Slovak (`sk`)

| Unit  | one      | few         | other        |
| ----- | -------- | ----------- | ------------ |
| day   | 1 deň    | {n} dni     | {n} dní      |
| week  | 1 týždeň | {n} týždne  | {n} týždňov  |
| month | 1 mesiac | {n} mesiace | {n} mesiacov |
| year  | 1 rok    | {n} roky    | {n} rokov    |

**Half:** `{n}½` — "3½ rokov".

---

## East Slavic: Russian, Ukrainian

Russian and Ukrainian share identical plural rules (CLDR groups them as
`ru uk`). They have three integer-relevant categories: `one`, `few`, `many`.

**CLDR rule (integers):**
```
one:   i % 10 = 1 and i % 100 ≠ 11
few:   i % 10 = 2..4 and i % 100 ∉ 12..14
many:  (everything else — i%10 = 0,5–9, or i%100 = 11–14)
```

For integers, `many` covers all values not matched by `one` or `few`. The CLDR
`other` category exists only for decimal values and is unreachable for integers.
The implementation returns `'many'` as the default, which is functionally correct.

### Russian (`ru`)

| Unit  | one      | few        | many        |
| ----- | -------- | ---------- | ----------- |
| day   | 1 день   | {n} дня    | {n} дней    |
| week  | 1 неделя | {n} недели | {n} недель  |
| month | 1 месяц  | {n} месяца | {n} месяцев |
| year  | 1 год    | {n} года   | {n} лет     |

**Half:** `{n} с половиной` — "3 с половиной года".

**Examples:**
- 1 год (one), 2 года (few), 5 лет (many), 11 лет (many), 21 год (one),
  22 года (few), 25 лет (many)

### Ukrainian (`uk`)

| Unit  | one       | few        | many        |
| ----- | --------- | ---------- | ----------- |
| day   | 1 день    | {n} дні    | {n} днів    |
| week  | 1 тиждень | {n} тижні  | {n} тижнів  |
| month | 1 місяць  | {n} місяці | {n} місяців |
| year  | 1 рік     | {n} роки   | {n} років   |

**Half:** `{n} з половиною` — "3 з половиною роки".

---

## Polish (`pl`)

Polish uses the same mod-10/mod-100 structure as Russian but with different
category names in CLDR and a distinct `one` rule (only n=1, not i%10=1).

**CLDR rule (integers):**
```
one:   n = 1
few:   i % 10 = 2..4 and i % 100 ∉ 12..14
many:  (everything else)
```

| Unit  | one       | few          | many         |
| ----- | --------- | ------------ | ------------ |
| day   | 1 dzień   | {n} dni      | {n} dni      |
| week  | 1 tydzień | {n} tygodnie | {n} tygodni  |
| month | 1 miesiąc | {n} miesiące | {n} miesięcy |
| year  | 1 rok     | {n} lata     | {n} lat      |

**Half:** `{n} i pół` — "3 i pół roku".

**Key difference from Russian:** In Russian, 21 → `one` (21 год). In Polish,
21 → `many` (21 lat). Only exactly 1 triggers the `one` form in Polish.

---

## Lithuanian (`lt`)

Lithuanian has a unique plural pattern that uses n%10 and n%100 with a
"teens exception" range of 11–19 (wider than the Slavic 12–14).

**CLDR rule (integers):**
```
one:   n % 10 = 1 and n % 100 ∉ 11..19
few:   n % 10 = 2..9 and n % 100 ∉ 11..19
other: (everything else — n%10 = 0, or n%100 ∈ 10..19)
```

| Unit  | one       | few          | other        |
| ----- | --------- | ------------ | ------------ |
| day   | 1 diena   | {n} dienos   | {n} dienų    |
| week  | 1 savaitė | {n} savaitės | {n} savaičių |
| month | 1 mėnuo   | {n} mėnesiai | {n} mėnesių  |
| year  | 1 metai   | {n} metai    | {n} metų     |

**Half:** `{n}½` — "3½ metų".

**Note:** CLDR defines a `many` category for Lithuanian, but it only applies
to decimal values (`f != 0`). For integers, the three-way one/few/other split
is complete.

**Examples:**
- 1 diena (one), 2 dienos (few), 10 dienų (other), 11 dienų (other),
  12 dienų (other), 21 diena (one), 22 dienos (few), 30 dienų (other)

---

## Latvian (`lv`)

Latvian has a unique `zero` category that covers more values than just n=0.
The `zero` form is used for all numbers where the last digit is 0, plus the
entire 11–19 range.

**CLDR rule (integers):**
```
zero:  n % 10 = 0 or n % 100 = 11..19
one:   n % 10 = 1 and n % 100 ≠ 11
other: (everything else — n%10 = 2..9 except teens)
```

| Unit  | zero       | one       | other       |
| ----- | ---------- | --------- | ----------- |
| day   | {n} dienu  | 1 diena   | {n} dienas  |
| week  | {n} nedēļu | 1 nedēļa  | {n} nedēļas |
| month | {n} mēnešu | 1 mēnesis | {n} mēneši  |
| year  | {n} gadu   | 1 gads    | {n} gadi    |

**Half:** `{n}½` — "3½ gadi".

**Grammatical explanation:** The three categories correspond to Latvian noun
cases:
- `zero` → genitive plural (used with 0, 10, 20, 30, 11–19, 111–119, etc.)
- `one` → nominative singular (used with 1, 21, 31, 41, etc.)
- `other` → nominative plural (used with 2–9, 22–29, 32–39, etc.)

**Examples:**
- 0 dienu (zero), 1 diena (one), 2 dienas (other), 5 dienas (other),
  10 dienu (zero), 11 dienu (zero), 12 dienu (zero), 19 dienu (zero),
  20 dienu (zero), 21 diena (one), 22 dienas (other)

---

## Romanian (`ro`)

Romanian uses a "few" category for an unusually wide range: 0, and all numbers
whose last two digits are 1–19 (except 1 itself).

**CLDR rule (integers):**
```
one:   n = 1
few:   n = 0 or (n ≠ 1 and n % 100 = 1..19)
other: (everything else — n % 100 ≥ 20 and n % 100 = 0)
```

| Unit  | one         | few           | other            |
| ----- | ----------- | ------------- | ---------------- |
| day   | 1 zi        | {n} zile      | {n} de zile      |
| week  | 1 săptămână | {n} săptămâni | {n} de săptămâni |
| month | 1 lună      | {n} luni      | {n} de luni      |
| year  | 1 an        | {n} ani       | {n} de ani       |

**Half:** `{0} și jumătate` — "3 ani și jumătate".

**Note:** The `other` form uses the preposition "de" (of), which is required
in Romanian for counts of 20 and above: "20 de zile" vs. "19 zile".

**Examples:**
- 0 zile (few), 1 zi (one), 2 zile (few), 19 zile (few), 20 de zile (other),
  100 de zile (other), 101 zile (few), 119 zile (few), 120 de zile (other)

---

## Slovenian (`sl`)

Slovenian is the only language in our set that uses the `two` (dual) category.
The dual is a grammatical number distinct from singular and plural, used for
exactly 2 items (and by extension, n%100=2).

**CLDR rule (integers):**
```
one:   i % 100 = 1
two:   i % 100 = 2
few:   i % 100 = 3..4
other: (everything else)
```

| Unit  | one     | two        | few        | other       |
| ----- | ------- | ---------- | ---------- | ----------- |
| day   | 1 dan   | {n} dneva  | {n} dni    | {n} dni     |
| week  | 1 teden | {n} tedna  | {n} tedne  | {n} tednov  |
| month | 1 mesec | {n} meseca | {n} mesece | {n} mesecev |
| year  | 1 leto  | {n} leti   | {n} leta   | {n} let     |

**Half:** `{0} in pol` — "3 leta in pol".

**Note:** The dual (`two`) and `few` forms are genuinely different: "2 dneva"
(dual) vs. "3 dni" (few). The `one` pattern applies at n=1, 101, 201, etc.
(anything where n%100=1).

**Examples:**
- 1 dan (one), 2 dneva (two), 3 dni (few), 4 dni (few), 5 dni (other),
  100 dni (other), 101 dan (one), 102 dneva (two), 103 dni (few)
