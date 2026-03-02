# Locales: Simple One/Other Plural Rules

Languages with binary singular/plural. The plural function returns `'one'` for
a specific count (usually just n=1) and `'other'` for everything else.

**CLDR source:** https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

---

## Group A: Singular at n=1 only

These languages use the `one` form exclusively for n=1. All other counts
(including 0) use the `other` form. This is the most common plural pattern
across world languages.

**CLDR rule family:** `n = 1` or `i = 1 and v = 0` (equivalent for integers).

### English (`en`)

| Unit  | one     | other      |
| ----- | ------- | ---------- |
| day   | 1 day   | {n} days   |
| week  | 1 week  | {n} weeks  |
| month | 1 month | {n} months |
| year  | 1 year  | {n} years  |

**Half:** `{n}½` — "3½ years". Uses Unicode ½ (U+00BD).

**Delimiter:** `", "` — "2 weeks, 3 days".

**Compactness:** English is the only locale with short/compact overrides:
- Normal: "3 months", "2 years, 1 month"
- Short: "3 mo", "2 yr, 1 mo"
- Compact: "3m", "2y1m"

### German (`de`)

| Unit  | one     | other      |
| ----- | ------- | ---------- |
| day   | 1 Tag   | {n} Tage   |
| week  | 1 Woche | {n} Wochen |
| month | 1 Monat | {n} Monate |
| year  | 1 Jahr  | {n} Jahre  |

**Half:** `{n}½` — "3½ Jahre".

### Spanish (`es`)

| Unit  | one      | other       |
| ----- | -------- | ----------- |
| day   | 1 día    | {n} días    |
| week  | 1 semana | {n} semanas |
| month | 1 mes    | {n} meses   |
| year  | 1 año    | {n} años    |

**Half:** `{n} y medio` — "3 y medio años".

**Note:** CLDR defines a `many` category for Spanish related to compact decimal
notation (1 million → "1M"). Since parent-time only uses integer counts, the
`many` category is not implemented.

### Italian (`it`)

| Unit  | one         | other         |
| ----- | ----------- | ------------- |
| day   | 1 giorno    | {n} giorni    |
| week  | 1 settimana | {n} settimane |
| month | 1 mese      | {n} mesi      |
| year  | 1 anno      | {n} anni      |

**Half:** `{0} e mezzo` — "3 anni e mezzo".

### Catalan (`ca`)

| Unit  | one       | other        |
| ----- | --------- | ------------ |
| day   | 1 dia     | {n} dies     |
| week  | 1 setmana | {n} setmanes |
| month | 1 mes     | {n} mesos    |
| year  | 1 any     | {n} anys     |

**Half:** `{n} i mig` — "3 i mig anys".

### Dutch (`nl`)

| Unit  | one     | other       |
| ----- | ------- | ----------- |
| day   | 1 dag   | {n} dagen   |
| week  | 1 week  | {n} weken   |
| month | 1 maand | {n} maanden |
| year  | 1 jaar  | {n} jaar    |

**Half:** `{n}½` — "3½ jaar".

**Note:** The plural of "jaar" is also "jaar" (invariant).

### Swedish (`sv`)

| Unit  | one     | other       |
| ----- | ------- | ----------- |
| day   | 1 dag   | {n} dagar   |
| week  | 1 vecka | {n} veckor  |
| month | 1 månad | {n} månader |
| year  | 1 år    | {n} år      |

**Half:** `{n}½` — "3½ år".

### Danish (`da`)

| Unit  | one     | other       |
| ----- | ------- | ----------- |
| day   | 1 dag   | {n} dage    |
| week  | 1 uge   | {n} uger    |
| month | 1 måned | {n} måneder |
| year  | 1 år    | {n} år      |

**Half:** `{n}½` — "3½ år".

**CLDR note:** Danish's full CLDR rule is `n = 1 or t != 0 and i = 0,1`, where
the second clause handles decimals like 0.5 or 1.5. Since parent-time only uses
integers, the rule simplifies to `n = 1`.

### Norwegian Bokmål (`nb`)

| Unit  | one     | other       |
| ----- | ------- | ----------- |
| day   | 1 dag   | {n} dager   |
| week  | 1 uke   | {n} uker    |
| month | 1 måned | {n} måneder |
| year  | 1 år    | {n} år      |

**Half:** `{n}½` — "3½ år".

### Finnish (`fi`)

| Unit  | one        | other         |
| ----- | ---------- | ------------- |
| day   | 1 päivä    | {n} päivää    |
| week  | 1 viikko   | {n} viikkoa   |
| month | 1 kuukausi | {n} kuukautta |
| year  | 1 vuosi    | {n} vuotta    |

**Half:** `{n} ja puoli` — "3 ja puoli vuotta".

**Note:** Finnish uses partitive case for the noun after numerals > 1
(e.g., "päivää" is partitive of "päivä"). The `one` form uses nominative.

### Estonian (`et`)

| Unit  | one     | other       |
| ----- | ------- | ----------- |
| day   | 1 päev  | {n} päeva   |
| week  | 1 nädal | {n} nädalat |
| month | 1 kuu   | {n} kuud    |
| year  | 1 aasta | {n} aastat  |

**Half:** `{n}½` — "3½ aastat".

**Note:** Like Finnish, Estonian uses partitive case in the plural form.

### Greek (`el`)

| Unit  | one        | other         |
| ----- | ---------- | ------------- |
| day   | 1 μέρα     | {n} μέρες     |
| week  | 1 εβδομάδα | {n} εβδομάδες |
| month | 1 μήνας    | {n} μήνες     |
| year  | 1 χρόνος   | {n} χρόνια    |

**Half:** `{0} και μισό` — "3 χρόνια και μισό".

### Bulgarian (`bg`)

| Unit  | one       | other       |
| ----- | --------- | ----------- |
| day   | 1 ден     | {n} дни     |
| week  | 1 седмица | {n} седмици |
| month | 1 месец   | {n} месеца  |
| year  | 1 година  | {n} години  |

**Half:** `{0} и половина` — "3 години и половина".

### Albanian (`sq`)

| Unit  | one    | other    |
| ----- | ------ | -------- |
| day   | 1 ditë | {n} ditë |
| week  | 1 javë | {n} javë |
| month | 1 muaj | {n} muaj |
| year  | 1 vit  | {n} vjet |

**Half:** `{0} e gjysmë` — "3 vjet e gjysmë".

**Note:** Albanian nouns for "day", "week", and "month" happen to be invariant
(same form for singular and plural), but "year" changes: vit/vjet.

### Turkish (`tr`)

| Unit  | one     | other     |
| ----- | ------- | --------- |
| day   | 1 gün   | {n} gün   |
| week  | 1 hafta | {n} hafta |
| month | 1 ay    | {n} ay    |
| year  | 1 yaş   | {n} yaş   |

**Half:** `{n} buçuk` — "3 buçuk yaş".

**Note:** Turkish nouns after numerals do not take the plural suffix `-ler/-lar`.
All unit forms are identical for `one` and `other`. The CLDR `one` category is
still implemented for correctness, but it produces the same output.

### Tamil (`ta`)

| Unit  | one     | other        |
| ----- | ------- | ------------ |
| day   | 1 நாள்  | {n} நாட்கள்  |
| week  | 1 வாரம் | {n} வாரங்கள் |
| month | 1 மாதம் | {n} மாதங்கள் |
| year  | 1 வயது  | {n} வயது     |

**Half:** `{0}ரை` (suffix) — "3 வயதுரை".

**Note:** `வயது` (vayadu) means "age" and is invariant.

### Telugu (`te`)

| Unit  | one        | other          |
| ----- | ---------- | -------------- |
| day   | 1 రోజు     | {n} రోజులు     |
| week  | 1 వారం     | {n} వారాలు     |
| month | 1 నెల      | {n} నెలలు      |
| year  | 1 సంవత్సరం | {n} సంవత్సరాలు |

**Half:** `{0}న్నర` (suffix) — "3 సంవత్సరాలున్నర".

### Marathi (`mr`)

| Unit  | one     | other     |
| ----- | ------- | --------- |
| day   | 1 दिवस  | {n} दिवस  |
| week  | 1 आठवडा | {n} आठवडे |
| month | 1 महिना | {n} महिने |
| year  | 1 वर्ष  | {n} वर्षे |

**Half:** `साडे {n}` (prefix) — "साडे 3 वर्षे".

**CLDR note:** CLDR defines `n = 1` for Marathi's `one` category (not n=0 or
n=1). This differs from other South Asian languages like Hindi and Bengali.

### Urdu (`ur`)

| Unit  | one     | other     |
| ----- | ------- | --------- |
| day   | 1 دن    | {n} دن    |
| week  | 1 ہفتہ  | {n} ہفتے  |
| month | 1 مہینہ | {n} مہینے |
| year  | 1 سال   | {n} سال   |

**Half:** `ساڑھے {n}` (prefix) — "ساڑھے 3 سال".

**Delimiter:** `، ` (Arabic comma).

**CLDR note:** CLDR defines `i = 1 and v = 0` for Urdu — only integer 1. This
differs from Hindi despite the languages being closely related.

---

## Group B: Singular at n=0 and n=1

These languages treat both 0 and 1 as singular. The `one` form is used for
n=0 and n=1; `other` for everything else.

### French (`fr`)

**CLDR rule:** `i = 0,1` — the `one` category covers integer values 0 and 1.

| Unit  | one                   | other        |
| ----- | --------------------- | ------------ |
| day   | {n} jour              | {n} jours    |
| week  | {n} semaine           | {n} semaines |
| month | invariant: `{n} mois` |              |
| year  | {n} an                | {n} ans      |

**Half:** `{0} et demi` — "3 ans et demi".

**Note:** `mois` (month) is invariant in French — same form for singular and
plural. It uses a plain string template instead of a plural-form map.

### Portuguese (`pt`)

**CLDR rule:** `i = 0..1` — same as French, 0 and 1 are singular.

| Unit  | one        | other       |
| ----- | ---------- | ----------- |
| day   | {n} dia    | {n} dias    |
| week  | {n} semana | {n} semanas |
| month | {n} mês    | {n} meses   |
| year  | {n} ano    | {n} anos    |

**Half:** `{0} e meio` — "3 anos e meio".

**Note:** This implements Brazilian Portuguese (`pt-BR`) rules where both 0 and
1 are singular. European Portuguese (`pt-PT`) uses `i = 1 and v = 0` (only 1 is
singular). For a pediatric age library, the Brazilian convention was chosen
because Brazil has a larger Portuguese-speaking population.

### Hindi (`hi`)

**CLDR rule:** `i = 0 or n = 1` — 0 and 1 are both `one`.

| Unit  | one        | other      |
| ----- | ---------- | ---------- |
| day   | {n} दिन    | {n} दिन    |
| week  | {n} सप्ताह | {n} सप्ताह |
| month | {n} महीना  | {n} महीने  |
| year  | {n} साल    | {n} साल    |

**Half:** `साढ़े {n}` (prefix) — "साढ़े 3 साल".

**Note:** Hindi uses the oblique case after numerals. Many unit nouns (दिन, सप्ताह,
साल) are invariant in the oblique; month (महीना/महीने) does change.

### Bengali (`bn`)

**CLDR rule:** `i = 0 or n = 1` — same as Hindi.

| Unit  | one        | other      |
| ----- | ---------- | ---------- |
| day   | {n} দিন    | {n} দিন    |
| week  | {n} সপ্তাহ | {n} সপ্তাহ |
| month | {n} মাস    | {n} মাস    |
| year  | {n} বছর    | {n} বছর    |

**Half:** `সাড়ে {n}` (prefix) — "সাড়ে 3 বছর".

**Note:** Bengali unit nouns are invariant when preceded by a numeral — both
singular and plural forms are identical for all four units. The `one` category
is still implemented for CLDR compliance.

### Gujarati (`gu`)

**CLDR rule:** `i = 0 or n = 1` — same as Hindi.

| Unit  | one           | other        |
| ----- | ------------- | ------------ |
| day   | {n} દિવસ      | {n} દિવસ     |
| week  | {n} અઠવાડિયું | {n} અઠવાડિયા |
| month | {n} મહિનો     | {n} મહિના    |
| year  | {n} વર્ષ      | {n} વર્ષ     |

**Half:** `સાડા {n}` (prefix) — "સાડા 3 વર્ષ".

### Persian (`fa`)

**CLDR rule:** `i = 0 or n = 1` — same as Hindi.

| Unit  | one      | other    |
| ----- | -------- | -------- |
| day   | {n} روز  | {n} روز  |
| week  | {n} هفته | {n} هفته |
| month | {n} ماه  | {n} ماه  |
| year  | {n} سال  | {n} سال  |

**Half:** `{0} و نیم` — "3 سال و نیم".

**Note:** Persian nouns after numerals do not take the plural suffix `-ها`.
All unit forms are identical for `one` and `other`, but the CLDR rule is
implemented for correctness.

### Punjabi (`pa`)

**CLDR rule:** `n = 0..1` — 0 and 1 are both `one`.

| Unit  | one       | other     |
| ----- | --------- | --------- |
| day   | {n} ਦਿਨ   | {n} ਦਿਨ   |
| week  | {n} ਹਫ਼ਤਾ | {n} ਹਫ਼ਤੇ |
| month | {n} ਮਹੀਨਾ | {n} ਮਹੀਨੇ |
| year  | {n} ਸਾਲ   | {n} ਸਾਲ   |

**Half:** `ਸਾਢੇ {n}` (prefix) — "ਸਾਢੇ 3 ਸਾਲ".
