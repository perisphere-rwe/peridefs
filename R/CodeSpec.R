#' R6 class for medical condition code specifications
#'
#' @description
#' Stores the code sets and narrative algorithm description for a single
#' version of a medical condition definition. Each version is a distinct
#' object (e.g., `spec_htn_v1`, `spec_htn_v2`).
#'
#' The spec stores:
#' - `defs`: named list with elements `condition` and `outcome`, each holding
#'   a narrative algorithm description string (or `NULL` if not defined).
#' - `codes`: named list of key-level lists keyed by `{code_type}_{encounter}`
#'   (e.g., `dx_icd9`). Each key-level list has:
#'   - `codes`: character vector of exact short-format codes (no periods).
#'   - `condition`: logical vector parallel to `codes`; `TRUE` if the code
#'     belongs to the condition/history definition.
#'   - `outcome`: logical vector parallel to `codes`; `TRUE` if the code
#'     belongs to the outcome definition.
#'   - `exclusions`: optional character string describing codes to exclude.
#'
#' @export
CodeSpec <- R6::R6Class(
  "CodeSpec",

  private = list(
    .condition = NULL,
    .version   = NULL,
    .label     = NULL,
    .defs      = NULL,
    .codes     = NULL,

    get_codes_impl = function(code_type, variable_type, periods, format) {
      keys <- names(private$.codes)

      if (!is.null(code_type)) {
        keys <- keys[keys %in% code_type]
      }

      result <- lapply(stats::setNames(keys, keys), function(k) {
        kd   <- private$.codes[[k]]
        mask <- if (variable_type == "condition") kd$condition else kd$outcome
        cd   <- kd$codes[mask]
        if (periods) cd <- add_periods_icd(cd)
        cd
      })

      if (identical(format, "tibble")) {
        rows <- lapply(names(result), function(k) {
          kd      <- private$.codes[[k]]
          mask    <- if (variable_type == "condition") kd$condition else kd$outcome
          parsed  <- parse_key(k)
          cd      <- kd$codes[mask]
          if (!length(cd)) return(NULL)
          tibble::tibble(
            code_type     = parsed$code_type,
            code          = if (periods) add_periods_icd(cd) else cd,
            variable_type = variable_type
          )
        })
        return(do.call(rbind, Filter(Negate(is.null), rows)))
      }

      result
    }
  ),

  active = list(
    #' @field condition Short condition identifier (read-only).
    condition = function() private$.condition,
    #' @field version Version label, e.g. `"v1"` (read-only).
    version   = function() private$.version,
    #' @field label Human-readable condition label (read-only).
    label     = function() private$.label
  ),

  public = list(
    #' @description Create a new `CodeSpec`.
    #' @param condition Short identifier string, e.g. `"htn"`.
    #' @param label Human-readable label, e.g. `"Hypertension"`.
    #' @param defs Named list with elements `condition` and `outcome` (character
    #'   strings or `NULL`).
    #' @param codes Named list of key-level lists. See class description.
    #' @param version Optional version label string, e.g. `"v1"`.
    #' @param versions Deprecated. Use `defs`/`codes`/`version` directly.
    initialize = function(condition, label, defs = NULL, codes = NULL,
                          version = NULL, versions = NULL) {
      # Backward compatibility with old multi-version API
      if (!is.null(versions) && (is.null(defs) || is.null(codes))) {
        vk <- names(versions)[length(names(versions))]
        if (is.null(defs))    defs    <- versions[[vk]]$defs
        if (is.null(codes))   codes   <- versions[[vk]]$codes
        if (is.null(version)) version <- vk
      }
      private$.condition <- condition
      private$.version   <- version
      private$.label     <- label
      private$.defs      <- defs
      private$.codes     <- codes
      invisible(self)
    },

    #' @description Print a summary of the spec.
    print = function(...) {
      ver_tag <- if (!is.null(private$.version)){
        cli::col_grey(paste0(" (", private$.version, ")"))
      } else {
        ""
      }

      cli::cli_h1("{self$label}{ver_tag}")
      cli::cli_text("Condition: {.code {self$condition}}")

      .print_def <- function(label, def) {
        if (is.null(def)) return(invisible(NULL))
        cli::cli_text("{.strong {label}:}")
        if (!is.null(names(def))) cli::cli_bullets(def) else cli::cli_text(def)
        cli::cli_text("")
      }
      .print_def("Condition def", private$.defs$condition)
      .print_def("Outcome def",   private$.defs$outcome)

      cli::cli_text("Code sets:")
      for (k in names(private$.codes)) {
        kd     <- private$.codes[[k]]
        n_cond <- sum(kd$condition)
        n_out  <- sum(kd$outcome)
        cli::cli_bullets(c(
          " " = "{.code {k}}: {n_cond} condition / {n_out} outcome codes"
        ))
      }
      invisible(self)
    },

    #' @description Return code-set keys.
    #' @return Character vector of keys like `"dx_icd9"`.
    keys = function() names(private$.codes),

    #' @description Retrieve codes from the spec.
    #' @param code_type Optional character vector of code types to return.
    #'   Valid values: `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`,
    #'   `"proc_icd10"`, `"hcpcs"`, `"cpt"`, `"rev"`. `NULL` returns all.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @param periods Logical. If `TRUE`, return codes with decimal periods
    #'   (e.g., `"401.0"`). Default `FALSE` returns short format (`"4010"`).
    #' @param format `"list"` (default) returns a named list of character
    #'   vectors; `"tibble"` returns a long-form tibble.
    #' @return Named list or tibble of codes.
    get_codes = function(code_type = NULL,
                         variable_type = c("condition", "outcome"),
                         periods = FALSE,
                         format = c("list", "tibble")) {
      private$get_codes_impl(
        code_type,
        match.arg(variable_type),
        periods,
        match.arg(format)
      )
    },

    #' @description Retrieve the narrative algorithm description.
    #' @param variable_type `"condition"` (default) or `"outcome"`.
    #' @return Character string, or `NULL` if no definition exists for that
    #'   variable type.
    get_defs = function(variable_type = c("condition", "outcome")) {
      private$.defs[[match.arg(variable_type)]]
    }
  )
)
