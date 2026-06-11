# Internal dispatcher: retrieve NDC codes from a DrugSpec.
# Called by drug-specific wrappers like get_antihypertensive_codes().
get_ndc <- function(spec) {
  if (!inherits(spec, c("DrugSpec", "CompositeDrugSpec"))) {
    cli::cli_abort(
      "{.arg spec} must be a {.cls DrugSpec} or {.cls CompositeDrugSpec} object."
    )
  }
  spec$get_codes()
}
