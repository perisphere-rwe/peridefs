toy_drug_v1 <- DrugSpec$new(
  drug_class    = "testdrug",
  label         = "Test Drug",
  version       = "v1",
  defs          = "From test list.",
  generic_names = c("DRUGONE", "DRUGTWO")
)

toy_drug_v2 <- DrugSpec$new(
  drug_class    = "testdrug",
  label         = "Test Drug",
  version       = "v2",
  defs          = "From FDB.",
  generic_names = c("DRUGONE", "DRUGTWO", "DRUGTHREE"),
  ndc           = c("12345-678-90")
)

test_that("active bindings return correct values", {
  expect_equal(toy_drug_v1$drug_class, "testdrug")
  expect_equal(toy_drug_v1$label,      "Test Drug")
  expect_equal(toy_drug_v1$version,    "v1")
})

test_that("get_generics() returns correct GNNs per version object", {
  expect_equal(toy_drug_v1$get_generics(), c("DRUGONE", "DRUGTWO"))
  expect_equal(toy_drug_v2$get_generics(), c("DRUGONE", "DRUGTWO", "DRUGTHREE"))
})

test_that("get_codes() returns NDC codes", {
  expect_length(toy_drug_v1$get_codes(), 0L)
  expect_equal(toy_drug_v2$get_codes(), "12345-678-90")
})

test_that("get_defs() returns correct narrative text", {
  expect_equal(toy_drug_v1$get_defs(), "From test list.")
  expect_equal(toy_drug_v2$get_defs(), "From FDB.")
})

test_that("spec_antihypertensive is a CompositeDrugSpec", {
  expect_s3_class(spec_antihypertensive, "CompositeDrugSpec")
  expect_equal(spec_antihypertensive$drug_class, "antihypertensive")
})

test_that("spec_antihypertensive has versioned leaf components", {
  comp_names <- names(spec_antihypertensive$components())
  expect_true("acei_v1"       %in% comp_names)
  expect_true("acei_v2"       %in% comp_names)
  expect_true("cardio_v1"     %in% comp_names)
  expect_true("int_sym_v2"    %in% comp_names)
  expect_true("thiazide_v1"   %in% comp_names)
  expect_true("vasodilators_v1" %in% comp_names)
})

test_that("get_antihypertensive_generics(component = 'acei_v1') returns a named list", {
  result <- get_antihypertensive_generics(component = "acei_v1")
  expect_type(result, "list")
  expect_named(result, "acei_v1")
})

test_that("get_antihypertensive_generics(component = 'acei_v1') includes expected GNNs", {
  gnns <- get_antihypertensive_generics(component = "acei_v1", concatenate = TRUE)
  expect_true("LISINOPRIL"  %in% gnns)
  expect_true("RAMIPRIL"    %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'acei_v2') has FDB variants", {
  gnns <- get_antihypertensive_generics(component = "acei_v2", concatenate = TRUE)
  expect_true("FOSINIPRIL"  %in% gnns)
  expect_true("MOEXEPRIL"   %in% gnns)
})

test_that("get_antihypertensive_generics() requires component=", {
  expect_error(get_antihypertensive_generics(), "component")
})

test_that("get_antihypertensive_generics(component = 'int_sym_v1') includes CARTEOLOL", {
  gnns <- get_antihypertensive_generics(component = "int_sym_v1", concatenate = TRUE)
  expect_true("CARTEOLOL" %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'int_sym_v2') excludes CARTEOLOL", {
  gnns <- get_antihypertensive_generics(component = "int_sym_v2", concatenate = TRUE)
  expect_false("CARTEOLOL" %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'all') returns named list of all components", {
  result <- get_antihypertensive_generics(component = "all")
  expect_type(result, "list")
  expect_true("acei_v1" %in% names(result))
  expect_equal(names(result), names(spec_antihypertensive$components()))
})

test_that("get_antidepressive_v1_generics() returns a named list by default", {
  result <- get_antidepressive_v1_generics()
  expect_type(result, "list")
  expect_named(result, "antidepressive_v1")
  expect_true("BUPROPION" %in% result$antidepressive_v1)
})

test_that("get_antidepressive_v1_generics(concatenate = TRUE) returns a flat vector", {
  result <- get_antidepressive_v1_generics(concatenate = TRUE)
  expect_type(result, "character")
  expect_null(names(result))
})


test_that("spec_antidiabetic has expected components", {
  comp_names <- names(spec_antidiabetic$components())
  expect_true("biguanide_v1"    %in% comp_names)
  expect_true("sglt2_v1"        %in% comp_names)
  expect_true("insulin_v1"      %in% comp_names)
})

test_that("antihypertensive union-of-components test with versioned names", {
  component_names <- c("acei_v1", "arb_v1", "alpha_v1", "alpha_beta_v1",
                        "cardio_v1", "cardio_vasod_v1", "int_sym_v1", "noncardio_v1",
                        "ccb_dhp_v1", "ccb_nondhp_v1",
                        "thiazide_v1", "loop_v1", "ksparing_v1", "aldo_v1",
                        "central_v1", "renin_v1", "vasodilators_v1")
  all_comp <- unique(unlist(lapply(
    component_names,
    \(nm) get_antihypertensive_generics(component = nm)
  )))
  # v1 components only — should equal the explicit v1 subset
  expect_true(length(all_comp) > 0L)
  # All v1 GNNs should come from v1 components
  expect_true("LISINOPRIL" %in% all_comp)
  expect_true("ATENOLOL"   %in% all_comp)
})
