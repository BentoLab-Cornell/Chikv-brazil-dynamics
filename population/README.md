# Annual IBGE municipality-by-age population inputs

The following **11 cleaned source CSV files** are included without modifying their content:

- `ibge_pop_age_2015_clean.csv`
- `ibge_pop_age_2016_clean.csv`
- `ibge_pop_age_2017_clean.csv`
- `ibge_pop_age_2018_clean.csv`
- `ibge_pop_age_2019_clean.csv`
- `ibge_pop_age_2020_clean.csv`
- `ibge_pop_age_2021_clean.csv`
- `ibge_pop_age_2022_clean.csv`
- `ibge_pop_age_2023_clean.csv`
- `ibge_pop_age_2024_clean.csv`
- `ibge_pop_age_2025_clean.csv`

`analysis/01_data_and_population/02_population_panel.R` reads **2016–2025** via `IBGE_DOWNLOADS_DIR` set in `analysis/00_setup.R`; the 2015 file is retained for provenance but not used in the current 2016–2025 panel.

The population script checks year coverage, municipality alignment, duplicates and reconciliation of age totals against total population, then saves `pop_panel_total.rds` and `pop_panel_age.rds` in the active R working directory (normally `analysis/`).

These uploaded files are identified by filename as cleaned IBGE inputs; their detailed cleaning workflow and IBGE table identifiers have **not** yet been independently audited. Record the source table, retrieval date, transformation pipeline and checksums before manuscript archiving.
