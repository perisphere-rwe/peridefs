#' R6 class for composite drug class specifications
#'
#' @description
#' A `CompositeDrugSpec` is a composition of all versioned drug class components
#' that collectively define a composite drug group (e.g., antihypertensives).
#' It holds references to specific versioned [DrugSpec] leaf objects,
#' accessible by name via the `component` argument.
#'
#' The `components` list is a flat named list mapping `"name_vX"` keys to
#' [DrugSpec] objects:
#' ```r
#' components = list(
#'   acei_v1 = spec_acei_v1,
#'   acei_v2 = spec_acei_v2,
#'   arb_v1  = spec_arb_v1,
#'   ...
#' )
#' ```
#'
#' The `component` argument is optional when calling `get_generics()`;
#' omitting it (or passing `"all"`) returns every component.
#'
#' @export
CompositeDrugSpec <- R6::R6Class(
  "CompositeDrugSpec",

  private = list(
    .drug_class = NULL,
    .version    = NULL,
    .label      = NULL,
    .defs       = NULL,
    .components = NULL,
    .condition  = NULL
  ),

  active = list(
    #' @field drug_class Short drug class identifier (read-only).
    drug_class = function() private$.drug_class,
    #' @field version Version label (read-only; typically `NULL` for composites).
    version    = function() private$.version,
    #' @field label Human-readable label (read-only).
    label      = function() private$.label,
    #' @field condition The single condition/indication this composite
    #'   represents (read-only), e.g. `"hypertension"`. Used as the default
    #'   `condition` filter in `get_generics()`.
    condition  = function() private$.condition
  ),

  public = list(
    #' @description Create a new `CompositeDrugSpec`.
    #' @param drug_class Short identifier string, e.g. `"antihypertensive"`.
    #' @param label Human-readable label.
    #' @param defs Character string describing the composite.
    #' @param components Named list of [DrugSpec] objects, keyed by
    #'   `"name_vX"` strings.
    #' @param version Optional version label (typically `NULL`).
    #' @param condition Required character string naming the single
    #'   condition/indication this composite represents, e.g.
    #'   `"hypertension"`. A `CompositeDrugSpec` always represents exactly
    #'   one condition (unlike a leaf [DrugSpec] built with `generic_defs`,
    #'   which may span several); this is used as the default `condition`
    #'   filter in `get_generics()`, so a shared leaf component tagged with
    #'   multiple conditions (e.g. a GLP-1 spec used by both the
    #'   obesity and diabetes composites) only contributes its
    #'   rows for *this* composite's condition unless the caller overrides
    #'   the filter explicitly.
    initialize = function(drug_class, label, defs = NULL, components = list(),
                          version = NULL, condition = NULL) {
      if (is.null(condition)) {
        cli::cli_abort(c(
          "{.arg condition} is required for {.cls CompositeDrugSpec}.",
          "i" = paste0(
            "A composite drug spec always represents a single condition/",
            "indication (e.g. {.val hypertension}); pass it explicitly."
          )
        ))
      }
      private$.drug_class <- drug_class
      private$.version    <- version
      private$.label      <- label
      private$.defs       <- defs
      private$.components <- components
      private$.condition  <- condition
      invisible(self)
    },

    #' @description Print a summary of the composite drug spec.
    print = function(...) {
      cli::cli_h1("{self$label} {cli::col_grey('(composite)')}")
      cli::cli_text("Drug class: {.code {self$drug_class}}")
      cli::cli_text("Condition: {.code {self$condition}}")
      if (!is.null(private$.defs)) cli::cli_text("{.strong Def:} {private$.defs}")

      comps <- private$.components
      if (length(comps)) {
        cli::cli_text("{length(comps)} component(s):")
        for (nm in names(comps)) {
          s <- comps[[nm]]
          n <- nrow(s$get_generics(priority = 1:3))
          cli::cli_bullets(c(" " = "{.code {nm}}: {s$label} ({n} GNNs)"))
        }
        cli::cli_text(cli::col_grey(
          "Use {.arg component} = {.val {names(comps)}} in {.fn get_*} functions."
        ))
      }
      invisible(self)
    },

    #' @description Return the flat named component list.
    #' @return Named list of [DrugSpec] objects.
    components = function() private$.components,

    #' @description Retrieve generic (and brand) drug names from one or more
    #'   components as a tidy data frame.
    #' @param component Optional component name(s), e.g. `"acei_v1"`. `NULL`
    #'   (default) or `"all"` returns every component.
    #' @param priority Integer vector subsetting confidence tiers to include.
    #'   Default `1`.
    #' @param condition Optional character vector subsetting to specific
    #'   condition(s), forwarded to each component's `get_generics()`.
    #'   Defaults to this composite's own `condition` (e.g.
    #'   `"hypertension"`), so a shared leaf component tagged with multiple
    #'   conditions only contributes its rows for this composite's
    #'   condition. Pass `NULL` explicitly to disable condition filtering
    #'   entirely (returns every row from every component regardless of
    #'   condition).
    #' @return A tibble with columns `generic`, `brand`, `priority`,
    #'   `condition`, `class`, and `version`.
    get_generics = function(component = NULL, priority = 1L, condition = self$condition) {
      if (!is.null(component) && !identical(component, "all")) {
        .validate_components(component, self)
      }
      comps <- if (is.null(component) || identical(component, "all")) {
        names(private$.components)
      } else {
        component
      }

      rows <- lapply(comps, function(nm) {
        .resolve_component(private$.components, nm, self$label)$get_generics(priority = priority, condition = condition)
      })

      unique(do.call(rbind, rows))
    },

    #' @description Retrieve the human-readable `label` for one or more
    #'   components as a tidy tibble.
    #'
    #'   This deliberately surfaces each leaf's `label` (e.g. `"ACE
    #'   Inhibitors"`) rather than its free-text `defs` field. A leaf
    #'   `DrugSpec`'s `defs` is typically just an internal sourcing note
    #'   (e.g. `"From the Perisphere antihypertensive medication list."`),
    #'   not a clinical definition -- and now that composite drug specs are
    #'   named after the condition they treat (e.g. `spec_hypertension`), a
    #'   `get_defs()`-style function here would be easy to confuse with the
    #'   condition side's `get_*_v1_defs()`, which *does* return a real
    #'   diagnostic-algorithm narrative. Returning labels instead avoids
    #'   that confusion by making clear this is a component listing, not a
    #'   clinical definition. Version isn't included in the output since
    #'   `name` (the component key, e.g. `"acei_v2"`) already encodes it.
    #' @param component Optional component name(s). `NULL` (default) or
    #'   `"all"` returns every component's label.
    #' @return A tibble with columns `name` (the component key, e.g.
    #'   `"acei_v1"`) and `label` (e.g. `"ACE Inhibitors"`).
    get_meds_labels = function(component = NULL) {
      comps <- private$.components
      if (!is.null(component) && !identical(component, "all")) {
        .validate_components(component, self)
      }
      keys <- if (is.null(component) || identical(component, "all")) {
        names(comps)
      } else {
        component
      }
      tibble::tibble(
        name  = keys,
        label = vapply(keys, function(nm) comps[[nm]]$label, character(1L), USE.NAMES = FALSE)
      )
    }
  )
)
