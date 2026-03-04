# Locale Data

This directory contains the canonical JSON definitions for all 71 locales supported by sayable-age. Each file defines how ages are expressed in one language — the words, plural rules, and developmental stage labels.

**These files are the single source of truth.** Every language implementation (TypeScript, Python, Go, etc.) generates its locale code from these JSON files. To improve a translation, you edit the JSON file here and the change propagates everywhere.

## How it works

When you edit a source file in this directory, a code generator reads it and produces locale files for all 21 language implementations automatically:

```
                          locales/fr.json
                          (you edit this)
                                |
                                v
                    +-------------------------+
                    |   codegen/generate.py   |
                    |   (code generator)      |
                    +-------------------------+
                                |
          +----------+----------+----------+--- ... ---+
          |          |          |          |            |
          v          v          v          v            v
      src/typescript  src/python  src/go  src/rust    (21 languages)
       locales/fr.ts  locales/   locale_  locales/
                       fr.py     fr.go    fr.rs
```

Each "Example output" link in the index below shows what the library actually produces for a given locale — formatted ages at every tier, stage labels, and half-year expressions. Use it to verify that your locale reads naturally.

## How to improve a locale

If you're a native speaker and notice a translation that sounds unnatural, a plural form that's wrong, or a stage label that uses the wrong register, you can fix it directly.

### 1. Find the file

Each file is named with the language's ISO 639 code: `en.json` for English, `fr.json` for French, `ar.json` for Arabic, and so on. See the [full index](#locale-index) below.

### 2. Open and edit

The files are plain text in JSON format. You can edit them in any text editor or directly on GitHub by clicking the pencil icon. Here's what the structure looks like, using French as an example:

```json
{
  "code": "fr",
  "name": "French",
  "pluralRule": "one_other_zero_one",
  "units": {
    "day":   { "one": "{n} jour", "other": "{n} jours" },
    "week":  { "one": "{n} semaine", "other": "{n} semaines" },
    "month": "{n} mois",
    "year":  { "one": "{n} an", "other": "{n} ans" }
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
  }
}
```

### 3. What each field means

| Field        | What it controls                                                      | Example                |
| ------------ | --------------------------------------------------------------------- | ---------------------- |
| `code`       | Language code (don't change this)                                     | `"fr"`                 |
| `name`       | English name of the language (don't change this)                      | `"French"`             |
| `pluralRule` | Which plural pattern to use (don't change unless you know CLDR rules) | `"one_other_zero_one"` |
| `units`      | How to say "3 days", "1 week", etc.                                   | `"{n} jours"`          |
| `half`       | How to express "and a half"                                           | `"{0} et demi"`        |
| `delimiter`  | Separator between parts like "2 years, 3 months"                      | `", "`                 |
| `justBorn`   | What to display for a baby born today                                 | `"Nouveau-né"`         |
| `stages`     | Developmental stage labels (newborn through adult)                    | `"Enfant"`             |

**About `{n}` and `{0}`:** In unit templates, `{n}` is replaced with the number (e.g., `"{n} jours"` becomes `"3 jours"`). In the half marker, `{0}` wraps the complete expression (e.g., `"{0} et demi"` becomes `"3 ans et demi"`).

**About plural forms:** If a unit has only one form for all counts (like French "mois"), use a simple string. If it changes by count (like "jour"/"jours"), use an object with the plural categories your language needs (`one`, `other`, `few`, `many`, etc.).

**About gendered stages:** If a stage label changes by gender in your language (like French "Nouveau-né"/"Nouveau-née"), use an object with `"m"` and `"f"` keys. If it's the same regardless of gender, use a simple string.

### 4. Submit your change

If you're comfortable with Git:
1. Fork the repository
2. Edit the JSON file
3. Open a pull request and mention that you're a native speaker

If you're not comfortable with Git, open an issue describing the correction and a maintainer will make the change.

### 5. What happens next

After your JSON edit is merged, a maintainer runs the code generator (`python -m codegen.generate`), which automatically updates the locale files in all 21 language implementations. You only need to edit one file.

## Locale index

Speaker counts are approximate and include L1 and L2 speakers.

| Language                | Code  | Speakers | Main countries                    | Source file              | Example output                  |
| ----------------------- | ----- | -------- | --------------------------------- | ------------------------ | ------------------------------- |
| Albanian                | `sq`  | ~7.5M    | Albania, Kosovo                   | [sq.json](src/sq.json)   | [output](examples/sq.md)  |
| Amharic                 | `am`  | ~57M     | Ethiopia                          | [am.json](src/am.json)   | [output](examples/am.md)  |
| Arabic                  | `ar`  | ~420M    | Middle East, North Africa         | [ar.json](src/ar.json)   | [output](examples/ar.md)  |
| Azerbaijani             | `az`  | ~23M     | Azerbaijan, Iran                  | [az.json](src/az.json)   | [output](examples/az.md)  |
| Basque                  | `eu`  | ~750K    | Spain (Basque Country), France    | [eu.json](src/eu.json)   | [output](examples/eu.md)  |
| Bengali                 | `bn`  | ~300M    | Bangladesh, India                 | [bn.json](src/bn.json)   | [output](examples/bn.md)  |
| Bosnian                 | `bs`  | ~2.5M    | Bosnia and Herzegovina            | [bs.json](src/bs.json)   | [output](examples/bs.md)  |
| Breton                  | `br`  | ~210K    | France (Brittany)                 | [br.json](src/br.json)   | [output](examples/br.md)  |
| Bulgarian               | `bg`  | ~8M      | Bulgaria                          | [bg.json](src/bg.json)   | [output](examples/bg.md)  |
| Burmese                 | `my`  | ~33M     | Myanmar                           | [my.json](src/my.json)   | [output](examples/my.md)  |
| Catalan                 | `ca`  | ~10M     | Spain (Catalonia), Andorra        | [ca.json](src/ca.json)   | [output](examples/ca.md)  |
| Central Atlas Tamazight | `tzm` | ~4.7M    | Morocco, Algeria                  | [tzm.json](src/tzm.json) | [output](examples/tzm.md) |
| Chinese                 | `zh`  | ~1.1B    | China, Taiwan, Singapore          | [zh.json](src/zh.json)   | [output](examples/zh.md)  |
| Cornish                 | `kw`  | ~3.5K    | United Kingdom (Cornwall)         | [kw.json](src/kw.json)   | [output](examples/kw.md)  |
| Croatian                | `hr`  | ~5.6M    | Croatia                           | [hr.json](src/hr.json)   | [output](examples/hr.md)  |
| Czech                   | `cs`  | ~11M     | Czech Republic                    | [cs.json](src/cs.json)   | [output](examples/cs.md)  |
| Danish                  | `da`  | ~6M      | Denmark                           | [da.json](src/da.json)   | [output](examples/da.md)  |
| Dutch                   | `nl`  | ~25M     | Netherlands, Belgium              | [nl.json](src/nl.json)   | [output](examples/nl.md)  |
| English                 | `en`  | ~1.5B    | Worldwide                         | [en.json](src/en.json)   | [output](examples/en.md)  |
| Estonian                | `et`  | ~1.1M    | Estonia                           | [et.json](src/et.json)   | [output](examples/et.md)  |
| Filipino                | `fil` | ~82M     | Philippines                       | [fil.json](src/fil.json) | [output](examples/fil.md) |
| Finnish                 | `fi`  | ~5.8M    | Finland                           | [fi.json](src/fi.json)   | [output](examples/fi.md)  |
| French                  | `fr`  | ~310M    | France, West Africa, Canada       | [fr.json](src/fr.json)   | [output](examples/fr.md)  |
| Georgian                | `ka`  | ~3.7M    | Georgia                           | [ka.json](src/ka.json)   | [output](examples/ka.md)  |
| German                  | `de`  | ~100M    | Germany, Austria, Switzerland     | [de.json](src/de.json)   | [output](examples/de.md)  |
| Greek                   | `el`  | ~13M     | Greece, Cyprus                    | [el.json](src/el.json)   | [output](examples/el.md)  |
| Gujarati                | `gu`  | ~57M     | India (Gujarat)                   | [gu.json](src/gu.json)   | [output](examples/gu.md)  |
| Hebrew                  | `he`  | ~9M      | Israel                            | [he.json](src/he.json)   | [output](examples/he.md)  |
| Hindi                   | `hi`  | ~600M    | India                             | [hi.json](src/hi.json)   | [output](examples/hi.md)  |
| Hungarian               | `hu`  | ~13M     | Hungary                           | [hu.json](src/hu.json)   | [output](examples/hu.md)  |
| Indonesian              | `id`  | ~200M    | Indonesia                         | [id.json](src/id.json)   | [output](examples/id.md)  |
| Irish                   | `ga`  | ~1.8M    | Ireland                           | [ga.json](src/ga.json)   | [output](examples/ga.md)  |
| Italian                 | `it`  | ~68M     | Italy, Switzerland                | [it.json](src/it.json)   | [output](examples/it.md)  |
| Japanese                | `ja`  | ~125M    | Japan                             | [ja.json](src/ja.json)   | [output](examples/ja.md)  |
| Javanese                | `jv`  | ~82M     | Indonesia (Java)                  | [jv.json](src/jv.json)   | [output](examples/jv.md)  |
| Kazakh                  | `kk`  | ~13M     | Kazakhstan                        | [kk.json](src/kk.json)   | [output](examples/kk.md)  |
| Khmer                   | `km`  | ~16M     | Cambodia                          | [km.json](src/km.json)   | [output](examples/km.md)  |
| Korean                  | `ko`  | ~77M     | South Korea, North Korea          | [ko.json](src/ko.json)   | [output](examples/ko.md)  |
| Latvian                 | `lv`  | ~1.7M    | Latvia                            | [lv.json](src/lv.json)   | [output](examples/lv.md)  |
| Lithuanian              | `lt`  | ~2.8M    | Lithuania                         | [lt.json](src/lt.json)   | [output](examples/lt.md)  |
| Macedonian              | `mk`  | ~2M      | North Macedonia                   | [mk.json](src/mk.json)   | [output](examples/mk.md)  |
| Malay                   | `ms`  | ~290M    | Malaysia, Indonesia, Brunei       | [ms.json](src/ms.json)   | [output](examples/ms.md)  |
| Maltese                 | `mt`  | ~520K    | Malta                             | [mt.json](src/mt.json)   | [output](examples/mt.md)  |
| Manx                    | `gv`  | ~2.5K    | Isle of Man                       | [gv.json](src/gv.json)   | [output](examples/gv.md)  |
| Marathi                 | `mr`  | ~83M     | India (Maharashtra)               | [mr.json](src/mr.json)   | [output](examples/mr.md)  |
| Nepali                  | `ne`  | ~25M     | Nepal                             | [ne.json](src/ne.json)   | [output](examples/ne.md)  |
| Norwegian Bokm&aring;l  | `nb`  | ~5.3M    | Norway                            | [nb.json](src/nb.json)   | [output](examples/nb.md)  |
| Persian                 | `fa`  | ~110M    | Iran, Afghanistan, Tajikistan     | [fa.json](src/fa.json)   | [output](examples/fa.md)  |
| Polish                  | `pl`  | ~45M     | Poland                            | [pl.json](src/pl.json)   | [output](examples/pl.md)  |
| Portuguese              | `pt`  | ~260M    | Brazil, Portugal                  | [pt.json](src/pt.json)   | [output](examples/pt.md)  |
| Punjabi                 | `pa`  | ~150M    | India (Punjab), Pakistan          | [pa.json](src/pa.json)   | [output](examples/pa.md)  |
| Romanian                | `ro`  | ~26M     | Romania, Moldova                  | [ro.json](src/ro.json)   | [output](examples/ro.md)  |
| Russian                 | `ru`  | ~255M    | Russia, Central Asia              | [ru.json](src/ru.json)   | [output](examples/ru.md)  |
| Scottish Gaelic         | `gd`  | ~57K     | United Kingdom (Scotland)         | [gd.json](src/gd.json)   | [output](examples/gd.md)  |
| Serbian                 | `sr`  | ~12M     | Serbia                            | [sr.json](src/sr.json)   | [output](examples/sr.md)  |
| Sinhala                 | `si`  | ~17M     | Sri Lanka                         | [si.json](src/si.json)   | [output](examples/si.md)  |
| Slovak                  | `sk`  | ~5.2M    | Slovakia                          | [sk.json](src/sk.json)   | [output](examples/sk.md)  |
| Slovenian               | `sl`  | ~2.5M    | Slovenia                          | [sl.json](src/sl.json)   | [output](examples/sl.md)  |
| Spanish                 | `es`  | ~560M    | Spain, Latin America              | [es.json](src/es.json)   | [output](examples/es.md)  |
| Swahili                 | `sw`  | ~200M    | East Africa                       | [sw.json](src/sw.json)   | [output](examples/sw.md)  |
| Swedish                 | `sv`  | ~10M     | Sweden, Finland                   | [sv.json](src/sv.json)   | [output](examples/sv.md)  |
| Tachelhit               | `shi` | ~7M      | Morocco                           | [shi.json](src/shi.json) | [output](examples/shi.md) |
| Tamil                   | `ta`  | ~85M     | India (Tamil Nadu), Sri Lanka     | [ta.json](src/ta.json)   | [output](examples/ta.md)  |
| Telugu                  | `te`  | ~83M     | India (Andhra Pradesh, Telangana) | [te.json](src/te.json)   | [output](examples/te.md)  |
| Thai                    | `th`  | ~61M     | Thailand                          | [th.json](src/th.json)   | [output](examples/th.md)  |
| Turkish                 | `tr`  | ~80M     | Turkey                            | [tr.json](src/tr.json)   | [output](examples/tr.md)  |
| Ukrainian               | `uk`  | ~40M     | Ukraine                           | [uk.json](src/uk.json)   | [output](examples/uk.md)  |
| Urdu                    | `ur`  | ~230M    | Pakistan, India                   | [ur.json](src/ur.json)   | [output](examples/ur.md)  |
| Uzbek                   | `uz`  | ~35M     | Uzbekistan                        | [uz.json](src/uz.json)   | [output](examples/uz.md)  |
| Vietnamese              | `vi`  | ~85M     | Vietnam                           | [vi.json](src/vi.json)   | [output](examples/vi.md)  |
| Welsh                   | `cy`  | ~880K    | United Kingdom (Wales)            | [cy.json](src/cy.json)   | [output](examples/cy.md)  |
