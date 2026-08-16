test_that("get_hypertension_v1_defs() returns a non-empty character vector", {
  result <- get_hypertension_v1_defs()
  expect_type(result, "character")
  expect_true(length(result) > 0L)
  expect_true(all(nchar(result) > 0L))
})

test_that("get_hypertension_v1_defs() includes the medication criterion", {
  # Versions were collapsed (issue #4); get_hypertension_v1_defs() now returns the
  # more complete (formerly v2) narrative, which mentions spec_hypertension.
  expect_true(any(grepl("spec_hypertension", get_hypertension_v1_defs())))
})

test_that("get_hypertension_v1_defs(variable_type = 'outcome') returns NULL", {
  expect_null(get_hypertension_v1_defs(variable_type = "outcome"))
})

test_that("get_hypertension_meds_labels(component = 'acei_v1') returns a one-row tibble", {
  result <- get_hypertension_meds_labels(component = "acei_v1")
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("name", "label"))
  expect_equal(result$name, "acei_v1")
  expect_equal(result$label, "ACE Inhibitors")
})

test_that("get_hypertension_meds_labels() with no component returns every component", {
  result <- get_hypertension_meds_labels()
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("name", "label"))
  expect_true("acei_v1" %in% result$name)
  expect_equal(result$label[result$name == "acei_v1"], "ACE Inhibitors")
})

test_that("get_hypertension_meds_labels() has no version column", {
  result <- get_hypertension_meds_labels()
  expect_false("version" %in% names(result))
})

test_that("get_defs() rejects non-spec objects", {
  expect_snapshot(error = TRUE, get_defs("not a spec"))
})

test_that("get_defs() on a CompositeDrugSpec dispatches to get_meds_labels()", {
  result <- get_defs(spec_hypertension)
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("name", "label"))
})
