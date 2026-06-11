#' Expand ICD-10-PCS prefix patterns to all matching valid codes
#'
#' @description
#' Resolves ICD-10-PCS pattern strings of the form used in the Perisphere
#' definitions document (e.g., `"0210xxx"`) into the full set of valid
#' 7-character ICD-10-PCS codes from the FY2026 CMS order file.
#'
#' Patterns are matched by **prefix**: trailing lowercase `x` characters
#' are stripped to form the prefix, and all valid codes that begin with that
#' prefix are returned. Codes with no trailing `x` are treated as exact codes
#' and returned only if they exist in the reference table.
#'
#' @param patterns Character vector of ICD-10-PCS pattern strings. Examples:
#'   - `"0210xxx"` — 4-character prefix, returns all 74 CABG variants
#'   - `"03CH0ZZ"` — exact code, returned as-is if valid
#'   - `c("0210xxx", "0211xxx")` — vectorised; results are unioned
#'
#' @return Character vector of unique valid ICD-10-PCS codes (7 characters,
#'   no periods).
#'
#' @examples
#' # All CABG codes (0210 prefix)
#' expand_pcs("0210xxx")
#'
#' # Exact code lookup
#' expand_pcs("02100Z9")
#'
#' # Multiple patterns — results are combined and deduplicated
#' expand_pcs(c("0210xxx", "0211xxx"))
#' @export
expand_pcs <- function(patterns) {
  if (!is.character(patterns) || !length(patterns)) {
    cli::cli_abort("{.arg patterns} must be a non-empty character vector.")
  }

  results <- lapply(patterns, function(p) {
    # Strip trailing x/X to get the fixed prefix
    prefix <- sub("[xX]+$", "", p)
    pcs_codes[startsWith(pcs_codes, prefix)]
  })

  unique(unlist(results, use.names = FALSE))
}
