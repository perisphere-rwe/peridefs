
# ---- code_spec() --------------------------------------------------------

test_that("code_spec() creates a CodeSpec with correct structure", {
  spec <- code_spec(
    condition = "test",
    label     = "Test",
    version   = "v1",
    codes     = list(dx_icd9 = c("4010", "4011"))
  )
  expect_s3_class(spec, "CodeSpec")
  expect_equal(spec$condition, "test")
  expect_equal(spec$version, "v1")
  codes <- spec$get_codes()
  expect_equal(codes$dx_icd9, c("4010", "4011"))
})

test_that("code_spec() sets both flags TRUE when codes is a plain vector", {
  spec  <- code_spec("t", "T", codes = list(dx_icd9 = c("4010")))
  priv  <- spec$.__enclos_env__$private
  kd    <- priv$.codes$dx_icd9
  expect_true(all(kd$condition))
  expect_true(all(kd$outcome))
})

test_that("code_spec() version argument is stored", {
  spec <- code_spec("t", "T", version = "v3")
  expect_equal(spec$version, "v3")
})

# ---- drug_spec() --------------------------------------------------------

test_that("drug_spec() creates a DrugSpec with correct structure", {
  spec <- drug_spec(
    drug_class    = "mymed",
    label         = "My Med",
    generic_names = c("DRUGONE", "DRUGTWO")
  )
  expect_s3_class(spec, "DrugSpec")
  expect_equal(spec$get_generics(), c("DRUGONE", "DRUGTWO"))
  expect_length(spec$get_codes(), 0L)
})

# ---- add_codes() --------------------------------------------------------

test_that("add_codes() does not modify the original spec", {
  original_len <- length(spec_htn_v1$get_codes()$dx_icd10)
  add_codes(spec_htn_v1, dx_icd10 = c("I119"))
  expect_equal(length(spec_htn_v1$get_codes()$dx_icd10), original_len)
})

test_that("add_codes() appends new codes to an existing key", {
  modified  <- add_codes(spec_htn_v1, dx_icd10 = c("I119"))
  new_codes <- modified$get_codes()$dx_icd10
  expect_true("I119" %in% new_codes)
})

test_that("add_codes() deduplicates codes already present", {
  existing <- spec_htn_v1$get_codes()$dx_icd10[[1]]
  modified  <- add_codes(spec_htn_v1, dx_icd10 = existing)
  expect_equal(
    length(modified$get_codes()$dx_icd10),
    length(spec_htn_v1$get_codes()$dx_icd10)
  )
})

test_that("add_codes() creates a new key when key does not exist", {
  modified <- add_codes(spec_htn_v1, hcpcs = c("G0001"))
  expect_true("hcpcs" %in% modified$keys())
})

# ---- remove_codes() -----------------------------------------------------

test_that("remove_codes() does not modify the original spec", {
  original <- spec_htn_v1$get_codes()$dx_icd9
  remove_codes(spec_htn_v1, dx_icd9 = original[1L])
  expect_equal(spec_htn_v1$get_codes()$dx_icd9, original)
})

test_that("remove_codes() removes specified codes", {
  first_code <- spec_htn_v1$get_codes()$dx_icd9[[1L]]
  modified   <- remove_codes(spec_htn_v1, dx_icd9 = first_code)
  expect_false(first_code %in% modified$get_codes()$dx_icd9)
})

test_that("remove_codes() silently ignores unknown keys", {
  expect_no_error(remove_codes(spec_htn_v1, no_such_key = c("X")))
})

# ---- modify_code_spec() -------------------------------------------------

test_that("modify_code_spec() updates label without modifying original", {
  modified <- modify_code_spec(spec_htn_v1, label = "HTN New Label")
  expect_equal(modified$label, "HTN New Label")
  expect_equal(spec_htn_v1$label, "Hypertension")
})

test_that("modify_code_spec() updates defs", {
  modified <- modify_code_spec(spec_htn_v1, defs = list(condition = "new def", outcome = NULL))
  expect_equal(modified$get_defs("condition"), "new def")
  expect_equal(spec_htn_v1$get_defs("condition"),  spec_htn_v1$get_defs("condition"))
})

# ---- modify_drug_spec() -------------------------------------------------

test_that("modify_drug_spec() updates generic_names on a leaf DrugSpec", {
  # Get a leaf spec from antihypertensive components
  acei_v1   <- spec_antihypertensive$components()$acei_v1
  original  <- acei_v1$get_generics()
  modified  <- modify_drug_spec(acei_v1, generic_names = c("ONLY_ONE"))
  expect_equal(modified$get_generics(), "ONLY_ONE")
  expect_equal(acei_v1$get_generics(), original)
})
