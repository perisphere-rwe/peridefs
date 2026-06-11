## =============================================================================
## download_pcs_codes.R
## Download and process the CMS ICD-10-PCS procedure code reference table.
## =============================================================================
##
## PURPOSE
## -------
## This script downloads the official ICD-10-PCS order file published by CMS,
## extracts all valid billable 7-character procedure codes, and saves them as
## internal package data (R/sysdata.rda). The resulting `pcs_codes` vector is
## used by expand_pcs() in R/expand_pcs.R to resolve prefix patterns like
## "0210xxx" into actual valid codes.
##
##
## WHEN TO UPDATE
## --------------
## CMS releases updated ICD-10-PCS code sets on two schedules each fiscal year:
##
##   October 1  — main annual update (e.g., FY2026 takes effect Oct 1, 2025)
##   April 1    — mid-year update with a smaller number of additions/deletions
##
## Re-run this script after either release if any procedure codes relevant to
## peridefs definitions have changed. For most years, the cardiovascular codes
## (sections 02, 03, 3E) are stable, so the October 1 update is the one that
## matters most.
##
## Check for new releases at:
##   https://www.cms.gov/medicare/coding-billing/icd-10-codes
##
##
## HOW TO UPDATE
## -------------
## 1. Find the new fiscal year. CMS labels files by the fiscal year they cover,
##    e.g., FY2027 covers October 1, 2026 – September 30, 2027.
##
## 2. Change the `fy` variable below to the new fiscal year (as a string):
##
##      fy <- "2027"
##
## 3. Verify the download URL resolves. CMS has used this pattern consistently:
##
##      https://www.cms.gov/files/zip/{fy}-icd-10-pcs-order-file-long-and-abbreviated-titles.zip
##
##    If the URL 404s, visit the CMS page above, find the new order file link,
##    and update the `url` construction below accordingly.
##
## 4. Source this script from the package root:
##
##      source("data-raw/download_pcs_codes.R")
##
##    It will print the number of codes extracted. Compare to the prior year —
##    the total grows by ~100-300 codes per annual update. A dramatic change
##    (thousands of codes added or removed) suggests something went wrong.
##
## 5. Rebuild the spec data so that expand_pcs() uses the new codes:
##
##      source("data-raw/build_specs.R")
##
## 6. Reload the package and spot-check a few known codes:
##
##      devtools::load_all()
##      expand_pcs("0210xxx")   # CABG — should return ~74 codes
##      expand_pcs("02100Z9")   # single CABG code — should return length 1
##
## 7. Run the test suite to confirm nothing broke:
##
##      devtools::test()
##
## 8. Commit both R/sysdata.rda and the updated data/ .rda files together.
##
##
## FILE FORMAT
## -----------
## The order file is a fixed-width text file. One row per code. Layout:
##
##   cols  1-5:  sequential order number (5 digits, zero-padded)
##   col   6:    space
##   cols  7-13: ICD-10-PCS code (7 alphanumeric characters; "       " for
##               header/category rows that have no billable code)
##   col  14:    space
##   col  15:    validity flag ("1" = valid/billable, "0" = header only)
##   col  16:    space
##   cols 17-77: short description (left-justified, space-padded)
##   col  78:    space
##   cols 79+:   long description
##
## Only rows where the 7-character code field is fully populated AND the
## validity flag is "1" are extracted. Header/category rows (flag = "0")
## are skipped; these are intermediate classification nodes used in the
## tabular display but not valid for billing.
##
## FY2026 baseline: 79,115 valid codes (as of October 1, 2025).
##
## =============================================================================

fy  <- "2026"
url <- paste0(
  "https://www.cms.gov/files/zip/", fy,
  "-icd-10-pcs-order-file-long-and-abbreviated-titles.zip"
)

tmp_zip <- tempfile(fileext = ".zip")
tmp_dir <- tempfile()
dir.create(tmp_dir)

message("Downloading FY", fy, " ICD-10-PCS order file...")
download.file(url, tmp_zip, quiet = FALSE)
unzip(tmp_zip, exdir = tmp_dir)

order_file <- list.files(tmp_dir, pattern = "^icd10pcs_order.*\\.txt$",
                         full.names = TRUE)
stopifnot(length(order_file) == 1L)

message("Parsing ", basename(order_file), "...")
lines       <- readLines(order_file)
long_enough <- nchar(lines) >= 15L
code_col    <- trimws(substr(lines[long_enough], 7L, 13L))
valid_col   <- trimws(substr(lines[long_enough], 15L, 15L))

pcs_codes <- code_col[nchar(code_col) == 7L & valid_col == "1"]
message("Extracted ", length(pcs_codes), " valid ICD-10-PCS codes.")

usethis::use_data(pcs_codes, internal = TRUE, overwrite = TRUE)
message("Saved to R/sysdata.rda")
message("Next steps: source('data-raw/build_specs.R'), then devtools::test()")
