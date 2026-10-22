# Chikungunya in Brazil: Spatiotemporal Risk, Disease Severity, and Vaccination Prioritization

**A nationwide Bayesian epidemiological analysis | Primary study period: 2016–2025 | 5,570 Brazilian municipalities**

![R](https://img.shields.io/badge/analysis-R-276DC3?logo=r&logoColor=white) ![INLA](https://img.shields.io/badge/Bayesian%20inference-INLA-475569) ![Status](https://img.shields.io/badge/status-manuscript%20revision-informational) ![Data](https://img.shields.io/badge/data-SINAN%20%2B%20IBGE-64748b)

> **Repository status (October 2026):** All 22 author-confirmed analysis modules (00–21) are organized under [`analysis/`](analysis/); historical SINAN, cleaned IBGE age-population inputs and provisional held-out 2026 surveillance files remain under [`data/`](data/). The superseded exploratory notebook was removed from `main` and remains recoverable in the [historical backup branch](https://github.com/hemaanizg/Chikungunya-Spatiotemporal-Analysis/tree/backup/pre-code-replacement-2026-10-20). Saved HPC model fits and some downstream outputs are not yet deposited; consult [reproducibility](docs/REPRODUCIBILITY.md) and the [file inventory](docs/DATA_INVENTORY.md).

## Project overview

Chikungunya has produced large, geographically heterogeneous epidemics across Brazil. This project brings together national SINAN/DATASUS surveillance records, IBGE population estimates, spatial Bayesian models, and clinical-outcome analyses to examine how **reported chikungunya burden, geographic risk, and severe disease differ across populations and over time**.

The revised work asks three connected questions:

1. **Geographic dynamics:** How have municipal patterns of reported chikungunya burden changed between 2016 and 2025, including the expansion from the Northeast toward the Central-West?
2. **Severity and demography:** How closely do geographic patterns of reported disease correspond to hospitalization and mortality, given strong differences in risk by age and other characteristics?
3. **Decision support:** How do alternative municipality-prioritization rules perform when compared with subsequent observed burden, and what do age-specific vaccine eligibility constraints imply for their interpretation?

This is an observational and modeling study of **reported, confirmed cases**. Surveillance incidence should not be read as the true infection rate: reporting, access to care, diagnostic practices, and ascertainment vary across settings.

## Study design at a glance

| Component | Revised analysis |
|---|---|
| Geographic coverage | All **5,570** Brazilian municipalities |
| Main observation window | **January 2016–December 2025** |
| Monthly model panel | **120 months × 5,570 municipalities = 668,400 municipality-months** |
| Case definition | SINAN chikungunya notifications with `CLASSI_FIN %in% c(1, 13)` within the specified date window; not restricted to laboratory confirmation |
| Demographic denominators | Municipality-year population and age structure, prepared from IBGE inputs |
| Primary spatial model | Negative-binomial Bayesian model fitted with **R-INLA** |
| External assessment | Nine one-year-ahead rolling-origin folds (2017–2025); separate, provisional **2026** surveillance validation |

Municipality-months without a confirmed notification are represented as **zero *reported* cases** in the complete model panel. This is a surveillance-data convention, **not evidence of zero infections**.

## Analytical framework

### 1. Descriptive and geographic epidemiology

Annual and weekly incidence summaries, demographic distributions, municipality-level maps, spatial clustering, and regional epidemic timing characterize the observed epidemic history. Wavelet analysis is retained as a supplementary characterization rather than evidence for a long-term multi-year cycle.

### 2. Bayesian spatiotemporal modeling

The revised primary model uses a **negative-binomial likelihood**, a **BYM2 structured/unstructured municipality effect**, a **monthly RW2 temporal component**, and an **unstructured (Type I) municipality-by-month interaction**. Log population enters with an **estimated regression coefficient**, rather than being forced to have an offset coefficient of one.

Sensitivity and diagnostic work includes comparison with Poisson models, pandemic-period exclusions, structured interaction assessments, prior/posterior summaries, and checks for remaining spatial autocorrelation. The full 2016–2025 fit was developed using Cornell's Seneca HPC environment; computational requirements can be substantial.

### 3. Clinical severity and spatial concordance

Kaplan–Meier and Cox analyses assess clinical progression across symptom-onset-to-hospitalization, hospitalization-to-death, and symptom-onset-to-death intervals. Separate analyses estimate population-standardized severe-outcome patterns and examine case–death spatial concordance at the **SUS health-region level**, where mortality counts are more stable.

### 4. Municipality prioritization and vaccine scenarios

The revision compares continuous, municipality-level prioritization approaches based on recent relative incidence and age-weighted severity. Product-specific scenarios distinguish the **18–59-year age group** from **adults aged 60 years and older**, with rankings and communication zones assessed against observed outcomes.

**Important:** The 18–59 and 60+ metrics are **relative burden-prioritization scores**, not calibrated predictions of deaths. Illustrative outcomes-averted-per-dose calculations use explicit assumed vaccine efficacy, coverage, and dose-supply scenarios; they are **not** estimates of causal vaccine effectiveness or observed campaign impact.

### 5. Temporal and external validation

The rolling-origin design trains on data available through each year and evaluates the following year, yielding nine target years (**2017–2025**). Comparisons include simple past-case and demographic baselines. A secondary evaluation considers a longer lead time from a 2016–2022 training period to 2024–2025 outcomes.

Separately, **2026 surveillance is held out of the primary 2016–2025 model** and used for an external assessment of pre-2026 rankings, with explicit attention to the provisional and incomplete nature of the 2026 data. This is validation of ranking concordance with reported outcomes, not a causal evaluation of vaccination.

## Data sources

| Source | Use | Link |
|---|---|---|
| SINAN / DATASUS | Confirmed chikungunya notification records and clinical variables | [DATASUS file transfer](https://datasus.saude.gov.br/transferencia-de-arquivos/) |
| Instituto Brasileiro de Geografia e Estatística (IBGE) | Population estimates and demographic denominators | [IBGE population estimates](https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html) |
| IBGE / `geobr` | Municipality boundaries and health-region geography | [`geobr` project](https://github.com/ipeaGIT/geobr) |
| IBGE 2022 Census | Age and race/ethnicity population composition for relevant analyses | [IBGE Census](https://censo2022.ibge.gov.br/) |

Raw chikungunya `.dbc` files **2015–2026**, including the separately held-out **CHIKBR26.dbc**, are versioned in [`data/chikungunya/`](data/chikungunya/). Cleaned IBGE municipality-age CSVs **2015–2025** are in [`data/population/`](data/population/). The 2015 population file is retained for provenance; the revised population panel currently reads **2016–2025**. The old Zika archive is in [`data/zika/`](data/zika/); the revised primary model does **not** use a nationally aggregated Zika covariate.

## Code availability and reproducibility

### Public repository: revised code now available

All **22 current numbered R/R Markdown modules** are committed under [`analysis/`](analysis/), organized into five themed folders. The superseded original exploratory notebook is available from the [historical backup branch](https://github.com/hemaanizg/Chikungunya-Spatiotemporal-Analysis/tree/backup/pre-code-replacement-2026-10-20), but no longer appears on `main`.

| Stage | Files | Description |
|---|---|---|
| Configuration and population | [00_setup.R](analysis/00_setup.R), [01_data_import_cleaning.Rmd](analysis/01_data_and_population/01_data_import_cleaning.Rmd), [02_population_panel.R](analysis/01_data_and_population/02_population_panel.R) | Package setup, confirmed-case filter, year-varying population and age panels |
| Epidemiological analyses | [03](analysis/02_descriptive_epidemiology/03_descriptive_epi.Rmd), [04](analysis/02_descriptive_epidemiology/04_geographic_demographic.Rmd), [05](analysis/02_descriptive_epidemiology/05_wavelet_analysis.Rmd) | Descriptive, geographic and peak-timing analyses |
| Spatial model | [06_inla_spacetime_model_2016_2025.Rmd](analysis/03_spatiotemporal_models/06_inla_spacetime_model_2016_2025.Rmd) | Primary negative-binomial spatiotemporal model and checks |
| Clinical outcomes and eligibility | [07](analysis/04_clinical_and_prioritization/07_priority_metric_2016_2025.Rmd), [08](analysis/04_clinical_and_prioritization/08_survival_cox_2016_2025.Rmd), [09](analysis/02_descriptive_epidemiology/09_symptom_analysis_2016_2025.Rmd), [10](analysis/04_clinical_and_prioritization/10_step1_eligibility_split_2016_2025.Rmd) | Earlier priority maps, survival, symptoms and age-eligibility split |
| Severity and allocation | [11](analysis/03_spatiotemporal_models/11_shared_component_model.Rmd), [12](analysis/03_spatiotemporal_models/12_severity_surface_2016_2025.Rmd), [13](analysis/04_clinical_and_prioritization/13_expected_burden_metric_2016_2025.Rmd) | Shared spatial component, severe outcomes, continuous and product-specific rankings |
| Forecast and audit | [14](analysis/05_forecasting_and_validation/14_rolling_origin_forecast_2016_2025.Rmd), [15](analysis/05_forecasting_and_validation/15_rolling_origin_scoring_2017_2025.Rmd), [16](analysis/01_data_and_population/16_step3_case_definition.Rmd), [17](analysis/05_forecasting_and_validation/17_secondary_forecast_2016_2022_to_2024_2025.Rmd) | Rolling origin fitting/scoring, case-definition checks, longer-horizon assessment |
| External checks and scenario analyses | [18](analysis/05_forecasting_and_validation/18_external_validation_2026.Rmd), [19](analysis/05_forecasting_and_validation/19_reporting_completeness_sensitivity_2025.Rmd), [20](analysis/04_clinical_and_prioritization/20_burden_averted_per_1000_doses.Rmd), [21](analysis/01_data_and_population/21_race_ethnicity_denominators_IBGE2022.Rmd) | Provisional 2026 validation, reporting sensitivity, hypothetical dose scenarios and census denominators |

### Folder layout

```text
analysis/
├── 00_setup.R
├── 01_data_and_population/            # 01, 02, 16, 21
├── 02_descriptive_epidemiology/        # 03, 04, 05, 09
├── 03_spatiotemporal_models/          # 06, 11, 12
├── 04_clinical_and_prioritization/    # 07, 08, 10, 13, 20
└── 05_forecasting_and_validation/     # 14, 15, 17, 18, 19
```

All 19 research modules other than 00, 01 and 18 retain their original code bytes. For 00, 01 and 18, only repository-relative input paths were adjusted; no model formulas or case filters were changed. Because most scripts still call `source("00_setup.R")`, **run them from `analysis/` as the working directory**, and explicitly pass `knit_root_dir` for nested Rmd files. See [analysis instructions](analysis/README.md).

### Reproducing the revised work

**[Read the detailed reproducibility guide](docs/REPRODUCIBILITY.md)** and **[data and output inventory](docs/DATA_INVENTORY.md)** for module dependencies, missing inputs, execution order, saved HPC products and limitations.

Important current requirements:

- The source files have been published; **required generated RDS/CSV outputs and HPC fits have not all been published**.
- File 01 reads the separately held-out **2026 DBC file** from `data/chikungunya/`, but never combines its cases with the main 2016–2025 dataset.
- File 02 requires ten cleaned IBGE municipality-by-age CSVs not in this GitHub repository.
- Some notebooks assume objects created in the same interactive R session; others load objects from `~/Downloads/inla_results/`. **After cloning, set the working directory to `analysis/` when running the numbered scripts** so that `source("00_setup.R")` and relative inputs resolve together.
- File 06 currently loads a previously computed primary model; its expensive fitting call is commented out. File 17 likewise scores saved HPC forecasts.
- A versioned environment lockfile and independent clean-clone execution test are not yet included. Avoid describing this checkout as a one-command complete reproduction.

### Software

The revised analysis is written in **R**, using packages including `INLA`, `sf`, `spdep`, `geobr`, `dplyr`, `ggplot2`, `survival`, `survminer`, `read.dbc`, and `WaveletComp`. The production primary fit was performed using **R 4.6.0** with **INLA 26.8.7** on Seneca HPC, as recorded in the revision notebook. These are reported for provenance, **not** as a claim that the historical notebook has been tested under that environment.

To install INLA from its own package repository:

```r
install.packages(
  "INLA",
  repos = c(getOption("repos"), INLA = "https://inla.r-inla-download.org/R/stable"),
  dependencies = TRUE
)
```

## Interpretation and limitations

- National notification systems capture **reported and classified disease**, not all CHIKV infections; geographic comparisons may reflect heterogeneous ascertainment.
- Temporal validation evaluates **future reported-case burden and ranking performance**, not forecast certainty under all epidemic conditions.
- The **2026 validation is based on partial, provisional surveillance data**, subject to later revision.
- Age-specific prioritization scores and assumed-efficacy dose scenarios must **not** be presented as observed deaths prevented.
- Explicit immunity dynamics, representative serology, mosquito indices, and causal vaccine-impact evaluation are outside the present analyses.






