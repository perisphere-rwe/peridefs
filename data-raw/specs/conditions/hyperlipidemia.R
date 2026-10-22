# Hyperlipidemia ------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Hyperlipidemia ----

### history, version 1 ----
#
# Any of following codes in any diagnosis position from inpatient or outpatient
# settings:
#
# (a)	≥2 claims on separate calendar days with ICD-9 diagnoses (any position)
# of 272.0, 272.1, 272.2, 272.3, 272.4 linked to an outpatient physician claim.
#
# (b)	≥2 claims on separate calendar days with ICD-9 diagnoses (any position)
# of 272.0, 272.1, 272.2, 272.3, 272.4.
#
# (c)	≥2 claims on separate calendar days with ICD-10 diagnoses (any position)
# of E78.0, E78.1, E78.2, E78.3, E78.4, E78.5 linked to an outpatient physician claim.
#
# (d)	≥2 claims on separate calendar days with ICD-10 diagnoses (any position)
# of E78.0, E78.1, E78.2, E78.3, E78.4, E78.5.
#

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# hyp_icd9  <- c("2720", "2721", "2722", "2723", "2724")
# hyp_icd10 <- c("E780", "E781", "E782", "E783", "E784", "E785")

spec_hyperlipidemia_v1 <- CodeSpec$new(
  condition = "hyperlipidemia", version = "v1", label = "Hyperlipidemia",
  defs = list(
    condition = c(
      "*" = paste0(
        "\u22652 claims on separate calendar days with ICD-9 diagnoses ",
        "{.strong 272.0}\u2013{.strong 272.4}, or ICD-10 diagnoses of {.strong E78.0}, ",
        "{.strong E78.1}, {.strong E78.2}, {.strong E78.3}, {.strong E78.4}, or {.strong E78.5} ",
        "in any diagnosis position (carrier, outpatient, inpatient, SNF, or HHA)."
      )
    ),
    outcome = NULL
  ),
  codes = read_codeset("hyperlipidemia_v1")
)
