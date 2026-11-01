# Annual municipality-by-age population inputs

Eleven cleaned CSV files are included: `ibge_pop_age_2015_clean.csv` through `ibge_pop_age_2025_clean.csv`. 

Module `analysis/01_data_and_population/02_population_panel.R` reads the ten 2016–2025 files through `IBGE_DOWNLOADS_DIR`, configured in `analysis/00_setup.R`. The 2015 file is retained outside the current 2016–2025 panel.

Each CSV includes municipality identification, age columns from under 1 year to 79 years, an open-ended 80+ category, and a total. The script reads Latin-1 text, constructs total/age panels and checks coverage, duplicate keys and age-total reconciliation. Generated `pop_panel_total.rds` and `pop_panel_age.rds` are written beneath `RESULTS_DIR`, defaulting to repository `results/`; `CHIKV_RESULTS_DIR` overrides that output root.

These cleaned, IBGE-labelled files still need documentation of the original source tables, release dates, preparation steps and handling of municipality boundary changes.

See the [data inventory](../docs/DATA_INVENTORY.md) and [setup guide](../docs/REPRODUCIBILITY.md).
