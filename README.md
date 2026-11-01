# Chikungunya burden in Brazil

R code and data for *Geographic distribution and prioritization of reported chikungunya burden in Brazil, 2016–2025*.

The main analyses cover 2016–2025. A separate, partial 2026 surveillance dataset is used for temporal evaluation.

## Running the code

Clone the repository and run the input and syntax checks from its root:

```sh
Rscript scripts/preflight.R --source-only
Rscript scripts/preflight.R
```

To use files stored elsewhere on your computer, set `CHIKV_RESULTS_DIR` and any other relevant paths before running an analysis. See the [setup and reproducibility notes](docs/REPRODUCIBILITY.md) for examples.

## Files

- [`analysis/`](analysis/README.md) — numbered R scripts and notebooks
- [`chikungunya/`](chikungunya/) — SINAN surveillance files
- [`population/`](population/) — annual population inputs
- [Data inventory](docs/DATA_INVENTORY.md) — input files and saved outputs
- [Module guide](docs/MODULE_TO_RESULT.md) — which analyses correspond to manuscript results

Some notebooks use model fits produced on Cornell's HPC cluster. These saved results are not all included in the repository, so a full rerun of the production analysis has not been independently tested.
