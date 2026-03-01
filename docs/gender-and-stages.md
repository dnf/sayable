# Gender Analysis of `formatStage` Labels

This document analyzes the 63 supported locales for gender issues in the developmental stage labels returned by `formatStage()`. Since there are no users yet, we can freely change any label to a better alternative.

## Background

In English, all six stage labels (Newborn, Infant, Toddler, Child, Teenager, Adult) are gender-neutral. This is **not** the case in many other languages. Many current translations default to the masculine grammatical form, which would be incorrect when referring to a girl.

The AAP/CDC age boundaries (newborn <2mo, infant 2-11mo, toddler 12-35mo, child 36-155mo, teenager 156-215mo, adult 216+mo) are medical/developmental and do **not** vary by gender, social class, or culture. No per-locale boundary changes are needed.

## Summary by Severity

### Tier 1 — No Gender Issues (22 locales)

These languages either lack grammatical gender or the chosen terms are already gender-neutral.

| Code | Language | Why |
|------|----------|-----|
| en | English | No gendered stage nouns |
| zh | Chinese | No grammatical gender |
| ja | Japanese | No grammatical gender |
| ko | Korean | No grammatical gender |
| th | Thai | No grammatical gender |
| vi | Vietnamese | No grammatical gender |
| ms | Malay | No grammatical gender |
| jv | Javanese | No grammatical gender |
| tr | Turkish | No grammatical gender |
| hu | Hungarian | No grammatical gender |
| fi | Finnish | No grammatical gender |
| et | Estonian | No grammatical gender |
| eu | Basque | No grammatical gender |
| fa | Persian | No grammatical gender |
| ga | Irish | Terms chosen are neutral (Páiste, Déagóir, Duine fásta) |
| hr | Croatian | Wisely uses neuter: Novorođenče, Dojenče, Dijete + "Odrasla osoba" |
| sr | Serbian | Same neuter pattern as Croatian |
| bs | Bosnian | Same neuter pattern as Croatian |
| nl | Dutch | All terms are common/neuter gender |
| sv | Swedish | Uses neuter "barn" compounds + common-gender terms |
| da | Danish | Same as Swedish |
| nb | Norwegian | Same as Swedish |

The South Slavic languages (Croatian, Serbian, Bosnian) are a model — they use neuter diminutive forms (-če endings) for young stages and the gender-neutral "Odrasla osoba" (grown person) for adult.

### Tier 2 — Minor Issues, 1-2 gendered terms (10 locales)

| Code | Language | Gendered terms | Notes |
|------|----------|----------------|-------|
| de | German | Erwachsener (m adult), Säugling (m, but generic) | Neugeborenes, Kleinkind, Kind are neuter |
| bg | Bulgarian | Възрастен (m adult) | All child terms are neuter |
| sk | Slovak | Novorodenec (m), Dospelý (m) | Dojča, Batoľa, Dieťa are neuter |
| el | Greek | Έφηβος (m teen), Ενήλικας (m adult) | All child terms are neuter |
| bn | Bengali | কিশোর/kishor (m teen; fem: কিশোরী) | Bengali has no grammatical gender on nouns; কিশোর is semantically masculine |
| gu | Gujarati | કિશોર (m teen; fem: કિશોરી) | બાળક and નાનું બાળક are genuinely neuter |
| mr | Marathi | किशोर (m teen; fem: किशोरी) | बाळ, मूल, अर्भक are genuinely neuter |
| ta | Tamil | சிறுவர் (m child; fem: சிறுமி) | Could use குழந்தை instead |
| pt | Portuguese | Recém-nascido (m), Adulto (m) | Criança, Bebê, Adolescente are neutral |
| ur | Urdu | چھوٹا بچہ (m toddler), بچہ (m child) | نومولود, شیرخوار, نوجوان, بالغ are practically neutral |

### Tier 3 — Moderate Issues, 3-4 gendered terms (8 locales)

| Code | Language | Masculine terms | Neutral terms |
|------|----------|-----------------|---------------|
| ru | Russian | Новорождённый, Малыш, Взрослый | Ребёнок (generic), Подросток (generic) |
| uk | Ukrainian | Новонароджений, Малюк, Дорослий | Немовля (neuter), Дитина (generic) |
| pl | Polish | Noworodek, Maluch, Nastolatek, Dorosły | Niemowlę (neuter), Dziecko (neuter) |
| cs | Czech | Novorozenec, Kojenec, Dospělý | Batole (neuter), Dítě (neuter) |
| hi | Hindi | छोटा बच्चा (m), बच्चा (m), किशोर (m) | नवजात, शिशु, वयस्क (practically neutral) |
| pa | Punjabi | ਨਵਜੰਮਿਆ, ਛੋਟਾ ਬੱਚਾ, ਬੱਚਾ, ਕਿਸ਼ੋਰ | ਸ਼ਿਸ਼ੂ, ਬਾਲਗ (practically neutral) |
| te | Telugu | చిన్న పిల్లవాడు, పిల్లవాడు, వయోజనుడు | శిశువు, కౌమారదశ (stage-based, neutral) |
| sq | Albanian | Fëmijë i vogël (m art.), Adoleshent, I rritur | Fëmijë (base is neutral), Foshnjë |

### Tier 4 — Significant Issues, most or all terms gendered (9 locales)

| Code | Language | # Masc | # Neutral | Detail |
|------|----------|--------|-----------|--------|
| ar | Arabic | **6/6** | 0 | ALL terms masculine. Arabic has no neuter gender and no gender-neutral convention. |
| es | Spanish | **4/6** | 2 | Recién nacido, Niño pequeño, Niño, Adulto are masculine |
| fr | French | **4/6** | 2 | Nouveau-né, Nourrisson (m but generic), Bambin, Adolescent |
| it | Italian | **4/6** | 2 | Neonato, Bimbo, Bambino, Adulto are masculine |
| ca | Catalan | **5/6** | 1 | Nounat, Nadó, Infant (?), Nen, Adolescent |
| ro | Romanian | **4/6** | 2 | Nou-născut, Sugar, Copil mic, Copil (m grammar, generic usage) |
| sl | Slovenian | **6/6** | 0 | ALL terms masculine: Novorojenček, Dojenček, Malček, Otrok, Najstnik, Odrasel |
| lt | Lithuanian | **6/6** | 0 | ALL terms masculine. Lithuanian has no neuter gender for nouns. |
| lv | Latvian | **6/6** | 0 | ALL terms masculine. Latvian has no neuter gender for nouns. |

---

## Detailed Analysis by Language Family

### Arabic (ar) — All 6 masculine, no neutral alternative possible

Arabic grammar **absolutely requires gendered forms**. There is no neuter gender. Every noun, adjective, and verb must agree with masculine or feminine. The current terms and their feminine equivalents:

| Stage | Current (masculine) | Feminine equivalent |
|-------|--------------------|--------------------|
| newborn | حديث الولادة | حديثة الولادة |
| infant | رضيع | رضيعة |
| toddler | طفل صغير | طفلة صغيرة |
| child | طفل | طفلة |
| teenager | مراهق | مراهقة |
| adult | بالغ | بالغة |

The masculine generic is the standard default in Arabic software, medical literature, and all formal writing. No gender-neutral alternative exists. If gendered variants are desired, both forms must be provided.

**Cultural note:** Islamic tradition has a distinctive 7/14/21 stage model (play stage, teaching stage, advisory stage), but the medical Arabic terminology aligns with Western pediatric conventions. The current AAP/CDC boundaries are appropriate.

**Recommendation:** Arabic is the strongest case for needing gendered variants in the type system, since neutrality is linguistically impossible.

### Romance Languages

#### Spanish (es)

| Stage | Current | Issue | Neutral alternative |
|-------|---------|-------|-------------------|
| newborn | Recién nacido | Masculine | *No clean neutral; conventional* |
| infant | Bebé | Functionally neutral | Already good |
| toddler | Niño pequeño | Masculine | **Criatura** (gram. feminine but used for any child) |
| child | Niño | Masculine (means "boy") | **Criatura** |
| teenager | Adolescente | Epicene (neutral) | Already good |
| adult | Adulto | Masculine | **Persona adulta** (but wordy) |

The RAE (April 2025) explicitly rejected -e/-x/-@ inclusive suffixes. "Criatura" is the most natural existing gender-neutral word for child in Spanish.

#### French (fr)

| Stage | Current | Issue | Neutral alternative |
|-------|---------|-------|-------------------|
| newborn | Nouveau-né | Masculine | *No clean neutral; conventional* |
| infant | Nourrisson | Masc. grammar, no feminine form | Functionally neutral; keep |
| toddler | Bambin | Masculine (fem: bambine) | **Tout-petit** (widely used, naturally neutral) |
| child | Enfant | Epicene (neutral) | Already good |
| teenager | Adolescent | Masculine (fem: adolescente) | *Conventional; keep* |
| adult | Adulte | Epicene (neutral) | Already good |

#### Italian (it)

| Stage | Current | Issue | Neutral alternative |
|-------|---------|-------|-------------------|
| newborn | Neonato | Masculine (fem: neonata) | *Conventional; keep* |
| infant | Lattante | Epicene (neutral) | Already good |
| toddler | Bimbo | Masculine (fem: bimba) | **Piccolo/a** or keep |
| child | Bambino | Masculine (fem: bambina) | *No clean neutral* |
| teenager | Adolescente | Epicene (neutral) | Already good |
| adult | Adulto | Masculine (fem: adulta) | *Conventional; keep* |

#### Portuguese (pt) — Best of the Romance languages

| Stage | Current | Issue |
|-------|---------|-------|
| newborn | Recém-nascido | Masculine (conventional) |
| infant | Bebê | Functionally neutral |
| toddler | Criança pequena | Neutral (criança is gender-neutral) |
| child | Criança | Neutral |
| teenager | Adolescente | Epicene |
| adult | Adulto | Masculine (conventional) |

Portuguese does well because "criança" is genuinely gender-neutral despite being grammatically feminine.

#### Catalan (ca)

| Stage | Current | Issue | Neutral alternative |
|-------|---------|-------|-------------------|
| newborn | Nounat | Masculine | *Conventional* |
| infant | Nadó | Masculine | — |
| toddler | Infant | Epicene | Already good |
| child | Nen | Masculine (means "boy") | **Criatura** (well-established neutral usage in Catalan) |
| teenager | Adolescent | Epicene | Already good |
| adult | Adult | Epicene | Already good |

#### Romanian (ro)

| Stage | Current | Issue |
|-------|---------|-------|
| newborn | Nou-născut | Masculine (conventional) |
| infant | Sugar | Masc. grammar, used generically |
| toddler | Copil mic | Masc. grammar, "copil" is generic |
| child | Copil | Masc. grammar, used generically |
| teenager | Adolescent | Epicene |
| adult | Adult | Epicene |

Romanian "copil" is masculine but functions generically, similar to Portuguese "criança."

### Slavic & Baltic Languages

#### Russian (ru)

| Stage | Current | Gender | Note |
|-------|---------|--------|------|
| newborn | Новорождённый | Masculine (fem: Новорождённая) | Substantivized adjective, must carry gender |
| infant | Младенец | Masculine (no fem form) | Used generically |
| toddler | Малыш | Masculine (fem: Малышка) | Colloquial/affectionate |
| child | Ребёнок | Masculine grammar, generic usage | Standard generic word |
| teenager | Подросток | Masculine, used generically | Least problematic |
| adult | Взрослый | Masculine (fem: Взрослая) | Substantivized adjective |

No neuter option exists for human referents in Russian. The masculine generic is the default, with no mainstream gender-neutral convention.

#### Slovenian (sl) — All 6 masculine

| Current (masc.) | Feminine equivalent | Pattern |
|-----------------|--------------------|----|
| Novorojenček | Novorojenčica | -ček → -čica |
| Dojenček | Dojenčica | -ček → -čica |
| Malček | Malčica | -ček → -čica |
| Otrok | (no standard fem.) | Used generically |
| Najstnik | Najstnica | -nik → -nica |
| Odrasel | Odrasla | adj. masc → fem |

Unlike Croatian (which uses neuter -če diminutives), Slovenian's -ček diminutives are masculine. The Croatian neuter strategy does not transfer naturally to Slovenian.

#### Lithuanian (lt) — All 6 masculine, no neuter gender exists

| Current (masc.) | Feminine | Pattern |
|-----------------|----------|---------|
| Naujagimis | Naujagimė | -is → -ė |
| Kūdikis | Kūdikė | -is → -ė |
| Mažylis | Mažylė | -is → -ė |
| Vaikas | (generic) | — |
| Paauglys | Paauglė | -ys → -ė |
| Suaugęs | Suaugusi | participle |

Lithuanian has only two genders (masculine/feminine). No neuter nouns exist, so the Croatian strategy is unavailable.

#### Latvian (lv) — All 6 masculine, no neuter gender exists

Same structural limitation as Lithuanian. The definite adjective forms (Jaundzimušais, Pieaugušais with -ais ending) are particularly overtly masculine.

### Indic Languages

#### The shared किशोर (kishor) problem

The Sanskrit-derived word किशोर appears in **6 of 8** Indic locales (Hindi, Bengali, Gujarati, Marathi, Punjabi; Telugu uses a different term). In every language, it is masculine with feminine form किशोरी (kishorī). This is the single most widespread gendered term across these locales.

#### Hindi (hi) and Punjabi (pa)

बच्चा/ਬੱਚਾ (bacchā) is explicitly masculine (fem: बच्ची/ਬੱਚੀ). छोटा बच्चा/ਛੋਟਾ ਬੱਚਾ has both adjective and noun masculine. These languages have only two genders (no neuter), making neutrality structurally difficult. The terms नवजात, शिशु, वयस्क are grammatically masculine but have no standard feminine forms and function as generics.

#### Telugu (te) — 3 terms have explicit masculine suffixes

The suffixes -వాడు (-vāḍu) and -ుడు (-uḍu) are unambiguous masculine markers. Gender-neutral alternatives:
- **బిడ్డ** (bidda) — warm, gender-neutral word for "child/baby," the best replacement for పిల్లవాడు
- **పసిబిడ్డ** (pasibidda) — "little child," neutral alternative for toddler

#### Tamil (ta) — 1 gendered term

சிறுவர் (siruvar, "child") means "boy(s)." The gender-neutral alternative குழந்தை (kuzhanthai) is already used for infant/toddler stages in the locale.

#### Gujarati (gu) and Marathi (mr) — Best of the Indic languages

Both have three-gender systems (masculine/feminine/neuter). Both already use neuter-gender terms for child stages (બાળક/बाळ/मूल). Only किशोर/કિશોર is gendered.

---

## Recommended Fixes (Strategy 2: Neutral Alternatives)

These are changes that can be made without altering the `stages` type interface — just swapping in better word choices.

### High-confidence swaps (clear improvement, well-established alternatives)

| Locale | Stage | Current | Proposed | Rationale |
|--------|-------|---------|----------|-----------|
| **fr** | toddler | Bambin | **Tout-petit** | Widely used, naturally gender-neutral |
| **ca** | child | Nen | **Criatura** | Standard gender-neutral alternative in Catalan |
| **te** | toddler | చిన్న పిల్లవాడు | **చిన్న బిడ్డ** | బిడ్డ is gender-neutral; -వాడు is masculine |
| **te** | child | పిల్లవాడు | **బిడ్డ** | బిడ్డ is the standard gender-neutral "child" |
| **te** | adult | వయోజనుడు | **వయోజనులు** or **పెద్దవారు** | Remove -ుడు masculine suffix |
| **ta** | child | சிறுவர் | **குழந்தை** | குழந்தை is already used for infant/toddler; it is neutral |

### Medium-confidence swaps (improvement but may need native speaker review)

| Locale | Stage | Current | Proposed | Rationale |
|--------|-------|---------|----------|-----------|
| **es** | toddler | Niño pequeño | **Criatura** | Gram. feminine but used for any child |
| **es** | child | Niño | **Criatura** | Same reasoning |
| **hi** | toddler | छोटा बच्चा | **छोटा शिशु** or **नन्हा बालक** | Harder — no clean neutral exists |
| **hi** | child | बच्चा | **बालक** | Slightly more formal but still masculine |
| **ur** | toddler | چھوٹا بچہ | **ننھا بچہ** | Still masculine, limited options |

### Requires type system change (gendered variants needed)

For **Arabic (ar)**, **Lithuanian (lt)**, **Latvian (lv)**, and **Slovenian (sl)**, no gender-neutral alternatives exist. These languages would require the `stages` type to support gendered variants:

```typescript
stages: {
  newborn: string | { m: string; f: string };
  infant: string | { m: string; f: string };
  // ...
}
```

---

## Social Class Considerations

Stage terminology is **not** class-stratified in any of the 63 locales. The only observable variation is **register** (formal/clinical vs. colloquial/warm):

- Russian "Малыш" (toddler) is warm/affectionate; a clinical alternative would be "ребёнок раннего возраста"
- Several languages use borrowed English terms (Czech "Teenager", Croatian "Tinejdžer") which may carry a slightly more modern/casual register vs. native equivalents

This is not a problem — the warm/parental register is appropriate for a parenting library.

---

## Cultural Notes on Age Boundaries

- **Islamic tradition** (relevant to Arabic, Urdu, Malay, etc.) has a distinctive 7/14/21 stage model, but the medical Arabic/Urdu terminology aligns with Western pediatric conventions
- **No culture surveyed** defines developmental stage transitions differently by gender in a way that would affect this library
- The word بالغ (bāligh) in Arabic literally means "one who has reached [maturity]" and connects to Islamic jurisprudence concepts, but its modern medical usage aligns with the library's boundaries

---

## The Shared किशोर (kishor) Problem

The Sanskrit-derived word किशोर (kishor, "adolescent boy") appears across Hindi, Bengali, Gujarati, Marathi, and Punjabi (6 locales). In every case it is masculine with a clear feminine counterpart किशोरी (kishorī). Possible approaches:

1. **Accept it** — the masculine generic is the convention in all these languages
2. **Use a stage-based term** — Telugu's approach (కౌమారదశ, "adolescent stage") avoids gendering the person. Similar constructions might work: Hindi किशोरावस्था (kishorāvasthā, "adolescent stage")
3. **Provide gendered variants** — if the type system supports it

---

## Decision Matrix

| Strategy | API change? | # locales fixed | Complexity | Best for |
|----------|-------------|-----------------|------------|----------|
| Neutral alternatives only | No | ~6-8 locales improved | Low | Quick wins |
| Gendered variants only | Yes | All 27 affected | High | Full correctness |
| Hybrid (neutral where possible, gendered where not) | Yes | All 27 affected | Medium | Best balance |

Since there are no users of this library yet, backwards compatibility is not a concern.
