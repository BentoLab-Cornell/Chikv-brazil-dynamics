# Base-R configuration: safe to source without loading analysis packages or data.
find_project_root <- function(start = getwd()) {
  explicit <- Sys.getenv("CHIKV_PROJECT_ROOT", unset = "")
  candidate <- normalizePath(if (nzchar(explicit)) explicit else start,
                             winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(candidate, "analysis", "00_setup.R")) &&
        dir.exists(file.path(candidate, "chikungunya")) &&
        dir.exists(file.path(candidate, "population"))) return(candidate)
    parent <- dirname(candidate)
    if (nzchar(explicit) || identical(parent, candidate)) {
      stop("Cannot locate the project. Run from the repository or set CHIKV_PROJECT_ROOT.",
           call. = FALSE)
    }
    candidate <- parent
  }
}

PROJECT_ROOT <- find_project_root()
CHIK_DATA_DIR <- file.path(PROJECT_ROOT, "chikungunya")
IBGE_DOWNLOADS_DIR <- file.path(PROJECT_ROOT, "population")
RAW_DBC_DIR <- PROJECT_ROOT

.results_setting <- path.expand(Sys.getenv("CHIKV_RESULTS_DIR", unset = "results"))
if (!grepl("^(/|[A-Za-z]:[/\\\\])", .results_setting)) {
  .results_setting <- file.path(PROJECT_ROOT, .results_setting)
}
RESULTS_DIR <- normalizePath(.results_setting, winslash = "/", mustWork = FALSE)
rm(.results_setting)

result_path <- function(...) file.path(RESULTS_DIR, ...)

# Optional production-run roots. Relative overrides are resolved from the repository.
# Preserving named HPC directories keeps archived fits separate from new analyses.
configured_path <- function(env_var, default_path) {
  selected <- Sys.getenv(env_var, unset = "")
  path <- path.expand(if (nzchar(selected)) selected else default_path)
  if (!grepl("^(/|[A-Za-z]:[/\\\\])", path)) {
    path <- file.path(PROJECT_ROOT, path)
  }
  normalizePath(path, winslash = "/", mustWork = FALSE)
}
PREP_CACHE_DIR <- configured_path("CHIKV_PREP_CACHE_DIR", RESULTS_DIR)
# Preparation caches may be archived with an HPC run. Read only from the
# explicitly configured source; writing regenerated caches still uses result_path().
prep_cache_path <- function(filename) file.path(PREP_CACHE_DIR, filename)

rolling_run_dir <- function() {
  configured_path("CHIKV_ROLLING_RUN_DIR", result_path("hpc_residence_20261028"))
}
shared_component_dir <- function() {
  configured_path("CHIKV_SHARED_COMPONENT_DIR",
                  result_path("shared_component_residence_20261030"))
}
ensure_results_dir <- function() {
  if (!dir.exists(RESULTS_DIR) &&
      !dir.create(RESULTS_DIR, recursive = TRUE, showWarnings = FALSE)) {
    stop("Cannot create results directory: ", RESULTS_DIR, call. = FALSE)
  }
  invisible(RESULTS_DIR)
}

# Missing caches must not silently start expensive fits during packaging/review.
require_model_fitting <- function(label) {
  if (!identical(tolower(Sys.getenv("CHIKV_ALLOW_MODEL_FITTING", unset = "false")), "true")) {
    stop("Saved result missing for ", label,
         ". Model fitting is disabled by default. Supply the verified production cache. ",
         "Only for an intentional rerun, set CHIKV_ALLOW_MODEL_FITTING=true.", call. = FALSE)
  }
  invisible(TRUE)
}
