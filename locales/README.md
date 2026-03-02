# Locale Data

This directory contains the canonical JSON definitions for all 71 locales supported by parent-time. Each file defines how ages are expressed in one language — the words, plural rules, and developmental stage labels.

**These files are the single source of truth.** Every language implementation (TypeScript, Python, Go, etc.) generates its locale code from these JSON files. To improve a translation, you edit the JSON file here and the change propagates everywhere.

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

| Field | What it controls | Example |
|-------|-----------------|---------|
| `code` | Language code (don't change this) | `"fr"` |
| `name` | English name of the language (don't change this) | `"French"` |
| `pluralRule` | Which plural pattern to use (don't change unless you know CLDR rules) | `"one_other_zero_one"` |
| `units` | How to say "3 days", "1 week", etc. | `"{n} jours"` |
| `half` | How to express "and a half" | `"{0} et demi"` |
| `delimiter` | Separator between parts like "2 years, 3 months" | `", "` |
| `justBorn` | What to display for a baby born today | `"Nouveau-né"` |
| `stages` | Developmental stage labels (newborn through adult) | `"Enfant"` |

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

After your JSON edit is merged, a maintainer runs the code generator (`python -m codegen.generate`), which automatically updates the locale files in all 18 language implementations. You only need to edit one file.

## Locale index

| Code | Language | Speakers | Main countries | File |
|------|----------|----------|----------------|------|
| `am` | Amharic | ~57M | Ethiopia | [am.json](am.json) |
| `ar` | Arabic | ~420M | Middle East, North Africa | [ar.json](ar.json) |
| `az` | Azerbaijani | ~23M | Azerbaijan, Iran | [az.json](az.json) |
| `bg` | Bulgarian | ~8M | Bulgaria | [bg.json](bg.json) |
| `bn` | Bengali | ~300M | Bangladesh, India | [bn.json](bn.json) |
| `br` | Breton | ~210K | France (Brittany) | [br.json](br.json) |
| `bs` | Bosnian | ~2.5M | Bosnia and Herzegovina | [bs.json](bs.json) |
| `ca` | Catalan | ~10M | Spain (Catalonia), Andorra | [ca.json](ca.json) |
| `cs` | Czech | ~11M | Czech Republic | [cs.json](cs.json) |
| `cy` | Welsh | ~880K | United Kingdom (Wales) | [cy.json](cy.json) |
| `da` | Danish | ~6M | Denmark | [da.json](da.json) |
| `de` | German | ~100M | Germany, Austria, Switzerland | [de.json](de.json) |
| `el` | Greek | ~13M | Greece, Cyprus | [el.json](el.json) |
| `en` | English | ~1.5B | Worldwide | [en.json](en.json) |
| `es` | Spanish | ~560M | Spain, Latin America | [es.json](es.json) |
| `et` | Estonian | ~1.1M | Estonia | [et.json](et.json) |
| `eu` | Basque | ~750K | Spain (Basque Country), France | [eu.json](eu.json) |
| `fa` | Persian | ~110M | Iran, Afghanistan, Tajikistan | [fa.json](fa.json) |
| `fi` | Finnish | ~5.8M | Finland | [fi.json](fi.json) |
| `fil` | Filipino | ~82M | Philippines | [fil.json](fil.json) |
| `fr` | French | ~310M | France, West Africa, Canada | [fr.json](fr.json) |
| `ga` | Irish | ~1.8M | Ireland | [ga.json](ga.json) |
| `gd` | Scottish Gaelic | ~57K | United Kingdom (Scotland) | [gd.json](gd.json) |
| `gu` | Gujarati | ~57M | India (Gujarat) | [gu.json](gu.json) |
| `gv` | Manx | ~2.5K | Isle of Man | [gv.json](gv.json) |
| `he` | Hebrew | ~9M | Israel | [he.json](he.json) |
| `hi` | Hindi | ~600M | India | [hi.json](hi.json) |
| `hr` | Croatian | ~5.6M | Croatia | [hr.json](hr.json) |
| `hu` | Hungarian | ~13M | Hungary | [hu.json](hu.json) |
| `id` | Indonesian | ~200M | Indonesia | [id.json](id.json) |
| `it` | Italian | ~68M | Italy, Switzerland | [it.json](it.json) |
| `ja` | Japanese | ~125M | Japan | [ja.json](ja.json) |
| `jv` | Javanese | ~82M | Indonesia (Java) | [jv.json](jv.json) |
| `ka` | Georgian | ~3.7M | Georgia | [ka.json](ka.json) |
| `kk` | Kazakh | ~13M | Kazakhstan | [kk.json](kk.json) |
| `km` | Khmer | ~16M | Cambodia | [km.json](km.json) |
| `ko` | Korean | ~77M | South Korea, North Korea | [ko.json](ko.json) |
| `kw` | Cornish | ~3.5K | United Kingdom (Cornwall) | [kw.json](kw.json) |
| `lt` | Lithuanian | ~2.8M | Lithuania | [lt.json](lt.json) |
| `lv` | Latvian | ~1.7M | Latvia | [lv.json](lv.json) |
| `mk` | Macedonian | ~2M | North Macedonia | [mk.json](mk.json) |
| `mr` | Marathi | ~83M | India (Maharashtra) | [mr.json](mr.json) |
| `ms` | Malay | ~290M | Malaysia, Indonesia, Brunei | [ms.json](ms.json) |
| `mt` | Maltese | ~520K | Malta | [mt.json](mt.json) |
| `my` | Burmese | ~33M | Myanmar | [my.json](my.json) |
| `nb` | Norwegian Bokm&aring;l | ~5.3M | Norway | [nb.json](nb.json) |
| `ne` | Nepali | ~25M | Nepal | [ne.json](ne.json) |
| `nl` | Dutch | ~25M | Netherlands, Belgium | [nl.json](nl.json) |
| `pa` | Punjabi | ~150M | India (Punjab), Pakistan | [pa.json](pa.json) |
| `pl` | Polish | ~45M | Poland | [pl.json](pl.json) |
| `pt` | Portuguese | ~260M | Brazil, Portugal | [pt.json](pt.json) |
| `ro` | Romanian | ~26M | Romania, Moldova | [ro.json](ro.json) |
| `ru` | Russian | ~255M | Russia, Central Asia | [ru.json](ru.json) |
| `shi` | Tachelhit | ~7M | Morocco | [shi.json](shi.json) |
| `si` | Sinhala | ~17M | Sri Lanka | [si.json](si.json) |
| `sk` | Slovak | ~5.2M | Slovakia | [sk.json](sk.json) |
| `sl` | Slovenian | ~2.5M | Slovenia | [sl.json](sl.json) |
| `sq` | Albanian | ~7.5M | Albania, Kosovo | [sq.json](sq.json) |
| `sr` | Serbian | ~12M | Serbia | [sr.json](sr.json) |
| `sv` | Swedish | ~10M | Sweden, Finland | [sv.json](sv.json) |
| `sw` | Swahili | ~200M | East Africa | [sw.json](sw.json) |
| `ta` | Tamil | ~85M | India (Tamil Nadu), Sri Lanka | [ta.json](ta.json) |
| `te` | Telugu | ~83M | India (Andhra Pradesh, Telangana) | [te.json](te.json) |
| `th` | Thai | ~61M | Thailand | [th.json](th.json) |
| `tr` | Turkish | ~80M | Turkey | [tr.json](tr.json) |
| `tzm` | Central Atlas Tamazight | ~4.7M | Morocco, Algeria | [tzm.json](tzm.json) |
| `uk` | Ukrainian | ~40M | Ukraine | [uk.json](uk.json) |
| `ur` | Urdu | ~230M | Pakistan, India | [ur.json](ur.json) |
| `uz` | Uzbek | ~35M | Uzbekistan | [uz.json](uz.json) |
| `vi` | Vietnamese | ~85M | Vietnam | [vi.json](vi.json) |
| `zh` | Chinese | ~1.1B | China, Taiwan, Singapore | [zh.json](zh.json) |

Speaker counts are approximate and include L1 and L2 speakers.
