# Analysis code

The numbered files are organized by topic. The numbers identify modules; they are not a required execution order. Use the [module guide](../docs/MODULE_TO_RESULT.md) to see which notebooks support the manuscript and which contain ancillary work.

| Folder | Modules | Contents |
|---|---|---|
| `01_data_and_population/` | 01, 02, 16, 21 | Surveillance data, population panels, case-definition checks, race/ethnicity analysis |
| `02_descriptive_epidemiology/` | 03, 04, 05, 09 | Descriptive, geographic, wavelet and symptom analyses |
| `03_spatiotemporal_models/` | 06, 11, 12 | Spatiotemporal and shared-component models |
| `04_clinical_and_prioritization/` | 07, 08, 10, 13, 20 | Clinical summaries, prioritization and allocation scenarios |
| `05_forecasting_and_validation/` | 14, 15, 17, 18, 19 | Rolling forecasts and temporal evaluations |

## Running a module

Run these commands from the repository root:

```sh
# Check inputs, code syntax, installed packages and saved outputs
Rscript scripts/preflight.R

# Run selected preparation modules in one R session
Rscript scripts/run_module.R 01 02
```

`run_module.R` runs only the modules you name. It sets the working directory to `analysis/` and saves notebook output and logs under `RESULTS_DIR/reports/`. Some notebooks depend on objects produced earlier in the same session; others can read saved RDS or CSV files.

Paths are defined in `00_paths.R` and loaded by `00_setup.R`. Results default to `results/` at the repository root. For example:

```sh
export CHIKV_RESULTS_DIR="/path/to/inla_results"
export CHIKV_PREP_CACHE_DIR="/path/to/prepared_rds"
export CHIKV_ROLLING_RUN_DIR="/path/to/hpc_run"
export CHIKV_SHARED_COMPONENT_DIR="/path/to/shared_component_fits"
```

Only set variables for directories that differ from the defaults. The [reproducibility guide](../docs/REPRODUCIBILITY.md) lists the other path options.

## Saved models and ancillary work

Module 06 loads archived primary and sensitivity fits; its fitting call is commented out. Module 17 reads saved longer-horizon predictions and scoring files. Modules 11 and 14 have active fitting code and may start a fit when a saved result is missing, so check the inputs before running them.

Not all sections of the notebooks appear in the paper. In particular, modules 07, 08, 09, 12 and 21 contain ancillary analyses. See the [module guide](../docs/MODULE_TO_RESULT.md) for the scope of each file.
