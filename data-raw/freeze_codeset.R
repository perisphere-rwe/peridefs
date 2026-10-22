## Freeze a built condition spec's code set to data-raw/codesets/<id>.csv.
##
## Use this once, when a new version is released:
##
##   source("data-raw/build_specs.R")      # builds spec_<condition>_<vN>
##   source("data-raw/freeze_codeset.R")
##   freeze_codeset(spec_diabetes_type2_v2)
##
## Then, in the condition's script under data-raw/specs/conditions/, replace
## the version's `codes = list(...)` with
##
##   codes = read_codeset("diabetes_type2_v2")
##
## (keep the derivation as a comment), add the id to
## `.released_condition_specs` in tests/testthat/test-frozen-versions.R, rebuild,
## and run devtools::test() to record its snapshot.
##
## Refuses to overwrite an existing CSV: released code sets never change.

freeze_codeset <- function(spec, dir = "data-raw/codesets") {
  if (!inherits(spec, "CodeSpec")) stop("`spec` must be a CodeSpec.", call. = FALSE)
  if (is.null(spec$version)) stop("`spec` has no version.", call. = FALSE)

  id   <- paste0(spec$condition, "_", spec$version)
  path <- file.path(dir, paste0(id, ".csv"))
  if (file.exists(path)) {
    stop(path, " already exists. Released code sets are frozen; ",
         "create a new version instead.", call. = FALSE)
  }

  codes <- spec$.__enclos_env__$private$.codes
  df <- do.call(rbind, lapply(names(codes), function(k) {
    data.frame(type = k, code = codes[[k]]$codes,
               condition = codes[[k]]$condition, outcome = codes[[k]]$outcome,
               stringsAsFactors = FALSE)
  }))

  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  utils::write.csv(df, path, row.names = FALSE)
  message("Wrote ", nrow(df), " codes to ", path)
  invisible(path)
}
