# Validate and return a named component spec from a composite's component list.
.resolve_component <- function(components, component, spec_label) {
  if (!component %in% names(components)) {
    cli::cli_abort(c(
      "Component {.val {component}} not found in {.val {spec_label}}.",
      "i" = "Available: {.val {names(components)}}"
    ))
  }
  components[[component]]
}

# Return the code_type for a key string.
parse_key <- function(key) {
  list(code_type = key)
}

# Add decimal periods to short-format ICD codes.
# Works for both ICD-9 ("4010" -> "401.0") and ICD-10 ("I120" -> "I12.0").
# Codes with 3 or fewer characters are returned unchanged.
add_periods_icd <- function(codes) {
  vapply(codes, function(code) {
    if (nchar(code) <= 3L) {
      code
    } else {
      paste0(substr(code, 1L, 3L), ".", substr(code, 4L, nchar(code)))
    }
  }, character(1L), USE.NAMES = FALSE)
}

# Null-coalescing operator (internal)
`%||%` <- function(x, y) if (is.null(x)) y else x


`%==%` <- function(x, y){
  all(x %in% y) & all(y %in% x)
}

# Returns TRUE if a get_codes() result contains no codes.
.result_is_empty <- function(result, format) {
  if (identical(format, "tibble")) {
    is.null(result) || (inherits(result, "data.frame") && nrow(result) == 0L)
  } else {
    is.list(result) && all(lengths(result) == 0L)
  }
}
