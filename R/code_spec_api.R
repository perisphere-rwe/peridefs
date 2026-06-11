# ---- Constructors -------------------------------------------------------

#' Create a user-defined condition code specification
#'
#' @description
#' Constructs a [CodeSpec] R6 object from user-supplied codes and definitions.
#' Codes should be provided in **exact short format** (no decimal periods,
#' e.g., `"4010"` not `"401.0"`).
#'
#' @param condition Short identifier string, e.g. `"my_cond"`.
#' @param label Human-readable label, e.g. `"My Condition"`.
#' @param version Optional version label string, e.g. `"v1"`. Stored as
#'   metadata only; use distinct object names (e.g., `my_spec_v1`) to
#'   distinguish versions.
#' @param defs Named list with elements `condition` and/or `outcome`, each a
#'   character string describing the algorithm. `NULL` elements are allowed.
#' @param codes Named list of key-level lists keyed by `{code_type}_{encounter}`
#'   (e.g., `"dx_icd9"`). Each element may be:
#'   - A character vector of codes — both `condition` and `outcome`
#'     flags are set to `TRUE` for all codes.
#'   - A list with elements `codes`, `condition` (logical
#'     vector), `outcome` (logical vector), and optionally `exclusions`.
#' @param exclusions Optional named list of exclusion note strings, one per
#'   code-set key.
#' @return A [CodeSpec] R6 object.
#' @examples
#' my_spec <- code_spec(
#'   condition = "test",
#'   label     = "Test Condition",
#'   version   = "v1",
#'   codes     = list(dx_icd9 = c("4010", "4011", "4019"))
#' )
#' my_spec
#' @export
code_spec <- function(condition,
                      label,
                      version    = NULL,
                      defs       = list(condition = NULL, outcome = NULL),
                      codes      = list(),
                      exclusions = NULL) {
  codes <- lapply(codes, function(el) {
    if (is.character(el)) {
      list(
        codes       = el,
        condition   = rep(TRUE,  length(el)),
        outcome     = rep(TRUE,  length(el)),
        exclusions  = NULL
      )
    } else {
      if (is.null(el$condition))   el$condition   <- rep(TRUE, length(el$codes))
      if (is.null(el$outcome))     el$outcome     <- rep(TRUE, length(el$codes))
      el
    }
  })

  if (!is.null(exclusions)) {
    for (k in names(exclusions)) {
      if (k %in% names(codes)) codes[[k]]$exclusions <- exclusions[[k]]
    }
  }

  CodeSpec$new(condition = condition, label = label,
               defs = defs, codes = codes, version = version)
}

#' Create a user-defined drug class specification
#'
#' @description Constructs a [DrugSpec] R6 object from user-supplied data.
#'
#' @param drug_class Short identifier string, e.g. `"my_drug"`.
#' @param label Human-readable label.
#' @param version Optional version label string, e.g. `"v1"`.
#' @param defs Character string describing the drug class. May be `NULL`.
#' @param generic_names Character vector of GNN drug names.
#' @param ndc Character vector of NDC codes. Defaults to `character(0)`.
#' @return A [DrugSpec] R6 object.
#' @examples
#' my_drug <- drug_spec(
#'   drug_class    = "my_drug",
#'   label         = "My Drug Class",
#'   version       = "v1",
#'   generic_names = c("DRUGONE", "DRUGTWO")
#' )
#' my_drug
#' @export
drug_spec <- function(drug_class,
                      label,
                      version       = NULL,
                      defs          = NULL,
                      generic_names = character(0L),
                      ndc           = character(0L)) {
  DrugSpec$new(drug_class = drug_class, label = label, version = version,
               defs = defs, generic_names = generic_names, ndc = ndc)
}


# ---- Fine-tuning helpers ------------------------------------------------

#' Add codes to a condition code specification
#'
#' @description
#' Returns a deep clone of `spec` with the specified codes appended to the
#' given key(s). The original spec is never modified.
#'
#' @param spec A [CodeSpec] object.
#' @param variable_type Which membership flag(s) to set for the new codes.
#'   `"condition"` sets `condition = TRUE, outcome = FALSE`;
#'   `"outcome"` sets `condition = FALSE, outcome = TRUE`;
#'   `"both"` (default) sets both to `TRUE`.
#' @param ... Named arguments where the name is a code-set key (e.g.,
#'   `dx_icd9`) and the value is a character vector of codes to add.
#' @return A modified deep clone of `spec`.
#' @examples
#' my_htn <- add_codes(
#'   spec_htn_v1,
#'   dx_icd10 = c("I119", "I130")
#' )
#' @export
add_codes <- function(spec,
                      variable_type = c("condition", "outcome", "both"),
                      ...) {
  if (!inherits(spec, "CodeSpec")) {
    cli::cli_abort("{.arg spec} must be a {.cls CodeSpec} object.")
  }
  vt     <- match.arg(variable_type)
  new_kv <- list(...)
  cloned <- spec$clone(deep = TRUE)
  priv   <- cloned$.__enclos_env__$private

  for (k in names(new_kv)) {
    new_codes  <- new_kv[[k]]
    cond_flag  <- vt %in% c("condition", "both")
    out_flag   <- vt %in% c("outcome",   "both")

    if (k %in% names(priv$.codes)) {
      existing <- priv$.codes[[k]]
      to_add   <- setdiff(new_codes, existing$codes)
      if (length(to_add)) {
        priv$.codes[[k]]$codes       <- c(existing$codes, to_add)

        priv$.codes[[k]]$condition   <- c(existing$condition, rep(cond_flag, length(to_add)))
        priv$.codes[[k]]$outcome     <- c(existing$outcome,   rep(out_flag,  length(to_add)))
      }
    } else {
      priv$.codes[[k]] <- list(
        codes       = new_codes,
        condition   = rep(cond_flag, length(new_codes)),
        outcome     = rep(out_flag,  length(new_codes)),
        exclusions  = NULL
      )
    }
  }

  cloned
}

#' Remove codes from a condition code specification
#'
#' @description
#' Returns a deep clone of `spec` with the specified codes removed from the
#' given key(s). The original spec is never modified.
#'
#' @param spec A [CodeSpec] object.
#' @param ... Named arguments where the name is a code-set key and the value
#'   is a character vector of codes to remove.
#' @return A modified deep clone of `spec`.
#' @examples
#' # Remove a specific code from the ICD-9 inpatient set
#' my_htn <- remove_codes(spec_htn_v1, dx_icd9 = c("4019"))
#' @export
remove_codes <- function(spec, ...) {
  if (!inherits(spec, "CodeSpec")) {
    cli::cli_abort("{.arg spec} must be a {.cls CodeSpec} object.")
  }
  rm_kv  <- list(...)
  cloned <- spec$clone(deep = TRUE)
  priv   <- cloned$.__enclos_env__$private

  for (k in names(rm_kv)) {
    if (!k %in% names(priv$.codes)) next
    to_remove <- rm_kv[[k]]
    keep      <- !priv$.codes[[k]]$codes %in% to_remove
    priv$.codes[[k]]$codes       <- priv$.codes[[k]]$codes[keep]

    priv$.codes[[k]]$condition   <- priv$.codes[[k]]$condition[keep]
    priv$.codes[[k]]$outcome     <- priv$.codes[[k]]$outcome[keep]
  }

  cloned
}

#' Modify a condition code specification
#'
#' @description
#' Returns a deep clone of `spec` with the requested modifications applied.
#'
#' @param spec A [CodeSpec] object.
#' @param label Optional replacement label string.
#' @param defs Optional replacement `defs` list (elements `condition`, `outcome`).
#' @param replace_codes Optional named list of key-level lists that fully
#'   replace existing code sets.
#' @return A modified deep clone of `spec`.
#' @export
modify_code_spec <- function(spec,
                              label         = NULL,
                              defs          = NULL,
                              replace_codes = NULL) {
  if (!inherits(spec, "CodeSpec")) {
    cli::cli_abort("{.arg spec} must be a {.cls CodeSpec} object.")
  }
  cloned <- spec$clone(deep = TRUE)
  priv   <- cloned$.__enclos_env__$private

  if (!is.null(label)) priv$.label <- label
  if (!is.null(defs))  priv$.defs  <- defs

  if (!is.null(replace_codes)) {
    for (k in names(replace_codes)) {
      priv$.codes[[k]] <- replace_codes[[k]]
    }
  }

  cloned
}

#' Modify a drug class specification
#'
#' @description
#' Returns a deep clone of `spec` with the requested modifications applied.
#'
#' @param spec A [DrugSpec] object.
#' @param label Optional replacement label string.
#' @param defs Optional replacement narrative string.
#' @param generic_names Optional replacement GNN character vector.
#' @param ndc Optional replacement NDC character vector.
#' @return A modified deep clone of `spec`.
#' @export
modify_drug_spec <- function(spec,
                              label         = NULL,
                              defs          = NULL,
                              generic_names = NULL,
                              ndc           = NULL) {
  if (!inherits(spec, "DrugSpec")) {
    cli::cli_abort("{.arg spec} must be a {.cls DrugSpec} object.")
  }
  cloned <- spec$clone(deep = TRUE)
  priv   <- cloned$.__enclos_env__$private

  if (!is.null(label))         priv$.label         <- label
  if (!is.null(defs))          priv$.defs          <- defs
  if (!is.null(generic_names)) priv$.generic_names <- generic_names
  if (!is.null(ndc))           priv$.ndc           <- ndc

  cloned
}
