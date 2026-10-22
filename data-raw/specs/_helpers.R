# Shared helpers for the spec build scripts ----------------------------------
# Sourced into the global environment by data-raw/build_specs.R, so every
# file under data-raw/specs/ can use them.

# ---- ICD expansion helpers -----------------------------------------------

expand10 <- function(...) {
  unname(
    unclass(
      children(as.icd10cm(c(...)), defined = TRUE)
    )
  )
}

expand9 <- function(...) {
  unname(
    unclass(
      children(as.icd9cm(c(...)), defined = TRUE)
    )
  )
}

range10 <- function(a, b) {
  unname(
    unclass(
      expand_range(as.icd10cm(a), as.icd10cm(b), defined = TRUE)
    )
  )
}

range9 <- function(a, b) {
  unname(
    unclass(
      expand_range(as.icd9cm(a), as.icd9cm(b), defined = TRUE)
    )
  )
}

# Expand a numeric HCPCS/CPT range to individual code strings.
# e.g., hcpcs_range("33510", "33519") -> c("33510","33511",...,"33519")
hcpcs_range <- function(a, b) {
  as.character(seq(as.integer(a), as.integer(b)))
}

# ---- Key builders ---------------------------------------------------------
# Definition lookups (icd9_defs(), icd10_defs(), ...) live in build_definitions.R.
source("data-raw/build_definitions.R")

# Build a standard key-level list. `type` is the code-type key (e.g. "dx_icd10")
# and selects which source supplies the definition for each code.
make_key <- function(type, codes,
                     condition = rep(TRUE, length(codes)),
                     outcome   = rep(TRUE, length(codes))) {
  list(
    codes       = codes,
    condition   = condition,
    outcome     = outcome,
    definitions = code_defs(type, codes)
  )
}

make_key_condition_only <- function(type, codes) {
  make_key(
    type, codes,
    condition = rep(TRUE,  length(codes)),
    outcome   = rep(FALSE, length(codes))
  )
}
