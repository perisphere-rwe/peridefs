test_that("get_htn_v1_codes() returns a named list by default", {
  result <- get_htn_v1_codes()
  expect_type(result, "list")
  expect_true(length(result) > 0L)
})

test_that("get_htn_v1_codes() result keys are bare code types", {
  result <- get_htn_v1_codes()
  expect_equal(sort(names(result)), c("dx_icd10", "dx_icd9"))
})

test_that("get_htn_v1_codes() code_type filter works", {
  result <- get_htn_v1_codes(code_type = "dx_icd9")
  expect_equal(names(result), "dx_icd9")
})

test_that("get_htn_v1_codes() periods = TRUE adds decimal points to 4+ char codes", {
  result <- get_htn_v1_codes(code_type = "dx_icd9", periods = TRUE)
  codes  <- unlist(result)
  expect_true(all(grepl("\\.", codes[nchar(codes) > 3L])))
})

test_that("get_htn_v1_codes() format = 'tibble' returns a tibble", {
  result <- get_htn_v1_codes(format = "tibble")
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("code_type", "code", "variable_type"))
})

test_that("get_htn_v1_codes() and get_htn_v2_codes() return identical code sets", {
  v1 <- get_htn_v1_codes()
  v2 <- get_htn_v2_codes()
  expect_equal(v1, v2)
})

test_that("get_htn_v1_codes() outcome variable_type returns empty sets", {
  result <- get_htn_v1_codes(variable_type = "outcome")
  expect_true(all(vapply(result, length, integer(1L)) == 0L))
})


# ---- component= argument tests ----

test_that("get_ascvd_codes(component = 'chd_v1') returns non-empty codes", {
  result <- get_ascvd_codes(component = "chd_v1")
  expect_type(result, "list")
  expect_true(length(unlist(result)) > 0L)
})

test_that("get_ascvd_codes(component = 'cerebrovasc_disease_v1') returns codes", {
  result <- get_ascvd_codes(component = "cerebrovasc_disease_v1")
  expect_type(result, "list")
  expect_true(length(unlist(result)) > 0L)
})

test_that("get_antihypertensive_generics(component = 'acei_v1') returns GNNs", {
  result <- get_antihypertensive_generics(component = "acei_v1")
  expect_type(result, "character")
  expect_true(length(result) > 0L)
})


test_that("component= required for composite — error without it", {
  expect_error(get_ascvd_codes(), "component")
  expect_error(get_antihypertensive_generics(), "component")
})

test_that("component= on a non-composite spec throws an informative error", {
  expect_error(
    get_htn_v1_codes(component = "anything"),
    "component"
  )
})

