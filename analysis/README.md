# Analysis modules

The 22 numbered research modules (00–21) retain the research code organized into five folders. `00_paths.R` is an additional path-configuration helper. Their numbers are identifiers, **not instructions to run every file in sequence**. Consult the [module-to-result map](../docs/MODULE_TO_RESULT.md) for final-paper, mixed and ancillary scope.

| Folder | Modules | Contents |
|---|---|---|
| `01_data_and_population/` | 01, 02, 16, 21 | Import, population panels, case-definition checks, ancillary race analysis |
| `02_descriptive_epidemiology/` | 03, 04, 05, 09 | Descriptive/geographic work and ancillary wavelet/symptom analyses |
| `03_spatiotemporal_models/` | 06, 11, 12 | Primary model, shared-component model, ancillary severity surface |
| `04_clinical_and_prioritization/` | 07, 08, 10, 13, 20 | Earlier priority framework, survival, age summaries, combined rankings and allocation scenarios |
| `05_forecasting_and_validation/` | 14, 15, 17, 18, 19 | Temporal fits/scoring, partial 2026 evaluation and score-window sensitivity |

## Execution

From the repository root:

```sh
# Structural/raw-input check only; no analysis:
Rscript scripts/preflight.R --source-only

# Installed-package and cache inventory as well; no analysis:
Rscript scripts/preflight.R --report-dir results/preflight

# Explicitly chosen preparation modules, in the same R process:
Rscript scripts/run_module.R 01 02
```

The runner sets the analysis working directory, executes the requested IDs in order and writes Markdown notebook reports and logs under timestamped folders in `results/reports/` (or the corresponding configured output root). It uses `knitr` for R Markdown execution; it does not promise a publication-ready HTML/PDF render. Standard cached case/population objects are loaded when available. Other dependencies remain the responsibility of the selected module and the analyst.

`00_setup.R` loads the shared paths from `00_paths.R` and loads research packages. Source data remain in `../chikungunya/` and `../population/`; generated artifacts use `RESULTS_DIR`, defaulting to the repository's `results/`. For example:

```sh
CHIKV_RESULTS_DIR=/absolute/path/chikv-results Rscript scripts/preflight.R
```

Several notebooks depend on objects prepared earlier in the same process or on saved model-derived outputs. Independent commands create independent R sessions; choose a prerequisite sequence or supply the expected caches. Plain RStudio Knit may use a nested notebook folder as its working directory; use the runner for the documented execution route.

## Fitting and scope limits

- Module 06 reads saved primary/sensitivity fits; its original primary fitting call remains commented out. The verified production fitting route still needs to be supplied.
- Modules 11 and 14 contain active fitting paths. Missing-cache model fitting is guarded and requires explicit `CHIKV_ALLOW_MODEL_FITTING=true`. Enabling it can launch expensive models; it is not part of the packaging checks or a substitute for production provenance.
- Module 17 reads existing longer-horizon predictions/scoring outputs; it does not contain the production fitter.
- Modules 13, 18 and 20 contain additional sections beyond the final paper. Running a whole notebook may generate ancillary outputs. Module 20's equal-dose section supports Figure S5/Table S4; its fixed-municipality-coverage scenario is a different comparison.
- File 19 changes the recent-incidence summary window with the full fitted model held fixed. It does not refit after removing 2025 and does not establish reporting completeness.

See [reproducibility](../docs/REPRODUCIBILITY.md) for dependencies and pending evidence, and the [inventory](../docs/DATA_INVENTORY.md) for expected cached products. A successful execution checks only the selected route; it does not validate the scientific estimand or every manuscript result.
