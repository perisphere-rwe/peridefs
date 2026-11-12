# Shared helpers for the spec build scripts ----------------------------------
# Sourced into the global environment by data-raw/build_specs.R, so every
# file under data-raw/specs/ can use them.

# Definition lookups (icd9_defs(), icd10_defs(), ...) and the cached CMS
# downloads they read live in build_definitions.R.
source("data-raw/build_definitions.R", local = TRUE)

# ---- Reference code lists ---------------------------------------------------
#
# Code expansion uses official reference files instead of the (unmaintained)
# icd package:
#
#   ICD-10-CM  CMS FY2026 order file (data-raw/.cache/icd10cm_2026.zip). Lists
#              every valid code, including non-billable headers such as
#              "I21", with a billable flag.
#   ICD-9-CM   data-raw/reference/icd9cm_hierarchy.csv: every defined ICD-9-CM
#              diagnosis code (billable and parent codes). ICD-9-CM has been
#              frozen since 2015, so this file never needs updating. It was
#              exported once from icd::icd9cm_hierarchy.
#
# To move ICD-10-CM to a new fiscal year, update the URL and file name in
# .icd10cm_reference() and in build_definitions.R together, then rebuild.
# Released versions are unaffected (they read frozen code sets; see below).

.icd10cm_reference <- local({
  tbl <- NULL
  function() {
    if (is.null(tbl)) {
      zip <- .defs_download(
        "https://www.cms.gov/files/zip/2026-code-descriptions-tabular-order.zip",
        "icd10cm_2026.zip"
      )
      x <- .defs_read_zip_lines(zip, "icd10cm_order_2026.txt")
      tbl <<- data.frame(
        code     = trimws(substr(x, 7L, 13L)),
        billable = substr(x, 15L, 15L) == "1",
        stringsAsFactors = FALSE
      )
    }
    tbl
  }
})

.icd9cm_reference <- local({
  codes <- NULL
  function() {
    if (is.null(codes)) {
      h <- utils::read.csv("data-raw/reference/icd9cm_hierarchy.csv",
                           colClasses = "character", encoding = "UTF-8")
      codes <<- h$code
    }
    codes
  }
})

# All reference codes that start with any of `prefixes` (each prefix itself is
# included when it is a valid code). Returned in reference-file order.
.expand_prefixes <- function(prefixes, universe) {
  prefixes <- toupper(gsub(".", "", prefixes, fixed = TRUE))
  hit <- Reduce(`|`, lapply(prefixes, function(p) startsWith(universe, p)),
                logical(length(universe)))
  universe[hit]
}

# Codes from `a` to `b` inclusive, plus every code under `b`. Endpoints do not
# have to be valid codes themselves.
.expand_between <- function(a, b, universe) {
  a <- toupper(gsub(".", "", a, fixed = TRUE))
  b <- toupper(gsub(".", "", b, fixed = TRUE))
  universe[universe >= a & (universe <= b | startsWith(universe, b))]
}

# ---- ICD expansion helpers ----------------------------------------------------
#
# Each takes short-format codes (no periods; periods are tolerated and
# stripped) and returns a character vector of valid codes.

# expand10("I21", "I22"): every ICD-10-CM code under I21 or I22, including the
# headers themselves.
expand10 <- function(...) .expand_prefixes(c(...), .icd10cm_reference()$code)

# expand9("401"): every ICD-9-CM code under 401, including 401 itself.
expand9 <- function(...) .expand_prefixes(c(...), .icd9cm_reference())

# range10("I20", "I25") / range9("410", "414"): every code from the first
# endpoint through the last, including everything under the last endpoint.
range10 <- function(a, b) .expand_between(a, b, .icd10cm_reference()$code)
range9  <- function(a, b) .expand_between(a, b, .icd9cm_reference())

# billable10(codes): keep only billable (leaf) ICD-10-CM codes.
billable10 <- function(codes) {
  ref <- .icd10cm_reference()
  codes[codes %in% ref$code[ref$billable]]
}

# Expand a numeric HCPCS/CPT range to individual code strings.
# e.g., hcpcs_range("33510", "33519") -> c("33510","33511",...,"33519")
hcpcs_range <- function(a, b) {
  as.character(seq(as.integer(a), as.integer(b)))
}

# ---- Key builders -------------------------------------------------------------

# Build a standard key-level list. `type` is the code-type key (e.g. "dx_icd10")
# and selects which source supplies the definition for each code.
# Optional `attributes` is a named list of extra per-code columns (vectors
# parallel to `codes`); `attributes_for` limits them to "condition" and/or
# "outcome" results (NULL = both).
make_key <- function(type, codes,
                     condition = rep(TRUE, length(codes)),
                     outcome   = rep(TRUE, length(codes)),
                     attributes = NULL, attributes_for = NULL) {
  key <- list(
    codes       = codes,
    condition   = condition,
    outcome     = outcome,
    definitions = code_defs(type, codes)
  )
  if (length(attributes)) {
    key$attributes     <- attributes
    key$attributes_for <- attributes_for
  }
  key
}

make_key_condition_only <- function(type, codes) {
  make_key(
    type, codes,
    condition = rep(TRUE,  length(codes)),
    outcome   = rep(FALSE, length(codes))
  )
}

# ---- Frozen code sets ---------------------------------------------------------
#
# Released versions do not re-derive their codes. Each reads its exact code
# set, with condition/outcome flags, from data-raw/codesets/<id>.csv, where
# <id> is "<condition>_<version>" (e.g. "chd_v1"). Definitions are still
# looked up at build time, so they can be refreshed without touching codes.
#
#   codes = read_codeset("chd_v1")
#
# Never edit a released CSV: create a new version (with its own CSV) instead.
# tests/testthat/test-frozen-versions.R fails if a released code set changes.

# Columns after `outcome` are per-code attributes (see make_key()); they may
# contain NA. A column holding only TRUE/FALSE is read as logical, otherwise
# as character. `attributes_for` limits them to "condition"/"outcome" results.
read_codeset <- function(id, attributes_for = NULL) {
  path <- file.path("data-raw", "codesets", paste0(id, ".csv"))
  if (!file.exists(path)) {
    stop("No frozen code set for '", id, "' (expected ", path, ").", call. = FALSE)
  }
  df <- utils::read.csv(path, colClasses = "character", na.strings = "NA",
                        encoding = "UTF-8")
  base <- c("type", "code", "condition", "outcome")
  if (!identical(names(df)[1:4], base) || anyNA(df[base])) {
    stop(path, " must start with columns type, code, condition, outcome, with no missing values in them.",
         call. = FALSE)
  }
  df$condition <- as.logical(df$condition)
  df$outcome   <- as.logical(df$outcome)
  attr_cols <- setdiff(names(df), base)
  for (nm in attr_cols) {
    if (all(df[[nm]] %in% c("TRUE", "FALSE", NA))) df[[nm]] <- as.logical(df[[nm]])
  }
  types <- unique(df$type)
  stats::setNames(lapply(types, function(k) {
    d <- df[df$type == k, , drop = FALSE]
    make_key(k, d$code, condition = d$condition, outcome = d$outcome,
             attributes = if (length(attr_cols)) as.list(d[attr_cols]) else NULL,
             attributes_for = attributes_for)
  }), types)
}

# To release a new version, build it from expansion helpers first, then write
# its CSV with freeze_codeset() (data-raw/freeze_codeset.R) and switch its
# `codes =` argument to read_codeset(). See CONTRIBUTING_GUIDE section 11.
