# Render a def (named character vector or plain string) to the console via cli.
# Returns the raw def invisibly so callers can still capture it.
.render_def <- function(def) {
  if (is.null(def)) return(invisible(NULL))
  if (!is.null(names(def))) {
    cli::cli_bullets(def)
  } else {
    cli::cli_text(def)
  }
  invisible(def)
}

#' Retrieve and display the narrative algorithm description
#'
#' @description
#' Renders the definition for a [CodeSpec] or [CompositeCodeSpec] to the
#' console using cli formatting (bullets, inline code markup, etc.) and
#' returns the raw definition invisibly for programmatic use. For a
#' [DrugSpec] leaf, renders and returns its (typically internal sourcing
#' note) `defs` text the same way. For a [CompositeDrugSpec], returns the
#' tibble of component `name`/`label` pairs from `$get_meds_labels()`
#' instead (see that method, or [get_hypertension_meds_labels()] and
#' friends) — composite drug specs don't carry a narrative definition the
#' way condition specs do.
#'
#' @param spec A [CodeSpec], [CompositeCodeSpec], [DrugSpec], or
#'   [CompositeDrugSpec] object.
#' @param variable_type `"condition"` (default) or `"outcome"`. Ignored for
#'   [DrugSpec] and [CompositeDrugSpec] objects.
#' @return The raw definition (named character vector or `NULL`), invisibly,
#'   for [CodeSpec]/[CompositeCodeSpec]/[DrugSpec]. A tibble with columns
#'   `name` and `label` for [CompositeDrugSpec].
#' @export
get_defs <- function(spec,
                     variable_type = c("condition", "outcome")) {
  if (inherits(spec, c("CodeSpec", "CompositeCodeSpec"))) {
    def <- spec$get_defs(variable_type = match.arg(variable_type))
    return(.render_def(def))
  }

  if (inherits(spec, "CompositeDrugSpec")) {
    return(spec$get_meds_labels())
  }

  if (inherits(spec, "DrugSpec")) {
    def <- spec$get_defs()
    return(.render_def(def))
  }

  cli::cli_abort(paste0(
    "{.arg spec} must be a {.cls CodeSpec}, {.cls CompositeCodeSpec}, ",
    "{.cls DrugSpec}, or {.cls CompositeDrugSpec} object."
  ))
}
