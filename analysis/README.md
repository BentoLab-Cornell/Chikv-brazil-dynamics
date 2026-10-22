# Analysis modules (2016–2025)

**00_setup.R** is the shared configuration file. Files 01–21 are grouped by topic, preserving all statistical model specifications. Only the shared source-data paths in Files 00, 01 and 18 were adjusted to point to the checked-in CHIK and IBGE datasets.

| Folder | Scripts | Focus |
|---|---|---|
| [01_data_and_population](01_data_and_population/) | 01, 02, 16, 21 | Case imports, denominators and definition audits |
| [02_descriptive_epidemiology](02_descriptive_epidemiology/) | 03, 04, 05, 09 | Descriptive epidemiology, geographic demography, wavelets and symptoms |
| [03_spatiotemporal_models](03_spatiotemporal_models/) | 06, 11, 12 | Bayesian INLA, shared-component and severity models |
| [04_clinical_and_prioritization](04_clinical_and_prioritization/) | 07, 08, 10, 13, 20 | Cox models, allocation metrics, eligibility and averted-burden scenarios |
| [05_forecasting_and_validation](05_forecasting_and_validation/) | 14, 15, 17, 18, 19 | Rolling-origin forecasting, 2026 validation and reporting completeness |

## How to execute

Keep **`analysis/`** as the R working directory so that `source("00_setup.R")` and relative paths remain resolvable:

```r
setwd("/path/to/Chikungunya-Spatiotemporal-Analysis/analysis")
source("00_setup.R")

# Render a nested notebook while keeping analysis/ as the chunk root:
rmarkdown::render(
  "03_spatiotemporal_models/06_inla_spacetime_model_2016_2025.Rmd",
  knit_root_dir = normalizePath(".")
)

# Or source the population script:
source("01_data_and_population/02_population_panel.R")
```

**Important:** Clicking Knit directly in RStudio may use the nested folder as the working directory and fail to locate `00_setup.R`. Setting the working directory once is not sufficient for a plain Knit; use the explicit `knit_root_dir` argument shown above.

These scripts are not automatically independent: some require upstream in-memory objects and saved HPC RDS files. Input-data paths now use repository-relative CHIK and population folders; model-result inputs (including HPC outputs) remain external. See [reproducibility](../docs/REPRODUCIBILITY.md) and [file inventory](../docs/DATA_INVENTORY.md).
