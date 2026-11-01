# Annual municipality-by-age population panel, 2016-2025
# Shared packages and external data paths are defined in 00_setup.R.
source("00_setup.R")

STUDY_START_YEAR <- 2016L
STUDY_END_YEAR   <- 2025L
EXPECTED_N_MUNI  <- 5570L


# ============================================================
# Read one annual IBGE municipality-by-age population file
# ============================================================

read_ibge_age_year <- function(path, year) {

  raw <- read_csv(
    path,
    locale = locale(encoding = "latin1"),
    col_types = cols(.default = "c"),
    show_col_types = FALSE
  )

  first_col <- names(raw)[1]

  raw <- raw %>%
    mutate(
      code_muni = str_sub(.data[[first_col]], 1, 6)
    ) %>%
    filter(
      str_detect(code_muni, "^\\d{6}$")
    )

  age_cols <- setdiff(
    names(raw),
    c(first_col, "Total", "code_muni")
  )

  if (length(age_cols) == 0L) {
    stop("No age columns found in: ", path)
  }

  raw <- raw %>%
    mutate(
      across(
        all_of(c(age_cols, "Total")),
        ~ as.numeric(gsub("\\.", "", .x))
      )
    )

  age_long <- raw %>%
    select(
      code_muni,
      all_of(age_cols)
    ) %>%
    pivot_longer(
      cols = all_of(age_cols),
      names_to = "age_label",
      values_to = "pop"
    ) %>%
    mutate(
      age = case_when(
        str_detect(age_label, "Menos que 1") ~ 0L,
        str_detect(age_label, "80 anos e mais") ~ 80L,
        TRUE ~ as.integer(str_extract(age_label, "^[0-9]+"))
      ),
      year = year
    ) %>%
    select(
      code_muni,
      year,
      age,
      pop
    )

  totals <- raw %>%
    transmute(
      code_muni,
      year = year,
      total_pop = Total
    )

  list(
    age_long = age_long,
    totals = totals
  )
}


# ============================================================
# Load annual population files, 2016-2025
# ============================================================

file_for_year <- function(year, dir = IBGE_DOWNLOADS_DIR) {
  file.path(
    dir,
    sprintf("ibge_pop_age_%d_clean.csv", year)
  )
}

years <- STUDY_START_YEAR:STUDY_END_YEAR

results <- lapply(
  years,
  function(y) {

    f <- file_for_year(y)

    if (!file.exists(f)) {
      stop(
        "Missing required population file for year ",
        y,
        ": ",
        f
      )
    }

    read_ibge_age_year(f, y)
  }
)

names(results) <- years

pop_panel_total <- bind_rows(
  lapply(results, `[[`, "totals")
)

pop_panel_age <- bind_rows(
  lapply(results, `[[`, "age_long")
)


# ============================================================
# Align to the 2020 municipality geography used by the INLA model
# ============================================================

space_levels_codes <- read_municipality(
  year = 2020
) %>%
  transmute(
    code_muni = str_pad(
      substr(as.character(code_muni), 1, 6),
      width = 6,
      pad = "0"
    )
  ) %>%
  pull(code_muni) %>%
  unique()

stopifnot(
  length(space_levels_codes) == EXPECTED_N_MUNI
)

pop_panel_total <- pop_panel_total %>%
  filter(code_muni %in% space_levels_codes)

pop_panel_age <- pop_panel_age %>%
  filter(code_muni %in% space_levels_codes)


# ============================================================
# Municipality-year checks
# ============================================================

expected_years <- STUDY_START_YEAR:STUDY_END_YEAR
expected_total_rows <- length(expected_years) * EXPECTED_N_MUNI

population_check <- pop_panel_total %>%
  group_by(year) %>%
  summarise(
    n_muni = n_distinct(code_muni),
    national_pop = sum(total_pop),
    n_missing_pop = sum(is.na(total_pop)),
    .groups = "drop"
  )

stopifnot(
  identical(
    sort(unique(pop_panel_total$year)),
    expected_years
  ),
  nrow(pop_panel_total) == expected_total_rows,
  all(population_check$n_muni == EXPECTED_N_MUNI),
  !anyDuplicated(pop_panel_total[c("code_muni", "year")]),
  !any(is.na(pop_panel_total$total_pop)),
  all(pop_panel_total$total_pop > 0)
)

coverage_check <- pop_panel_total %>%
  group_by(year) %>%
  summarise(
    missing_from_graph = length(setdiff(space_levels_codes, code_muni)),
    extra_vs_graph = length(setdiff(code_muni, space_levels_codes)),
    .groups = "drop"
  )

stopifnot(
  all(coverage_check$missing_from_graph == 0),
  all(coverage_check$extra_vs_graph == 0)
)


# ============================================================
# Age-specific population checks
# ============================================================

stopifnot(
  !any(is.na(pop_panel_age$age)),
  !any(is.na(pop_panel_age$pop)),
  all(pop_panel_age$pop >= 0),
  !anyDuplicated(pop_panel_age[c("code_muni", "year", "age")])
)

age_coverage <- pop_panel_age %>%
  distinct(code_muni, year) %>%
  count(year, name = "n_muni")

stopifnot(
  nrow(age_coverage) == length(expected_years),
  all(age_coverage$n_muni == EXPECTED_N_MUNI)
)


# ============================================================
# Reconcile age-specific population to annual municipality totals
# ============================================================

age_total_check <- pop_panel_age %>%
  group_by(code_muni, year) %>%
  summarise(
    age_total_pop = sum(pop),
    .groups = "drop"
  ) %>%
  left_join(
    pop_panel_total,
    by = c("code_muni", "year")
  ) %>%
  mutate(
    difference = age_total_pop - total_pop
  )

stopifnot(
  !any(is.na(age_total_check$total_pop)),
  all(age_total_check$difference == 0)
)


# ============================================================
# Age-band population helper
# ============================================================

make_age_band <- function(data, lo, hi = Inf) {

  out <- data %>%
    filter(
      age >= lo,
      age <= hi
    ) %>%
    group_by(code_muni, year) %>%
    summarise(
      pop_band = sum(pop),
      .groups = "drop"
    )

  out
}

pop_18_59 <- make_age_band(pop_panel_age, 18, 59)
pop_60plus <- make_age_band(pop_panel_age, 60)
pop_65plus <- make_age_band(pop_panel_age, 65)

stopifnot(
  nrow(pop_18_59) == expected_total_rows,
  nrow(pop_60plus) == expected_total_rows,
  nrow(pop_65plus) == expected_total_rows,
  !any(is.na(pop_18_59$pop_band)),
  !any(is.na(pop_60plus$pop_band)),
  !any(is.na(pop_65plus$pop_band)),
  all(pop_18_59$pop_band >= 0),
  all(pop_60plus$pop_band >= 0),
  all(pop_65plus$pop_band >= 0)
)


# ============================================================
# Save population objects
# ============================================================

saveRDS(
  pop_panel_total,
  result_path("pop_panel_total.rds")
)

saveRDS(
  pop_panel_age,
  result_path("pop_panel_age.rds")
)


# ============================================================
# Compact audit output
# ============================================================

print(population_check)
