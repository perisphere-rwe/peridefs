# get_version_diffs(), list_versions(), and the version history -------------

# Three versions of a toy condition, for multi-version behaviour.
.toy <- function(version, dx_icd10) {
  code_spec(condition = "toy", label = "Toy", version = version,
            codes = list(dx_icd10 = dx_icd10))
}
.toy_v1 <- .toy("v1", c("A01", "A02", "A03"))
.toy_v2 <- .toy("v2", c("A01", "A02", "A04"))
.toy_v3 <- .toy("v3", c("A01", "A03", "A04"))

# ---- get_version_diffs() ------------------------------------------------------

.diffs <- function(...) peridefs:::.diff_specs(list(...), variable_type = "condition",
                                               periods = FALSE, changes_only = FALSE)

test_that("get_version_diffs() returns one logical column per version, then code/type/definition/change", {
  d <- get_version_diffs("diabetes_type2", c("v1", "v2"))
  expect_s3_class(d, "tbl_df")
  expect_identical(names(d), c("v1", "v2", "code", "type", "definition", "change"))
  expect_type(d$v1, "logical")
  expect_type(d$v2, "logical")
})

test_that("versions can be labels or numbers, in any order, and default to all", {
  d <- get_version_diffs("diabetes_type2", c("v1", "v2"))
  expect_identical(get_version_diffs("diabetes_type2", c(1, 2)), d)
  expect_identical(get_version_diffs("diabetes_type2", c(2L, 1L)), d)
  expect_identical(get_version_diffs("diabetes_type2", c("v2", "v1")), d)
  expect_identical(get_version_diffs("diabetes_type2", c("V1", "2")), d)
  expect_identical(get_version_diffs("diabetes_type2"), d)
})

test_that("diabetes type 2 v1 -> v2: drops ICD-9, E08, E09, E13; adds E11A", {
  v1 <- get_diabetes_type2_v1_codes()
  v2 <- get_diabetes_type2_v2_codes()
  d  <- get_version_diffs("diabetes_type2", c(1, 2))

  # Every code from either version appears exactly once
  expect_identical(nrow(d), length(union(paste(v1$type, v1$code), paste(v2$type, v2$code))))
  expect_false(anyDuplicated(paste(d$type, d$code)) > 0)
  expect_identical(sum(d$v1), nrow(v1))
  expect_identical(sum(d$v2), nrow(v2))

  # v2 is ICD-10 E11 only
  expect_true(all(v2$type == "dx_icd10"))
  expect_true(all(startsWith(v2$code, "E11")))
  expect_false(any(d$v2[d$type == "dx_icd9"]))
  expect_false(any(d$v2[grepl("^E(08|09|13)", d$code)]))

  # E11A is the only addition; every v1 E11 code is kept
  added <- d[!d$v1 & d$v2, ]
  expect_identical(added$code, "E11A")
  expect_identical(added$change, "added in v2")
  e11_v1 <- d$v1 & startsWith(d$code, "E11")
  expect_true(all(d$v2[e11_v1]))
  expect_true(all(d$change[e11_v1] == "unchanged"))
  expect_true(all(d$change[d$v1 & !d$v2] == "removed in v2"))

  # Definitions come through
  expect_match(d$definition[d$code == "E11A"], "remission", ignore.case = TRUE)
})

test_that("heart failure v1 -> v2: drops ICD-9; history also drops I11.0/I13.0/I13.2", {
  hyp <- c("I110", "I130", "I132")
  for (vt in c("condition", "outcome")) {
    d <- get_version_diffs("hf", c(1, 2), variable_type = vt)
    expect_true(all(d$change[d$type == "dx_icd9"] == "removed in v2"))
    expect_false(any(!d$v1 & d$v2))
    expect_true(all(d$change[d$type == "dx_icd10" & !d$code %in% hyp] == "unchanged"))
    if (vt == "condition") {
      expect_true(all(d$change[d$code %in% hyp] == "removed in v2"))
    } else {
      expect_true(all(d$change[d$code %in% hyp] == "unchanged"))
    }
  }
  expect_identical(sort(get_hf_v2_codes()$code),
                   sort(c("I501", "I5020", "I5021", "I5022", "I5023", "I5030", "I5031",
                          "I5032", "I5033", "I5040", "I5041", "I5042", "I5043",
                          "I50810", "I50811", "I50812", "I50813", "I50814", "I5082",
                          "I5083", "I5084", "I5089", "I509")))
  expect_identical(sort(get_hf_v2_codes(variable_type = "outcome")$code),
                     sort(c("I110", "I130", "I132", "I501", "I5020", "I5021", "I5022",
                            "I5023", "I5030", "I5031", "I5032", "I5033", "I5040",
                            "I5041", "I5042", "I5043", "I50810", "I50811", "I50812",
                            "I50813", "I50814", "I5082", "I5083", "I5084", "I5089",
                            "I509")))
  expect_identical(list_versions("hf")$version, c("v1", "v2"))
})

test_that("heart failure v2 outcome codes carry acuity, required_secondary, qualifies_as_primary", {
  out  <- get_hf_v2_codes(variable_type = "outcome")
  base <- c("type", "code", "priority", "version", "definition")
  expect_identical(names(out), c(base, "acuity", "required_secondary", "qualifies_as_primary"))
  # History stays the plain five-column table; v1 is unchanged.
  expect_identical(names(get_hf_v2_codes()), base)
  expect_identical(names(get_hf_v1_codes(variable_type = "outcome")), base)

  at <- function(code) out[out$code == code, , drop = FALSE]
  expect_true(all(is.na(out$acuity[out$code %in% c("I110", "I130", "I132")])))
  expect_identical(at("I110")$required_secondary, "I50.x")
  expect_identical(at("I130")$required_secondary, "I50.x + N18.x")
  expect_identical(at("I132")$required_secondary, "I50.x + N18.x")
  expect_true(all(out$required_secondary[startsWith(out$code, "I50") | out$code == "I509"] == "none"))

  acute <- c("I5021", "I5023", "I5031", "I5033", "I5041", "I5043", "I50811", "I50813")
  expect_setequal(out$code[out$acuity %in% c("acute", "acute_on_chronic")], acute)
  expect_setequal(out$code[out$qualifies_as_primary], c(acute, "I110", "I130", "I132"))
  expect_setequal(out$code[out$acuity %in% "chronic"], c("I5022", "I5032", "I5042", "I50812"))
  expect_true(all(out$acuity[out$code %in% c("I50814", "I5082", "I5083", "I5084", "I509")] == "unspecified"))
  expect_false(at("I5084")$qualifies_as_primary)
  expect_setequal(unique(out$acuity), c(NA, "acute", "acute_on_chronic", "chronic", "unspecified"))
})

test_that("comparisons handle any number of versions", {
  d <- .diffs(.toy_v3, .toy_v1, .toy_v2)
  expect_identical(names(d)[1:3], c("v1", "v2", "v3"))
  expect_identical(d$code, c("A01", "A02", "A03", "A04"))
  expect_identical(d$v1, c(TRUE, TRUE, TRUE, FALSE))
  expect_identical(d$v2, c(TRUE, TRUE, FALSE, TRUE))
  expect_identical(d$v3, c(TRUE, FALSE, TRUE, TRUE))
  expect_identical(d$change, c("unchanged", "removed in v3",
                               "removed in v2; added in v3", "added in v2"))
})

test_that("changes_only = TRUE keeps only codes that changed", {
  d <- peridefs:::.diff_specs(list(.toy_v1, .toy_v2, .toy_v3), "condition",
                              periods = FALSE, changes_only = TRUE)
  expect_identical(d$code, c("A02", "A03", "A04"))
  d2 <- get_version_diffs("diabetes_type2", c(1, 2), changes_only = TRUE)
  expect_false(any(d2$change == "unchanged"))
  expect_identical(nrow(d2), sum(xor(d2$v1, d2$v2)))
})

test_that("get_version_diffs() passes variable_type and periods through", {
  d <- get_version_diffs("diabetes_type2", c(1, 2), variable_type = "outcome", periods = TRUE)
  # Diabetes is condition-only, so outcome falls back to the condition codes
  expect_identical(sum(d$v2), nrow(get_diabetes_type2_v2_codes(variable_type = "outcome")))
  expect_true("E11.A" %in% d$code)
})

test_that("ASCVD component conditions are recognised", {
  expect_identical(peridefs:::.as_code_spec(get_chd_v1_codes)$condition, "chd")
  expect_identical(peridefs:::.as_code_spec(get_stroke_v1_defs)$condition, "stroke")
  expect_error(get_version_diffs("chd"), "only one version")
})

test_that("get_version_diffs() rejects comparisons that aren't legitimate", {
  # same version twice (in any spelling)
  expect_error(get_version_diffs("diabetes_type2", c(1, 1)), "only once")
  expect_error(get_version_diffs("diabetes_type2", c("v1", "1")), "only once")
  # fewer than two versions
  expect_error(get_version_diffs("diabetes_type2", 1), "at least two")
  expect_error(get_version_diffs("hypertension"), "only one version")
  # versions that don't exist
  expect_error(get_version_diffs("diabetes_type2", c(1, 3)), "no version")
  # malformed versions
  expect_error(get_version_diffs("diabetes_type2", c(1, 2.5)), "version labels")
  expect_error(get_version_diffs("diabetes_type2", c("v1", "latest")), "version labels")
  expect_error(get_version_diffs("diabetes_type2", c(0, 1)), "version labels")
  expect_error(get_version_diffs("diabetes_type2", TRUE), "version labels")
  # bad or unknown condition
  expect_error(get_version_diffs("not_a_condition"), "Unknown condition")
  expect_error(get_version_diffs(c("diabetes_type1", "diabetes_type2")), "single condition")
  expect_error(get_version_diffs(get_diabetes_type2_v1_codes), "single condition")
  expect_error(get_version_diffs(), "single condition")
  expect_error(get_version_diffs("ascvd"), "Unknown condition")
})

# ---- format = "flextable" -----------------------------------------------------

test_that("format = 'flextable' returns a table shaded like a GitHub diff", {
  skip_if_not_installed("flextable")
  d  <- get_version_diffs("diabetes_type2")
  ft <- get_version_diffs("diabetes_type2", format = "flextable")
  expect_s3_class(ft, "flextable")
  expect_identical(names(ft$body$dataset),
                   c("definition", "code", "v1", "v2", "type", "change"))
  expect_identical(nrow(ft$body$dataset), nrow(d))

  bg  <- ft$body$styles$cells$background.color$data
  cat <- peridefs:::.diff_category(d, c("v1", "v2"))
  cols <- peridefs:::.diff_colors
  # every cell of a row takes its row colour; the change cell the stronger one
  for (j in c("definition", "code", "v1", "v2", "type")) {
    expect_identical(unname(bg[, j]), unname(cols$row[cat]))
  }
  expect_identical(unname(bg[, "change"]), unname(cols$change[cat]))
  # spot checks: E11A added (green), 250 removed (red), E119 unchanged (grey)
  code <- ft$body$dataset$code
  expect_identical(unname(bg[code == "E11A", "code"]), "#dafbe1")
  expect_identical(unname(bg[code == "250",  "code"]), "#ffebe9")
  expect_identical(unname(bg[code == "E119", "code"]), "#eff1f3")
})

test_that("flextable output handles changes_only and multi-version 'mixed' rows", {
  skip_if_not_installed("flextable")
  ft <- get_version_diffs("diabetes_type2", changes_only = TRUE, format = "flextable")
  expect_false(any(ft$body$dataset$change == "unchanged"))

  ft3 <- peridefs:::.version_diffs_flextable(.diffs(.toy_v1, .toy_v2, .toy_v3))
  expect_identical(names(ft3$body$dataset),
                   c("definition", "code", "v1", "v2", "v3", "type", "change"))
  bg <- ft3$body$styles$cells$background.color$data
  # A01 unchanged, A02 removed, A03 removed then re-added (mixed), A04 added
  expect_identical(unname(bg[, "code"]),
                   unname(peridefs:::.diff_colors$row[c("unchanged", "removed", "mixed", "added")]))
})

test_that("format = 'flextable' errors clearly when flextable is not installed", {
  local_mocked_bindings(.has_flextable = function() FALSE)
  expect_error(get_version_diffs("diabetes_type2", format = "flextable"),
               "requires the flextable package")
  expect_s3_class(get_version_diffs("diabetes_type2"), "tbl_df")
  expect_error(get_version_diffs("diabetes_type2", format = "html"))
})

# ---- list_versions() ----------------------------------------------------------

test_that("list_versions() lists every exported versioned condition getter", {
  lv <- list_versions()
  expect_identical(names(lv), c("condition", "version", "label", "codes_function",
                                "defs_function", "n_codes", "date", "summary"))
  getters <- grep("^get_.+_v[0-9]+_codes$", getNamespaceExports("peridefs"), value = TRUE)
  expect_setequal(sub("\\(\\)$", "", lv$codes_function), getters)
})

test_that("list_versions(condition) shows each version with its history", {
  lv <- list_versions("diabetes_type2")
  expect_identical(lv$version, c("v1", "v2"))
  expect_identical(lv$codes_function,
                   c("get_diabetes_type2_v1_codes()", "get_diabetes_type2_v2_codes()"))
  expect_identical(lv$n_codes, c(nrow(get_diabetes_type2_v1_codes()),
                                 nrow(get_diabetes_type2_v2_codes())))
  expect_true(is.na(lv$summary[1]))
  expect_false(is.na(lv$summary[2]))
  expect_error(list_versions("not_a_condition"), "Unknown condition")
})

# ---- Version history ----------------------------------------------------------

test_that("every released version after v1 has a version-history entry, and vice versa", {
  log <- peridefs:::.version_log
  later <- .released_condition_specs[!grepl("_v1$", .released_condition_specs)]
  logged <- paste0(log$condition, "_", log$version)
  expect(all(later %in% logged), paste0(
    "No .version_log entry (R/changelog.R) for: ",
    paste(setdiff(later, logged), collapse = ", ")
  ))
  expect(all(logged %in% .released_condition_specs), paste0(
    ".version_log has entries for unreleased versions: ",
    paste(setdiff(logged, .released_condition_specs), collapse = ", ")
  ))
  expect_false(anyNA(log))
  expect_false(any(grepl("%", c(log$summary, log$rationale), fixed = TRUE)))
})

test_that("the generated version history lists the exact codes that changed", {
  md <- peridefs:::.rd_version_history("diabetes_type2")
  expect_match(md, "**v1**: initial version", fixed = TRUE)
  expect_match(md, "**v2** (2026-10-22", fixed = TRUE)
  expect_match(md, "Added 1 code:\n", fixed = TRUE)
  expect_match(md, "dx_icd10 (1): `E11A`", fixed = TRUE)
  removed <- get_version_diffs("diabetes_type2", c(1, 2))
  removed <- removed[removed$v1 & !removed$v2, ]
  expect_match(md, paste0("Removed ", nrow(removed), " codes:"), fixed = TRUE)
  for (cd in removed$code) expect_match(md, paste0("`", cd, "`"), fixed = TRUE)
})
