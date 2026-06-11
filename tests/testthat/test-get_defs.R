test_that("get_htn_v1_defs() returns a non-empty character vector", {
  result <- get_htn_v1_defs()
  expect_type(result, "character")
  expect_true(length(result) > 0L)
  expect_true(all(nchar(result) > 0L))
})

test_that("get_htn_v1_defs() and get_htn_v2_defs() differ", {
  expect_false(identical(get_htn_v1_defs(), get_htn_v2_defs()))
})

test_that("get_htn_v1_defs(variable_type = 'outcome') returns NULL", {
  expect_null(get_htn_v1_defs(variable_type = "outcome"))
})

test_that("get_antihypertensive_defs(component = 'acei_v1') returns a non-empty string", {
  result <- get_antihypertensive_defs(component = "acei_v1")
  expect_type(result, "character")
  expect_gt(nchar(result), 0L)
})

test_that("get_antihypertensive_defs() errors without component=", {
  expect_error(get_antihypertensive_defs(), "component")
})

test_that("get_defs() rejects non-spec objects", {
  expect_snapshot(error = TRUE, get_defs("not a spec"))
})
