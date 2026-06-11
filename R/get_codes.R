# Internal dispatcher: retrieve codes from a CodeSpec.
# Called by condition-specific wrappers like get_htn_v1_codes().
get_codes <- function(spec,
                      code_type     = NULL,
                      variable_type = c("condition", "outcome"),
                      periods       = FALSE,
                      format        = c("list", "tibble")) {
  if (!inherits(spec, c("CodeSpec", "CompositeCodeSpec"))) {
    cli::cli_abort(c(
      "{.arg spec} must be a {.cls CodeSpec} or {.cls CompositeCodeSpec} object.",
      i = "Use {.fn get_ndc} to retrieve NDC codes from a {.cls DrugSpec}."
    ))
  }
  spec$get_codes(
    code_type     = code_type,
    variable_type = match.arg(variable_type),
    periods       = periods,
    format        = match.arg(format)
  )
}
