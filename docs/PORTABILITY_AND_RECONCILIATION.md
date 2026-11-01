# Portability changes and remaining result reconciliation

This audit separates **safe source-code portability cleanup** from **scientific validation of already-completed production analyses**. The original production model fits are not regenerated, overwritten or validated by editing the notebooks.

## What the portability patch changes

- All DBC input paths in module 01 use `CHIK_DATA_DIR`. Module 18 uses the same location for the separate provisional 2026 input.
- Modules 01/02 write their intentionally regenerated preparation RDS caches to `RESULTS_DIR`; existing preparation caches can be read without copies via explicit `CHIKV_PREP_CACHE_DIR`. The preflight, runner, and reading sites in modules 07/13/14/20 respect that configured read location. Other modules 06/07/12/13/18/19/20/21 use configured result paths.
- Modules 14/15/17 retain the historical `hpc_residence_20261028` directory structure, configurable via `CHIKV_ROLLING_RUN_DIR`. Modules 14/15 preserve the exact historical `Chik_total_residence_corrected.rds` filename by default; change this only with verified cohort provenance using `CHIKV_ROLLING_CASE_CACHE` and, if needed, `CHIKV_ROLLING_INPUT_DIR`.
- Module 11 retains `shared_component_residence_20261030` under `CHIKV_SHARED_COMPONENT_DIR`; both modules 11 and 14 block missing-cache INLA fitting by default. The opt-in environment variable is `CHIKV_ALLOW_MODEL_FITTING=true`.
- Module 06 and module 18 can load verified geometry via `CHIKV_MUNI_GEOMETRY_PATH`. Existing geobr fallback behavior remains. A graph with the correct node count is **not** alone evidence of correct municipality order.
- Module 17 no longer duplicates inconsistent percentages in notebook prose. Its saved HPC scoring CSV is the numeric source of truth; the notebook does not recompute the production model.

## Before running any analysis

1. Preserve **copies** of all original fit RDS, prediction CSV, scoring CSV, run logs and manuscript figures. Do not point a newly executed module at your sole archived production output folder.
2. Set `CHIKV_RESULTS_DIR` to a separate working result directory for fresh preparation runs, or to a **read-only / backed-up** archive only for cache-reading and figure inspection. If the three preparation caches are in an HPC subfolder, set `CHIKV_PREP_CACHE_DIR` to that folder for cache-only checks. Running module 01 or 02 intentionally writes caches under `RESULTS_DIR`, not `CHIKV_PREP_CACHE_DIR`; clear the latter before consuming freshly regenerated caches. Some other notebooks also write derived outputs.
3. Set `CHIKV_ROLLING_RUN_DIR` and `CHIKV_SHARED_COMPONENT_DIR` to the correct production-run directories if they differ from the default. Never assume identical names imply compatible results.
4. Start with `Rscript scripts/preflight.R --source-only` and check package versions. The preflight is structural, not a reproduction of the scientific results. Only intentionally execute selected modules.

## Outstanding checks that cannot be certified from repository code alone

| Area | Evidence needed | Status |
|---|---|---|
| Reported production fits | Original fit RDS, full code/commit, log, environment, input hashes and municipality/key order | Not included in repository; not rerun |
| Municipality attribution | Author confirms reported production analyses used `ID_MN_RESI`; archive proof in original cohort and model-run records, including any `5399*` code harmonization | Confirmed by author, archived provenance pending |
| Module 17 percentages | Author supplied summary of three local performance CSVs with MD5 checksums (details below). Residence-named run is the configured source, but companion prediction, municipality rankings, correlations, and submitted manuscript still need comparison | Two distinct historical summary versions identified; manuscript and source provenance pending |
| Module 06 scientific estimates | Actual primary and sensitivity fit outputs, saved posterior summary tables, model formula, versions and generation log | Not independently checked |
| Provisional 2026 | Surveillance extraction date/version. `DT_SIN_PRI` is symptom onset, not download/notification date | Extraction metadata pending |
| Supplementary plots | Latest S1 residual map, S2 prior/posterior, S3 score-window, S4 longer horizon, S5 partial 2026, S6 equal-dose allocation; image, legend, caption and numbers must agree | Plot artifact comparison pending; S6 image previously flagged as outdated |
| Parameter choices | Actual prior settings, population denominators, scoring windows, and vaccine illustration assumptions | Code retained as specified; external scientific verification pending |

## Validation and interpretation boundaries

The edits do **not** imply that production results previously used `ID_MUNICIP`. The author confirmed all *executed* production analyses used residence (`ID_MN_RESI`); previously inconsistent references were in unexecuted extra analyses.

Do not silently replace historical fitted objects, rerun INLA to fill gaps, retroactively change paper statistics, or regenerate the final S6 plot from an unverified cache. A green source-only preflight or successful notebook execution proves neither scientific correctness nor agreement with published/submitted numbers.

## Local secondary-forecast result versions located on 2026-10-31

The author ran a **read-only** directory/MD5 and CSV comparison on their Mac. These numbers are transcribed from that command output; we did not independently receive or parse the source CSV files.

| Archived scoring path (relative to `~/Downloads/inla_results/`) | MD5 | Total cases | INLA cases selected | INLA deaths selected | INLA capture (cases / deaths) |
|---|---|---:|---:|---:|---|
| `hpc_residence_20261028/results/secondary_forecast_2016_2022_residence/scoring/secondary_forecast_performance_2016_2022_to_2024_2025.csv` | `d209ef2d877371b29da167a8372e2150` | 325,928 | 278,760 | 289 / 355 | 85.52809% / 81.40845% |
| `hpc_residence_20261028/results/secondary_forecast_2016_2022/scoring/secondary_forecast_performance_2016_2022_to_2024_2025.csv` | `cb666218541b55a41c4825d7b2a95e1e` | 325,936 | 277,362 | 316 / 355 | 85.09707% / 89.01408% |
| `secondary_forecast_2016_2022/scoring/secondary_forecast_performance_2016_2022_to_2024_2025.csv` | `cb666218541b55a41c4825d7b2a95e1e` | 325,936 | 277,362 | 316 / 355 | 85.09707% / 89.01408% |

All versions select 1,857 municipalities. Two legacy copies have identical MD5s. The code of module 17 **already points at the residence-named directory**; its latest performance output matches the notebook's former concluding figures (~85.5%, ~81.4%). The older summary matches its former contradictory text (~85.1%, ~89.0%). The difference includes 8 observed cases in the evaluation denominator and substantial ranking/capture changes; it cannot safely be attributed to a particular municipality-field choice solely from directory names.

The current manuscript's longer-horizon result (Supplementary Fig. S4) should be reconciled against the **complete matched bundle** of residence-named prediction, scoring, municipality rankings and correlation files, plus archived generating code, not selected by whichever value is higher. Do not copy files from the legacy directory to fill missing residence outputs. Run the new read-only `scripts/audit_secondary_forecast.R` and compare the printed row-level and correlation summaries with the submitted figure/caption. Record the extraction/production identity before calling this scientifically verified.
