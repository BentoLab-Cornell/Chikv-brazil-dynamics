# ============================================================
# Chikungunya Bayesian spatiotemporal model, Brazil, 2016-2025
# Primary HPC analysis
#
# Outcome: confirmed chikungunya cases (CLASSI_FIN %in% c(1, 13))
# Likelihood: Negative binomial
# Population: log(POP) as an estimated fixed effect (NOT an offset)
# Spatial main effect: BYM2
# Temporal main effect: monthly RW2
# Space-time interaction: municipality x month IID (Type I)
# Study window: 2016-01-01 through 2025-12-31
# ============================================================

library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)
library(INLA)

cat("===== Chikungunya INLA primary model: 2016-2025 =====\n")
cat("Start:", format(Sys.time()), "\n")

dir.create("results", showWarnings = FALSE)
dir.create("logs", showWarnings = FALSE)

# ------------------------------------------------------------
# 1. Load fixed inputs prepared previously
# ------------------------------------------------------------

Chik_total <- readRDS("Chik_total_residence_corrected.rds")
pop_panel_total <- readRDS("pop_panel_total.rds")
muni_sf <- readRDS("muni_sf_2020.rds")

space_levels <- substr(as.character(muni_sf$code_muni), 1, 6)
space_levels <- str_pad(space_levels, width = 6, pad = "0")

stopifnot(length(space_levels) == nrow(muni_sf))
stopifnot(!anyDuplicated(space_levels))

g <- INLA::inla.read.graph("brazil_muni_2020.adj")

# ------------------------------------------------------------
# 2. Build complete municipality-month panel
# ------------------------------------------------------------

make_panel_muni_month_pop <- function(
  dat,
  pop_panel_total,
  space_levels,
  start_date = "2016-01-01",
  end_date   = "2025-12-01"
) {

  all_months <- seq(
    as.Date(start_date),
    as.Date(end_date),
    by = "month"
  )

  # Full national grid first: every municipality x every month.
  full_panel <- tidyr::crossing(
    code_muni = space_levels,
    ym_date   = all_months
  ) %>%
    mutate(
      ym   = format(ym_date, "%Y-%m"),
      year = lubridate::year(ym_date)
    )

  # Confirmed chikungunya notifications only.
  # Dates are floored to month, so 2025-12-31 belongs to the
  # 2025-12-01 monthly bin.
  observed_cases <- dat %>%
    transmute(
      code_muni = substr(as.character(ID_MN_RESI_CORR), 1, 6),
      code_muni = str_pad(code_muni, width = 6, pad = "0"),
      ym_date    = floor_date(as.Date(DT_SIN_PRI), unit = "month"),
      is_conf    = CLASSI_FIN %in% c(1, 13)
    ) %>%
    filter(
      is_conf,
      !is.na(code_muni),
      !is.na(ym_date),
      ym_date >= as.Date(start_date),
      ym_date <= as.Date(end_date),
      code_muni %in% space_levels
    ) %>%
    count(code_muni, ym_date, name = "cases")

  panel <- full_panel %>%
    left_join(observed_cases, by = c("code_muni", "ym_date")) %>%
    mutate(cases = replace_na(cases, 0L)) %>%
    left_join(pop_panel_total, by = c("code_muni", "year")) %>%
    rename(POP = total_pop) %>%
    filter(!is.na(POP), POP > 0) %>%
    mutate(
      space = match(code_muni, space_levels),
      time  = match(ym_date, all_months)
    )

  n_space <- length(space_levels)

  panel <- panel %>%
    mutate(
      st_id = (time - 1L) * n_space + space
    )

  # Sanity checks for the intended 2016-2025 analysis.
  stopifnot(length(all_months) == 120L)
  stopifnot(n_distinct(panel$code_muni) == length(space_levels))
  stopifnot(n_distinct(panel$time) == 120L)
  stopifnot(nrow(panel) == length(space_levels) * 120L)
  stopifnot(!anyNA(panel$space))
  stopifnot(!anyNA(panel$time))
  stopifnot(!anyNA(panel$POP))
  stopifnot(!anyNA(panel$cases))
  stopifnot(min(panel$time) == 1L)
  stopifnot(max(panel$time) == 120L)
  stopifnot(min(panel$st_id) == 1L)
  stopifnot(max(panel$st_id) == length(space_levels) * 120L)

  panel
}

cat("Building panel...\n")

panel_chik_2016_2025 <- make_panel_muni_month_pop(
  Chik_total,
  pop_panel_total,
  space_levels
)

cat("Panel rows:", nrow(panel_chik_2016_2025), "\n")
cat("Municipalities:", n_distinct(panel_chik_2016_2025$space), "\n")
cat("Months:", n_distinct(panel_chik_2016_2025$time), "\n")
cat("Maximum st_id:", max(panel_chik_2016_2025$st_id), "\n")
cat("Total confirmed cases:", sum(panel_chik_2016_2025$cases), "\n")

# ------------------------------------------------------------
# 3. Primary model
# ------------------------------------------------------------

formula_chik <- cases ~
  log(POP) +
  f(
    space,
    model = "bym2",
    graph = g,
    scale.model = TRUE,
    hyper = list(
      prec = list(prior = "pc.prec", param = c(1, 0.01)),
      phi  = list(prior = "pc", param = c(0.5, 2/3))
    )
  ) +
  f(
    time,
    model = "rw2",
    constr = TRUE,
    hyper = list(
      prec = list(prior = "pc.prec", param = c(1, 0.01))
    )
  ) +
  f(
    st_id,
    model = "iid",
    hyper = list(
      prec = list(prior = "pc.prec", param = c(2, 0.01))
    )
  )

cat("Starting INLA fit:", format(Sys.time()), "\n")

fit_chik_nb_2016_2025 <- inla(
  formula_chik,
  family = "nbinomial",
  data = panel_chik_2016_2025,

  # Keep fitted values because later rate/IRR and diagnostics use them.
  control.predictor = list(
    compute = TRUE,
    link = 1
  ),

  # Primary model-comparison quantities.
  control.compute = list(
    dic = TRUE,
    waic = TRUE,
    cpo = FALSE,
    mlik = FALSE,
    return.marginals = FALSE,
    openmp.strategy = "huge"
  ),

  num.threads = "1:1",
  verbose = TRUE
)

cat("INLA fit completed:", format(Sys.time()), "\n")

# ------------------------------------------------------------
# 4. Save model and panel
# ------------------------------------------------------------

saveRDS(
  fit_chik_nb_2016_2025,
  "results/fit_chik_nb_2016_2025_residence.rds"
)

saveRDS(
  panel_chik_2016_2025,
  "results/panel_chik_2016_2025_residence.rds"
)

# ------------------------------------------------------------
# 5. Human-readable summary
# ------------------------------------------------------------

sink("results/fit_chik_nb_2016_2025_residence_summary.txt")

cat("Completed:", format(Sys.time()), "\n\n")

cat("=== Study window ===\n")
cat("2016-01-01 through 2025-12-31\n\n")

cat("=== Panel ===\n")
cat("Rows:", nrow(panel_chik_2016_2025), "\n")
cat("Municipalities:", n_distinct(panel_chik_2016_2025$space), "\n")
cat("Months:", n_distinct(panel_chik_2016_2025$time), "\n")
cat("Maximum st_id:", max(panel_chik_2016_2025$st_id), "\n")
cat("Confirmed cases:", sum(panel_chik_2016_2025$cases), "\n\n")

cat("=== Fixed effects ===\n")
print(fit_chik_nb_2016_2025$summary.fixed)

cat("\n=== Hyperparameters ===\n")
print(fit_chik_nb_2016_2025$summary.hyperpar)

cat("\n=== Model fit ===\n")
cat("DIC:", fit_chik_nb_2016_2025$dic$dic, "\n")
cat("WAIC:", fit_chik_nb_2016_2025$waic$waic, "\n")

cat("\n=== log(POP) coefficient ===\n")
if ("log(POP)" %in% rownames(fit_chik_nb_2016_2025$summary.fixed)) {
  print(
    fit_chik_nb_2016_2025$summary.fixed[
      "log(POP)",
      c("mean", "sd", "0.025quant", "0.5quant", "0.975quant")
    ]
  )
}

sink()

cat("Saved: results/fit_chik_nb_2016_2025_residence.rds\n")
cat("Saved: results/panel_chik_2016_2025_residence.rds\n")
cat("Saved: results/fit_chik_nb_2016_2025_residence_summary.txt\n")
cat("===== FINISHED =====\n")
