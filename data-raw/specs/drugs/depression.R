# Antidepressive medications ------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Antidepressive medication components ----

spec_antidep_ssri_v1 <- DrugSpec$new(
  "ssri", "SSRIs",
  version = "v1",
  defs    = "Selective serotonin reuptake inhibitors (SSRIs).",
  generic_names = c(
    "CITALOPRAM",
    "CITALOPRAM HYDROBROMIDE",  # n=184,818,869 in MC Rx table
    "ESCITALOPRAM",
    "ESCITALOPRAM OXALATE",  # n=293,715,823 in MC Rx table
    "FLUOXETINE",  # n=2,368 in MC Rx table
    "FLUOXETINE HCL",  # n=229,522,546 in MC Rx table
    "PAROXETINE",
    "PAROXETINE HCL",  # n=87,014,857 in MC Rx table
    "SERTRALINE",
    "SERTRALINE HCL"  # n=361,607,336 in MC Rx table
  ),
  generic_names_probable = c(
    # Same GNRC_NM covers both the MDD-approved (Pexeva) and VMS-only,
    # non-MDD-approved (Brisdelle 7.5 mg) paroxetine mesylate products.
    "PAROXETINE MESYLATE"  # n=977,517 in MC Rx table
  ),
  brand_names = list(
    # Both brands share this GNRC_NM; dose distinguishes them (7.5mg
    # Brisdelle for VMS vs. 7.5-25mg Pexeva for MDD) — see bkbellows's PR #1
    # review comment.
    "PAROXETINE MESYLATE" = c("Brisdelle", "Pexeva")
  ),
  generic_names_cautious = c(
    # US approval is OCD/social anxiety disorder only; no US MDD approval
    # (MDD approval exists in Europe but not the US).
    "FLUVOXAMINE",
    "FLUVOXAMINE MALEATE"  # n=10,691,902 in MC Rx table
  )
)

spec_antidep_snri_v1 <- DrugSpec$new(
  "snri", "SNRIs",
  version = "v1",
  defs    = "Serotonin-norepinephrine reuptake inhibitors (SNRIs).",
  generic_names = c(
    "DESVENLAFAXINE",  # n=824,794 in MC Rx table
    "DESVENLAFAXINE FUMARATE",  # n=4,680 in MC Rx table
    "DESVENLAFAXINE SUCCINATE",  # n=33,049,132 in MC Rx table
    "LEVOMILNACIPRAN",
    "LEVOMILNACIPRAN HCL",  # n=1,616,535 in MC Rx table
    "LEVOMILNACIPRAN HYDROCHLORIDE",  # n=583,942 in MC Rx table
    "VENLAFAXINE",
    "VENLAFAXINE BESYLATE",  # n=23,174 in MC Rx table
    "VENLAFAXINE HCL"  # n=165,131,988 in MC Rx table
  ),
  generic_names_probable = c(
    "DULOXETINE",  # NOTE: also FDA-approved for fibromyalgia, diabetic neuropathy, and chronic MSK pain
    "DULOXETINE HCL"  # n=214,463,588; NOTE: also FDA-approved for fibromyalgia, diabetic neuropathy, and chronic MSK pain
  ),
  generic_names_cautious = c(
    # US approval is fibromyalgia only (Savella); no US antidepressant indication.
    "MILNACIPRAN",
    "MILNACIPRAN HCL"  # n=3,639,057 in MC Rx table
  )
)

spec_antidep_tca_v1 <- DrugSpec$new(
  "tca", "Tricyclic Antidepressants",
  version = "v1",
  defs    = "Tricyclic and tetracyclic antidepressants (TCAs).",
  # 2026-08-23: priority tiers added (this spec previously had none). See
  # generic_names_probable/generic_names_cautious below for the specific
  # drugs pulled out of the plain (priority 1) list and why.
  generic_names = c(
    "AMITRIPTYLINE",
    "AMITRIPTYLINE HCL",  # n=95,689,949 in MC Rx table
    "AMITRIPTYLINE HCL/PERPHENAZINE",  # n=4,276 in MC Rx table
    "AMITRIPTYLINE/CHLORDIAZEPOXIDE",  # n=133,845 in MC Rx table
    "AMOXAPINE",  # n=99,875 in MC Rx table
    "DESIPRAMINE",
    "DESIPRAMINE HCL",  # n=1,744,858 in MC Rx table
    "MAPROTILINE",
    "MAPROTILINE HCL",  # n=59,763 in MC Rx table
    "NORTRIPTYLINE",
    "NORTRIPTYLINE HCL",  # n=29,908,577 in MC Rx table
    "PERPHENAZINE/AMITRIPTYLINE HCL",  # n=395,854 in MC Rx table
    "PROTRIPTYLINE",
    "PROTRIPTYLINE HCL",  # n=294,863 in MC Rx table
    "TRIMIPRAMINE",
    "TRIMIPRAMINE MALEATE"  # n=35,695 in MC Rx table
  ),
  generic_names_probable = c(
    "DOXEPIN",  # NOTE: also FDA-approved (as low-dose Silenor, 3-6mg) for insomnia
    "DOXEPIN HCL",  # n=25,915,220; NOTE: also FDA-approved (as low-dose Silenor, 3-6mg) for insomnia
    "IMIPRAMINE",  # NOTE: also FDA-approved (Tofranil) for childhood nocturnal enuresis
    "IMIPRAMINE HCL",  # n=5,602,753; NOTE: also FDA-approved (Tofranil) for childhood nocturnal enuresis
    "IMIPRAMINE PAMOATE"  # n=278,673; NOTE: also FDA-approved (Tofranil-PM) for childhood nocturnal enuresis
  ),
  generic_names_cautious = c(
    # US approval is OCD only (Anafranil, 1989); depression approval exists
    # outside the US, where clomipramine has long been used as an
    # antidepressant.
    "CLOMIPRAMINE",
    "CLOMIPRAMINE HCL"  # n=3,359,761 in MC Rx table
  )
)

spec_antidep_maoi_v1 <- DrugSpec$new(
  "maoi", "MAOIs",
  version = "v1",
  defs    = "Monoamine oxidase inhibitors (MAOIs).",
  generic_names = c(
    "ISOCARBOXAZID",  # n=15,320 in MC Rx table
    "PHENELZINE",
    "PHENELZINE SULFATE",  # n=314,051 in MC Rx table
    "TRANYLCYPROMINE",
    "TRANYLCYPROMINE SULFATE"  # n=316,001 in MC Rx table
  ),
  generic_names_probable = c(
    # GNRC_NM "SELEGILINE" covers both the oral (Parkinson's-only) and
    # transdermal Emsam patch (MDD-approved) forms.
    "SELEGILINE"  # n=247,338 in MC Rx table
  ),
  generic_names_cautious = c(
    # "SELEGILINE HCL" denotes the oral hydrochloride salt, which is
    # Parkinson's-only; the MDD-approved form is the transdermal patch
    # (Emsam), whose GNRC_NM is plain "SELEGILINE" (see probable, above).
    "SELEGILINE HCL"  # n=806,042 in MC Rx table
  )
)

spec_antidep_other_v1 <- DrugSpec$new(
  "other", "Other Antidepressants",
  version = "v1",
  defs    = paste0(
    "Atypical and other-mechanism antidepressants, including NDRIs (bupropion), ",
    "NaSSAs (mirtazapine), SARIs (nefazodone, trazodone), and serotonin ",
    "modulators (vilazodone, vortioxetine). Note: perphenazine is intentionally ",
    "excluded — see commented-out entry in generic_names."
  ),
  generic_names = c(
    "DEXTROMETHORPHAN HBR/BUPROPION",  # n=1,469,999 in MC Rx table
    "MIRTAZAPINE",  # n=88,176,986 in MC Rx table
    "NEFAZODONE",
    "NEFAZODONE HCL",  # n=831,947 in MC Rx table
    # "PERPHENAZINE",  # First-generation antipsychotic (Trilafon); no antidepressant FDA indication — standalone claims reflect antipsychotic use. Combo products (amitriptyline/perphenazine) are captured in the TCA spec. n=3,639,397
    "VILAZODONE",
    "VILAZODONE HCL",  # n=12,478,041 in MC Rx table
    "VILAZODONE HYDROCHLORIDE",  # n=3,003,724 in MC Rx table
    "VORTIOXETINE",
    "VORTIOXETINE HYDROBROMIDE"  # n=18,701,850 in MC Rx table
  ),
  generic_names_probable = c(
    "BUPROPION",  # NOTE: also approved for smoking cessation (Zyban)
    "BUPROPION HBR",  # n=492,497; NOTE: also approved for smoking cessation (Zyban)
    "BUPROPION HCL",  # n=290,468,738; NOTE: also approved for smoking cessation (Zyban)
    # FDA-approved for MDD, but nationally ~85% of prescriptions (~20M of ~24M
    # in 2019) are off-label for insomnia — it is the #1 prescribed sleep aid
    # in the US by volume, so standalone claims often reflect insomnia, not
    # depression, treatment.
    "TRAZODONE",
    "TRAZODONE HCL"  # n=265,385,791 in MC Rx table
  )
)

spec_depression <- CompositeDrugSpec$new(
  drug_class = "antidepressive",
  label      = "Antidepressive Medications",
  defs       = paste0(
    "Antidepressive medication subclasses (v1): SSRIs, SNRIs, tricyclic ",
    "antidepressants, MAOIs, and other/atypical agents."
  ),
  condition  = "depression",
  components = list(
    ssri_v1  = spec_antidep_ssri_v1,
    snri_v1  = spec_antidep_snri_v1,
    tca_v1   = spec_antidep_tca_v1,
    maoi_v1  = spec_antidep_maoi_v1,
    other_v1 = spec_antidep_other_v1
  )
)
