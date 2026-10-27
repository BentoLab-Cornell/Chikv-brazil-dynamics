# Annual municipality-by-age population inputs

Eleven cleaned CSV files are included: `ibge_pop_age_2015_clean.csv` through `ibge_pop_age_2025_clean.csv`. Their contents remain unchanged by repository packaging.

Module `analysis/01_data_and_population/02_population_panel.R` reads the ten 2016–2025 files through `IBGE_DOWNLOADS_DIR`, configured in `analysis/00_setup.R`. The 2015 file is retained outside the current 2016–2025 panel.

Each CSV includes municipality identification, age columns from under 1 year to 79 years, an open-ended 80+ category, and a total. The script reads Latin-1 text, constructs total/age panels and checks coverage, duplicate keys and age-total reconciliation. Generated `pop_panel_total.rds` and `pop_panel_age.rds` are written beneath `RESULTS_DIR`, defaulting to repository `results/`; `CHIKV_RESULTS_DIR` overrides that output root.

The files are labelled as cleaned IBGE inputs. Exact source tables/APIs, reference and release dates, cleaning/transformation code, and any interpolation or projection assumptions still require documentation. The fixed-2020 municipality mapping and population conservation also require scientific reconciliation; successful row-count checks alone do not establish them. Do not infer a verified production provenance from these filenames.

See the [data inventory](../docs/DATA_INVENTORY.md) and [reproducibility guide](../docs/REPRODUCIBILITY.md). Preserve these source CSVs separately from generated panels.
