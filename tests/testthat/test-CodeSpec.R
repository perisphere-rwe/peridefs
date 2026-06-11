toy_spec <- CodeSpec$new(
  condition = "test",
  label     = "Test Condition",
  version   = "v1",
  defs  = list(condition = "v1 condition def", outcome = NULL),
  codes = list(
    dx_icd9 = list(
      codes       = c("4010", "4011", "4019"),

      condition   = c(TRUE, TRUE, FALSE),
      outcome     = c(FALSE, FALSE, TRUE),
      exclusions  = NULL
    ),
    dx_icd10 = list(
      codes       = c("I10"),

      condition   = c(TRUE),
      outcome     = c(TRUE),
      exclusions  = NULL
    )
  )
)

test_that("keys() returns correct keys", {
  expect_equal(toy_spec$keys(), c("dx_icd9", "dx_icd10"))
})

test_that("active bindings return correct values", {
  expect_equal(toy_spec$condition, "test")
  expect_equal(toy_spec$label,     "Test Condition")
  expect_equal(toy_spec$version,   "v1")
})

test_that("get_codes() returns named list by default", {
  result <- toy_spec$get_codes()
  expect_type(result, "list")
  expect_named(result, c("dx_icd9", "dx_icd10"))
})

test_that("get_codes() filters by variable_type = 'condition'", {
  result <- toy_spec$get_codes(variable_type = "condition")
  # dx_icd9: condition flags are TRUE, TRUE, FALSE -> 2 codes
  expect_equal(result$dx_icd9, c("4010", "4011"))
})

test_that("get_codes() filters by variable_type = 'outcome'", {
  result <- toy_spec$get_codes(variable_type = "outcome")
  expect_equal(result$dx_icd9, c("4019"))
})

test_that("get_codes() filters by code_type", {
  result <- toy_spec$get_codes(code_type = "dx_icd9")
  expect_named(result, "dx_icd9")
})

test_that("get_codes() applies periods correctly", {
  result <- toy_spec$get_codes(code_type = "dx_icd9",
                                variable_type = "condition", periods = TRUE)
  expect_equal(result$dx_icd9, c("401.0", "401.1"))
})

test_that("get_codes() returns tibble when requested", {
  result <- toy_spec$get_codes(format = "tibble")
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("code_type", "code", "variable_type"))
})

test_that("get_defs() returns correct text", {
  expect_equal(toy_spec$get_defs("condition"), "v1 condition def")
  expect_null(toy_spec$get_defs("outcome"))
})

test_that("spec_htn_v1 is a CodeSpec with expected structure", {
  expect_s3_class(spec_htn_v1, "CodeSpec")
  expect_equal(spec_htn_v1$condition, "htn")
  expect_equal(spec_htn_v1$version,   "v1")
  expect_true(all(c("dx_icd9", "dx_icd10") %in% spec_htn_v1$keys()))
})

test_that("spec_htn_v1 ICD-9 codes are non-empty and short-format", {
  codes <- spec_htn_v1$get_codes(code_type = "dx_icd9")
  expect_true(length(codes$dx_icd9) > 0L)
  expect_true(all(!grepl("\\.", codes$dx_icd9)))
})

test_that("spec_htn_v1 ICD-10 codes include I10", {
  codes <- spec_htn_v1$get_codes(code_type = "dx_icd10")
  expect_true("I10" %in% codes$dx_icd10)
})

test_that("spec_htn_v1 outcome codes are empty (HTN is condition-only)", {
  codes <- spec_htn_v1$get_codes(variable_type = "outcome")
  expect_true(all(vapply(codes, length, integer(1L)) == 0L))
})

test_that("spec_htn_v1 and spec_htn_v2 have same codes but different defs", {
  expect_equal(spec_htn_v1$get_codes(), spec_htn_v2$get_codes())
  expect_false(identical(spec_htn_v1$get_defs("condition"),
                          spec_htn_v2$get_defs("condition")))
})
