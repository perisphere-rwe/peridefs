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
#' The `component` argument is **required** when calling any `get_*` method.
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
    #' @param versions Deprecated. Use `defs`/`components` directly.
    initialize = function(drug_class, label, defs = NULL, components = list(),
                          version = NULL, versions = NULL) {
      # Backward compat with old multi-version API
      if (!is.null(versions)) {
        vk <- names(versions)[length(names(versions))]
        v  <- versions[[vk]]
        if (is.null(defs)) defs <- v$defs
        if (!length(components)) {
          # Old components stored as list(name = list(spec = ..., version = ...))
          old_comps <- v$components
          flat <- list()
          for (nm in names(old_comps)) {
            cd <- old_comps[[nm]]
            flat[[nm]] <- if (is.list(cd) && !is.null(cd$spec)) cd$spec else cd
          }
          components <- flat
        }
        if (is.null(version)) version <- vk
      }
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
          n <- length(s$get_generics())
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

    #' @description Retrieve GNNs from a named component.
    #' @param component **Required.** Component name, e.g. `"acei_v1"`.
    #' @return Character vector of GNN strings.
    get_generics = function(component = NULL) {
      if (is.null(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(private$.components)}}"
        ))
      }
      if (identical(component, "all")) {
        return(unique(unlist(lapply(private$.components, function(s) s$get_generics()))))
      }
      .resolve_component(private$.components, component, self$label)$get_generics()
    },

    #' @description Retrieve NDC codes from a named component.
    #' @param component **Required.** Component name, or `"all"` for the union
    #'   across all components.
    #' @return Character vector of NDC codes.
    get_codes = function(component = NULL) {
      if (is.null(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(private$.components)}}"
        ))
      }
      if (identical(component, "all")) {
        return(unique(unlist(lapply(private$.components, function(s) s$get_codes()))))
      }
      .resolve_component(private$.components, component, self$label)$get_codes()
    },

    #' @description Retrieve the narrative description for a named component.
    #' @param component **Required.** Component name.
    #' @return Character string, or `NULL`.
    get_defs = function(component = NULL) {
      if (is.null(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to see all component defs, or specify one: {.val {names(private$.components)}}"
        ))
      }
      if (identical(component, "all")) {
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
