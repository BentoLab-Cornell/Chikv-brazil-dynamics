# Module-to-result map

This is a source-level map to the revised manuscript, not proof that the available notebook version generated each submitted estimate. Final production files and logs must establish that connection. Figure/table numbers refer to the edited main manuscript and supplement and should be checked again at submission.

**Scope labels:** *final-paper support* identifies code relevant to reported results; *mixed* means the notebook also contains unreported work; *ancillary* is retained research material outside the final paper. Do not execute every numbered module by default or restore an unreported analysis merely because code exists.

| ID | Notebook/script | Scope and manuscript connection |
|---|---|---|
| 00 | `00_setup.R` (loads helper `00_paths.R`) | Configuration/packages; no scientific result |
| 01 | `01_data_and_population/01_data_import_cleaning.Rmd` | Preparation: confirmed primary cohort, dates and age variables; separate 2026 input |
| 02 | `01_data_and_population/02_population_panel.R` | Preparation: annual total/age denominators for descriptive, modeling and allocation results |
| 03 | `02_descriptive_epidemiology/03_descriptive_epi.Rmd` | Mixed: national temporal summaries supporting Figure 1A and descriptive Results; also contains additional clinical/descriptive summaries |
| 04 | `02_descriptive_epidemiology/04_geographic_demographic.Rmd` | Mixed: municipal incidence mapping supporting Figure 2 and geographic Results; race and other extra sections are not final-paper findings |
| 05 | `02_descriptive_epidemiology/05_wavelet_analysis.Rmd` | Ancillary: wavelet/phase/peak timing; absent from the final main/SI despite historical notebook wording |
| 06 | `03_spatiotemporal_models/06_inla_spacetime_model_2016_2025.Rmd` | Final-paper support: primary fit summaries (Table 1/Figure 3), prior plots (Figure S1), model sensitivities (Tables S1–S2), residual diagnostics and fitted incidence used downstream. Primary fitting code remains commented; saved fits are needed |
| 07 | `04_clinical_and_prioritization/07_priority_metric_2016_2025.Rmd` | Ancillary: earlier categorical/dual-axis prioritization; replaced in the paper by module 13's continuous comparisons |
| 08 | `04_clinical_and_prioritization/08_survival_cox_2016_2025.Rmd` | Ancillary: Kaplan–Meier/Cox and clinical progression analyses; not reported in final main/SI |
| 09 | `02_descriptive_epidemiology/09_symptom_analysis_2016_2025.Rmd` | Ancillary: symptom summaries; not reported in final main/SI |
| 10 | `04_clinical_and_prioritization/10_step1_eligibility_split_2016_2025.Rmd` | Mixed: descriptive case/death age-window summaries supporting Figure 1B/Results; optional older-priority correlations are ancillary. Age bands do not establish regulatory eligibility or preventable deaths |
| 11 | `03_spatiotemporal_models/11_shared_component_model.Rmd` | Final-paper support: separate annual health-region case/death models and 2025 spatial fields (Figure 4). Cached fits/production provenance are needed |
| 12 | `03_spatiotemporal_models/12_severity_surface_2016_2025.Rmd` | Ancillary: health-region hospitalization/death rates. This is not the age-population/CFR severity component used by the final combined score |
| 13 | `04_clinical_and_prioritization/13_expected_burden_metric_2016_2025.Rmd` | Mixed: demographic severity component, combined score, capture curves (Figure 5), age-restricted rank-overlap sensitivity and incidence-by-population benchmark. Earlier “two-product” communication zones are ancillary; age-restricted scores are not product-specific impact estimates |
| 14 | `05_forecasting_and_validation/14_rolling_origin_forecast_2016_2025.Rmd` | Final-paper support: rolling model fits/predicted case rankings for 2017–2025; scored by 15. Active fitting is guarded |
| 15 | `05_forecasting_and_validation/15_rolling_origin_scoring_2017_2025.Rmd` | Final-paper support: Figure 6/Table S3. Case-count ranking, prior-year cases and prior-year ≥65 population-share comparator; not validation of the combined age-weighted score itself |
| 16 | `01_data_and_population/16_step3_case_definition.Rmd` | Supporting audit: confirmed-case classification versus confirmation criterion; cohort terminology/checks, not a separate main result |
| 17 | `05_forecasting_and_validation/17_secondary_forecast_2016_2022_to_2024_2025.Rmd` | Final-paper support: Figure S3, through-2022 model scored on 2024–2025. Reads saved prediction/scoring files; no production fitter. The age-comparator formula still needs confirmation |
| 18 | `05_forecasting_and_validation/18_external_validation_2026.Rmd` | Mixed: Figure S4/Results, partial-2026 temporal evaluation and carried-forward 2025 ranking. Named-pilot/Dourados/state summaries are ancillary; not an evaluation of rollout impact |
| 19 | `05_forecasting_and_validation/19_reporting_completeness_sensitivity_2025.Rmd` | Final-paper support: Figure S2, changing the incidence-summary months while holding the full fit and severity component fixed; no refit without 2025 |
| 20 | `04_clinical_and_prioritization/20_burden_averted_per_1000_doses.Rmd` | Mixed: equal-dose section supports Figure S5/Table S4; fixed-municipality-coverage scenarios are separate supporting calculations. No observed vaccine effectiveness or product-specific older-adult benefit is estimated |
| 21 | `01_data_and_population/21_race_ethnicity_denominators_IBGE2022.Rmd` | Ancillary: race/ethnicity denominators and rate summaries; absent from final main/SI |

Paths are relative to `analysis/`.

## Names and interpretations

| Historical code/file label | Final-paper meaning |
|---|---|
| `IRR`, `T_irr`, “transmission-only” | Relative fitted incidence: fitted cases divided by population, then normalized to the contemporaneous municipality median; not a conventional regression incidence-rate ratio or direct transmission measurement |
| “age/severity-only”, `V_burden` | Population-weighted demographic severity component; not the rolling ≥65 population-share comparator |
| “expected-burden”, `combined_burden` | Uncalibrated combined incidence–demographic score; not an expected death count |
| “age-only” in module 15 | Previous-year proportion aged ≥65 |
| “age-only” in module 17 | Construction requires confirmation from the production ranking; do not assume it is module 15's comparator |
| “external validation” in module 18 | Later-period evaluation in the same surveillance system; use *held-out temporal evaluation* |
| “reporting completeness” in module 19 | Sensitivity to the score-summary window with the fitted model held fixed |
| “two-product” in module 13 | Age-restricted relative scores and communication outputs; no product-specific effectiveness calculation |

## Submission output checks

- Resolve production-input and geographic/denominator checks before finalizing figures or estimates.
- Export the already-coded municipality-averaged residual map if the verified fit is available; the edited supplement does not yet include it.
- Present the already-reported incidence-by-population comparison alongside the combined score. The current Figure 5 lacks its curve/table.
- Keep source-plot labels consistent with the edited captions, including the Figure 6 difference in percentage points. Confirm final portable figure exports and table/figure numbering.
- Retain the stated uncertainty limits: national CPO/PIT were unavailable, shared-component magnitudes depend on specification/priors, and allocation intervals propagate CFR uncertainty only with ranks/allocations fixed.

These are output/provenance completion tasks, not instructions to add ancillary analyses or refit every model.
