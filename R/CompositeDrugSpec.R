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
    .components = NULL
  ),

  active = list(
    #' @field drug_class Short drug class identifier (read-only).
    drug_class = function() private$.drug_class,
    #' @field version Version label (read-only; typically `NULL` for composites).
    version    = function() private$.version,
    #' @field label Human-readable label (read-only).
    label      = function() private$.label
  ),

  public = list(
    #' @description Create a new `CompositeDrugSpec`.
    #' @param drug_class Short identifier string, e.g. `"antihypertensive"`.
    #' @param label Human-readable label.
    #' @param defs Character string describing the composite.
    #' @param components Named list of [DrugSpec] objects, keyed by
    #'   `"name_vX"` strings.
    #' @param version Optional version label (typically `NULL`).
    initialize = function(drug_class, label, defs = NULL, components = list(),
                          version = NULL) {
      private$.drug_class <- drug_class
      private$.version    <- version
      private$.label      <- label
      private$.defs       <- defs
      private$.components <- components
      invisible(self)
    },

    #' @description Print a summary of the composite drug spec.
    print = function(...) {
      cli::cli_h1("{self$label} {cli::col_grey('(composite)')}")
      cli::cli_text("Drug class: {.code {self$drug_class}}")
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
    #' @return A tibble with columns `generic`, `brand`, `priority`, `class`,
    #'   and `version`.
    get_generics = function(component = NULL, priority = 1L) {
      if (!is.null(component) && !identical(component, "all")) {
        .validate_components(component, self)
      }
      comps <- if (is.null(component) || identical(component, "all")) {
        names(private$.components)
      } else {
        component
      }

      rows <- lapply(comps, function(nm) {
        .resolve_component(private$.components, nm, self$label)$get_generics(priority = priority)
      })

      unique(do.call(rbind, rows))
    },

    #' @description Retrieve the narrative description for one or more
    #'   components.
    #' @param component Optional component name. `NULL` (default) or `"all"`
    #'   renders every component's description.
    #' @return Character string, or (for `"all"`/`NULL`) an invisible named
    #'   list rendered to the console.
    get_defs = function(component = NULL) {
      if (is.null(component) || identical(component, "all")) {
        defs <- lapply(stats::setNames(names(private$.components),
                                       names(private$.components)),
                       function(nm) {
                         d <- private$.components[[nm]]$get_defs()
                         if (!is.null(d)) {
                           cli::cli_text("{.strong {nm}:}")
                           cli::cli_text(d)
                           cli::cli_text("")
                         }
                         invisible(d)
                       })
        return(invisible(defs))
      }
      .render_def(.resolve_component(private$.components, component, self$label)$get_defs())
    }
  )
)
