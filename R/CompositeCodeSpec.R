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
#' The `component` argument is **required** when calling `get_codes()` or
#' `get_defs()`. The `variable_type` argument is forwarded to the component
#' spec, so both condition and outcome codes are accessible.
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
      # Backward compat with old multi-version API
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

    #' @description Retrieve codes from a named component.
    #' @param component **Required.** Name of a component, e.g. `"chd_v1"`.
    #'   Print the spec to see available names.
    #' @param code_type Optional character vector of code types to filter.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @param periods Logical. `FALSE` (default) = short format.
    #' @param format `"list"` (default) or `"tibble"`.
    #' @return Named list or tibble of codes.
    get_codes = function(component     = NULL,
                         code_type     = NULL,
                         variable_type = c("condition", "outcome"),
                         periods       = FALSE,
                         format        = c("list", "tibble")) {
      vt  <- match.arg(variable_type)
      fmt <- match.arg(format)

      if (is.null(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(private$.components)}}",
          "i" = "Print {.code {self$condition}} spec to see all options."
        ))
      }

      if (identical(component, "all")) {
        all_lists <- lapply(private$.components, function(s) {
          s$get_codes(code_type = code_type, variable_type = vt,
                      periods = periods, format = "list")
        })
        all_keys <- unique(unlist(lapply(all_lists, names)))
        result <- lapply(stats::setNames(all_keys, all_keys), function(k) {
          unique(unlist(lapply(all_lists, \(x) x[[k]] %||% character(0L))))
        })
        if (identical(fmt, "tibble")) {
          rows <- lapply(names(result), function(k) {
            cd <- result[[k]]
            if (!length(cd)) return(NULL)
            tibble::tibble(code_type = k, code = cd, variable_type = vt)
          })
          return(do.call(rbind, Filter(Negate(is.null), rows)))
        }
        return(result)
      }

      s <- .resolve_component(private$.components, component, self$label)
      s$get_codes(code_type = code_type, variable_type = vt,
                  periods = periods, format = fmt)
    },

    #' @description Retrieve the narrative algorithm description from a
    #'   named component.
    #' @param component **Required.** Component name.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @return Character string, or `NULL`.
    get_defs = function(component = NULL,
                        variable_type = c("condition", "outcome")) {
      if (is.null(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Available: {.val {names(private$.components)}}"
        ))
      }
      s <- .resolve_component(private$.components, component, self$label)
      s$get_defs(match.arg(variable_type))
    }
  )
)
