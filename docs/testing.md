# Test Cases

This document defines the canonical, complete set of test cases for
parent-time. It is the single source of truth — every test case listed here
must be implemented in every language. Each implementation translates these
specifications into its native test framework.

All test cases use explicit `(dateOfBirth, asOf)` pairs for determinism.
No test depends on the current date except where specifically noted.

**CLDR source for expected strings:**
https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

---

## 1. Null / edge cases

These test that invalid inputs return null (or the language equivalent:
`None`, `nil`, `std::nullopt`, etc.).

| # | Input | Expected |
|---|-------|----------|
| 1.1 | `dateOfBirth = null` | null |
| 1.2 | `dateOfBirth = undefined` (where applicable) | null |
| 1.3 | `dateOfBirth = ""` (empty string) | null |
| 1.4 | `dateOfBirth = "2025-07-01"`, `asOf = "2025-06-15"` (future DOB) | null |

---

## 2. Days tier (0–6 days)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 2.1 | 2025-06-15 | 2025-06-15 | "Newborn" | Born today, 0 days |
| 2.2 | 2025-06-14 | 2025-06-15 | "1 day" | Singular |
| 2.3 | 2025-06-12 | 2025-06-15 | "3 days" | Plural |
| 2.4 | 2025-06-09 | 2025-06-15 | "6 days" | Maximum days before weeks |
| 2.5 | 2025-06-08 | 2025-06-15 | "1 week" | 7 days = transition to weeks |

---

## 3. Weeks+days tier (7 days to <3 calendar months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 3.1 | 2025-06-08 | 2025-06-15 | "1 week" | Exactly 7 days |
| 3.2 | 2025-06-07 | 2025-06-15 | "1 week, 1 day" | Singular day remainder |
| 3.3 | 2025-06-06 | 2025-06-15 | "1 week, 2 days" | Plural day remainder |
| 3.4 | 2025-06-02 | 2025-06-15 | "1 week, 6 days" | Max days in week |
| 3.5 | 2025-06-01 | 2025-06-15 | "2 weeks" | Exactly 14 days |
| 3.6 | 2025-05-31 | 2025-06-15 | "2 weeks, 1 day" | 15 days |
| 3.7 | 2025-05-26 | 2025-06-15 | "2 weeks, 6 days" | 20 days |
| 3.8 | 2025-05-25 | 2025-06-15 | "3 weeks" | 21 days |
| 3.9 | 2025-05-15 | 2025-06-15 | "4 weeks, 3 days" | 1 calendar month, still weeks |
| 3.10 | 2025-04-15 | 2025-06-15 | "8 weeks, 5 days" | 2 calendar months, still weeks |
| 3.11 | 2025-03-15 | 2025-06-14 | "13 weeks" | Day before 3-month birthday |
| 3.12 | 2025-03-15 | 2025-06-15 | "3 months" | Exactly 3 months = transition |

---

## 4. Month boundaries — standard months

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 4.1 | 2025-01-01 | 2025-04-01 | "3 months" | Standard 3-month boundary |
| 4.2 | 2025-01-01 | 2025-03-31 | weeks pattern | Not yet 3 months |
| 4.3 | 2025-06-15 | 2025-09-15 | "3 months" | Mid-month boundary |
| 4.4 | 2025-06-15 | 2025-09-14 | weeks pattern | Day before 3-month mark |
| 4.5 | 2025-06-15 | 2025-12-15 | "6 months" | 6 months |

---

## 5. Month boundaries — February non-leap year

2025 is not a leap year (Feb has 28 days).

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 5.1 | 2025-01-31 | 2025-02-28 | "4 weeks" | 1 cal month (clamped to Feb 28) |
| 5.2 | 2025-01-31 | 2025-04-30 | "3 months" | Apr has no 31st, clamp to 30 |
| 5.3 | 2025-01-31 | 2025-04-29 | weeks pattern | Day before 3-month mark |
| 5.4 | 2025-02-01 | 2025-05-01 | "3 months" | Standard 3-month from Feb |
| 5.5 | 2025-02-01 | 2025-04-30 | weeks pattern | Day before 3 months from Feb |

---

## 6. Month boundaries — February leap year

2024 is a leap year (Feb has 29 days).

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 6.1 | 2024-01-31 | 2024-02-29 | "4 weeks, 1 day" | Leap year, Feb 29 exists |
| 6.2 | 2024-01-31 | 2024-02-28 | "4 weeks" | 28 days |
| 6.3 | 2024-01-31 | 2024-04-30 | "3 months" | 3 months with Apr clamp |
| 6.4 | 2024-01-30 | 2024-02-29 | weeks pattern | 1 month (clamped to 29) |
| 6.5 | 2024-01-30 | 2024-02-28 | weeks pattern | Not yet 1 month |

---

## 7. Month boundaries — 30-day months

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 7.1 | 2025-03-31 | 2025-06-30 | "3 months" | Jun 30 is 3mo (clamped from 31) |
| 7.2 | 2025-03-31 | 2025-06-29 | weeks pattern | Day before 3-month mark |
| 7.3 | 2025-08-31 | 2025-11-30 | "3 months" | Nov 30 is 3mo (clamped from 31) |
| 7.4 | 2025-08-31 | 2025-11-29 | weeks pattern | Day before 3-month mark |

---

## 8. Month boundaries — leap year baby (born Feb 29)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 8.1 | 2024-02-29 | 2024-05-29 | "3 months" | 3 months from Feb 29 |
| 8.2 | 2024-02-29 | 2024-05-28 | weeks pattern | Day before 3 months |
| 8.3 | 2024-02-29 | 2025-02-28 | "12 months" | Non-leap: birthday clamps to 28 |
| 8.4 | 2024-02-29 | 2025-03-01 | "12 months" | Day after clamped birthday |

---

## 9. Months tier (3–23 months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 9.1 | 2025-01-15 | 2025-04-15 | "3 months" | Transition point |
| 9.2 | 2025-01-15 | 2025-07-15 | "6 months" | |
| 9.3 | 2024-06-15 | 2025-06-15 | "12 months" | Not "1 year" |
| 9.4 | 2024-01-15 | 2025-12-15 | "23 months" | Upper boundary |
| 9.5 | 2025-01-15 | 2025-07-14 | "5 months" | Day before boundary |
| 9.6 | 2024-11-10 | 2025-04-10 | "5 months" | Cross-year boundary |

---

## 10. Years+months tier (24–35 months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 10.1 | 2023-06-15 | 2025-06-15 | "2 years" | Exactly 24 months |
| 10.2 | 2023-06-15 | 2025-07-15 | "2 years, 1 month" | Singular month |
| 10.3 | 2023-06-15 | 2025-12-15 | "2 years, 6 months" | |
| 10.4 | 2023-06-15 | 2026-05-15 | "2 years, 11 months" | Upper boundary |
| 10.5 | 2023-06-15 | 2025-06-14 | "23 months" | Day before 24 months |

---

## 11. Half-year tier (3–6 years)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 11.1 | 2022-06-15 | 2025-06-15 | "3 years" | Exactly 3 years |
| 11.2 | 2022-06-15 | 2025-11-15 | "3 years" | 3y5m (under half) |
| 11.3 | 2022-06-15 | 2025-12-15 | "3½ years" | 3y6m |
| 11.4 | 2022-06-15 | 2026-05-15 | "3½ years" | 3y11m |
| 11.5 | 2021-06-15 | 2025-06-15 | "4 years" | Exactly 4 years |
| 11.6 | 2021-06-15 | 2025-12-15 | "4½ years" | 4y6m |
| 11.7 | 2020-06-15 | 2025-06-15 | "5 years" | Exactly 5 years |
| 11.8 | 2020-06-15 | 2026-02-15 | "5½ years" | 5y8m |
| 11.9 | 2019-06-15 | 2025-06-15 | "6 years" | Exactly 6 years |
| 11.10 | 2019-06-15 | 2025-12-15 | "6½ years" | 6y6m |
| 11.11 | 2019-06-15 | 2026-05-15 | "6½ years" | 6y11m (last month before 7) |
| 11.12 | 2022-06-15 | 2025-06-14 | "2 years, 11 months" | Day before 3rd birthday |

---

## 12. Integer tier (7+ years)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 12.1 | 2018-06-15 | 2025-06-15 | "7 years" | Exactly 7 years |
| 12.2 | 2018-03-20 | 2025-06-15 | "7 years" | 7y3m — no ½ at 7+ |
| 12.3 | 1980-01-01 | 2025-06-15 | "45 years" | Adult |

---

## 13. Cross-year transitions with February

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 13.1 | 2024-12-31 | 2025-03-31 | "3 months" | Dec→Jan→Feb(28)→Mar |
| 13.2 | 2024-12-31 | 2025-03-30 | weeks pattern | Day before 3mo from Dec 31 |
| 13.3 | 2024-11-30 | 2025-02-28 | "3 months" | Nov→Dec→Jan→Feb(28 clamp) |
| 13.4 | 2024-11-30 | 2025-02-27 | weeks pattern | Day before 3mo from Nov 30 |

---

## 14. Born-on-31st progression

Tracks a child born Jan 31, 2025 through their first year, verifying
month-count clamping at each step.

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 14.1 | 2025-01-31 | 2025-04-30 | "3 months" | Apr clamp |
| 14.2 | 2025-01-31 | 2025-05-31 | "4 months" | May has 31 |
| 14.3 | 2025-01-31 | 2025-06-30 | "5 months" | Jun clamp |
| 14.4 | 2025-01-31 | 2025-07-01 | "5 months" | Before Jul 31 |
| 14.5 | 2025-01-31 | 2025-07-31 | "6 months" | Jul has 31 |

---

## 15. Default asOf (current date)

Test that when `asOf` is omitted, the function uses the current date.
This requires mocking or overriding the system clock.

| # | DOB | System date | Expected |
|---|-----|-------------|----------|
| 15.1 | 2020-01-01 | 2025-06-15 | "5 years" |
| 15.2 | 2025-06-10 | 2025-06-15 | "5 days" |

---

## 16. formatStage — null / edge cases

| # | Input | Expected |
|---|-------|----------|
| 16.1 | `dateOfBirth = null` | null |
| 16.2 | `dateOfBirth = undefined` (where applicable) | null |
| 16.3 | `dateOfBirth = ""` | null |
| 16.4 | `dateOfBirth = "2025-07-01"`, `asOf = "2025-06-15"` | null |

---

## 17. formatStage — Newborn (0–1 months, <2 calendar months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 17.1 | 2025-06-15 | 2025-06-15 | "Newborn" | Born today |
| 17.2 | 2025-06-14 | 2025-06-15 | "Newborn" | 1 day |
| 17.3 | 2025-05-25 | 2025-06-15 | "Newborn" | 3 weeks |
| 17.4 | 2025-05-15 | 2025-06-15 | "Newborn" | 1 month |
| 17.5 | 2025-04-16 | 2025-06-15 | "Newborn" | 1 month 29 days |
| 17.6 | 2025-04-15 | 2025-06-15 | "Infant" | Exactly 2 months = transition |

---

## 18. formatStage — Infant (2–11 months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 18.1 | 2025-04-15 | 2025-06-15 | "Infant" | 2 months |
| 18.2 | 2024-12-15 | 2025-06-15 | "Infant" | 6 months |
| 18.3 | 2024-07-15 | 2025-06-15 | "Infant" | 11 months |
| 18.4 | 2024-06-15 | 2025-06-15 | "Toddler" | 12 months = transition |

---

## 19. formatStage — Toddler (12–35 months)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 19.1 | 2024-06-15 | 2025-06-15 | "Toddler" | 12 months |
| 19.2 | 2024-01-15 | 2025-07-15 | "Toddler" | 18 months |
| 19.3 | 2023-06-15 | 2025-06-15 | "Toddler" | 24 months |
| 19.4 | 2023-06-15 | 2026-05-15 | "Toddler" | 35 months |
| 19.5 | 2022-06-15 | 2025-06-15 | "Child" | 36 months = transition |

---

## 20. formatStage — Child (36–155 months, 3–12 years)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 20.1 | 2022-06-15 | 2025-06-15 | "Child" | 3 years |
| 20.2 | 2021-06-15 | 2025-06-15 | "Child" | 4 years |
| 20.3 | 2019-06-15 | 2025-06-15 | "Child" | 6 years |
| 20.4 | 2016-06-15 | 2025-06-15 | "Child" | 9 years |
| 20.5 | 2013-06-15 | 2026-05-15 | "Child" | 12y11m |
| 20.6 | 2012-06-15 | 2025-06-15 | "Teenager" | 13 years = transition |

---

## 21. formatStage — Teenager (156–215 months, 13–17 years)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 21.1 | 2012-06-15 | 2025-06-15 | "Teenager" | 13 years |
| 21.2 | 2010-06-15 | 2025-06-15 | "Teenager" | 15 years |
| 21.3 | 2008-06-15 | 2026-05-15 | "Teenager" | 17y11m |
| 21.4 | 2007-06-15 | 2025-06-15 | "Adult" | 18 years = transition |

---

## 22. formatStage — Adult (216+ months, 18+ years)

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 22.1 | 2007-06-15 | 2025-06-15 | "Adult" | 18 years |
| 22.2 | 2000-06-15 | 2025-06-15 | "Adult" | 25 years |
| 22.3 | 1980-01-01 | 2025-06-15 | "Adult" | 45 years |

---

## 23. formatStage — default asOf

| # | DOB | System date | Expected |
|---|-----|-------------|----------|
| 23.1 | 2025-06-15 | 2025-06-15 | "Newborn" |
| 23.2 | 2020-01-01 | 2025-06-15 | "Child" |
| 23.3 | 1980-01-01 | 2025-06-15 | "Adult" |

---

## 24. ParentTime class — English locale delegation

Verify that the class-based API produces the same results as the bare functions.

| # | Method | DOB | asOf | Expected |
|---|--------|-----|------|----------|
| 24.1 | formatAge | 2025-06-15 | 2025-06-15 | "Newborn" |
| 24.2 | formatAge | 2025-06-12 | 2025-06-15 | "3 days" |
| 24.3 | formatAge | 2025-06-07 | 2025-06-15 | "1 week, 1 day" |
| 24.4 | formatAge | 2025-01-15 | 2025-07-15 | "6 months" |
| 24.5 | formatAge | 2023-06-15 | 2025-07-15 | "2 years, 1 month" |
| 24.6 | formatAge | 2022-06-15 | 2025-12-15 | "3½ years" |
| 24.7 | formatAge | 2018-06-15 | 2025-06-15 | "7 years" |
| 24.8 | formatStage | 2025-06-15 | 2025-06-15 | "Newborn" |
| 24.9 | formatStage | 2025-01-15 | 2025-06-15 | "Infant" |
| 24.10 | formatStage | 2024-06-15 | 2025-06-15 | "Toddler" |
| 24.11 | formatStage | 2022-06-15 | 2025-06-15 | "Child" |
| 24.12 | formatStage | 2012-06-15 | 2025-06-15 | "Teenager" |
| 24.13 | formatStage | 2007-06-15 | 2025-06-15 | "Adult" |
| 24.14 | formatAge | null | 2025-06-15 | null |
| 24.15 | formatStage | null | 2025-06-15 | null |

---

## 25. i18n — locale with all plural features

Test with a locale that exercises singular/plural forms, half marker, delimiter,
justBorn label, and stage labels. The TypeScript tests use an inline
Spanish-like locale for this purpose.

| # | Method | DOB | asOf | Expected (Spanish) | Notes |
|---|--------|-----|------|-------------------|-------|
| 25.1 | formatAge | 2025-06-15 | 2025-06-15 | "Recién nacido" | justBorn |
| 25.2 | formatAge | 2025-06-14 | 2025-06-15 | "1 día" | Singular day |
| 25.3 | formatAge | 2025-06-12 | 2025-06-15 | "3 días" | Plural days |
| 25.4 | formatAge | 2025-06-08 | 2025-06-15 | "1 semana" | Singular week |
| 25.5 | formatAge | 2025-06-07 | 2025-06-15 | "1 semana, 1 día" | Compound |
| 25.6 | formatAge | 2025-05-26 | 2025-06-15 | "2 semanas, 6 días" | Plural compound |
| 25.7 | formatAge | 2025-01-15 | 2025-07-15 | "6 meses" | Months |
| 25.8 | formatAge | 2023-06-15 | 2025-07-15 | "2 años, 1 mes" | Singular month |
| 25.9 | formatAge | 2023-06-15 | 2025-12-15 | "2 años, 6 meses" | Years+months |
| 25.10 | formatAge | 2022-06-15 | 2025-12-15 | "3 y medio años" | Half marker |
| 25.11 | formatAge | 2022-06-15 | 2025-06-15 | "3 años" | No half |
| 25.12 | formatAge | 2018-06-15 | 2025-06-15 | "7 años" | 7+ years |
| 25.13 | formatStage | 2025-06-15 | 2025-06-15 | "Recién nacido" | Stage label |
| 25.14 | formatStage | 2025-01-15 | 2025-06-15 | "Bebé" | |
| 25.15 | formatStage | 2024-06-15 | 2025-06-15 | "Niño pequeño" | |
| 25.16 | formatStage | 2022-06-15 | 2025-06-15 | "Niño" | |
| 25.17 | formatStage | 2012-06-15 | 2025-06-15 | "Adolescente" | |
| 25.18 | formatStage | 2007-06-15 | 2025-06-15 | "Adulto" | |
| 25.19 | formatAge | null | 2025-06-15 | null | Null handling |
| 25.20 | formatStage | null | 2025-06-15 | null | Null handling |

---

## 26. Compactness — short

Using the English locale with `compactness = "short"`.

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 26.1 | 2025-06-12 | 2025-06-15 | "3 d" | Short days |
| 26.2 | 2025-06-08 | 2025-06-15 | "1 wk" | Short week |
| 26.3 | 2025-06-07 | 2025-06-15 | "1 wk, 1 d" | Short compound |
| 26.4 | 2025-01-15 | 2025-07-15 | "6 mo" | Short months |
| 26.5 | 2023-06-15 | 2025-07-15 | "2 yr, 1 mo" | Short years+months |
| 26.6 | 2022-06-15 | 2025-12-15 | "3½ yr" | Short half |
| 26.7 | 2018-06-15 | 2025-06-15 | "7 yr" | Short years |
| 26.8 | 2025-06-15 | 2025-06-15 | "Newborn" | justBorn unchanged |
| 26.9 | formatStage | | | "Infant" | Stages unchanged |

---

## 27. Compactness — compact

Using the English locale with `compactness = "compact"`.

| # | DOB | asOf | Expected | Notes |
|---|-----|------|----------|-------|
| 27.1 | 2025-06-12 | 2025-06-15 | "3d" | Compact days |
| 27.2 | 2025-06-08 | 2025-06-15 | "1w" | Compact week |
| 27.3 | 2025-06-07 | 2025-06-15 | "1w1d" | No delimiter |
| 27.4 | 2025-01-15 | 2025-07-15 | "6m" | Compact months |
| 27.5 | 2023-06-15 | 2025-07-15 | "2y1m" | No delimiter |
| 27.6 | 2022-06-15 | 2025-12-15 | "3½y" | Compact half |
| 27.7 | 2018-06-15 | 2025-06-15 | "7y" | Compact years |
| 27.8 | 2025-06-15 | 2025-06-15 | "Newborn" | justBorn unchanged |

---

## 29. Locale-specific edge cases — plural rules

Test locales that exercise distinct plural rule families: Hebrew dual forms
(`he`), Macedonian mod-based plurals (`mk`), Swahili noun-class changes
(`sw`), Indonesian other-only (`id`), and Amharic zero-one rule with
Ethiopic delimiter (`am`).

### 29.1 — Hebrew (`he`) — dual forms

The `he` rule: n=1→one, n=2→two, else→other. Hebrew uses special dual-number
forms (שבועיים, חודשיים, שנתיים) when n=2. Also has gendered stages.

| # | Method | DOB | asOf | Expected | Notes |
|---|--------|-----|------|----------|-------|
| 29.1 | formatAge | 2025-06-15 | 2025-06-15 | `רק נולד` | justBorn |
| 29.2 | formatAge | 2025-06-14 | 2025-06-15 | `יום 1` | 1 day — one form |
| 29.3 | formatAge | 2025-06-12 | 2025-06-15 | `3 ימים` | 3 days — other form |
| 29.4 | formatAge | 2025-06-01 | 2025-06-15 | `שבועיים` | 2 weeks — dual form |
| 29.5 | formatAge | 2025-05-25 | 2025-06-15 | `3 שבועות` | 3 weeks — other form |
| 29.6 | formatAge | 2025-01-15 | 2025-07-15 | `6 חודשים` | 6 months — other |
| 29.7 | formatAge | 2025-03-15 | 2025-06-15 | `3 חודשים` | 3 months — other |
| 29.8 | formatAge | 2023-06-15 | 2025-07-15 | `שנתיים, חודש 1` | 2y dual + 1m one |
| 29.9 | formatAge | 2022-06-15 | 2025-12-15 | `3 שנים וחצי` | 3½ years — half marker |
| 29.10 | formatAge | 2018-06-15 | 2025-06-15 | `7 שנים` | 7+ years — other |
| 29.11 | formatStage | 2025-06-15 | 2025-06-15, m | `רק נולד` | masculine newborn |
| 29.12 | formatStage | 2025-06-15 | 2025-06-15, f | `רק נולדה` | feminine newborn |
| 29.13 | formatStage | 2007-06-15 | 2025-06-15, m | `מבוגר` | masculine adult |
| 29.14 | formatStage | 2007-06-15 | 2025-06-15, f | `מבוגרת` | feminine adult |

### 29.2 — Macedonian (`mk`) — mod10/mod100 rule

The `mk` rule: n%10=1 and n%100≠11 → one, else other.

| # | Method | DOB | asOf | Expected | Notes |
|---|--------|-----|------|----------|-------|
| 29.15 | formatAge | 2025-06-15 | 2025-06-15 | `Новороденче` | justBorn |
| 29.16 | formatAge | 2025-06-14 | 2025-06-15 | `1 ден` | 1 day — one |
| 29.17 | formatAge | 2025-06-12 | 2025-06-15 | `3 дена` | 3 days — other |
| 29.18 | formatAge | 2025-01-15 | 2025-07-15 | `6 месеци` | 6 months — other |
| 29.19 | formatAge | 2023-06-15 | 2025-07-15 | `2 години, 1 месец` | 2y1m — one for month |
| 29.20 | formatAge | 2022-06-15 | 2025-12-15 | `3 години и пол` | 3½ years — half marker |
| 29.21 | formatAge | 2018-06-15 | 2025-06-15 | `7 години` | 7+ years — other |

### 29.3 — Swahili (`sw`) — one_other with noun class changes

Swahili changes noun prefixes between singular/plural: mwezi/miezi, mwaka/miaka.

| # | Method | DOB | asOf | Expected | Notes |
|---|--------|-----|------|----------|-------|
| 29.22 | formatAge | 2025-06-15 | 2025-06-15 | `Mzaliwa mpya` | justBorn |
| 29.23 | formatAge | 2025-06-14 | 2025-06-15 | `siku 1` | 1 day — one |
| 29.24 | formatAge | 2025-06-12 | 2025-06-15 | `siku 3` | 3 days — other (same word) |
| 29.25 | formatAge | 2025-01-15 | 2025-07-15 | `miezi 6` | 6 months — other (noun class) |
| 29.26 | formatAge | 2023-06-15 | 2025-07-15 | `miaka 2, mwezi 1` | 2y other + 1m one |
| 29.27 | formatAge | 2022-06-15 | 2025-12-15 | `miaka 3 na nusu` | 3½ years — half marker |

### 29.4 — Indonesian (`id`) — other_only (no plural forms)

Every count uses the same unit string.

| # | Method | DOB | asOf | Expected | Notes |
|---|--------|-----|------|----------|-------|
| 29.28 | formatAge | 2025-06-15 | 2025-06-15 | `Baru lahir` | justBorn |
| 29.29 | formatAge | 2025-06-14 | 2025-06-15 | `1 hari` | 1 day |
| 29.30 | formatAge | 2025-06-12 | 2025-06-15 | `3 hari` | 3 days (same unit) |
| 29.31 | formatAge | 2025-01-15 | 2025-07-15 | `6 bulan` | 6 months |
| 29.32 | formatAge | 2022-06-15 | 2025-12-15 | `3 tahun setengah` | 3½ years — half marker |
| 29.33 | formatAge | 2018-06-15 | 2025-06-15 | `7 tahun` | 7+ years |

### 29.5 — Amharic (`am`) — one_other_zero_one with Ethiopic delimiter

Tests `one_other_zero_one` rule (n∈{0,1}→one) and Ethiopic comma delimiter `፣ `.

| # | Method | DOB | asOf | Expected | Notes |
|---|--------|-----|------|----------|-------|
| 29.34 | formatAge | 2025-06-15 | 2025-06-15 | `አዲስ የተወለደ` | justBorn |
| 29.35 | formatAge | 2025-06-14 | 2025-06-15 | `1 ቀን` | 1 day — one form |
| 29.36 | formatAge | 2025-06-12 | 2025-06-15 | `3 ቀናት` | 3 days — other form |
| 29.37 | formatAge | 2025-06-07 | 2025-06-15 | `1 ሳምንት፣ 1 ቀን` | 1w1d with Ethiopic delimiter |
| 29.38 | formatAge | 2025-01-15 | 2025-07-15 | `6 ወራት` | 6 months — other form |
| 29.39 | formatAge | 2022-06-15 | 2025-12-15 | `3 ዓመታት ተኩል` | 3½ years — half marker |

---

## Test count summary

| Section | Count |
|---------|-------|
| 1. Null/edge | 4 |
| 2. Days tier | 5 |
| 3. Weeks+days tier | 12 |
| 4. Month boundaries — standard | 5 |
| 5. Month boundaries — Feb non-leap | 5 |
| 6. Month boundaries — Feb leap | 5 |
| 7. Month boundaries — 30-day months | 4 |
| 8. Month boundaries — leap baby | 4 |
| 9. Months tier | 6 |
| 10. Years+months tier | 5 |
| 11. Half-year tier | 12 |
| 12. Integer tier | 3 |
| 13. Cross-year transitions | 4 |
| 14. Born-on-31st progression | 5 |
| 15. Default asOf (formatAge) | 2 |
| 16. formatStage null/edge | 4 |
| 17–22. formatStage stages | 25 |
| 23. formatStage default asOf | 3 |
| 24. Class delegation | 15 |
| 25. i18n locale | 20 |
| 26. Compactness short | 9 |
| 27. Compactness compact | 8 |
| 29. Locale-specific edge cases | 39 |
| **Total** | **202** |

### Implementation notes

- **TypeScript** has the most granular test splitting (147 tests in vitest,
  some tests combine multiple assertions).
- **Languages without null/undefined distinction** (Go, Rust, C++) adapt
  tests 1.1–1.2 to their empty/optional patterns.
- **Clock mocking** (tests 15, 23) is implemented differently per language:
  vitest fake timers (TS), monkeypatch (Python), package-level `timeNow` var
  (Go), `Timecop` or similar (Ruby), etc.
- **Tests 4.2, 4.4, 5.3, 5.5, 6.4, 6.5, 7.2, 7.4, 8.2, 13.2, 13.4** verify
  the result matches a `weeks` pattern rather than asserting an exact string,
  because the specific week+day count varies by implementation's day-count
  algorithm.
