#!/usr/bin/env Rscript
# Run only explicitly selected stages; this is not an automatic full-paper pipeline.
.argv_file <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
source(file.path(dirname(normalizePath(.argv_file, mustWork = TRUE)), "repository_helpers.R"))
.root <- script_project_root()
setwd(.root)
source(file.path(.root, "analysis", "00_paths.R"))
if (!identical(normalizePath(PROJECT_ROOT), normalizePath(.root))) {
  stop("CHIKV_PROJECT_ROOT points to another checkout. Unset it or run that checkout's script.", call. = FALSE)
}

ids <- commandArgs(trailingOnly = TRUE)
if (!length(ids) || any(!grepl("^(0?[1-9]|1[0-9]|2[01])$", ids))) {
  stop("Usage: Rscript scripts/run_module.R 01 02 [other explicitly selected module IDs]", call. = FALSE)
}
ids <- sprintf("%02d", as.integer(ids))
files <- list.files(file.path(PROJECT_ROOT, "analysis"), "\\.(R|Rmd)$",
                    recursive = TRUE, full.names = TRUE)
selected <- vapply(ids, function(id) {
  hit <- files[startsWith(basename(files), paste0(id, "_"))]
  if (length(hit) != 1L) stop("Module ID does not identify one source file: ", id)
  hit
}, character(1))

# Check all declared package names up front, without installing anything.
dependencies <- declared_packages(c(selected, file.path(PROJECT_ROOT, "analysis", "00_setup.R")))
if (any(grepl("\\.Rmd$", selected))) dependencies <- union(dependencies, "knitr")
missing <- setdiff(dependencies, rownames(installed.packages()))
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "),
       ". Run scripts/preflight.R and see docs/REPRODUCIBILITY.md.", call. = FALSE)
}

# Keep runner bookkeeping private: notebook variables must not overwrite the loop/log.
run_selected <- function(module_ids, module_files) {
  ensure_results_dir()
  report_root <- tempfile(paste0(format(Sys.time(), "%Y%m%dT%H%M%S"), "_"),
                          tmpdir = result_path("reports"))
  dir.create(report_root, recursive = TRUE, showWarnings = FALSE)
  setwd(file.path(PROJECT_ROOT, "analysis"))

  # Explicitly named caches only; no arbitrary workspace is restored.
  for (object_name in c("Chik_total", "pop_panel_total", "pop_panel_age")) {
    cache_file <- result_path(paste0(object_name, ".rds"))
    if (file.exists(cache_file)) assign(object_name, readRDS(cache_file), envir = .GlobalEnv)
  }
  if (exists("Chik_total", envir = .GlobalEnv, inherits = FALSE)) {
    assign("combined_all", get("Chik_total", envir = .GlobalEnv), envir = .GlobalEnv)
  }
  # Module 06 remains a saved-fit notebook; its commented fits are not enabled.
  assign("params", list(run_heavy_models = FALSE, results_dir = RESULTS_DIR), envir = .GlobalEnv)
  run_log <- data.frame(module = module_ids, source = module_files, status = "not_started", stringsAsFactors = FALSE)
  failure <- NULL
  for (i in seq_along(module_files)) {
    cat("Running module", module_ids[i], "from", module_files[i], "\n")
    failure <- tryCatch({
      if (grepl("\\.Rmd$", module_files[i])) {
        knitr::opts_knit$set(root.dir = file.path(PROJECT_ROOT, "analysis"))
        knitr::opts_chunk$set(error = FALSE,
                            fig.path = paste0(file.path(report_root, paste0(module_ids[i], "_figures")), "/"))
        knitr::knit(module_files[i], output = file.path(report_root, paste0(module_ids[i], ".md")),
                    envir = .GlobalEnv, quiet = FALSE)
      } else {
        source(module_files[i], local = .GlobalEnv, chdir = FALSE)
      }
      NULL
    }, error = function(e) e)
    run_log$status[i] <- if (is.null(failure)) "completed" else "failed"
    if (!is.null(failure)) break
  }
  write.csv(run_log, file.path(report_root, "module_run.csv"), row.names = FALSE)
  writeLines(c("Execution environment; source/output provenance still requires author verification.",
               capture.output(sessionInfo())), file.path(report_root, "session_info.txt"))
  if (!is.null(failure)) stop(conditionMessage(failure), call. = FALSE)
  cat("Selected modules completed. Reports:", report_root, "\n")
}
run_selected(ids, selected)
