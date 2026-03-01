# Locale Reference

Quick reference for all 63 locales supported by parent-time.

For detailed documentation on plural rules, stage labels, and half-year markers,
see [locales.md](locales.md).

## All locales

| Code | Language | Speakers | Countries | Plural rule | Categories |
|------|----------|----------|-----------|-------------|------------|
| `am` | Amharic | 57M | Ethiopia | `one_other_zero_one` | one, other |
| `ar` | Arabic | 400M | Egypt, Saudi Arabia, Iraq, Morocco + 20 more | `ar` | zero, one, two, few, many, other |
| `az` | Azerbaijani | 23M | Azerbaijan, Iran | `one_other` | one, other |
| `bg` | Bulgarian | 8M | Bulgaria | `one_other` | one, other |
| `bn` | Bengali | 300M | Bangladesh, India | `one_other_zero_one` | one, other |
| `bs` | Bosnian | 2.5M | Bosnia and Herzegovina | `slavic_bcs` | one, few, other |
| `ca` | Catalan | 10M | Spain (Catalonia), Andorra | `one_other` | one, other |
| `cs` | Czech | 11M | Czech Republic | `cs_sk` | one, few, other |
| `da` | Danish | 6M | Denmark | `one_other` | one, other |
| `de` | German | 100M | Germany, Austria, Switzerland + 3 more | `one_other` | one, other |
| `el` | Greek | 13M | Greece, Cyprus | `one_other` | one, other |
| `en` | English | 1.5B | US, UK, Australia, Canada + 50 more | `one_other` | one, other |
| `es` | Spanish | 560M | Spain, Mexico, Colombia, Argentina + 17 more | `one_other` | one, other |
| `et` | Estonian | 1.1M | Estonia | `one_other` | one, other |
| `eu` | Basque | 750K | Spain (Basque Country), France | `other_only` | other |
| `fa` | Persian | 110M | Iran, Afghanistan, Tajikistan | `one_other_zero_one` | one, other |
| `fi` | Finnish | 5.8M | Finland | `one_other` | one, other |
| `fil` | Filipino | 82M | Philippines | `other_only` | other |
| `fr` | French | 310M | France, Canada, Belgium, Switzerland + 25 more | `one_other_zero_one` | one, other |
| `ga` | Irish | 1.8M | Ireland | `other_only` | other |
| `gu` | Gujarati | 57M | India (Gujarat) | `one_other_zero_one` | one, other |
| `he` | Hebrew | 9M | Israel | `he` | one, two, other |
| `hi` | Hindi | 600M | India | `one_other_zero_one` | one, other |
| `hr` | Croatian | 5.5M | Croatia | `slavic_bcs` | one, few, other |
| `hu` | Hungarian | 13M | Hungary | `other_only` | other |
| `id` | Indonesian | 200M | Indonesia | `other_only` | other |
| `it` | Italian | 68M | Italy, Switzerland | `one_other` | one, other |
| `ja` | Japanese | 125M | Japan | `other_only` | other |
| `jv` | Javanese | 82M | Indonesia (Java) | `other_only` | other |
| `ka` | Georgian | 3.7M | Georgia | `one_other` | one, other |
| `kk` | Kazakh | 13M | Kazakhstan | `one_other` | one, other |
| `km` | Khmer | 16M | Cambodia | `other_only` | other |
| `ko` | Korean | 81M | South Korea, North Korea | `other_only` | other |
| `lt` | Lithuanian | 2.8M | Lithuania | `lt` | one, few, other |
| `lv` | Latvian | 1.5M | Latvia | `lv` | zero, one, other |
| `mk` | Macedonian | 1.4M | North Macedonia | `mk` | one, other |
| `mr` | Marathi | 83M | India (Maharashtra) | `one_other` | one, other |
| `ms` | Malay | 77M | Malaysia, Brunei, Singapore | `other_only` | other |
| `my` | Burmese | 33M | Myanmar | `other_only` | other |
| `nb` | Norwegian Bokmal | 5M | Norway | `one_other` | one, other |
| `ne` | Nepali | 25M | Nepal | `one_other` | one, other |
| `nl` | Dutch | 25M | Netherlands, Belgium | `one_other` | one, other |
| `pa` | Punjabi | 125M | Pakistan, India (Punjab) | `one_other_zero_one` | one, other |
| `pl` | Polish | 45M | Poland | `pl` | one, few, many |
| `pt` | Portuguese | 260M | Brazil, Portugal, Angola, Mozambique + 5 more | `one_other_zero_one` | one, other |
| `ro` | Romanian | 26M | Romania, Moldova | `ro` | one, few, other |
| `ru` | Russian | 258M | Russia, Belarus, Kazakhstan + 5 more | `ru_uk` | one, few, many |
| `si` | Sinhala | 17M | Sri Lanka | `one_other_zero_one` | one, other |
| `sk` | Slovak | 5.2M | Slovakia | `cs_sk` | one, few, other |
| `sl` | Slovenian | 2.5M | Slovenia | `sl` | one, two, few, other |
| `sq` | Albanian | 7.5M | Albania, Kosovo, North Macedonia | `one_other` | one, other |
| `sr` | Serbian | 9M | Serbia | `slavic_bcs` | one, few, other |
| `sv` | Swedish | 13M | Sweden, Finland | `one_other` | one, other |
| `sw` | Swahili | 200M | Tanzania, Kenya, Uganda, DRC + 5 more | `one_other` | one, other |
| `ta` | Tamil | 78M | India (Tamil Nadu), Sri Lanka, Singapore | `one_other` | one, other |
| `te` | Telugu | 83M | India (Andhra Pradesh, Telangana) | `one_other` | one, other |
| `th` | Thai | 61M | Thailand | `other_only` | other |
| `tr` | Turkish | 88M | Turkey, Cyprus | `one_other` | one, other |
| `uk` | Ukrainian | 33M | Ukraine | `ru_uk` | one, few, many |
| `ur` | Urdu | 230M | Pakistan, India | `one_other` | one, other |
| `uz` | Uzbek | 35M | Uzbekistan | `one_other` | one, other |
| `vi` | Vietnamese | 85M | Vietnam | `other_only` | other |
| `zh` | Chinese | 1.1B | China, Taiwan, Singapore, Malaysia + 3 more | `other_only` | other |

Speaker counts include both native and L2 speakers (approximate).

## Plural rules

There are 14 distinct plural rule patterns used across the 63 locales:

| Rule | Categories | Logic | Used by |
|------|-----------|-------|---------|
| `other_only` | other | Always `other` | eu, fil, ga, hu, id, ja, jv, km, ko, ms, my, th, vi, zh |
| `one_other` | one, other | n=1 &rarr; one | az, bg, ca, da, de, el, en, es, et, fi, it, ka, kk, mr, nb, ne, nl, sq, sv, sw, ta, te, tr, uk, ur, uz |
| `one_other_zero_one` | one, other | n&isin;{0,1} &rarr; one | am, bn, fa, fr, gu, hi, pa, pt, si |
| `he` | one, two, other | n=1 &rarr; one, n=2 &rarr; two | he |
| `mk` | one, other | n%10=1 and n%100&ne;11 &rarr; one | mk |
| `cs_sk` | one, few, other | n=1 &rarr; one, n&isin;2..4 &rarr; few | cs, sk |
| `slavic_bcs` | one, few, other | Slavic mod-10/mod-100 pattern | bs, hr, sr |
| `lt` | one, few, other | Lithuanian mod-10/mod-100 | lt |
| `ro` | one, few, other | n=1 &rarr; one, n=0 or n%100&isin;1..19 &rarr; few | ro |
| `lv` | zero, one, other | Latvian mod-10/mod-100 | lv |
| `sl` | one, two, few, other | Slovenian mod-100 | sl |
| `pl` | one, few, many | n=1 &rarr; one, Polish mod-10/mod-100 &rarr; few, else many | pl |
| `ru_uk` | one, few, many | Slavic mod-10/mod-100 with many | ru, uk |
| `ar` | zero, one, two, few, many, other | Full Arabic CLDR pattern | ar |
