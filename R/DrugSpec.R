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
    .generics   = NULL,  # tibble: generic, brand (list-col), priority

    # Build the list-column of brand names for a vector of generic names,
    # using an existing named-list lookup (name = character vector of
    # brand(s)). Names not present in `lookup` get an empty character vector.
    brand_for = function(names_vec, lookup) {
      lapply(names_vec, function(nm) {
        if (nm %in% names(lookup)) as.character(lookup[[nm]]) else character(0L)
      })
    },

    # Validate that every name in `brand_names` matches a known generic.
    validate_brand_names = function(brand_names, all_generic) {
      unknown <- setdiff(names(brand_names), all_generic)
      if (length(unknown)) {
        cli::cli_abort(c(
          "{.arg brand_names} has entries for unknown generic(s): {.val {unknown}}",
          "i" = paste0(
            "Names must match an entry in {.arg generic_names}, ",
            "{.arg generic_names_probable}, or {.arg generic_names_cautious}."
          )
        ))
      }
      invisible(NULL)
    }
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
    #' @param generic_names Character vector of GNN drug names that are
    #'   single-indication and aligned with, and FDA-approved for, this drug
    #'   class's indication. Stored at `priority = 1` (core).
    #' @param generic_names_probable Character vector of GNN drug names that
    #'   have more than one indication (e.g., also FDA-approved, or widely
    #'   used off-label, for a different condition) in addition to this drug
    #'   class's indication. Stored at `priority = 2` (probable).
    #' @param generic_names_cautious Character vector of GNN drug names that
    #'   are included in this drug class despite not having their expected
    #'   indication approved in the US (e.g., approved for a related but
    #'   distinct condition, or not marketed in the US at all). Stored at
    #'   `priority = 3` (cautious).
    #' @param brand_names Optional named list mapping a GNN drug name (must
    #'   appear in `generic_names`, `generic_names_probable`, or
    #'   `generic_names_cautious`) to one or more brand name strings, e.g.
    #'   `list(SEMAGLUTIDE = "Ozempic", "PAROXETINE MESYLATE" = c("Brisdelle",
    #'   "Pexeva"))`. Generics with no entry get an empty brand vector.
    #'   Stored as a list-column (`brand`) in `get_generics()` output, since a
    #'   single generic can map to zero, one, or multiple brands.
    #' @param version Optional version label string, e.g. `"v1"`.
    initialize = function(drug_class,
                          label,
                          defs                    = NULL,
                          generic_names           = character(0L),
                          generic_names_probable  = character(0L),
                          generic_names_cautious  = character(0L),
                          brand_names             = list(),
                          version                 = NULL) {
      private$.drug_class <- drug_class
      private$.version    <- version
      private$.label      <- label
      private$.defs       <- defs

      all_generic <- c(generic_names, generic_names_probable, generic_names_cautious)
      private$validate_brand_names(brand_names, all_generic)

      private$.generics <- rbind(
        tibble::tibble(
          generic  = generic_names,
          brand    = private$brand_for(generic_names, brand_names),
          priority = 1L
        ),
        tibble::tibble(
          generic  = generic_names_probable,
          brand    = private$brand_for(generic_names_probable, brand_names),
          priority = 2L
        ),
        tibble::tibble(
          generic  = generic_names_cautious,
          brand    = private$brand_for(generic_names_cautious, brand_names),
          priority = 3L
        )
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
      by_priority <- table(factor(private$.generics$priority, levels = 1:3))
      cli::cli_text(
        "{n} generic name(s) ({by_priority[['1']]} core, ",
        "{by_priority[['2']]} probable, {by_priority[['3']]} cautious)"
      )
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
    #' @return A tibble with columns `generic`, `brand` (a list-column of
    #'   character vectors — `character(0)` when a generic has no known
    #'   brand, length 1+ otherwise), `priority`, `class`, and `version`. Use
    #'   `tidyr::unnest(result, brand, keep_empty = TRUE)` to get one row per
    #'   brand (this drops the generic entirely for a plain `unnest()` without
    #'   `keep_empty = TRUE`, since most generics have no brand on record).
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
