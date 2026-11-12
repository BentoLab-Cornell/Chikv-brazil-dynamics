# Running the analyses

The repository includes surveillance inputs, cleaned population files and the R analysis code. Some model fits and forecasts were produced separately on HPC and must be supplied to rerun the corresponding downstream notebooks.

## Archived analysis outputs

Download `AB9_submission_candidate.tar.gz` from the [paper revision release](https://github.com/BentoLab-Cornell/Chikv-brazil-dynamics/releases/tag/paper-revision-2026-11). It includes the primary fit and matching panel, production scripts and log, shared-component and sensitivity fits, and saved prediction, scoring and plotting data. Extract it and set `CHIKV_RESULTS_DIR` to the extracted `results/` directory. Run `shasum -a 256 -c SHA256SUMS.txt` from the extracted archive root to check the files.

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

The DBC import environment was checked using the installed package metadata. It reported `read.dbc` version `1.0.6` from CRAN, built for R `4.6.0` on `aarch64-apple-darwin23`. The primary Seneca fit reads prepared RDS inputs and does not load `read.dbc`. A full production environment lockfile is unavailable.

Some notebooks download municipality geometry using `geobr` when no cached copy is present. Reusing the original geometry and adjacency files is preferable when checking saved model outputs.

## Running selected notebooks

```sh
Rscript scripts/run_module.R 01 02
```

The command above runs modules 01 and 02 in the same R process and writes reports to `RESULTS_DIR/reports/`. Other modules may need objects prepared in that session or saved outputs from earlier work. See the [module guide](MODULE_TO_RESULT.md) before choosing a sequence.

Module 06 reads saved primary and sensitivity models. Place the original panel `panel_chik_2016_2025_residence.rds` and its matching fit `fit_chik_nb_2016_2025_residence.rds` from Seneca job 239791 together under `RESULTS_DIR/residence/`. Module 06 preserves the panel's saved row order when attaching fitted values. Module 17 also reads saved predictions and scores rather than fitting the original longer-horizon model. Modules 11 and 14 contain active model fitting code. If the required fit is absent, running either notebook can start a lengthy fit.

## Reproducing the reported results

A successful preflight confirms that local files and dependencies can be found. It does not establish that a saved fit corresponds to the published model or reproduce the HPC run.

### Primary fit on Seneca

The [production fitter](../production/primary/02_fit_primary_nb_2016_2025_residence.R) and [Slurm launcher](../production/primary/run_primary_nb_2016_2025_residence.slurm) are the scripts used for job 239791. The job completed on 28 October 2026 with R 4.6.0 and INLA 26.08.07. Its panel contained 668,400 rows, 5,570 municipalities, 120 months and 1,215,063 cases.

Run Module 01 to create the confirmed cohort and harmonize residence codes. In the same R session, write the harmonized six-digit residence code under the field name expected by the fitter:

```r
saveRDS(
  dplyr::mutate(Chik_total, ID_MN_RESI_CORR = code_muni),
  file.path(production_dir, "Chik_total_residence_corrected.rds")
)
```

Set `production_dir` to the working directory for the job before running that command. Copy the Module 02 `pop_panel_total.rds`, the original ordered `muni_sf_2020.rds`, the matching `brazil_muni_2020.adj` and both production scripts into that directory. The adjacency file was matched to the copy in the rolling-origin archive by SHA-256 (`0fcaed9c0bfb4e3c489a8f6665249685f7aa92662d3ae61437be80b2baca95ea`). Keep the geometry and graph in their original order.

From the working directory on Seneca, with the R and Conda paths in the launcher configured for your account, run:

```sh
mkdir -p logs results
sbatch run_primary_nb_2016_2025_residence.slurm
```

The fitter writes the primary fit, its matching panel and a text summary under `results/`. To use an existing fit, place the matching fit and panel under `RESULTS_DIR/residence/` as described above.

### Longer-horizon evaluation

Module 17 reads the saved municipality predictions from `secondary_forecast_2016_2022_residence/predictions/` and the performance, rank-correlation and municipality-ranking CSVs from `secondary_forecast_2016_2022_residence/scoring/`. Keep both directories under `CHIKV_ROLLING_RUN_DIR/results/`. The notebook uses these outputs to assemble the reported evaluation.

The current manuscript distinguishes retrospective temporal evaluation from real-time forecasting. National CPO/PIT diagnostics were not available for the final model fit.
