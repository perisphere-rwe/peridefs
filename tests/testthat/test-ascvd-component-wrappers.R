# ---- ASCVD component wrapper functions ------------------------------------
#
# get_chd_v1_codes(), get_stroke_v1_codes(), get_lead_pad_v1_codes(),
# get_cerebrovasc_disease_v1_codes() and their _defs() counterparts are thin
# wrappers around get_ascvd_codes()/get_ascvd_defs() with `component` pinned.
# These tests confirm each wrapper is equivalent to the underlying composite
# call it forwards to.

test_that("get_chd_v1_codes() matches get_ascvd_codes(component = 'chd_v1')", {
  expect_equal(get_chd_v1_codes(), get_ascvd_codes(component = "chd_v1"))
})

test_that("get_stroke_v1_codes() matches get_ascvd_codes(component = 'stroke_v1')", {
  expect_equal(get_stroke_v1_codes(), get_ascvd_codes(component = "stroke_v1"))
})

test_that("get_lead_pad_v1_codes() matches get_ascvd_codes(component = 'lead_pad_v1')", {
  expect_equal(get_lead_pad_v1_codes(), get_ascvd_codes(component = "lead_pad_v1"))
})

test_that("get_cerebrovasc_disease_v1_codes() matches get_ascvd_codes(component = 'cerebrovasc_disease_v1')", {
  expect_equal(
    get_cerebrovasc_disease_v1_codes(),
    get_ascvd_codes(component = "cerebrovasc_disease_v1")
  )
})

test_that("ASCVD component code wrappers forward extra arguments", {
  expect_equal(
    get_chd_v1_codes(code_type = "dx_icd9", variable_type = "outcome"),
    get_ascvd_codes(component = "chd_v1", code_type = "dx_icd9", variable_type = "outcome")
  )
  expect_equal(
    get_stroke_v1_codes(periods = TRUE),
    get_ascvd_codes(component = "stroke_v1", periods = TRUE)
  )
})

test_that("get_chd_v1_defs() matches get_ascvd_defs(component = 'chd_v1')", {
  expect_equal(get_chd_v1_defs(), get_ascvd_defs(component = "chd_v1"))
})

test_that("get_stroke_v1_defs() matches get_ascvd_defs(component = 'stroke_v1')", {
  expect_equal(get_stroke_v1_defs(), get_ascvd_defs(component = "stroke_v1"))
})

test_that("get_lead_pad_v1_defs() matches get_ascvd_defs(component = 'lead_pad_v1')", {
  expect_equal(get_lead_pad_v1_defs(), get_ascvd_defs(component = "lead_pad_v1"))
})

test_that("get_cerebrovasc_disease_v1_defs() matches get_ascvd_defs(component = 'cerebrovasc_disease_v1')", {
  expect_equal(
    get_cerebrovasc_disease_v1_defs(),
    get_ascvd_defs(component = "cerebrovasc_disease_v1")
  )
})

test_that("ASCVD component wrappers return non-empty results", {
  expect_true(nrow(get_chd_v1_codes()) > 0L)
  expect_true(nrow(get_stroke_v1_codes()) > 0L)
  expect_true(nrow(get_lead_pad_v1_codes()) > 0L)
  expect_true(nrow(get_cerebrovasc_disease_v1_codes()) > 0L)
})
