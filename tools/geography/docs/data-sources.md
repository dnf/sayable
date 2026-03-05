# Data Sources

## Country Language Data (`countries.json`)

Language proportions for ~195 countries. Each entry includes the fraction of the population that speaks the language (L1 + L2 speakers combined).

### Primary sources

- **CIA World Factbook (2024)** — Public domain. Language data from the "Languages" field of each country entry. https://www.cia.gov/the-world-factbook/
- **Ethnologue, 27th edition (2024)** — Used to fill gaps and cross-check proportions, especially for multilingual countries in Africa and Asia. https://www.ethnologue.com/

### Notes

- Proportions may sum to more than 1.0 for multilingual countries (e.g., Paraguay where both Spanish and Guarani are widely spoken). Coverage is capped at 100%.
- Languages not in our locale set are still listed to show where gaps exist.
- Language codes use ISO 639-1 where available, matching the codes used by our locale files.
- "L2 speakers" includes those who use the language as a second or additional language in daily life, education, or commerce — not just native speakers.

## Map Geometries (`data/ne_110m.geojson`)

Country boundary polygons for choropleth rendering.

- **Natural Earth, 1:110m Admin 0 — Countries (v5.1.1)** — Public domain (CC0). https://www.naturalearthdata.com/
- Source repository: https://github.com/nvkelso/natural-earth-vector
- File: `ne_110m_admin_0_countries.geojson` (~800KB)
- Contains `ISO_A2` codes for joining with `countries.json` and `CONTINENT` field for filtering.
- Some entities have `-99` as their ISO code (France, Norway, Kosovo, N. Cyprus, Somaliland). The generator handles these with a manual override table.
