# ASCVD composite -----------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

# Depends on: conditions/chd.R, stroke.R, lead_pad.R, cerebrovasc_disease.R

## ASCVD composite ----
#
# ASCVD, history, version 1: Defined by a history of CHD, (ischemic or any)
# stroke.
#
# ASCVD, history, version 2: Defined by a history of CHD, cerebrovascular
# disease, or LEAD/PAD.
#
# ASCVD, outcome, version 1: Defined by an event of CHD, stroke.
#
# ASCVD, outcome, version 2: Defined by an event of CHD, stroke, or LEAD/PAD.
#

spec_ascvd <- CompositeCodeSpec$new(
  condition = "ascvd",
  label = "Atherosclerotic Cardiovascular Disease (ASCVD)",
  defs = paste0(
    "Composition of all ASCVD component specs: coronary heart disease (CHD), ",
    "stroke, lower extremity artery disease (LEAD) / peripheral arterial ",
    "disease (PAD), and cerebrovascular disease"
  ),
  components = list(
    chd_v1                 = spec_chd_v1,
    stroke_v1              = spec_stroke_v1,
    lead_pad_v1            = spec_lead_pad_v1,
    cerebrovasc_disease_v1 = spec_cerebrovasc_disease_v1
  ),
  # Per the definition book: the condition/history definition uses
  # cerebrovascular disease (not stroke), while the outcome definition uses
  # stroke (not cerebrovascular disease). CHD and LEAD/PAD apply to both.
  components_by_variable_type = list(
    condition = c("chd_v1", "cerebrovasc_disease_v1", "lead_pad_v1"),
    outcome   = c("chd_v1", "stroke_v1", "lead_pad_v1")
  )
)
