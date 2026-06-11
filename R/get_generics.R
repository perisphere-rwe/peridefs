# Internal dispatcher: retrieve GNN drug names from a DrugSpec.
# Called by drug-specific wrappers like get_antihypertensive_generics().
get_generics <- function(spec) {
  if (!inherits(spec, c("DrugSpec", "CompositeDrugSpec"))) {
    cli::cli_abort(
      "{.arg spec} must be a {.cls DrugSpec} or {.cls CompositeDrugSpec} object."
    )
  }
  spec$get_generics()
}
