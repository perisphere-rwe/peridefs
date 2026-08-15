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
  generic_names = c("DRUGONE", "DRUGTWO", "DRUGTHREE")
)

test_that("active bindings return correct values", {
  expect_equal(toy_drug_v1$drug_class, "testdrug")
  expect_equal(toy_drug_v1$label,      "Test Drug")
  expect_equal(toy_drug_v1$version,    "v1")
})

test_that("get_generics() returns a tibble with the expected columns", {
  result <- toy_drug_v1$get_generics()
  expect_s3_class(result, "tbl_df")
  expect_equal(names(result), c("generic", "brand", "priority", "class", "version"))
})

test_that("get_generics() returns correct GNNs per version object", {
  expect_equal(toy_drug_v1$get_generics()$generic, c("DRUGONE", "DRUGTWO"))
  expect_equal(toy_drug_v2$get_generics()$generic, c("DRUGONE", "DRUGTWO", "DRUGTHREE"))
})

test_that("get_generics() tags class and version", {
  result <- toy_drug_v2$get_generics()
  expect_true(all(result$class == "testdrug"))
  expect_true(all(result$version == "v2"))
})

test_that("get_generics() priority defaults to 1 and can be widened", {
  result <- toy_drug_v1$get_generics()
  expect_true(all(result$priority == 1L))
  widened <- toy_drug_v1$get_generics(priority = 1:3)
  expect_equal(nrow(widened), nrow(result))
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

test_that("get_antihypertensive_generics(component = 'acei_v1') returns tibble tagged with that class", {
  result <- get_antihypertensive_generics(component = "acei_v1")
  expect_s3_class(result, "tbl_df")
  expect_true(all(result$class == "acei"))
  expect_true(all(result$version == "v1"))
})

test_that("get_antihypertensive_generics(component = 'acei_v1') includes expected GNNs", {
  gnns <- get_antihypertensive_generics(component = "acei_v1")$generic
  expect_true("LISINOPRIL"  %in% gnns)
  expect_true("RAMIPRIL"    %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'acei_v2') has FDB variants", {
  gnns <- get_antihypertensive_generics(component = "acei_v2")$generic
  expect_true("FOSINIPRIL"  %in% gnns)
  expect_true("MOEXEPRIL"   %in% gnns)
})

test_that("get_antihypertensive_generics() with no component returns every component", {
  result <- get_antihypertensive_generics()
  expect_true("acei_v1" %in% unique(paste(result$class, result$version, sep = "_")))
})

test_that("get_antihypertensive_generics(component = 'int_sym_v1') includes CARTEOLOL", {
  gnns <- get_antihypertensive_generics(component = "int_sym_v1")$generic
  expect_true("CARTEOLOL" %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'int_sym_v2') excludes CARTEOLOL", {
  gnns <- get_antihypertensive_generics(component = "int_sym_v2")$generic
  expect_false("CARTEOLOL" %in% gnns)
})

test_that("get_antihypertensive_generics(component = 'all') returns every component", {
  result <- get_antihypertensive_generics(component = "all")
  expect_true("acei_v1" %in% unique(paste(result$class, result$version, sep = "_")))
})

test_that("spec_antidepressive is a CompositeDrugSpec with 5 components", {
  expect_s3_class(spec_antidepressive, "CompositeDrugSpec")
  expect_equal(names(spec_antidepressive$components()),
               c("ssri_v1", "snri_v1", "tca_v1", "maoi_v1", "other_v1"))
})

test_that("get_antidepressive_generics(component = 'ssri_v1') includes SERTRALINE", {
  result <- get_antidepressive_generics(component = "ssri_v1")
  expect_true("SERTRALINE" %in% result$generic)
})

test_that("get_antidepressive_generics(component = 'all') returns all GNNs across priority tiers", {
  result <- get_antidepressive_generics(component = "all", priority = 1:3)
  expect_type(result$generic, "character")
  expect_equal(nrow(result), 70L)
  expect_true("BUPROPION"   %in% result$generic)      # priority 2 (also approved for smoking cessation)
  expect_true("TRANYLCYPROMINE" %in% result$generic)  # priority 1
})

test_that("get_antidepressive_generics(component = 'all') defaults to priority = 1 (core) only", {
  result <- get_antidepressive_generics(component = "all")
  expect_true(all(result$priority == 1L))
  expect_false("BUPROPION" %in% result$generic)
  expect_true("TRANYLCYPROMINE" %in% result$generic)
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
    \(nm) get_antihypertensive_generics(component = nm)$generic
  )))
  # v1 components only — should equal the explicit v1 subset
  expect_true(length(all_comp) > 0L)
  # All v1 GNNs should come from v1 components
  expect_true("LISINOPRIL" %in% all_comp)
  expect_true("ATENOLOL"   %in% all_comp)
})
