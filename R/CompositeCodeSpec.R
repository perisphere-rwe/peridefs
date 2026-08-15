#' R6 class for composite condition code specifications
#'
#' @description
#' A `CompositeCodeSpec` is a composition of all versioned condition components
#' that collectively define a composite endpoint (e.g., ASCVD). Unlike
#' [CodeSpec], it does not store codes directly — instead it holds references
#' to specific versioned [CodeSpec] leaf objects, accessible by name via the
#' `component` argument.
#'
#' The `components` list is a flat named list mapping `"name_vX"` keys to
#' [CodeSpec] objects, e.g.:
#' ```r
#' components = list(
#'   chd_v1           = spec_chd_v1,
#'   stroke_v1        = spec_stroke_v1,
#'   cerebrovasc_disease_v1 = spec_cerebrovasc_disease_v1
#' )
#' ```
#'
#' The `component` argument is optional when calling `get_codes()` or
#' `get_defs()`; omitting it (or passing `"all"`) returns every component.
#' The `variable_type` argument is forwarded to the component spec, so both
#' condition and outcome codes are accessible.
#'
#' @export
CompositeCodeSpec <- R6::R6Class(
  "CompositeCodeSpec",

  private = list(
    .condition  = NULL,
    .version    = NULL,
    .label      = NULL,
    .defs       = NULL,
    .components = NULL
  ),

  active = list(
    #' @field condition Short condition identifier (read-only).
    condition = function() private$.condition,
    #' @field version Version label (read-only; `NULL` for composites).
    version   = function() private$.version,
    #' @field label Human-readable label (read-only).
    label     = function() private$.label
  ),

  public = list(
    #' @description Create a new `CompositeCodeSpec`.
    #' @param condition Short identifier string, e.g. `"ascvd"`.
    #' @param label Human-readable label.
    #' @param defs Character string describing the composite definition.
    #' @param components Named list of [CodeSpec] objects, keyed by
    #'   `"name_vX"` strings.
    #' @param version Optional version label (typically `NULL` for composites).
    initialize = function(condition, label, defs = NULL, components = list(),
                          version = NULL) {
      private$.condition  <- condition
      private$.version    <- version
      private$.label      <- label
      private$.defs       <- defs
      private$.components <- components
      invisible(self)
    },

    #' @description Print a summary of the composite spec.
    print = function(...) {
      cli::cli_h1("{self$label} {cli::col_grey('(composite)')}")
      cli::cli_text("Condition: {.code {self$condition}}")
      if (!is.null(private$.defs)) cli::cli_text("{.strong Def:} {private$.defs}")

      comps <- private$.components
      if (length(comps)) {
        cli::cli_text("{.strong Components:}")
        for (nm in names(comps)) {
          s <- comps[[nm]]
          cli::cli_bullets(c(" " = "{.code {nm}}: {s$label}"))
        }
        cli::cli_text(cli::col_grey(
          "Use {.arg component} = {.val {names(comps)}} in {.fn get_*} functions."
        ))
      }
      invisible(self)
    },

    #' @description Return the flat named component list.
    #' @return Named list of [CodeSpec] objects.
    components = function() private$.components,

    #' @description Return the code-set keys available across all components.
    #' @return Character vector of unique key strings.
    keys = function() {
      unique(unlist(lapply(private$.components, \(s) s$keys())))
    },

    #' @description Retrieve codes from one or more components as a tidy
    #'   data frame.
    #' @param component Optional component name(s), e.g. `"chd_v1"`. `NULL`
    #'   (default) or `"all"` returns every component, with a `class` column
    #'   distinguishing them.
    #' @param code_type Optional character vector of code types to filter.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @param periods Logical. `FALSE` (default) = short format.
    #' @param priority Integer vector subsetting confidence tiers to include.
    #'   Default `1`.
    #' @return A tibble with columns `type`, `code`, `priority`, `version`,
    #'   and `class` (the component name).
    get_codes = function(component     = NULL,
                         code_type     = NULL,
                         variable_type = c("condition", "outcome"),
                         periods       = FALSE,
                         priority      = 1L) {
      vt <- match.arg(variable_type)

      if (!is.null(component) && !identical(component, "all")) {
        .validate_components(component, self)
      }
      comps <- if (is.null(component) || identical(component, "all")) {
        names(private$.components)
      } else {
        component
      }

      rows <- lapply(comps, function(nm) {
        s      <- .resolve_component(private$.components, nm, self$label)
        result <- s$get_codes(code_type = code_type, variable_type = vt,
                              periods = periods, priority = priority)
        result$class <- nm
        result
      })

      unique(do.call(rbind, rows))
    },

    #' @description Retrieve the narrative algorithm description from one or
    #'   more components.
    #' @param component Optional component name. `NULL` (default) or `"all"`
    #'   renders every component's description.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @return Character string, or (for `"all"`/`NULL`) an invisible named
    #'   list rendered to the console.
    get_defs = function(component     = NULL,
                        variable_type = c("condition", "outcome")) {
      vt <- match.arg(variable_type)

      if (is.null(component) || identical(component, "all")) {
        defs <- lapply(stats::setNames(names(private$.components),
                                       names(private$.components)),
                       function(nm) {
                         d <- private$.components[[nm]]$get_defs(variable_type = vt)
                         if (!is.null(d)) {
                           cli::cli_text("{.strong {nm}:}")
                           cli::cli_text(d)
                           cli::cli_text("")
                         }
                         invisible(d)
                       })
        return(invisible(defs))
      }

      s <- .resolve_component(private$.components, component, self$label)
      s$get_defs(vt)
    }
  )
)
