# Antihypertensive medications ----------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Antihypertensive medication components ----

### ACE inhibitors ----

spec_acei_v1 <- DrugSpec$new(
  "acei", "ACE Inhibitors",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # Standalone ACE inhibitors that also carry a distinct FDA-approved
  # indication beyond hypertension (heart failure, post-MI, stable CAD) are
  # moved to generic_names_probable below; BENAZEPRIL and MOEXIPRIL remain
  # here because their US labels are hypertension-only. Fixed-dose
  # antihypertensive combination products (see spec_acei_v2) are left at
  # priority 1 regardless of a standalone component's other indications,
  # matching the convention already used elsewhere in this file (e.g.
  # HCTZ/SPIRONOLACTONE in spec_aldo_v1).
  generic_names = c(
    "BENAZEPRIL",
    "MOEXIPRIL"
  ),
  generic_names_probable = c(
    "CAPTOPRIL",  # n=2,536,660; NOTE: also FDA-approved for heart failure, post-MI LV dysfunction, and diabetic nephropathy
    "ENALAPRIL",  # NOTE: also FDA-approved for symptomatic heart failure
    "FOSINOPRIL",  # NOTE: also FDA-approved for heart failure
    "LISINOPRIL",  # n=659,049,069; NOTE: also FDA-approved for heart failure and acute MI
    "PERINDOPRIL",  # NOTE: also FDA-approved to reduce CV death/non-fatal MI risk in stable CAD
    "QUINAPRIL",  # NOTE: also FDA-approved for heart failure
    "RAMIPRIL",  # n=33,136,146; NOTE: also FDA-approved to improve survival post-MI complicated by heart failure/LV dysfunction
    "TRANDOLAPRIL"  # n=1,363,466; NOTE: also FDA-approved for post-MI LV dysfunction/heart failure
  )
)

spec_acei_v2 <- DrugSpec$new(
  "acei", "ACE Inhibitors",
  version = "v2",
  defs    = "From First Data Bank (FDB).",
  # 2026-08-23: priority tiers added (this spec previously had none), same
  # rationale as spec_acei_v1: standalone ingredients with a distinct
  # additional FDA-approved indication (heart failure, post-MI, stable CAD)
  # move to generic_names_probable; fixed-dose antihypertensive combination
  # products stay priority 1 regardless of a standalone component's other
  # indications (matching the rest of the file's convention). ENALAPRILAT
  # DIHYDRATE (IV form) stays priority 1 -- its own approved indication is
  # narrower (hypertensive emergencies only), not heart failure.
  generic_names = c(
    "AMLODIPINE BESYLATE/BENAZEPRIL",  # n=38,671,935 in MC Rx table
    "BENAZEPRIL",
    "BENAZEPRIL HCL",  # n=39,100,906 in MC Rx table
    "BENAZEPRIL/HYDROCHLOROTHIAZIDE",  # n=7,330,130 in MC Rx table
    "CAPTOPRIL/HYDROCHLOROTHIAZIDE",  # n=195,735 in MC Rx table
    "ENALAPRIL MALEATE/FELODIPINE",  # n=637 in MC Rx table
    "ENALAPRIL MALEATE/HCTZ",  # n=3 in MC Rx table
    "ENALAPRIL/HYDROCHLOROTHIAZIDE",  # n=3,262,351 in MC Rx table
    "ENALAPRILAT DIHYDRATE",  # n=11,908 in MC Rx table
    "FOSINOPRIL/HYDROCHLOROTHIAZIDE",  # n=386,427 in MC Rx table
    "LISINOPRIL/HYDROCHLOROTHIAZIDE",  # n=143,246,937 in MC Rx table
    "MOEXEPRIL",
    "MOEXIPRIL",
    "MOEXIPRIL HCL",  # n=700,755 in MC Rx table
    "MOEXIPRIL/HYDROCHLOROTHIAZIDE",  # n=348,350 in MC Rx table
    "PERINDOPRIL ARG/AMLODIPINE BES",  # n=17,656 in MC Rx table
    "QUINAPRIL/HYDROCHLOROTHIAZIDE",  # n=1,723,417 in MC Rx table
    "TRANDOLAPRIL/VERAPAMIL HCL"  # n=464,374 in MC Rx table
  ),
  generic_names_probable = c(
    "CAPTOPRIL",  # n=2,536,660; NOTE: also FDA-approved for heart failure, post-MI LV dysfunction, and diabetic nephropathy
    "ENALAPRIL",  # NOTE: also FDA-approved for symptomatic heart failure
    "ENALAPRIL MALEATE",  # n=41,907,960; NOTE: also FDA-approved for symptomatic heart failure
    "FOSINIPRIL",  # NOTE: also FDA-approved for heart failure
    "FOSINOPRIL",  # NOTE: also FDA-approved for heart failure
    "FOSINOPRIL SODIUM",  # n=4,651,718; NOTE: also FDA-approved for heart failure
    "LISINOPRIL",  # n=659,049,069; NOTE: also FDA-approved for heart failure and acute MI
    "PERINDOPRIL",  # NOTE: also FDA-approved to reduce CV death/non-fatal MI risk in stable CAD
    "PERINDOPRIL ERBUMINE",  # n=515,270; NOTE: also FDA-approved to reduce CV death/non-fatal MI risk in stable CAD
    "QUINAPRIL",  # NOTE: also FDA-approved for heart failure
    "QUINAPRIL HCL",  # n=13,127,354; NOTE: also FDA-approved for heart failure
    "RAMIPRIL",  # n=33,136,146; NOTE: also FDA-approved to improve survival post-MI complicated by heart failure/LV dysfunction
    "TRANDOLAPRIL"  # n=1,363,466; NOTE: also FDA-approved for post-MI LV dysfunction/heart failure
  )
)

### Aldosterone antagonists ----

spec_aldo_v1 <- DrugSpec$new(
  "aldo", "Aldosterone Antagonists",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  # Migrated to generic_defs (2026-08-15) as a proof of concept for
  # condition-specific priority tiers; every row is still tagged
  # "hypertension" for now (no behavior change — see AGENTS.md).
  generic_defs = tibble::tribble(
    ~generic,                     ~priority, ~condition,     ~brand,
    "HCTZ/SPIRONOLACTONE",        1L,        "hypertension", NA,
    "SPIRONOLACTONE/HCTZ",        1L,        "hypertension", NA,
    "EPLERENONE",                 2L,        "hypertension", "Inspra",
    "SPIRONOLACTONE",             2L,        "hypertension", NA,
    "SPIRONOLACTONE, MICRONIZED", 2L,        "hypertension", NA,
    # @BKB: please review this priority = 3L tag. Per the priority-tier
    # definition (P3 = indicated for the condition, alone or with others,
    # but only outside the US), FINERENONE doesn't appear to have a
    # hypertension indication anywhere -- Kerendia is approved worldwide
    # (US, EU, Japan, China, 95+ countries) for CKD associated with T2D
    # (and, as of 2025-2026, HF with LVEF >=40%), not for hypertension in
    # any market. If confirmed, this row doesn't fit any of the three
    # tiers and should probably be excluded from the hypertension spec
    # entirely rather than tagged priority 3. Flagging for manual
    # confirmation rather than changing unilaterally.
    # Sources:
    #   - https://www.bayer.com/media/en-us/us-fda-approves-finerenone-for-new-indication-in-patients-with-heart-failure-with-left-ventricular-ejection-fraction-of--40/
    #     ("finerenone is approved for the treatment of adult patients with
    #     CKD associated with T2D in more than 95 countries worldwide,
    #     including in China, Europe, Japan, and the U.S."; new HF LVEF>=40%
    #     indication as of July 2025 -- neither indication is hypertension)
    #   - https://pace-cme.org/news/fda-approves-new-indication-for-finerenone-in-patients-with-hfmrefhfpef/2475672/
    #     ("Finerenone was previously approved in the U.S. for the treatment
    #     of adults with CKD associated with T2D ... It is authorized in
    #     over 95 countries ... for this indication")
    "FINERENONE",                 3L,        "hypertension", "Kerendia"
  ),
  # HCTZ/SPIRONOLACTONE: n=27 in MC Rx table
  # SPIRONOLACTONE/HCTZ: n=9 in MC Rx table
  # EPLERENONE: n=4,270,119; also approved for post-MI heart failure with LV dysfunction
  # SPIRONOLACTONE: n=134,722,193; also used for heart failure, primary hyperaldosteronism, PCOS, and feminizing HRT
  # SPIRONOLACTONE, MICRONIZED: n=2,803; also used for heart failure, primary hyperaldosteronism, PCOS, and feminizing HRT
)

### Alpha-1 blockers ----

spec_alpha_v1 <- DrugSpec$new(
  "alpha", "Alpha-1 Blockers",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c(
    "PRAZOSIN HCL/POLYTHIAZIDE"  # n=9 in MC Rx table; fixed-dose antihypertensive combo, not prescribed for PTSD
  ),
  generic_names_probable = c(
    "DOXAZOSIN",  # NOTE: also approved for BPH; ER formulation is BPH-only (not HTN)
    "DOXAZOSIN MESYLATE",  # n=30,006,202; NOTE: also approved for BPH; ER formulation is BPH-only (not HTN)
    "PRAZOSIN",  # NOTE: also used for PTSD-related nightmares (VA/DoD guideline first-line)
    "PRAZOSIN HCL",  # n=27,727,643; NOTE: also used for PTSD-related nightmares (VA/DoD guideline first-line)
    "TERAZOSIN",  # NOTE: also approved for BPH
    "TERAZOSIN HCL"  # n=18,490,325; NOTE: also approved for BPH
  )
)

### Alpha-beta blockers ----
spec_alpha_beta_v1 <- DrugSpec$new(
  "alpha_beta", "Alpha-Beta Blockers",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # LABETALOL is also used for hypertension of pregnancy (pre-eclampsia),
  # but per bkbellows's PR #1 review that's still "hypertension" rather
  # than a distinct condition, so it's intentionally left at priority 1
  # (see AGENTS.md). CARVEDILOL, however, has genuinely distinct additional
  # FDA-approved indications (heart failure, post-MI LV dysfunction) and
  # moves to generic_names_probable.
  generic_names = c(
    "LABETALOL",
    "LABETALOL HCL"  # n=24,814,249 in MC Rx table
    # "LABETALOL IN DEXTROSE 5 %",  # n=5 in MC Rx table (this is an IV)
    # "LABETALOL IN NACL, ISO-OSMOTIC"  # n=27 in MC Rx table (this is an IV)
  ),
  generic_names_probable = c(
    "CARVEDILOL",  # n=191,074,509; NOTE: also FDA-approved for heart failure and post-MI LV dysfunction
    "CARVEDILOL PHOSPHATE"  # n=3,747,156; NOTE: also FDA-approved for heart failure and post-MI LV dysfunction
  )
)

spec_alpha_beta_v2 <- DrugSpec$new(
  "alpha_beta", "Alpha-Beta Blockers",
  version = "v2",
  defs    = "From First Data Bank (FDB). Adds LABETOLOL spelling variant.",
  # 2026-08-23: priority tiers added -- see spec_alpha_beta_v1 for rationale.
  generic_names = c(
    "LABETALOL",
    "LABETOLOL"
  ),
  generic_names_probable = c(
    "CARVEDILOL"  # n=191,074,509; NOTE: also FDA-approved for heart failure and post-MI LV dysfunction
  )
)

### ARBs ----
spec_arb_v1 <- DrugSpec$new(
  "arb", "Angiotensin Receptor Blockers (ARBs)",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none). ARBs
  # with a distinct additional FDA-approved indication (heart failure,
  # diabetic nephropathy) move to generic_names_probable. TELMISARTAN's
  # only other label claim is cardiovascular risk reduction in high-risk
  # patients unable to take ACE inhibitors -- not a separately diagnosed
  # condition -- so it stays priority 1, unlike the CAD/HF-type claims for
  # the ACE inhibitors above.
  # @BKB: this CV-risk-reduction-vs-distinct-condition line is more
  # subjective than the other tiering calls in this file -- please
  # spot-check whether TELMISARTAN's ONTARGET-based indication really
  # belongs outside priority 2 (compare against PERINDOPRIL above, which
  # was moved to probable for a similarly-framed stable-CAD risk-reduction
  # claim).
  generic_names = c(
    "AZILSARTAN",
    "EPROSARTAN",
    "OLMESARTAN",
    "TELMISARTAN"  # n=15,875,773 in MC Rx table
  ),
  generic_names_probable = c(
    "CANDESARTAN",  # NOTE: also FDA-approved for chronic heart failure (NYHA II-IV)
    "IRBESARTAN",  # n=30,438,200; NOTE: also FDA-approved for diabetic nephropathy in T2D
    "LOSARTAN",  # NOTE: also FDA-approved for diabetic nephropathy in T2D
    "VALSARTAN"  # n=68,668,702; NOTE: also FDA-approved for chronic heart failure and post-MI LV dysfunction
  )
)

spec_arb_v2 <- DrugSpec$new(
  "arb", "Angiotensin Receptor Blockers (ARBs)",
  version = "v2",
  defs    = "From First Data Bank (FDB). Adds OLMESARTEN spelling variant.",
  # 2026-08-23: priority tiers added -- see spec_arb_v1 for rationale.
  # Fixed-dose antihypertensive combination products stay priority 1
  # regardless of a standalone component's other indications.
  generic_names = c(
    "AMLODIPINE BES/OLMESARTAN MED",  # n=8,209,749 in MC Rx table
    "AMLODIPINE BESYLATE/VALSARTAN",  # n=4,094,379 in MC Rx table
    "AMLODIPINE/VALSARTAN",  # n=5,148,545 in MC Rx table
    "AMLODIPINE/VALSARTAN/HCTHIAZID",  # n=2,301,457 in MC Rx table
    "AMLODIPINE/VALSARTAN/HCTZ",  # n=453,468 in MC Rx table
    "AZILSARTAN",
    "AZILSARTAN MED/CHLORTHALIDONE",  # n=2,480,588 in MC Rx table
    "AZILSARTAN MEDOXOMIL",  # n=2,408,516 in MC Rx table
    "CANDESARTAN CILEXETIL/HCTZ",  # n=3 in MC Rx table
    "CANDESARTAN/HYDROCHLOROTHIAZID",  # n=1,787,845 in MC Rx table
    "EPROSARTAN",
    "EPROSARTAN MESYLATE",  # n=49,411 in MC Rx table
    "EPROSARTAN/HYDROCHLOROTHIAZIDE",  # n=21,511 in MC Rx table
    "IRBESARTAN/HYDROCHLOROTHIAZIDE",  # n=8,128,615 in MC Rx table
    "LOSARTAN POTASSIUM/HCTZ",  # n=8 in MC Rx table
    "LOSARTAN/HYDROCHLOROTHIAZIDE",  # n=104,228,299 in MC Rx table
    "NEBIVOLOL HCL/VALSARTAN",  # n=10,523 in MC Rx table
    "OLMESARTAN",
    "OLMESARTAN MED/AMLODIPINE/HCTZ",  # n=486,595 in MC Rx table
    "OLMESARTAN MEDOXOMIL",  # n=43,759,431 in MC Rx table
    "OLMESARTAN/AMLODIPIN/HCTHIAZID",  # n=4,201,739 in MC Rx table
    "OLMESARTAN/HYDROCHLOROTHIAZIDE",  # n=22,004,651 in MC Rx table
    "OLMESARTEN",
    "OLMESARTN/HYDROCHLOROTHIAZIDE",  # n=128,042 in MC Rx table
    "TELMISARTAN",  # n=15,875,773 in MC Rx table
    "TELMISARTAN/AMLODIPINE",  # n=425,910 in MC Rx table
    "TELMISARTAN/HYDROCHLOROTHIAZID"  # n=6,353,512 in MC Rx table
  ),
  generic_names_probable = c(
    "CANDESARTAN",  # NOTE: also FDA-approved for chronic heart failure (NYHA II-IV)
    "CANDESARTAN CILEXETIL",  # n=6,691,116; NOTE: also FDA-approved for chronic heart failure (NYHA II-IV)
    "IRBESARTAN",  # n=30,438,200; NOTE: also FDA-approved for diabetic nephropathy in T2D
    "LOSARTAN",  # NOTE: also FDA-approved for diabetic nephropathy in T2D
    "LOSARTAN POTASSIUM",  # n=404,382,651; NOTE: also FDA-approved for diabetic nephropathy in T2D
    "VALSARTAN"  # n=68,668,702; NOTE: also FDA-approved for chronic heart failure and post-MI LV dysfunction
  )
)

### Beta blockers: cardioselective  ----
spec_beta_cardio_v1 <- DrugSpec$new(
  "beta_cardio", "Beta Blockers (Cardioselective)",
  version = "v1",
  defs    = "Cardioselective beta blockers from the Perisphere antihypertensive medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # ATENOLOL and the METOPROLOL salts carry distinct additional FDA-approved
  # indications (angina, acute MI, heart failure for the succinate salt) and
  # move to generic_names_probable. BISOPROLOL is guideline-recommended for
  # heart failure (one of the three classic HFrEF beta blockers) but its US
  # label remains hypertension-only, unlike carvedilol/metoprolol succinate
  # -- that HF use is off-label in the US, so it stays priority 1 per the
  # "indicated" (not just well-documented off-label) reading used elsewhere
  # in this tiering scheme. BETAXOLOL (oral) has no other oral indication;
  # its ophthalmic (glaucoma) form is a separate product/GNRC_NM.
  generic_names = c(
    "ATENOLOL/CHLORTHALIDONE",  # n=9,970,067 in MC Rx table
    "BETAXOLOL",
    "BETAXOLOL HCL",  # n=856,860 in MC Rx table
    "BISOPROL/HYDROCHLOROTHIAZIDE",  # n=1,114,763 in MC Rx table
    "BISOPROLOL",
    "BISOPROLOL FUMARATE",  # n=12,350,330; NOTE: guideline-recommended for HFrEF, but this is off-label in the US (no FDA HF indication)
    "BISOPROLOL FUMARATE/HCTZ",  # n=5,399,045 in MC Rx table
    "BISOPROLOL/HYDROCHLOROTHIAZIDE",  # n=7,336,325 in MC Rx table
    "CHLORTHALIDONE/ATENOLOL",  # n=32 in MC Rx table
    "METOPROLOL SU/HYDROCHLOROTHIAZ",  # n=48,126 in MC Rx table
    "METOPROLOL SUCCINATE/HCTZ",  # n=56,464 in MC Rx table
    "METOPROLOL/HYDROCHLOROTHIAZIDE",  # n=1,266,691 in MC Rx table
    "METOPROL/HYDROCHLOROTHIAZIDE"  # n=17,286 in MC Rx table
  ),
  generic_names_probable = c(
    "ATENOLOL",  # n=133,656,295; NOTE: also FDA-approved for angina and acute MI
    "METOPROLOL",  # NOTE: also FDA-approved for angina, acute MI, and (succinate ER) heart failure
    "METOPROLOL SUCCINATE",  # n=362,686,652; NOTE: also FDA-approved for chronic heart failure (NYHA II-III)
    "METOPROLOL TARTRATE"  # n=238,634,149; NOTE: also FDA-approved for angina and acute MI
  )
)

### Beta blockers: cardioselective-vasodilatory ----
# NEBIVOLOL/NEBIVOLOL HCL reviewed for priority tiers (2026-08-23): nebivolol
# is used for heart failure in Europe (Nebilet), but that indication is not
# FDA-approved -- its only US-approved indication is hypertension -- so it
# stays priority 1 (no probable/cautious tier warranted).
spec_beta_cardio_vasod_v1 <- DrugSpec$new(
  "beta_cardio_vasod", "Beta Blockers (Cardioselective, Vasodilatory)",
  version = "v1",
  defs    = "Cardioselective vasodilatory beta blocker from the Perisphere antihypertensive medication list.",
  generic_names = c(
    "NEBIVOLOL",
    "NEBIVOLOL HCL"  # n=39,298,685 in MC Rx table
  )
)

### Beta blockers: ISA ----
# 2026-08-23: priority tiers added (this spec previously had none).
# ACEBUTOLOL is also FDA-approved for ventricular arrhythmias (PVCs); the
# other ISA beta blockers here have no other US-approved indication.
spec_beta_int_sym_v1 <- DrugSpec$new(
  "beta_int_sym", "Beta Blockers (Intrinsic Sympathomimetic Activity)",
  version = "v1",
  defs    = "ISA beta blockers from the Perisphere antihypertensive medication list.",
  generic_names = c(
    "CARTEOLOL",
    "PENBUTOLOL",
    "PINDOLOL"  # n=856,187 in MC Rx table
  ),
  generic_names_probable = c(
    "ACEBUTOLOL"  # NOTE: also FDA-approved for ventricular arrhythmias (PVCs)
  )
)

spec_beta_int_sym_v2 <- DrugSpec$new(
  "beta_int_sym", "Beta Blockers (Intrinsic Sympathomimetic Activity)",
  version = "v2",
  defs    = "ISA beta blockers from FDB. Excludes CARTEOLOL and PENBUTOLOL.",
  generic_names = c(
    "CARTEOLOL HCL",  # n=295,236 in MC Rx table
    "PENBUTOLOL SULFATE",  # n=7,256 in MC Rx table
    "PINDOLOL"  # n=856,187 in MC Rx table
  ),
  generic_names_probable = c(
    "ACEBUTOLOL",  # NOTE: also FDA-approved for ventricular arrhythmias (PVCs)
    "ACEBUTOLOL HCL"  # n=1,592,039; NOTE: also FDA-approved for ventricular arrhythmias (PVCs)
  )
)

### Beta blockers: noncardioselective  ----
spec_beta_noncardio_v1 <- DrugSpec$new(
  "beta_noncardio", "Beta Blockers (Noncardioselective)",
  version = "v1",
  defs    = "Noncardioselective beta blockers from the Perisphere antihypertensive medication list.",
  generic_names = c(
    "HCTZ/PROPRANOLOL HCL",  # n=1 in MC Rx table
    "NADOLOL",  # n=8,721,728 in MC Rx table
    "NADOLOL/BENDROFLUMETHIAZIDE",  # n=39,079 in MC Rx table
    "PROPRANOLOL HCL/HCTZ",  # n=45 in MC Rx table
    "PROPRANOLOL/HYDROCHLOROTHIAZID",  # n=104,281 in MC Rx table
    "TIMOLOL/HYDROCHLOROTHIAZIDE"  # n=2 in MC Rx table
  ),
  generic_names_probable = c(
    "PROPRANOLOL",  # NOTE: also approved for angina, arrhythmias, essential tremor, migraine prophylaxis, and portal HTN
    "PROPRANOLOL HCL",  # n=90,513,340; NOTE: also approved for angina, arrhythmias, essential tremor, migraine prophylaxis, and portal HTN
    "TIMOLOL",  # n=766,670; NOTE: also approved for angina and migraine prevention
    "TIMOLOL MALEATE"  # n=33,785,241; NOTE: also approved for angina and migraine prevention
  )
)

### CCB: dihydropyridines ----
# CCB DHP: no v2 change — same list in both Perisphere and FDB sources.
spec_ccb_dhp_v1 <- DrugSpec$new(
  "ccb_dhp", "Calcium Channel Blockers (Dihydropyridines)",
  version = "v1",
  defs    = "Dihydropyridine CCBs from the Perisphere antihypertensive medication list and FDB.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # AMLODIPINE and NIFEDIPINE are also FDA-approved for angina; oral
  # NICARDIPINE likewise. The IV/infusion NICARDIPINE formulations stay
  # priority 1 -- that's a known route-of-administration gap in this
  # tiering scheme (see AGENTS.md), not a change here. FELODIPINE,
  # ISRADIPINE, LEVAMLODIPINE MALEATE, and NISOLDIPINE have no other known
  # US-approved indication. AMLODIPINE BESYLATE/CELECOXIB is a discontinued
  # niche combo product, left untouched per AGENTS.md.
  generic_names = c(
    "AMLODIPINE BESYLATE/CELECOXIB",  # n=292 in MC Rx table
    "FELODIPINE",  # n=6,536,585 in MC Rx table
    "ISRADIPINE",  # n=300,988 in MC Rx table
    "LEVAMLODIPINE MALEATE",  # n=1,561 in MC Rx table
    "NICARDIPINE HCL IN 0.9% NACL",  # n=1,437 in MC Rx table
    "NICARDIPINE HCL-0.9% SOD CHLOR",  # n=35 in MC Rx table
    "NICARDIPINE IN 5 % DEXTROSE",  # n=1 in MC Rx table
    "NICARDIPINE IN DEXTROSE,ISO-OS",  # n=43 in MC Rx table
    "NICARDIPINE IN NACL, ISO-OSM",  # n=28,752 in MC Rx table
    "NISOLDIPINE"  # n=872,050 in MC Rx table
  ),
  generic_names_probable = c(
    "AMLODIPINE",  # NOTE: also FDA-approved for chronic stable and vasospastic angina, and CAD
    "AMLODIPINE BENZOATE",  # n=98,290; NOTE: also FDA-approved for chronic stable and vasospastic angina, and CAD
    "AMLODIPINE BESYLATE",  # n=609,583,943; NOTE: also FDA-approved for chronic stable and vasospastic angina, and CAD
    "NICARDIPINE",  # NOTE: oral form also FDA-approved for chronic stable angina
    "NICARDIPINE HCL",  # n=208,932; NOTE: oral form also FDA-approved for chronic stable angina
    "NIFEDIPINE",  # n=56,763,296; NOTE: also FDA-approved for chronic stable and vasospastic angina
    "NIFEDIPINE, MICRONIZED"  # n=1,715; NOTE: also FDA-approved for chronic stable and vasospastic angina
  )
)

### CCB: non-dihydropyridines ----
spec_ccb_nondhp_v1 <- DrugSpec$new(
  "ccb_nondhp", "Calcium Channel Blockers (Non-Dihydropyridines)",
  version = "v1",
  defs    = "Non-dihydropyridine CCBs from the Perisphere antihypertensive medication list.",
  generic_names_probable = c(
    "DILTIAZEM",  # NOTE: also widely used for AF rate control and angina
    "DILTIAZEM HCL",  # n=97,751,376; NOTE: also widely used for AF rate control and angina
    "DILTIAZEM MALATE",  # n=1; NOTE: also widely used for AF rate control and angina
    "VERAPAMIL",  # NOTE: also used for SVT, AF rate control, and angina
    "VERAPAMIL HCL"  # n=36,104,608; NOTE: also used for SVT, AF rate control, and angina
  )
)

### Centrally acting agents ----
spec_central_v1 <- DrugSpec$new(
  "central", "Centrally Acting Agents",
  version = "v1",
  defs    = "Centrally acting antihypertensives from the Perisphere list. Note: exclude APRACLONIDINE when matching CLONIDINE.",
  generic_names = c(
    "METHYLDOPA"  # n=1,313,741 in MC Rx table
  ),
  generic_names_probable = c(
    "CLONIDINE",  # n=7,489,006; NOTE: also used for ADHD (Kapvay ER) and opioid/alcohol withdrawal
    "GUANFACINE"  # NOTE: ER form (Intuniv) is approved for ADHD; same GNRC_NM covers both HTN and ADHD indications
  ),
  brand_names = list(
    # ADHD-approved ER brands; the HTN-indicated brands (Catapres, Tenex)
    # were never discussed in the PR review, so only the ADHD brand is
    # recorded here for now.
    CLONIDINE  = "Kapvay",
    GUANFACINE = "Intuniv"
  )
)

spec_central_v2 <- DrugSpec$new(
  "central", "Centrally Acting Agents",
  version = "v2",
  defs    = "Centrally acting antihypertensives from FDB. Note: exclude APRACLONIDINE when matching CLONIDINE.",
  generic_names = c(
    "CLONIDINE HCL/CHLORTHALIDONE",  # n=8,778 in MC Rx table
    "GUANABENZ",
    "GUANABENZ ACETATE",  # n=808 in MC Rx table
    "HYDRALAZINE HCL/RESERPINE/HCTZ",  # n=5 in MC Rx table
    "HYDRALAZINE/RESERPIN/HCTHIAZID",  # n=4 in MC Rx table
    "HYDRALAZINE/RESERPIN/HCTZ",  # n=13 in MC Rx table
    "METHYLDOPA",  # n=1,313,741 in MC Rx table
    "METHYLDOPA/CHLOROTHIAZIDE",  # n=1 in MC Rx table
    "METHYLDOPA/HYDROCHLOROTHIAZIDE",  # n=27,242 in MC Rx table
    "METHYLDOPATE HCL",  # n=61 in MC Rx table
    "RESERPINE",  # n=6,204 in MC Rx table
    "RESERPINE/CHLOROTHIAZIDE",  # n=6 in MC Rx table
    "RESERPINE/CHLORTHALIDONE",  # n=1 in MC Rx table
    "RESERPINE/HYDROCHLOROTHIAZIDE",  # n=46 in MC Rx table
    "RESERPINE/HYDROFLUMETHIAZIDE",  # n=10 in MC Rx table
    "RESERPINE/TRICHLORMETHIAZIDE"  # n=1 in MC Rx table
  ),
  generic_names_probable = c(
    "CLONIDINE",  # n=7,489,006; NOTE: also used for ADHD (Kapvay ER) and opioid/alcohol withdrawal
    "CLONIDINE HCL",  # n=96,485,351; NOTE: also used for ADHD (Kapvay ER) and opioid/alcohol withdrawal
    "GUANFACINE",  # NOTE: ER form (Intuniv) is approved for ADHD; same GNRC_NM covers both HTN and ADHD indications
    "GUANFACINE HCL"  # n=40,070,257; NOTE: ER form (Intuniv) is approved for ADHD; same GNRC_NM covers both HTN and ADHD indications
  ),
  brand_names = list(
    CLONIDINE      = "Kapvay",
    "CLONIDINE HCL" = "Kapvay",
    GUANFACINE     = "Intuniv",
    "GUANFACINE HCL" = "Intuniv"
  )
)

### Diuretics: thiazide ----
# 2026-08-23: priority tiers added to spec_diuretics_thiazide_v1/v2 (these
# previously had none). Thiazide/thiazide-type diuretic labels list "edema"
# (associated with heart failure, hepatic cirrhosis, corticosteroid/estrogen
# therapy, or renal dysfunction) as a distinct FDA-approved indication
# alongside hypertension -- the same rationale already used for loop
# diuretics (spec_diuretics_loop_v1/v2) in this file -- so every standalone
# entry here moves to generic_names_probable rather than staying priority 1.
spec_diuretics_thiazide_v1 <- DrugSpec$new(
  "diuretics_thiazide", "Diuretics (Thiazide and Thiazide-Type)",
  version = "v1",
  defs    = "Thiazide diuretics from the Perisphere antihypertensive medication list.",
  generic_names_probable = c(
    "BENDROFLUMETHIAZIDE",  # n=3; NOTE: also FDA-approved for edema
    "CHLOROTHIAZIDE",  # n=282,136; NOTE: also FDA-approved for edema
    "CHLOROTHIAZIDE SODIUM",  # n=26,344; NOTE: also FDA-approved for edema
    "CHLORTHALIDONE",  # n=40,665,762; NOTE: also FDA-approved for edema
    "HCTZ",  # NOTE: also FDA-approved for edema
    "HYDROCHLOROTHIAZIDE",  # n=313,609,977; NOTE: also FDA-approved for edema
    "INDAPAMIDE",  # n=5,810,554; NOTE: also FDA-approved for edema associated with heart failure
    "METOLAZONE",  # n=10,414,571; NOTE: also FDA-approved for edema (heart failure, renal disease)
    "POLYTHIAZIDE"  # n=12; NOTE: also FDA-approved for edema
  )
)

spec_diuretics_thiazide_v2 <- DrugSpec$new(
  "diuretics_thiazide", "Diuretics (Thiazide and Thiazide-Type)",
  version = "v2",
  defs    = "Thiazide diuretics from FDB. Includes additional agents and spelling variants.",
  generic_names_probable = c(
    "BENDROFLUMETHIAZIDE",  # n=3; NOTE: also FDA-approved for edema
    "CHLOROTHIAZIDE",  # n=282,136; NOTE: also FDA-approved for edema
    "CHLOROTHIAZIDE SODIUM",  # n=26,344; NOTE: also FDA-approved for edema
    "CHLORTHALIDONE",  # n=40,665,762; NOTE: also FDA-approved for edema
    "HCTZ",  # NOTE: also FDA-approved for edema
    "HYDROCHLOROTHIAZIDE",  # n=313,609,977; NOTE: also FDA-approved for edema
    "HYDROCHOLOROTHIAZIDE",  # NOTE: also FDA-approved for edema (spelling variant of hydrochlorothiazide)
    "INDAPAMIDE",  # n=5,810,554; NOTE: also FDA-approved for edema associated with heart failure
    "METOLAZONE",  # n=10,414,571; NOTE: also FDA-approved for edema (heart failure, renal disease)
    "POLYTHIAZIDE"  # n=12; NOTE: also FDA-approved for edema
  )
)

### Diuretics: loop ----
spec_diuretics_loop_v1 <- DrugSpec$new(
  "diuretics_loop", "Diuretics (Loop)",
  version = "v1",
  defs    = "Loop diuretics from the Perisphere antihypertensive medication list.",
  generic_names_probable = c(
    "BUMETANIDE",  # n=22,577,818; NOTE: primarily prescribed for heart failure/edema in US practice
    "FUROSEMIDE",  # n=280,141,596; NOTE: primarily prescribed for heart failure/edema in US practice
    "TORSEMIDE"  # n=24,278,347; NOTE: primarily prescribed for heart failure/edema in US practice
  )
)

spec_diuretics_loop_v2 <- DrugSpec$new(
  "diuretics_loop", "Diuretics (Loop)",
  version = "v2",
  defs    = "Loop diuretics from FDB. Adds ETHACRYNIC ACID.",
  generic_names = c(
    "ETHACRYNIC ACID",  # n=356,706 in MC Rx table
    "FUROSEMIDE IN 0.9 % NACL"  # n=234; NOTE: IV infusion — inpatient-only; antihypertensive use is negligible
  ),
  generic_names_probable = c(
    "BUMETANIDE",  # n=22,577,818; NOTE: primarily prescribed for heart failure/edema in US practice
    "FUROSEMIDE",  # n=280,141,596; NOTE: primarily prescribed for heart failure/edema in US practice
    "TORSEMIDE"  # n=24,278,347; NOTE: primarily prescribed for heart failure/edema in US practice
  )
)

### Diuretics: potassium-sparing ----
# 2026-08-23: priority tiers added to spec_diuretics_ksparing_v1/v2 (these
# previously had none). AMILORIDE and TRIAMTERENE labels list "edema"
# (heart failure, hepatic cirrhosis, nephrotic syndrome, steroid-induced,
# idiopathic) as a distinct FDA-approved indication alongside hypertension
# -- same rationale as the thiazide diuretics above -- so the standalone
# ingredients move to generic_names_probable. Fixed-dose antihypertensive
# combination products stay priority 1, matching the convention used
# throughout this file.
spec_diuretics_ksparing_v1 <- DrugSpec$new(
  "diuretics_ksparing", "Diuretics (Potassium-Sparing)",
  version = "v1",
  defs    = "Potassium-sparing diuretics from the Perisphere antihypertensive medication list.",
  generic_names_probable = c(
    "AMILORIDE",  # NOTE: also FDA-approved for edema
    "TRIAMTERENE"  # n=308,537; NOTE: also FDA-approved for edema
  )
)

spec_diuretics_ksparing_v2 <- DrugSpec$new(
  "diuretics_ksparing", "Diuretics (Potassium-Sparing)",
  version = "v2",
  defs    = "Potassium-sparing diuretics from FDB. Adds spelling variants.",
  generic_names = c(
    "AMILORIDE HCL/HCTZ",  # n=21 in MC Rx table
    "AMILORIDE/HYDROCHLOROTHIAZIDE",  # n=1,025,583 in MC Rx table
    "HCTZ/TRIAMTERENE",  # n=1,826 in MC Rx table
    "HYDROCHLOROTHIAZIDE/AMILOR HCL",  # n=32 in MC Rx table
    "TRIAMTERENE/HCTZ",  # n=149 in MC Rx table
    "TRIAMTERENE/HYDROCHLOROTHIAZID"  # n=66,530,088 in MC Rx table
  ),
  generic_names_probable = c(
    "AMILORIDE",  # NOTE: also FDA-approved for edema
    "AMILORIDE HCL",  # n=1,731,096; NOTE: also FDA-approved for edema
    "TRIAMTERENE",  # n=308,537; NOTE: also FDA-approved for edema
    "TRIAMTERINE",  # NOTE: spelling variant of triamterene; also FDA-approved for edema
    "TRIMATERENE"  # NOTE: spelling variant of triamterene; also FDA-approved for edema
  )
)

### Direct renin inhibitors ----
# Priority tiers reviewed (2026-08-23): ALISKIREN's only FDA-approved
# indication is hypertension (its diabetic-nephropathy combination-therapy
# program was discontinued for safety reasons, not approved); remains
# priority 1.
spec_renin_v1 <- DrugSpec$new(
  "renin", "Direct Renin Inhibitors",
  version = "v1",
  defs    = "Direct renin inhibitors from the Perisphere antihypertensive medication list.",
  generic_names = c(
    "ALISKIREN",
    "ALISKIREN HEMIFUMARATE",  # n=1,771,161 in MC Rx table
    "ALISKIREN/AMLODIPIN/HCTHIAZIDE",  # n=7,400 in MC Rx table
    "ALISKIREN/AMLODIPINE",  # n=10,469 in MC Rx table
    "ALISKIREN/AMLODIPINE BESYLATE",  # n=25,388 in MC Rx table
    "ALISKIREN/AMLODIPINE/HCTZ",  # n=7,693 in MC Rx table
    "ALISKIREN/HYDROCHLOROTHIAZIDE",  # n=439,319 in MC Rx table
    "ALISKIREN/VALSARTAN"  # n=53,354 in MC Rx table
  )
)

### Direct vasodilators ----
spec_vasodilators_v1 <- DrugSpec$new(
  "vasodilators", "Direct Vasodilators",
  version = "v1",
  defs    = "Direct vasodilators from the Perisphere antihypertensive medication list.",
  generic_names = c(
    "HYDRALAZINE HCL/HCTZ",  # n=17 in MC Rx table
    "HYDRALAZINE/HYDROCHLOROTHIAZID"  # n=1,585 in MC Rx table
  ),
  generic_names_probable = c(
    "HYDRALAZINE",  # NOTE: also used for heart failure (isosorbide dinitrate + hydralazine regimen)
    "HYDRALAZINE HCL",  # n=59,439,978; NOTE: also used for heart failure (isosorbide dinitrate + hydralazine regimen)
    "MINOXIDIL"  # n=8,870,133; NOTE: also prescribed at low doses (off-label) for androgenic alopecia
  )
)

## Antihypertensive medication compositions ----

# Removed 2026-08-15: spec_betablockers, spec_ccb, and spec_diuretics were
# unused, unexported intermediate composites (drug-class groupings within
# antihypertensives) — every leaf they reference is already flattened
# directly into spec_hypertension below, and nothing else in this file
# referenced them. Deleted as dead code as part of formalizing that
# CompositeDrugSpec objects are always condition-scoped (a single
# `condition`), not drug-class-scoped.

### All antihypertensives ----

# All drug specs listed directly. Sub-composites (betablockers, ccb,
# diuretics) still exist as standalone objects but are kept flat here.
# If we nested, it would mean you'd have to run get_codes more than once,
# which would make the package feel too clunky.

spec_hypertension <- CompositeDrugSpec$new(
  drug_class = "antihypertensive",
  label      = "Antihypertensive Medications",
  defs       = paste0(
    "All antihypertensive leaf components across versions (v1 = Perisphere list; ",
    "v2 = FDB). Note for central agents: exclude APRACLONIDINE when matching CLONIDINE."
  ),
  condition  = "hypertension",
  components = list(
    acei_v1         = spec_acei_v1,
    acei_v2         = spec_acei_v2,
    arb_v1          = spec_arb_v1,
    arb_v2          = spec_arb_v2,
    alpha_v1        = spec_alpha_v1,
    alpha_beta_v1   = spec_alpha_beta_v1,
    alpha_beta_v2   = spec_alpha_beta_v2,
    cardio_v1       = spec_beta_cardio_v1,
    cardio_vasod_v1 = spec_beta_cardio_vasod_v1,
    int_sym_v1      = spec_beta_int_sym_v1,
    int_sym_v2      = spec_beta_int_sym_v2,
    noncardio_v1    = spec_beta_noncardio_v1,
    ccb_dhp_v1      = spec_ccb_dhp_v1,
    ccb_nondhp_v1   = spec_ccb_nondhp_v1,
    thiazide_v1     = spec_diuretics_thiazide_v1,
    thiazide_v2     = spec_diuretics_thiazide_v2,
    loop_v1         = spec_diuretics_loop_v1,
    loop_v2         = spec_diuretics_loop_v2,
    ksparing_v1     = spec_diuretics_ksparing_v1,
    ksparing_v2     = spec_diuretics_ksparing_v2,
    aldo_v1         = spec_aldo_v1,
    central_v1      = spec_central_v1,
    central_v2      = spec_central_v2,
    renin_v1        = spec_renin_v1,
    vasodilators_v1 = spec_vasodilators_v1
  )
)
