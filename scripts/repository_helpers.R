# Shared non-analytical helpers used by the preflight and explicit module runner.
script_project_root <- function() {
  arg <- grep("^--file=", commandArgs(), value = TRUE)
  if (length(arg) != 1L) stop("Use Rscript to run this command.", call. = FALSE)
  dirname(dirname(normalizePath(sub("^--file=", "", arg), mustWork = TRUE)))
}

r_source_text <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (!grepl("\\.Rmd$", path)) return(lines)
  inside <- FALSE
  code <- character()
  for (line in lines) {
    if (!inside && grepl("^```\\{r([ ,}]|$)", line)) {
      inside <- TRUE
    } else if (inside && grepl("^```[[:space:]]*$", line)) {
      inside <- FALSE
      code <- c(code, "")
    } else if (inside) code <- c(code, line)
  }
  if (inside) stop("Unclosed R chunk in ", path)
  code
}

declared_packages <- function(paths) {
  found <- character()
  walk <- function(x) {
    if (!is.call(x) && !is.expression(x) && !is.pairlist(x)) return(invisible(NULL))
    if (is.call(x)) {
      op <- as.character(x[[1]])
      if (length(op) == 1L && op %in% c("library", "require", "requireNamespace") && length(x) >= 2L) {
        if (is.symbol(x[[2]]) || is.character(x[[2]])) found <<- c(found, as.character(x[[2]]))
      }
      if (length(op) == 1L && op %in% c("::", ":::")) found <<- c(found, as.character(x[[2]]))
    }
    for (i in seq_along(x)) {
      if (!identical(x[[i]], quote(expr = ))) walk(x[[i]])
    }
    invisible(NULL)
  }
  for (path in paths) walk(parse(text = r_source_text(path), keep.source = FALSE))
  sort(unique(found))
}
