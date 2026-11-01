# Running the analyses

The repository includes surveillance inputs, cleaned population files and the R analysis code. Some model fits and forecasts were produced separately on HPC and must be supplied to rerun the corresponding downstream notebooks.

## File paths

Run commands from the repository root. `analysis/00_paths.R` defines the paths used by the notebooks; `analysis/00_setup.R` loads them.

| Variable | Location |
|---|---|
| `CHIKV_CHIK_DATA_DIR` | SINAN DBC files; defaults to `chikungunya/` |
| `CHIKV_POPULATION_DIR` | Annual population CSVs; defaults to `population/` |
| `CHIKV_RESULTS_DIR` | Main results directory; defaults to `results/` |
| `CHIKV_PREP_CACHE_DIR` | Cached `Chik_total.rds`, `pop_panel_total.rds`, `pop_panel_age.rds`; defaults to the results directory |
| `CHIKV_ROLLING_RUN_DIR` | Archived rolling-origin and secondary-forecast run; defaults to `RESULTS_DIR/hpc_residence_20261028` |
| `CHIKV_SHARED_COMPONENT_DIR` | Annual shared-component fits; defaults to `RESULTS_DIR/shared_component_residence_20261030` |
| `CHIKV_ROLLING_INPUT_DIR` | Separate directory for rolling-origin case and population inputs |
| `CHIKV_ROLLING_CASE_CACHE` | Rolling-origin case filename; defaults to `Chik_total_residence_corrected.rds` |
| `CHIKV_MUNI_GEOMETRY_PATH` | Path to a saved `muni_sf_2020.rds` file |

Set paths for your machine before running R. For example:

```sh
export CHIKV_RESULTS_DIR="/path/to/inla_results"
export CHIKV_PREP_CACHE_DIR="/path/to/prepared_rds"
export CHIKV_ROLLING_RUN_DIR="/path/to/hpc_run"
export CHIKV_SHARED_COMPONENT_DIR="/path/to/shared_component_fits"
```

The archived rolling and secondary forecast files keep their existing directory structure beneath `CHIKV_ROLLING_RUN_DIR/results/`. The [data inventory](DATA_INVENTORY.md) lists the expected filenames.

## Checks

```sh
# Input files and source syntax
Rscript scripts/preflight.R --source-only

# Also check installed packages and saved artifacts
Rscript scripts/preflight.R

# Optional: write a file-by-file report
Rscript scripts/preflight.R --report-dir results/preflight
```

These commands do not run the analyses. The full check reports missing required files as `MISSING_OR_INVALID` and optional files as `PENDING`. It checks whether packages are installed, not whether every package can be loaded successfully or matches the original HPC environment.

## R environment

The notebooks use R with `knitr`, `read.dbc`, `dplyr`, `tidyr`, `readr`, `readxl`, `ggplot2`, `sf`, `geobr`, `spdep`, `INLA` and other packages listed in `analysis/00_setup.R` and the individual scripts. System libraries may be needed for spatial packages.

A production lockfile is not available. The original installation source and version of `read.dbc`, along with the full production package environment, still need to be documented. The installed-package report describes the computer on which the check was run.

Some notebooks download municipality geometry using `geobr` when no cached copy is present. Reusing the original geometry and adjacency files is preferable when checking saved model outputs.

## Running selected notebooks

```sh
Rscript scripts/run_module.R 01 02
```

The command above runs modules 01 and 02 in the same R process and writes reports to `RESULTS_DIR/reports/`. Other modules may need objects prepared in that session or saved outputs from earlier work. See the [module guide](MODULE_TO_RESULT.md) before choosing a sequence.

Module 06 reads saved primary and sensitivity models; the fitting call in that notebook is commented out. Module 17 also reads saved predictions and scores rather than fitting the original longer-horizon model. Modules 11 and 14 contain active model fitting code. If the required fit is absent, running either notebook can start a lengthy fit.

## Reproducing the reported results

A successful preflight confirms that local files and dependencies can be found. It does not establish that a saved fit corresponds to the published model or reproduce the HPC run.

For a complete production archive, the following information is still needed:

- The executable fitting scripts and saved model outputs (or keyed posterior and prediction summaries), together with input checksums and run logs.
- Source and release details for the SINAN extracts and the annual IBGE population files, including the transformations used to construct the cleaned files.
- Model settings, software versions, municipality ordering and population vintages used in the forecasting runs.
- A record linking each submitted table or figure to its source output.

The current manuscript distinguishes retrospective temporal evaluation from real-time forecasting. National CPO/PIT diagnostics were not available for the final model fit.
