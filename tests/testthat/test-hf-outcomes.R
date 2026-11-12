# classify_hf_outcomes() ------------------------------------------------------

# Diagnosis rows: one tibble row per diagnosis on a claim.
.dx <- function(patient_id, claim_id, claim_setting, claim_date, dx_position, dx_code,
                ref_date = "2024-01-01") {
  tibble::tibble(
    patient_id = patient_id, claim_id = claim_id, claim_setting = claim_setting,
    claim_date = as.Date(claim_date), dx_position = as.integer(dx_position),
    dx_code = dx_code, ref_date = as.Date(ref_date)
  )
}

# One inpatient claim with a primary code and optional secondary codes.
.inpt <- function(patient_id, claim_id, primary, secondary = character(), date = "2024-02-01",
                  setting = "inpatient", ref_date = "2024-01-01") {
  codes <- c(primary, secondary)
  .dx(patient_id, claim_id, setting, date, seq_along(codes), codes, ref_date)
}

.acute <- function(df, ...) {
  classify_hf_outcomes(df, col_ref_date = "ref_date",
                       outcomes = "acute_hf_hospitalization", ...)
}

.toy <- rbind(
  .dx(1, "c1", "outpatient", "2024-01-10", 1, "I509"),
  .dx(1, "c2", "inpatient",  "2024-03-01", 1, "I5021"),
  .dx(2, "c4", "inpatient",  "2024-02-01", 1, "I5022"),
  .dx(3, "c5", "inpatient",  "2024-02-05", 1:3, c("I130", "I5022", "N184")),
  .dx(4, "c6", "inpatient",  "2024-04-09", 1:2, c("I130", "I5022"))
)

.toy_expected <- tibble::tibble(
  patient_id = c(1, 1, 2, 3, 3, 4),
  outcome = c("incident_hf", "acute_hf_hospitalization", "incident_hf",
              "acute_hf_hospitalization", "incident_hf", "incident_hf"),
  claim_id = c("c1", "c2", "c4", "c5", "c5", "c6"),
  claim_date = as.Date(c("2024-01-10", "2024-03-01", "2024-02-01", "2024-02-05",
                         "2024-02-05", "2024-04-09")),
  qualifying_code = c("I509", "I5021", "I5022", "I130", "I5022", "I5022")
)

test_that("classifies acute hospitalizations and incident events on a small example", {
  out <- classify_hf_outcomes(.toy, col_ref_date = "ref_date")
  expect_s3_class(out, "tbl_df")
  expect_equal(out, .toy_expected)
})

test_that("gives the same result on a duckdb table as on a local data frame", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  skip_if_not_installed("dbplyr")
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  remote <- dplyr::copy_to(con, .toy, "toy_claims")

  out <- classify_hf_outcomes(remote, col_ref_date = "ref_date")
  expect_s3_class(out, "tbl_lazy")
  expect_equal(as.data.frame(dplyr::collect(out)), as.data.frame(.toy_expected))

  # min_event_days uses date arithmetic on the backend
  late <- classify_hf_outcomes(remote, col_ref_date = "ref_date", min_event_days = 45L)
  late_local <- classify_hf_outcomes(.toy, col_ref_date = "ref_date", min_event_days = 45L)
  expect_equal(as.data.frame(dplyr::collect(late)), as.data.frame(late_local))

  # The prevalent-HF check also runs against the backend
  prior <- rbind(.toy, .dx(9, "p1", "outpatient", "2023-05-01", 1, "I509"))
  remote_prior <- dplyr::copy_to(con, prior, "prior_claims")
  expect_error(classify_hf_outcomes(remote_prior, col_ref_date = "ref_date"),
               class = "peridefs_prior_hf_error")
})

test_that("acute hospitalization rules follow the outcome code table", {
  qual <- function(...) nrow(.acute(.inpt(1, "x", ...))) == 1L

  # (a) acute and acute-on-chronic I50 codes qualify as primary
  for (cd in c("I5021", "I5023", "I5031", "I5033", "I5041", "I5043", "I50811", "I50813")) {
    expect_true(qual(cd), label = paste(cd, "as primary"))
  }
  # chronic and unspecified I50 codes, and I50.84, do not
  for (cd in c("I5022", "I5032", "I5042", "I50812", "I509", "I501", "I5020", "I5084", "I5082")) {
    expect_false(qual(cd), label = paste(cd, "as primary"))
  }

  # (b) I11.0 needs an I50 code in a non-primary position; any I50 will do
  expect_true(qual("I110", "I5022"))
  expect_true(qual("I110", c("I10", "I509")))
  expect_false(qual("I110"))
  expect_false(qual("I110", "N189"))

  # I13.0 and I13.2 need both an I50 and an N18 code
  expect_true(qual("I130", c("I5022", "N184")))
  expect_true(qual("I132", c("N185", "I509")))
  expect_false(qual("I130", "I5022"))
  expect_false(qual("I132", "N185"))

  # An acute code in a secondary position does not qualify
  expect_false(qual("I10", "I5021"))
  expect_false(qual("N189", c("I5021", "I5023")))

  # Only overnight inpatient claims count
  expect_false(qual("I5021", setting = "outpatient"))
  expect_false(qual("I5021", setting = "ed"))
})

test_that("inpatient_setting is configurable and qualifying_code is the primary code", {
  claims <- .inpt(1, "x", "I130", c("I509", "N184"), setting = "IP")
  expect_equal(nrow(.acute(claims)), 0L)
  out <- .acute(claims, inpatient_setting = "IP")
  expect_equal(out$qualifying_code, "I130")
  expect_equal(out$outcome, "acute_hf_hospitalization")
})

test_that("only claims strictly after the reference date plus min_event_days are classified", {
  claims <- rbind(
    .inpt(1, "on_ref", "I5021", date = "2024-01-01"),
    .inpt(1, "day1",   "I5021", date = "2024-01-02"),
    .inpt(1, "day31",  "I5021", date = "2024-02-01"),
    .inpt(1, "day32",  "I5021", date = "2024-02-02")
  )
  expect_equal(.acute(claims, exclude_prevalent_hf = FALSE)$claim_id, c("day1", "day31", "day32"))
  expect_equal(.acute(claims, min_event_days = 31L)$claim_id, "day32")
  expect_equal(.acute(claims, min_event_days = 30L)$claim_id, c("day31", "day32"))
  expect_equal(.acute(claims, min_event_days = 400L)$claim_id, character())
})

test_that("incident_hf is the first claim with any I50 code per patient, deterministically", {
  inc <- function(df) classify_hf_outcomes(df, col_ref_date = "ref_date", outcomes = "incident_hf")

  claims <- rbind(
    .inpt(1, "late",  "I5022", date = "2024-05-01"),
    .inpt(1, "early", "I509",  date = "2024-02-01", setting = "outpatient"),
    # Hypertensive codes alone, and I50 codes in any position, are handled correctly
    .inpt(2, "htn",   "I110",  date = "2024-02-01"),
    .inpt(2, "sec",   "I10", "I5084", date = "2024-03-01"),
    # Same date: smallest claim ID, then the first I50 code alphabetically
    .inpt(3, "b", "I509", date = "2024-02-01"),
    .inpt(3, "a", "I50810", c("I5022", "I509"), date = "2024-02-01")
  )
  out <- inc(claims)
  expect_equal(nrow(out), 3L)
  expect_equal(out$claim_id, c("early", "sec", "a"))
  expect_equal(out$qualifying_code, c("I509", "I5084", "I5022"))
  expect_true(all(out$outcome == "incident_hf"))
})

test_that("exclude_prevalent_hf errors on heart failure claims before the reference date", {
  prior <- rbind(
    .inpt(1, "p1", "I110", date = "2023-06-02", setting = "outpatient"),
    .inpt(1, "p2", "I10", "I509", date = "2023-07-01"),
    .inpt(2, "p3", "N189", "I5022", date = "2023-08-01"),
    .inpt(3, "ok", "I10", date = "2023-08-01"),
    .inpt(1, "after", "I5021", date = "2024-02-01")
  )

  # Condition checked: the whole outcome code table (here, I11.0 and I50.x), any position
  err <- expect_error(classify_hf_outcomes(prior, col_ref_date = "ref_date"),
                      class = "peridefs_prior_hf_error")
  msg <- conditionMessage(err)
  expect_match(msg, "3 heart failure claims from 2 patients")
  expect_match(msg, "patient 1, claim p1 on 2023-06-02: I110", fixed = TRUE)
  expect_match(msg, "exclude_prevalent_hf = FALSE", fixed = TRUE)

  # Not run when the flag is FALSE
  expect_no_error(classify_hf_outcomes(prior, col_ref_date = "ref_date",
                                       exclude_prevalent_hf = FALSE))
  # Not run when only acute hospitalizations are requested
  expect_no_error(classify_hf_outcomes(prior, col_ref_date = "ref_date",
                                       outcomes = "acute_hf_hospitalization"))

  # A claim on the reference date is not "before" it
  on_ref <- .inpt(1, "on", "I509", date = "2024-01-01")
  expect_no_error(classify_hf_outcomes(on_ref, col_ref_date = "ref_date"))
  # Non-heart-failure claims before the reference date are fine
  other <- .inpt(1, "pre", "I10", "E119", date = "2023-01-01")
  expect_no_error(classify_hf_outcomes(rbind(other, .inpt(1, "x", "I5021")),
                                       col_ref_date = "ref_date"))
})

test_that("recurrent events: with exclude_prevalent_hf = FALSE, prior claims are ignored", {
  claims <- rbind(
    .inpt(1, "old", "I5021", date = "2023-03-01"),
    .inpt(1, "new", "I5021", date = "2024-03-01")
  )
  out <- classify_hf_outcomes(claims, col_ref_date = "ref_date", exclude_prevalent_hf = FALSE)
  expect_equal(out$claim_id, c("new", "new"))
  expect_setequal(out$outcome, c("acute_hf_hospitalization", "incident_hf"))
})

test_that("column names are mapped with col_* arguments, output names are standard", {
  renamed <- dplyr::rename(.toy, pid = patient_id, clm = claim_id, icd = dx_code,
                           pos = dx_position, site = claim_setting, dt = claim_date,
                           index = ref_date)
  out <- classify_hf_outcomes(
    renamed, col_ref_date = "index", col_patient_id = "pid", col_claim_id = "clm",
    col_dx_code = "icd", col_dx_position = "pos", col_claim_setting = "site",
    col_claim_date = "dt"
  )
  expect_equal(out, .toy_expected)
})

test_that("returns an empty table with the expected columns when nothing qualifies", {
  out <- .acute(.inpt(1, "x", "I10", "E119"))
  expect_equal(nrow(out), 0L)
  expect_identical(names(out), c("patient_id", "outcome", "claim_id", "claim_date", "qualifying_code"))
})

test_that("version can be given as a label or a number", {
  expect_equal(classify_hf_outcomes(.toy, col_ref_date = "ref_date", version = 2), .toy_expected)
  expect_equal(classify_hf_outcomes(.toy, col_ref_date = "ref_date", version = "V2"), .toy_expected)
})

test_that("invalid input gives informative errors", {
  expect_error(classify_hf_outcomes(.toy), "col_ref_date.*required")
  expect_error(classify_hf_outcomes("x", col_ref_date = "ref_date"), "data frame")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "nope"), "missing 1 required column")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", col_dx_code = "nope"),
               "col_dx_code")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "claim_date"), "different column")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", version = "v1"),
               "No heart failure outcome rules.*v1")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", version = "latest"), "version")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", min_event_days = -1L),
               "min_event_days")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", min_event_days = 1.5),
               "min_event_days")
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", outcomes = "recurrent"))
  expect_error(classify_hf_outcomes(.toy, col_ref_date = "ref_date", exclude_prevalent_hf = NA),
               "exclude_prevalent_hf")

  missing_ref <- .toy
  missing_ref$ref_date[2] <- NA
  expect_error(classify_hf_outcomes(missing_ref, col_ref_date = "ref_date"),
               "1 missing value")
})
