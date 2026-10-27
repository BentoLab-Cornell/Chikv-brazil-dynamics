# Reproducibility guide

This repository contains research source and source-data files plus packaging helpers. It is not yet a complete archived production run. The helpers standardize paths and make missing prerequisites visible; they do not certify the results or complete the pending scientific checks.

## Configuration

Run the commands below from the repository root. `analysis/00_paths.R` supplies path configuration; `analysis/00_setup.R` loads it alongside the research packages.

| Setting | Default / meaning |
|---|---|
| Source surveillance | `chikungunya/` at the repository root |
| Source population | `population/` at the repository root |
| `RESULTS_DIR` | `<repository>/results` |
| `CHIKV_RESULTS_DIR` | Optional absolute or repository-relative override for generated artifacts |
| `CHIKV_ALLOW_MODEL_FITTING` | Fitting guard; active fitting paths in modules 11/14 require explicit `true` |

Keep raw inputs separate from generated outputs. Use an empty output directory for a fresh execution check, or a documented directory containing the matching production caches. A cache's existence alone does not establish compatibility: preserve input hashes, case definition, municipality keys/order, model specification, software versions and the generating commit with each production artifact.

## 1. Non-analytical preflight

```sh
Rscript scripts/preflight.R --source-only
Rscript scripts/preflight.R --report-dir results/preflight
```

`--source-only` checks required CHIK/population file presence, R/R Markdown syntax and the artifact-inventory file. The full check additionally inventories installed-package versions and required caches. It does not test package loadability or compatibility. `--report-dir` writes checks, input checksums and a session record, plus installed-package versions in full mode. Neither command imports patient records, fits models, downloads inputs or checks reported estimates. Full-check exit status 2 indicates missing prerequisites; a source-only pass does not imply that modeling dependencies or production outputs are present.

To inventory a separate cache directory:

```sh
CHIKV_RESULTS_DIR=/absolute/path/chikv-results Rscript scripts/preflight.R
```

## 2. Software environment

R is required. The runner uses `knitr`; the research modules use packages including `read.dbc`, `dplyr`, `tidyr`, `readr`, `readxl`, `stringr`, `lubridate`, `tibble`, `purrr`, `ggplot2`, `sf`, `geobr`, `spdep` and `INLA`, with additional plotting/ancillary packages listed in `analysis/00_setup.R` and individual modules. Because shared setup loads ancillary dependencies too, package availability should be checked before selecting a module.

There is no verified production lockfile in this release. In particular, a tested `read.dbc` installation source/version and the production R/INLA environment must be recorded by the authors. Installing a current package version is not evidence that it matches the production fit. `sf` and related packages may also need platform-specific system libraries. Do not infer exact production settings from successful package installation.

The package/version list produced by preflight describes the checking environment, not an authenticated production environment.

Some modules retrieve geometry through `geobr` when cached geometry is absent. Record the actual source version and retrieval date; a run using newly retrieved geometry is not automatically the archived production run.

## 3. Explicit module execution

```sh
Rscript scripts/run_module.R 01 02
```

The requested modules execute sequentially in one R process. The example prepares case/population objects and their caches; it is an analysis action, unlike preflight. Markdown notebook reports, a module run log and a session record are written to timestamped folders under `<RESULTS_DIR>/reports`. The runner can load standard cached case/population objects when present. It does not automatically execute every dependency or every numbered module.

Use the [module map](MODULE_TO_RESULT.md) to select only the intended work. The dependency outline is:

| Stage | Required preceding inputs | Modules |
|---|---|---|
| Import and population preparation | Included CHIK DBCs and population CSVs; geometry where requested | 01, 02 |
| Descriptive results and cohort checks | Prepared case/population objects | 03, 04, 10, 16 |
| Primary spatial results | Prepared objects plus identified primary/sensitivity fits | 06 |
| Case/death shared spatial results | Prepared objects, health-region geography and saved annual fits or a deliberately authorized fit | 11 |
| Combined ranking and simple benchmark | Prepared objects and primary fitted-incidence output | 13 |
| Rolling evaluation | Prepared objects plus rolling fits/predictions | 14, then 15 |
| Longer-horizon evaluation | Archived through-2022 prediction/scoring files | 17 |
| Partial 2026 evaluation | Pre-2026 ranking output and CHIKBR26.dbc; 2025 prediction is an additional comparison | 18 |
| Score-window sensitivity | Primary fitted-incidence output and ranking output | 19 |
| Equal-dose illustration | Primary fitted incidence, ranking output and age-population panel | 20 |

This is a dependency guide, not a tested one-command workflow. Several modules contain mixed scope or session-object assumptions; see the map before execution.

## 4. Saved fits and expensive work

Module 06's primary fitting block remains commented. Its `run_heavy_models` parameter alone does not execute that block or establish how the reported fit was produced. Module 17 likewise uses saved outputs rather than implementing its production fitter. The authors must provide the exact production fitting route and fit identity.

The active fitting paths in modules 11 and 14 require explicit `CHIKV_ALLOW_MODEL_FITTING=true` when a fit is needed. This guard prevents unintended computation; it does not verify model specifications or archive missing outputs. No model fitting is required for the preflight or repository packaging checks.

For reproducing tables and figures from cached runs, supply the artifacts listed in [the inventory](DATA_INVENTORY.md), preserving their relative subdirectories beneath `RESULTS_DIR`. Missing model fits are not replaced with invented or approximate results.

## 5. Evidence still needed for a reproducible release

1. **Production records:** identify the generating code commit, exact executable fit route, input hashes and keyed output files for each reported result. Supply required fits or sufficient keyed posterior/prediction summaries and the associated logs.
2. **Source provenance:** archive surveillance extraction/version metadata and the authoritative IBGE sources and transformations used for each annual total/age population file. Distinguish the 2026 extraction date from the latest symptom-onset date.
3. **Scientific reconciliation:** confirm notification versus residence attribution, fixed-boundary handling, age/cohort rules and their effect on outputs. Packaging changes do not resolve these questions.
4. **Model and temporal metadata:** record complete priors/defaults, constraints/scaling, software/hardware/runtime, population vintages, fold inputs and the actual longer-horizon age comparator. Keep outcome-holdout claims distinct from real-time forecasts.
5. **Final output consistency:** map every submitted figure/table to verified outputs; include the existing residual map and incidence-by-population display where available. Check source-plot labels against final captions. Record unavailable CPO/PIT outputs as a limitation.
6. **Execution record:** after these items are reconciled, test the documented selected workflow in a fresh session and archive its session/package record and logs. State precisely which paths were tested and which remain untested.

The partial-2026 evaluation, combined-score ranking and illustrative two-year allocation assumptions should remain aligned with the final manuscript. Ancillary notebook titles and narrative are historical research material, not evidence that every retained analysis is reported in the paper.
