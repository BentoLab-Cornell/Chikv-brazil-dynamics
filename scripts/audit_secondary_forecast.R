#!/usr/bin/env Rscript
# Read-only cross-file checks for the archived residence-named through-2022
# secondary forecast. This does not fit INLA or modify any results.
argv <- grep("^--file=", commandArgs(), value = TRUE)
if (length(argv) != 1L) stop("Run via Rscript scripts/audit_secondary_forecast.R")
script_file <- normalizePath(sub("^--file=", "", argv[1]), mustWork = TRUE)
root <- dirname(dirname(script_file))
setwd(root)
source(file.path("analysis", "00_paths.R"))

out_dir <- file.path(rolling_run_dir(), "results",
                     "secondary_forecast_2016_2022_residence")
paths <- c(
  prediction = file.path(out_dir, "predictions", "forecast_secondary_2024_2025.csv"),
  performance = file.path(out_dir, "scoring",
                          "secondary_forecast_performance_2016_2022_to_2024_2025.csv"),
  correlations = file.path(out_dir, "scoring",
                           "secondary_forecast_rank_correlations_2016_2022.csv"),
  rankings = file.path(out_dir, "scoring",
                       "secondary_forecast_municipality_rankings_2024_2025.csv")
)
cat("Archived residence run:", out_dir, "\n")
missing <- paths[!file.exists(paths)]
if (length(missing)) {
  stop("Missing files; do not substitute from legacy run:\n",
       paste(missing, collapse = "\n"))
}
print(data.frame(file = names(paths), md5 = unname(tools::md5sum(paths))),
      row.names = FALSE)

pred <- read.csv(paths["prediction"], colClasses = "character",
                 check.names = FALSE)
rankings <- read.csv(paths["rankings"], colClasses = "character",
                     check.names = FALSE)
perf <- read.csv(paths["performance"], check.names = FALSE)
cor <- read.csv(paths["correlations"], check.names = FALSE)

stopifnot(
  nrow(pred) == 5570L,
  nrow(rankings) == 5570L,
  all(c("code_muni") %in% names(pred)),
  all(c("code_muni") %in% names(rankings)),
  !anyNA(pred$code_muni),
  !anyNA(rankings$code_muni),
  !anyDuplicated(pred$code_muni),
  !anyDuplicated(rankings$code_muni),
  setequal(pred$code_muni, rankings$code_muni),
  nrow(perf) == 3L,
  all(c("rule", "n_selected", "cases_captured", "cases_total",
        "cases_capture_share", "deaths_captured", "deaths_total",
        "deaths_capture_share") %in% names(perf)),
  all(perf$n_selected == 1857),
  length(unique(perf$cases_total)) == 1L,
  length(unique(perf$deaths_total)) == 1L,
  all(is.finite(perf$cases_capture_share)),
  all(is.finite(perf$deaths_capture_share)),
  all(abs(perf$cases_captured / perf$cases_total -
          perf$cases_capture_share) < 1e-6),
  all(abs(perf$deaths_captured / perf$deaths_total -
          perf$deaths_capture_share) < 1e-6)
)

cat("\nCHECKS PASSED: 5570 unique matching municipalities and scoring shares.\n")
cat("Authoritative performance for this run:\n")
print(data.frame(
  rule = perf$rule,
  cases = paste(perf$cases_captured, "/", perf$cases_total),
  cases_pct = sprintf("%.2f%%", 100 * perf$cases_capture_share),
  deaths = paste(perf$deaths_captured, "/", perf$deaths_total),
  deaths_pct = sprintf("%.2f%%", 100 * perf$deaths_capture_share)
), row.names = FALSE)
cat("\nCorrelation table (verbatim from the same archived run):\n")
print(cor, row.names = FALSE)
cat("\nNOTE: These are internal consistency checks, not independent proof of fit provenance.\n")
