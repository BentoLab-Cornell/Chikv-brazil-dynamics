# Chikungunya dynamics in Brazil

Code and data for **“Geographic distribution and prioritization of reported chikungunya burden in Brazil, 2016–2025.”** The study examines reported disease burden using historical surveillance and population data; partial 2026 surveillance is held out for temporal evaluation.

## Getting started

From the repository root, check source files and R syntax without running analyses:

```sh
Rscript scripts/preflight.R --source-only
```

For dependencies and module execution, see the [reproducibility guide](docs/REPRODUCIBILITY.md). Generated outputs go to `results/` by default.

## Repository guide

- [`analysis/`](analysis/README.md): research modules and execution instructions.
- [`chikungunya/`](chikungunya/) and [`population/`](population/): surveillance and population inputs.
- [Data inventory](docs/DATA_INVENTORY.md): source files and expected outputs.
- [Module-to-result map](docs/MODULE_TO_RESULT.md): manuscript analyses and retained ancillary work.

**Reproducibility status:** production fits, provenance and environment details remain incomplete; end-to-end reproduction has not yet been verified. See the reproducibility guide for outstanding requirements.
