#' peridefs: Perisphere Medical Code Definitions
#'
#' @description
#' Provides structured, versioned medical code definitions (ICD-9, ICD-10,
#' HCPCS, CPT, Revenue codes, and drug generic names) for use in
#' claims-based research. Bundled code sets are pre-expanded and accessible
#' through a consistent R6-based API covering medical conditions and drug
#' classes.
#'
#' @section Main classes:
#' - [CodeSpec]: Versioned ICD/HCPCS/CPT code sets for a medical condition.
#' - [DrugSpec]: Versioned generic drug name (GNN) and NDC sets for a drug class.
#' - [CompositeCodeSpec]: Union of multiple [CodeSpec] objects (e.g., ASCVD).
#' - [CompositeDrugSpec]: Union of multiple [DrugSpec] objects (e.g., antihypertensives).
#'
#' @section ICD-10-PCS expansion:
#' The [expand_pcs()] function resolves prefix patterns (e.g., `"0210xxx"`)
#' to all matching valid ICD-10-PCS codes using the bundled FY2026 CMS
#' reference table.
#'
#' @keywords internal
"_PACKAGE"

# Suppress R CMD check notes about spec_* objects used in wrapper functions.
# All spec_* names are package data objects loaded lazily from data/.
utils::globalVariables(c(
  "spec_antidiab_alpha_glucosidase", "spec_antidiab_amylin",
  "spec_antidiab_biguanide", "spec_antidiab_dpp4", "spec_antidiab_glp1",
  "spec_antidiab_insulin", "spec_antidiab_meglitinide",
  "spec_antidiab_sglt2", "spec_antidiab_sulfonylurea", "spec_antidiab_tzd",
  "spec_antidiabetic", "spec_antihypertensive", "spec_arb", "spec_ascvd",
  "spec_beta_int_sym", "spec_beta_noncardio", "spec_betablockers",
  "spec_diuretics_ksparing", "spec_diuretics_loop", "spec_diuretics_thiazide",
  "spec_statin_fluvastatin", "spec_statin_lovastatin",
  "spec_statin_pitavastatin", "spec_statin_pravastatin",
  "spec_statin_rosuvastatin", "spec_statin_simvastatin", "spec_stroke"
))

# Explicit imports to satisfy R CMD check (used internally via R6, cli, etc.)
#' @importFrom R6 R6Class
#' @importFrom rlang abort
#' @importFrom tibble tibble
NULL
