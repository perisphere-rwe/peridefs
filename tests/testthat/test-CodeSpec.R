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

# helper: pull codes of a given type out of a get_codes() tibble
.codes_of <- function(df, type) df$code[df$type == type]

test_that("keys() returns correct keys", {
  expect_equal(toy_spec$keys(), c("dx_icd9", "dx_icd10"))
})

test_that("active bindings return correct values", {
  expect_equal(toy_spec$condition, "test")
  expect_equal(toy_spec$label,     "Test Condition")
  expect_equal(toy_spec$version,   "v1")
})

test_that("get_codes() returns a tibble with the expected columns", {
  result <- toy_spec$get_codes()
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("type", "code", "priority", "version"))
})

test_that("get_codes() filters by variable_type = 'condition'", {
  result <- toy_spec$get_codes(variable_type = "condition")
  # dx_icd9: condition flags are TRUE, TRUE, FALSE -> 2 codes
  expect_equal(sort(.codes_of(result, "dx_icd9")), c("4010", "4011"))
})

test_that("get_codes() filters by variable_type = 'outcome'", {
  result <- toy_spec$get_codes(variable_type = "outcome")
  expect_equal(.codes_of(result, "dx_icd9"), c("4019"))
})

test_that("get_codes() filters by code_type", {
  result <- toy_spec$get_codes(code_type = "dx_icd9")
  expect_true(all(result$type == "dx_icd9"))
})

test_that("get_codes() applies periods correctly", {
  result <- toy_spec$get_codes(code_type = "dx_icd9", variable_type = "condition",
                               periods = TRUE)
  expect_equal(sort(.codes_of(result, "dx_icd9")), c("401.0", "401.1"))
})

test_that("get_codes() priority column defaults to 1 and filters correctly", {
  result <- toy_spec$get_codes()
  expect_true(all(result$priority == 1L))
  none <- toy_spec$get_codes(priority = 2)
  expect_equal(nrow(none), 0L)
})

test_that("get_defs() returns correct text", {
  expect_equal(toy_spec$get_defs("condition"), "v1 condition def")
  expect_null(toy_spec$get_defs("outcome"))
})

test_that("spec_hypertension_v1 is a CodeSpec with expected structure", {
  expect_s3_class(spec_hypertension_v1, "CodeSpec")
  expect_equal(spec_hypertension_v1$condition, "hypertension")
  expect_equal(spec_hypertension_v1$version,   "v1")
  expect_true(all(c("dx_icd9", "dx_icd10") %in% spec_hypertension_v1$keys()))
})

test_that("spec_hypertension_v1 ICD-9 codes are non-empty and short-format", {
  codes <- .codes_of(spec_hypertension_v1$get_codes(code_type = "dx_icd9"), "dx_icd9")
  expect_true(length(codes) > 0L)
  expect_true(all(!grepl("\\.", codes)))
})

test_that("spec_hypertension_v1 ICD-10 codes include I10", {
  codes <- .codes_of(spec_hypertension_v1$get_codes(code_type = "dx_icd10"), "dx_icd10")
  expect_true("I10" %in% codes)
})

test_that("spec_hypertension_v1 outcome falls back to condition codes (hypertension is condition-only)", {
  outcome_result   <- spec_hypertension_v1$get_codes(variable_type = "outcome")
  condition_result <- spec_hypertension_v1$get_codes(variable_type = "condition")
  expect_equal(outcome_result, condition_result)
})

test_that("spec_hypertension_v1's condition def includes the medication criterion", {
  # Versions were collapsed (issue #4); spec_hypertension_v1 now carries the more
  # complete (formerly v2) narrative, which mentions spec_hypertension.
  expect_true(any(grepl("spec_hypertension", spec_hypertension_v1$get_defs("condition"))))
})
