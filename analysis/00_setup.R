# Shared configuration and packages

# Run numbered scripts with analysis/ as the working directory, or use
# scripts/run_module.R. Raw inputs remain in the repository's root folders.
.paths_file <- if (file.exists("00_paths.R")) "00_paths.R" else file.path("analysis", "00_paths.R")
source(.paths_file, local = TRUE)
rm(.paths_file)

# Report every missing shared dependency before attaching packages.
.shared_packages <- c(
  "read.dbc", "dplyr", "tidyr", "readr", "readxl", "stringr", "lubridate", "tibble",
  "ggplot2", "scales", "viridis", "RColorBrewer", "patchwork", "gridGraphics",
  "cowplot", "ggrepel", "sf", "geobr", "spdep", "INLA", "WaveletComp", "survival",
  "survminer", "ggsurvfit", "broom", "gtsummary", "UpSetR", "purrr"
)
.missing_packages <- setdiff(.shared_packages, rownames(installed.packages()))
if (length(.missing_packages)) {
  stop("Missing shared packages: ", paste(.missing_packages, collapse = ", "),
       ". See docs/REPRODUCIBILITY.md; run scripts/preflight.R for details.", call. = FALSE)
}
rm(.shared_packages, .missing_packages)
ensure_results_dir()

# Data import / wrangling
library(read.dbc)
library(dplyr)
library(tidyr)
library(readr)
library(readxl)
library(stringr)
library(lubridate)
library(tibble)

# Plotting
library(ggplot2)
library(scales)
library(viridis)
library(RColorBrewer)
library(patchwork)
library(gridGraphics)
library(cowplot)
library(ggrepel)

# Spatial analysis
library(sf)
library(geobr)
library(spdep)

# Modelling
library(INLA)
library(WaveletComp)
library(survival)
library(survminer)
library(ggsurvfit)
library(broom)
library(gtsummary)

# Other utilities
library(UpSetR)
library(purrr)

# Brazilian macro-region lookup by state code
state_region_lookup <- tibble(
  code_state = sprintf(
    "%02d",
    c(
      11, 12, 13, 14, 15, 16, 17,
      21, 22, 23, 24, 25, 26, 27, 28, 29,
      31, 32, 33, 35,
      41, 42, 43,
      50, 51, 52, 53
    )
  ),
  region = c(
    rep("North", 7),
    rep("Northeast", 9),
    rep("Southeast", 4),
    rep("South", 3),
    rep("Center-West", 4)
  )
)
