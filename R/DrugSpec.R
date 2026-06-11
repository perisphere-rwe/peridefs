#' R6 class for drug class specifications
#'
#' @description
#' Stores the generic drug names (GNNs), NDC codes, and narrative description
#' for a single version of a drug class definition. Each version is a distinct
#' object (e.g., `spec_acei_v1`, `spec_acei_v2`).
#'
#' @export
DrugSpec <- R6::R6Class(
  "DrugSpec",

  private = list(
    .drug_class    = NULL,
    .version       = NULL,
    .label         = NULL,
    .defs          = NULL,
    .generic_names = NULL,
    .ndc           = NULL
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
    #' @param ndc Character vector of NDC codes.
    #' @param version Optional version label string, e.g. `"v1"`.
    #' @param versions Deprecated. Use `defs`/`generic_names`/`version` directly.
    initialize = function(drug_class,
                          label,
                          defs          = NULL,
                          generic_names = character(0L),
                          ndc           = character(0L),
                          version       = NULL,
                          versions      = NULL) {
      # Backward compatibility with old multi-version API
      if (!is.null(versions)) {
        vk <- names(versions)[length(names(versions))]
        v  <- versions[[vk]]
        if (is.null(defs))          defs          <- v$defs
        if (!length(generic_names)) generic_names <- v$generic_names %||% character(0L)
        if (!length(ndc))           ndc           <- v$ndc           %||% character(0L)
        if (is.null(version))       version       <- vk
      }
      private$.drug_class    <- drug_class
      private$.version       <- version
      private$.label         <- label
      private$.defs          <- defs
      private$.generic_names <- generic_names
      private$.ndc           <- ndc
      invisible(self)
    },

    #' @description Print a summary of the spec.
    print = function(...) {
      ver_tag <- if (!is.null(private$.version))
        cli::col_grey(paste0(" (", private$.version, ")")) else ""
      cli::cli_h1("{self$label}{ver_tag}")
      cli::cli_text("Drug class: {.code {self$drug_class}}")
      if (!is.null(private$.defs)) cli::cli_text("{.strong Def:} {private$.defs}")
      cli::cli_text(
        "{length(private$.generic_names)} generic name(s), {length(private$.ndc)} NDC code(s)"
      )
      if (length(private$.generic_names)) {
        preview <- paste(utils::head(private$.generic_names, 5L), collapse = ", ")
        if (length(private$.generic_names) > 5L) preview <- paste0(preview, ", ...")
        cli::cli_text("  GNNs: {preview}")
      }
      invisible(self)
    },

    #' @description Retrieve generic drug names (GNNs).
    #' @return Character vector of GNN strings.
    get_generics = function() private$.generic_names,

    #' @description Retrieve NDC codes.
    #' @return Character vector of NDC codes (empty until populated).
    get_codes = function() private$.ndc,

    #' @description Retrieve the narrative drug class description.
    #' @return Character string, or `NULL`.
    get_defs = function() private$.defs
  )
)
