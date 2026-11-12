# Annual municipality-by-age population inputs

Eleven cleaned CSV files are included: `ibge_pop_age_2015_clean.csv` through `ibge_pop_age_2025_clean.csv`. 

Module `analysis/01_data_and_population/02_population_panel.R` reads the ten 2016–2025 files through `IBGE_DOWNLOADS_DIR`, configured in `analysis/00_setup.R`. The 2015 file is retained outside the current 2016–2025 panel.

Each CSV includes municipality identification, age columns from under 1 year to 79 years, an open-ended 80+ category, and a total. The script reads Latin-1 text, constructs total/age panels and checks coverage, duplicate keys and age-total reconciliation. Generated `pop_panel_total.rds` and `pop_panel_age.rds` are written beneath `RESULTS_DIR`, defaulting to repository `results/`; `CHIKV_RESULTS_DIR` overrides that output root.

## Source and preparation

The 2016–2025 inputs were verified against the 2000–2025 RIPSA release *Resident Population: Study of Population Estimates by Municipality, Age and Sex*, distributed through [DATASUS TabNet](https://tabnet.datasus.gov.br/cgi/deftohtm.exe?ibge/cnv/popsvs2024br.def) (table definition `ibge/cnv/popsvs2024br.def`). The municipality totals and all available age-category counts in the ten annual CSVs matched the corresponding TabNet values before alignment to the study geography. Totals and age-specific denominators come from the same table. Module 02 reads the published annual estimates directly, with no additional interpolation or projection.

Module 02 takes the six-digit municipality identifier from the source labels, reshapes the age columns to long format, and filters both panels to the 5,570 municipalities in the 2020 IBGE geography obtained via `geobr`. The 2025 source table includes 5,571 municipalities. Boa Esperança do Norte (`510183`) falls outside the fixed study geography, so its population was excluded without redistribution. The resulting panel covers 55,700 municipality-years. The age-category counts sum to the published total for every retained municipality-year.

The release is retrospective. Its target-year population estimates were used as covariates in rolling-origin validation. The verification covers the 2016–2025 inputs used in the paper. The population tables were exported from DATASUS TabNet on 1 May 2026.

See the [data inventory](../docs/DATA_INVENTORY.md) and [setup guide](../docs/REPRODUCIBILITY.md).
