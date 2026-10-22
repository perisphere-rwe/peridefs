# Frozen code sets and build helpers ----------------------------------------
#
# Released condition versions are built from data-raw/codesets/<id>.csv (see
# read_codeset() in data-raw/specs/_helpers.R). These tests check that each
# released version has its CSV and that the CSV matches the built spec
# exactly (same code types, codes, order, and condition/outcome flags), and
# exercise the CMS-based expansion helpers used to author new versions.
#
# data-raw/ is not part of the installed package, so these tests run only
# from a source checkout (devtools::test()) and are skipped otherwise. The
# expansion-helper tests also need the cached CMS files in data-raw/.cache/
# (created by the first run of data-raw/build_specs.R).

.pkg_root  <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = FALSE)
.data_raw  <- file.path(.pkg_root, "data-raw")
.codesets  <- file.path(.data_raw, "codesets")
.cms_cache <- file.path(.data_raw, ".cache", "icd10cm_2026.zip")

.read_codeset_csv <- function(id) {
  utils::read.csv(file.path(.codesets, paste0(id, ".csv")),
                  colClasses = c("character", "character", "logical", "logical"),
                  encoding = "UTF-8")
}

.spec_codeset <- function(spec) {
  codes <- .private(spec)$.codes
  do.call(rbind, lapply(names(codes), function(k) {
    data.frame(type = k, code = as.vector(codes[[k]]$codes),
               condition = codes[[k]]$condition, outcome = codes[[k]]$outcome,
               stringsAsFactors = FALSE)
  }))
}

# Source the build helpers into a private environment (once per test run).
.build_helpers <- local({
  env <- NULL
  function() {
    if (is.null(env)) {
      env <<- new.env(parent = asNamespace("peridefs"))
      withr::with_dir(.pkg_root, sys.source("data-raw/specs/_helpers.R", envir = env))
    }
    env
  }
})

.cond_leaves <- .condition_leaves(.all_specs())

# ---- Frozen CSVs --------------------------------------------------------------

test_that("every released condition version has a frozen code set CSV", {
  skip_if_not(dir.exists(.codesets), "data-raw/codesets not available")
  missing <- .released_condition_specs[
    !file.exists(file.path(.codesets, paste0(.released_condition_specs, ".csv")))
  ]
  expect(length(missing) == 0L, paste0(
    "No data-raw/codesets/<id>.csv for released version(s): ",
    paste(missing, collapse = ", "),
    ". Freeze them with freeze_codeset() (data-raw/freeze_codeset.R)."
  ))
})

test_that("each frozen code set CSV matches its built spec exactly", {
  skip_if_not(dir.exists(.codesets), "data-raw/codesets not available")
  for (id in intersect(.released_condition_specs, names(.cond_leaves))) {
    path <- file.path(.codesets, paste0(id, ".csv"))
    if (!file.exists(path)) next
    expect_identical(.read_codeset_csv(id), .spec_codeset(.cond_leaves[[id]]),
                     label = paste0("data-raw/codesets/", id, ".csv"))
  }
})

test_that("every frozen code set CSV belongs to a released version", {
  skip_if_not(dir.exists(.codesets), "data-raw/codesets not available")
  ids <- sub("\\.csv$", "", list.files(.codesets, pattern = "\\.csv$"))
  extra <- setdiff(ids, .released_condition_specs)
  expect(length(extra) == 0L, paste0(
    "CSV(s) in data-raw/codesets/ for unreleased version(s): ",
    paste(extra, collapse = ", "),
    ". Add them to `.released_condition_specs` or remove the CSV."
  ))
})

# ---- Build helpers ------------------------------------------------------------

test_that("read_codeset() reproduces a released spec's codes and flags", {
  skip_if_not(dir.exists(.codesets), "data-raw/codesets not available")
  skip_if_not(file.exists(.cms_cache), "cached CMS files not available")
  h  <- .build_helpers()
  ks <- withr::with_dir(.pkg_root, h$read_codeset("hypertension_v1"))
  spec_codes <- .private(.cond_leaves[["hypertension_v1"]])$.codes
  expect_identical(names(ks), names(spec_codes))
  for (k in names(ks)) {
    expect_identical(ks[[k]]$codes,     as.vector(spec_codes[[k]]$codes))
    expect_identical(ks[[k]]$condition, spec_codes[[k]]$condition)
    expect_identical(ks[[k]]$outcome,   spec_codes[[k]]$outcome)
  }
  expect_error(withr::with_dir(.pkg_root, h$read_codeset("no_such_v9")), "No frozen code set")
})

test_that("ICD-9 expansion uses the full hierarchy (parents included)", {
  skip_if_not(file.exists(file.path(.data_raw, "reference", "icd9cm_hierarchy.csv")),
              "ICD-9 reference not available")
  h <- .build_helpers()
  withr::with_dir(.pkg_root, {
    expect_identical(h$expand9("401"), c("401", "4010", "4011", "4019"))
    expect_identical(h$expand9("401.1"), "4011")
    r <- h$range9("410", "414")
    expect_true(all(substr(r, 1, 3) %in% as.character(410:414)))
    expect_true(all(c("410", "4149", "41400") %in% r))
    expect_false("415" %in% r)
  })
})

test_that("ICD-10-CM expansion uses the current CMS file", {
  skip_if_not(file.exists(.cms_cache), "cached CMS files not available")
  h <- .build_helpers()
  withr::with_dir(.pkg_root, {
    i21 <- h$expand10("I21")
    expect_true(all(startsWith(i21, "I21")))
    expect_true(all(c("I21", "I210", "I21A1", "I21B") %in% i21))
    expect_identical(h$expand10("I21.0"), h$expand10("I210"))
    expect_identical(h$billable10(c("I21", "I210", "I2101")), "I2101")
    expect_true(all(startsWith(h$range10("I20", "I22"), "I2")))
  })
})
