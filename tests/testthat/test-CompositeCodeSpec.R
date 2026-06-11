# Toy composite: flat component structure with two small CodeSpecs
toy_a <- CodeSpec$new(
  condition = "comp_a", label = "Component A", version = "v1",
  defs  = list(condition = "A condition def", outcome = "A outcome def"),
  codes = list(
    dx_icd9  = list(codes = c("4010", "4011"),
                    condition = c(TRUE, TRUE), outcome = c(FALSE, FALSE),
                    exclusions = NULL),
    dx_icd10 = list(codes = c("I10"),
                    condition = c(TRUE), outcome = c(TRUE), exclusions = NULL)
  )
)

toy_b <- CodeSpec$new(
  condition = "comp_b", label = "Component B", version = "v1",
  defs  = list(condition = "B condition def", outcome = "B outcome def"),
  codes = list(
    dx_icd9  = list(codes = c("4011", "4019"),
                    condition = c(TRUE, FALSE), outcome = c(FALSE, TRUE),
                    exclusions = NULL),
    hcpcs    = list(codes = c("G0001"),
                    condition = c(TRUE), outcome = c(TRUE), exclusions = NULL)
  )
)

toy_composite <- CompositeCodeSpec$new(
  condition  = "toy_comp",
  label      = "Toy Composite",
  defs       = "Toy composite of A and B.",
  components = list(a_v1 = toy_a, b_v1 = toy_b)
)

# ---- Structure tests --------------------------------------------------------

test_that("CompositeCodeSpec has correct class and fields", {
  expect_s3_class(toy_composite, "CompositeCodeSpec")
  expect_equal(toy_composite$condition, "toy_comp")
  expect_equal(toy_composite$label,     "Toy Composite")
})

test_that("components() returns flat named list", {
  comps <- toy_composite$components()
  expect_type(comps, "list")
  expect_equal(sort(names(comps)), c("a_v1", "b_v1"))
})

test_that("keys() returns union of component keys", {
  keys <- toy_composite$keys()
  expect_true("dx_icd9"  %in% keys)
  expect_true("hcpcs"    %in% keys)
  expect_true("dx_icd10" %in% keys)
})

# ---- get_codes() tests — component required ---------------------------------

test_that("get_codes() errors without component=", {
  expect_error(toy_composite$get_codes(), "component")
})

test_that("get_codes(component = 'a_v1') returns component A codes", {
  result <- toy_composite$get_codes(component = "a_v1", variable_type = "condition")
  expect_equal(sort(result$dx_icd9), c("4010", "4011"))
  expect_equal(result$dx_icd10, "I10")
})

test_that("get_codes(component = 'b_v1') returns component B codes", {
  result <- toy_composite$get_codes(component = "b_v1", variable_type = "condition")
  expect_equal(result$dx_icd9, c("4011"))
  expect_equal(result$hcpcs,   c("G0001"))
})

test_that("get_codes() respects variable_type filtering", {
  cond <- toy_composite$get_codes(component = "b_v1", variable_type = "condition")
  out  <- toy_composite$get_codes(component = "b_v1", variable_type = "outcome")
  expect_true("4011" %in% cond$dx_icd9)
  expect_false("4019" %in% cond$dx_icd9)
  expect_true("4019" %in% out$dx_icd9)
})

test_that("get_codes() code_type filter works", {
  result <- toy_composite$get_codes(component = "a_v1", code_type = "dx_icd9",
                                     variable_type = "condition")
  expect_named(result, "dx_icd9")
})

test_that("get_codes() returns tibble when requested", {
  result <- toy_composite$get_codes(component = "a_v1", format = "tibble")
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("code_type", "code", "variable_type"))
})

test_that("get_codes() applies periods to ICD codes", {
  result <- toy_composite$get_codes(component = "a_v1", code_type = "dx_icd9",
                                     variable_type = "condition", periods = TRUE)
  expect_true(all(grepl("\\.", result$dx_icd9)))
})

# ---- get_defs() tests -------------------------------------------------------

test_that("get_defs() errors without component=", {
  expect_error(toy_composite$get_defs(), "component")
})

test_that("get_defs() returns correct narrative for component", {
  expect_equal(toy_composite$get_defs("a_v1", "condition"), "A condition def")
  expect_equal(toy_composite$get_defs("b_v1", "outcome"),   "B outcome def")
})

# ---- ASCVD integration tests ------------------------------------------------

test_that("spec_ascvd is a CompositeCodeSpec", {
  expect_s3_class(spec_ascvd, "CompositeCodeSpec")
  expect_equal(spec_ascvd$condition, "ascvd")
})

test_that("spec_ascvd has expected components including chd_v1, hf_v1, isch_stroke_v1", {
  comp_names <- names(spec_ascvd$components())
  expect_true("chd_v1"                 %in% comp_names)
  expect_true("cerebrovasc_disease_v1" %in% comp_names)
})

test_that("get_ascvd_codes(component = 'chd_v1') returns CHD condition codes", {
  result <- get_ascvd_codes(component = "chd_v1", variable_type = "condition")
  expect_type(result, "list")
  expect_true("dx_icd9"  %in% names(result))
  expect_true("dx_icd10" %in% names(result))
  expect_true("hcpcs"    %in% names(result))
})

test_that("get_ascvd_codes() errors without component=", {
  expect_error(get_ascvd_codes(), "component")
})

test_that("get_ascvd_defs() errors without component=", {
  expect_error(get_ascvd_defs(), "component")
})

test_that("get_ascvd_defs(component = 'chd_v1') returns a non-empty character vector", {
  result <- get_ascvd_defs(component = "chd_v1", variable_type = "condition")
  expect_type(result, "character")
  expect_true(length(result) > 0L)
  expect_true(all(nchar(result) > 0L))
})

test_that("chd_v1 codes are a subset of chd_v1 condition codes directly", {
  ascvd_chd <- get_ascvd_codes(component = "chd_v1", code_type = "dx_icd9",
                                 variable_type = "condition")$dx_icd9
  direct_chd <- spec_ascvd$components()$chd_v1$get_codes(
    code_type = "dx_icd9", variable_type = "condition"
  )$dx_icd9
  expect_equal(ascvd_chd, direct_chd)
})

