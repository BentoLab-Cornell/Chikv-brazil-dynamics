#!/usr/bin/env Rscript
# Inspect the checkout without importing surveillance records or running models.
.argv_file <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
source(file.path(dirname(normalizePath(.argv_file, mustWork = TRUE)), "repository_helpers.R"))
.root <- script_project_root()
setwd(.root)
source(file.path(.root, "analysis", "00_paths.R"))
if (!identical(normalizePath(PROJECT_ROOT), normalizePath(.root))) {
  stop("CHIKV_PROJECT_ROOT points to another checkout. Unset it or run that checkout's script.", call. = FALSE)
}

args <- commandArgs(trailingOnly = TRUE)
source_only <- "--source-only" %in% args
report_dir <- NULL
while (length(args)) {
  if (args[1] == "--source-only") {
    args <- args[-1]
  } else if (args[1] == "--report-dir" && length(args) >= 2L) {
    report_dir <- args[2]
    args <- args[-c(1, 2)]
  } else {
    stop("Usage: Rscript scripts/preflight.R [--source-only] [--report-dir PATH]", call. = FALSE)
  }
}

checks <- data.frame(category = character(), item = character(), status = character(),
                     detail = character(), stringsAsFactors = FALSE)
record <- function(category, item, ok, detail = "", optional = FALSE) {
  status <- if (ok) "PASS" else if (optional) "PENDING" else "MISSING_OR_INVALID"
  checks[nrow(checks) + 1L, ] <<- c(category, item, status, detail)
}

raw_paths <- c(file.path("chikungunya", sprintf("CHIKBR%02d.dbc", 15:26)),
               file.path("population", sprintf("ibge_pop_age_%d_clean.csv", 2015:2025)))
for (p in raw_paths) {
  info <- file.info(file.path(PROJECT_ROOT, p))
  record("input", p, !is.na(info$size) && info$size > 0 && !info$isdir,
         "Presence/nonempty check only; provenance and cohort validity need author verification.")
}

sources <- c(list.files("analysis", "\\.(R|Rmd)$", recursive = TRUE, full.names = TRUE),
             list.files("scripts", "\\.R$", full.names = TRUE))
parse_ok <- TRUE
for (p in sources) {
  outcome <- tryCatch({parse(text = r_source_text(p), keep.source = FALSE); ""},
                      error = function(e) conditionMessage(e))
  record("syntax", p, !nzchar(outcome), outcome)
  parse_ok <- parse_ok && !nzchar(outcome)
}

package_report <- data.frame()
if (!source_only && parse_ok) {
  required_packages <- declared_packages(sources)
  installed <- installed.packages()
  versions <- installed[match(required_packages, rownames(installed)), "Version"]
  package_report <- data.frame(package = required_packages, installed_version = versions,
                               stringsAsFactors = FALSE)
  for (i in seq_along(required_packages)) {
    record("package", required_packages[i], !is.na(versions[i]),
           if (is.na(versions[i])) "Not installed in this R library." else versions[i])
  }
}

inventory_path <- file.path(PROJECT_ROOT, "docs", "REQUIRED_ARTIFACTS.csv")
inventory_error <- ""
inventory <- tryCatch({
  x <- read.csv(inventory_path, stringsAsFactors = FALSE)
  stopifnot(all(c("path", "producer", "consumer", "requirement", "notes") %in% names(x)),
            !anyDuplicated(x$path), all(nzchar(x$path)),
            !any(grepl("^(/|~)|(^|/)\\.\\.(/|$)", x$path)),
            all(x$requirement %in% c("required", "optional")))
  x
}, error = function(e) {inventory_error <<- conditionMessage(e); NULL})
record("inventory", "docs/REQUIRED_ARTIFACTS.csv", !is.null(inventory), inventory_error)
if (!source_only && !is.null(inventory)) {
  for (i in seq_len(nrow(inventory))) {
    p <- result_path(inventory$path[i])
    info <- file.info(p)
    record("artifact", inventory$path[i], !is.na(info$size) && info$size > 0 && !info$isdir,
           paste("Producer:", inventory$producer[i], "Consumer:", inventory$consumer[i],
                 inventory$notes[i]), optional = inventory$requirement[i] != "required")
  }
}

cat("Repository:", PROJECT_ROOT, "\nResults:", RESULTS_DIR, "\n")
cat("Mode:", if (source_only) "source-only" else "inputs, source, installed packages and caches", "\n")
summary_counts <- as.data.frame(table(checks$category, checks$status))
names(summary_counts) <- c("category", "status", "count")
print(summary_counts[summary_counts$count > 0L, ], row.names = FALSE)
outstanding <- checks[checks$status != "PASS", c("category", "item", "status")]
if (nrow(outstanding)) {
  for (i in seq_len(nrow(outstanding))) {
    cat(outstanding$status[i], "[", outstanding$category[i], "] ", outstanding$item[i], "\n", sep = "")
  }
}

if (!is.null(report_dir)) {
  dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
  write.csv(checks, file.path(report_dir, "preflight_checks.csv"), row.names = FALSE)
  if (nrow(package_report)) write.csv(package_report, file.path(report_dir, "installed_packages.csv"), row.names = FALSE)
  input_files <- file.path(PROJECT_ROOT, raw_paths)
  existing <- file.exists(input_files)
  write.csv(data.frame(path = raw_paths[existing], md5 = unname(tools::md5sum(input_files[existing]))),
            file.path(report_dir, "input_checksums.csv"), row.names = FALSE)
  writeLines(c("Packaging-check environment; not verified production provenance.",
               capture.output(sessionInfo())), file.path(report_dir, "session_info.txt"))
  cat("Reports written to:", normalizePath(report_dir), "\n")
}
cat("No analysis was executed. Presence, syntax and installation checks do not validate results.\n")
if (source_only) cat("Source-only mode does not check required packages or saved model outputs.\n")
quit(status = if (any(checks$status == "MISSING_OR_INVALID")) 2L else 0L)
