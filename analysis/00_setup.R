# Shared configuration and packages

# Run numbered scripts with analysis/ as the working directory.
# Raw and cleaned input datasets are committed to data/ in this repository.
PROJECT_ROOT <- normalizePath("..", winslash = "/", mustWork = TRUE)
RAW_DBC_DIR <- file.path(PROJECT_ROOT, "data")
CHIK_DATA_DIR <- file.path(RAW_DBC_DIR, "chikungunya")
IBGE_DOWNLOADS_DIR <- file.path(RAW_DBC_DIR, "population")
stopifnot(dir.exists(CHIK_DATA_DIR), dir.exists(IBGE_DOWNLOADS_DIR))

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
