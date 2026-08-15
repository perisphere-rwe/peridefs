#' R6 class for drug class specifications
#'
#' @description
#' Stores the generic drug names (GNNs) and narrative description for a
#' single version of a drug class definition. Each version is a distinct
#' object (e.g., `spec_acei_v1`, `spec_acei_v2`).
#'
#' @export
DrugSpec <- R6::R6Class(
  "DrugSpec",

  private = list(
    .drug_class = NULL,
    .version    = NULL,
    .label      = NULL,
    .defs       = NULL,
    .generics   = NULL  # tibble: generic, brand, priority
  ),

  active = list(
    #' @field drug_class Short drug class identifier (read-only).
    drug_class = function() private$.drug_class,
    #' @field version Version label, e.g. `"v1"` (read-only).
    version    = function() private$.version,
    #' @field label Human-readable drug class label (read-only).
    label      = function() private$.label
  ),

  public = list(
    #' @description Create a new `DrugSpec`.
    #' @param drug_class Short identifier string, e.g. `"acei"`.
    #' @param label Human-readable label.
    #' @param defs Character string describing the drug class. May be `NULL`.
    #' @param generic_names Character vector of GNN drug names.
    #' @param version Optional version label string, e.g. `"v1"`.
    initialize = function(drug_class,
                          label,
                          defs          = NULL,
                          generic_names = character(0L),
                          version       = NULL) {
      private$.drug_class <- drug_class
      private$.version    <- version
      private$.label      <- label
      private$.defs       <- defs
      private$.generics   <- tibble::tibble(
        generic  = generic_names,
        brand    = NA_character_,
        priority = 1L
      )
      invisible(self)
    },

    #' @description Print a summary of the spec.
    print = function(...) {
      ver_tag <- if (!is.null(private$.version))
        cli::col_grey(paste0(" (", private$.version, ")")) else ""
      cli::cli_h1("{self$label}{ver_tag}")
      cli::cli_text("Drug class: {.code {self$drug_class}}")
      if (!is.null(private$.defs)) cli::cli_text("{.strong Def:} {private$.defs}")
      n <- nrow(private$.generics)
      cli::cli_text("{n} generic name(s)")
      if (n) {
        preview <- paste(utils::head(private$.generics$generic, 5L), collapse = ", ")
        if (n > 5L) preview <- paste0(preview, ", ...")
        cli::cli_text("  GNNs: {preview}")
      }
      invisible(self)
    },

    #' @description Retrieve generic (and brand) drug names as a tidy data
    #'   frame.
    #' @param priority Integer vector subsetting confidence tiers to include
    #'   (`1` = core, `2` = probable, `3` = cautious). Default `1`.
    #' @return A tibble with columns `generic`, `brand`, `priority`, `class`,
    #'   and `version`.
    get_generics = function(priority = 1L) {
      result <- private$.generics
      if (!is.null(priority)) {
        result <- result[result$priority %in% priority, , drop = FALSE]
      }
      result$class   <- private$.drug_class
      result$version <- private$.version %||% NA_character_
      result
    },

    #' @description Retrieve the narrative drug class description.
    #' @return Character string, or `NULL`.
    get_defs = function() private$.defs
  )
)
