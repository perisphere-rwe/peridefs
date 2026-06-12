

test_that("get_htn_v1_codes() returns a named list by default", {
  result <- get_htn_v1_codes()
  expect_type(result, "list")
  expect_true(length(result) > 0L)
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

# codes match expected values

test_that("expected code sets: hypertension", {


  dx_icd9 <- c(
    "401",
    "4010",
    "4011",
    "4019",
    "4030",
    "40300",
    "40301",
    "4031",
    "40310",
    "40311",
    "4039",
    "40390",
    "40391"
  )

  dx_icd10 <- c(
    "I10",
    "I11",
    "I110",
    "I119",
    "I12",
    "I120",
    "I129",
    "I13",
    "I130",
    "I131",
    "I1310",
    "I1311",
    "I132",
    "I15",
    "I150",
    "I151",
    "I152",
    "I158",
    "I159",
    "I120",
    "I129",
    "I16",
    "I160",
    "I161",
    "I169"
  )

  v1 <- get_htn_v1_codes()
  v2 <- get_htn_v2_codes()

  expect_true(v1$dx_icd9  %==%  dx_icd9)
  expect_true(v1$dx_icd10 %==%  dx_icd10)
  expect_true(v1$dx_icd9  %==%  v2$dx_icd9)
  expect_true(v1$dx_icd10 %==%  v2$dx_icd10)

})


test_that("expected code sets: CHD", {

  dx_icd9 <- c(
    "410",
    "4100",
    "41000",
    "41001",
    "41002",
    "4101",
    "41010",
    "41011",
    "41012",
    "4102",
    "41020",
    "41021",
    "41022",
    "4103",
    "41030",
    "41031",
    "41032",
    "4104",
    "41040",
    "41041",
    "41042",
    "4105",
    "41050",
    "41051",
    "41052",
    "4106",
    "41060",
    "41061",
    "41062",
    "4107",
    "41070",
    "41071",
    "41072",
    "4108",
    "41080",
    "41081",
    "41082",
    "4109",
    "41090",
    "41091",
    "41092",
    "411",
    "4110",
    "4111",
    "4118",
    "41181",
    "41189",
    "412",
    "413",
    "4130",
    "4131",
    "4139",
    "414",
    "4140",
    "41400",
    "41401",
    "41402",
    "41403",
    "41404",
    "41405",
    "41406",
    "41407",
    "4141",
    "41410",
    "41411",
    "41412",
    "41419",
    "4142",
    "4143",
    "4144",
    "4148",
    "4149",
    "V4581",
    "V4582"
  )

  dx_icd10 <- c(
    "I21",
    "I210",
    "I2101",
    "I2102",
    "I2109",
    "I211",
    "I2111",
    "I2119",
    "I212",
    "I2121",
    "I2129",
    "I213",
    "I214",
    "I219",
    "I21A",
    "I21A1",
    "I21A9",
    "I22",
    "I220",
    "I221",
    "I222",
    "I228",
    "I229",
    "I2510",
    "I25810",
    "I25811",
    "I25812",
    "I253",
    "I2541",
    "I2542",
    "Z951",
    "Z9861",
    "I200",
    "I201",
    "I208",
    "I209",
    "I240",
    "I241",
    "I248",
    "I252",
    "I255",
    "I2582",
    "I2583",
    "I2584",
    "I2589",
    "I259"
  )


  proc_icd9 <- c("0066",
                 "360",
                 paste(3601:3619),
                 362)


  proc_icd10 <- c(expand_pcs('0210'),
                  expand_pcs('0211'),
                  expand_pcs('0212'),
                  expand_pcs('0213'),
                  expand_pcs('0270'),
                  expand_pcs('0271'),
                  expand_pcs('0272'),
                  expand_pcs('0273'),
                  expand_pcs('02C0'),
                  expand_pcs('02C1'),
                  expand_pcs('02C2'),
                  expand_pcs('02C3'),
                  expand_pcs('3E07'))

  hcpcs <- c(
    paste(33510:33519),
    paste(33521:33523),
    "33530",
    paste(33533:33536),
    paste(92980:92982),
    "92984",
    "92995",
    "92996",
    "92920",
    "92921",
    "92924",
    "92925",
    "92928",
    "92929",
    "92933",
    "92934",
    "92937",
    "92938",
    "92941",
    "92943",
    "92944",
    "92973",
    "C9600",
    "C9601",
    "C9602",
    "C9603",
    "C9604",
    "C9605",
    "C9606",
    "C9607",
    "C9608",
    "G0290",
    "G0291"
  )

  chd_v1 <- get_ascvd_codes(component = 'chd_v1')
  chd_v2 <- get_ascvd_codes(component = 'chd_v2')

  expect_true(chd_v1$dx_icd9 %==% dx_icd9)
  expect_true(chd_v1$dx_icd10 %==% dx_icd10)
  expect_true(chd_v1$proc_icd9 %==% proc_icd9)
  expect_true(chd_v1$proc_icd10 %==% proc_icd10)

  expect_true(chd_v1$dx_icd9 %==% chd_v2$dx_icd9)
  expect_true(chd_v1$dx_icd10 %==% chd_v2$dx_icd10)
  expect_true(chd_v1$proc_icd9 %==% chd_v2$proc_icd9)
  expect_true(chd_v1$proc_icd10 %==% chd_v2$proc_icd10)


})





