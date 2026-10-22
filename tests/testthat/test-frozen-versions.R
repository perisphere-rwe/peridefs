# Frozen-version tests ------------------------------------------------------
#
# A released spec version (e.g. `diabetes_type2_v1`) must never change. If a
# code set, a condition/outcome flag, a drug generic, or a narrative needs to
# change, create a new version (`_v2`) instead of editing the released one.
#
# How this file enforces that:
#
# 1. Every released leaf spec is serialised to plain text and compared with
#    a snapshot file in `_snaps/frozen-versions/`. Any change to a released
#    version fails the test and shows a line-by-line diff.
# 2. The `.released_*` manifests below list every released version. A test
#    fails if a released version disappears from the package, or if a new
#    version appears that has not been added to the manifest. Adding a
#    version to the manifest is the explicit "this version is now released"
#    step.
# 3. Composite structure (which components exist, which are the defaults per
#    variable type) is snapshotted too, so changing what `get_ascvd_codes()`
#    returns by default is never silent.
# 4. Each exported `get_<condition>_<vN>_codes()` must return codes for the
#    condition and version its name claims.
#
# Code *descriptions* (the `definition` column) are deliberately NOT frozen:
# they come from CMS/NLM reference files and may be refreshed without a
# version bump. Everything that changes which patients a definition selects
# is frozen.
#
# Workflow:
# - First run (or a new version added to a manifest): testthat records the
#   snapshot. Review the new files in `_snaps/frozen-versions/` and commit.
# - A failure on an existing version means a released definition changed.
#   Revert the change and create a new version instead. Only accept the new
#   snapshot (`testthat::snapshot_accept("frozen-versions")`) for a
#   deliberate, documented correction.

# ---- Release manifests ------------------------------------------------------

# Condition leaf specs, identified as "<condition>_<version>". Includes the
# components of composite condition specs (e.g. the ASCVD components).
.released_condition_specs <- c(
  "asthma_v1",
  "cerebrovasc_disease_v1",
  "chd_v1",
  "ckd_v1",
  "copd_v1",
  "depression_v1",
  "diabetes_type1_v1",
  "diabetes_type2_v1",
  "hf_v1",
  "hyperlipidemia_v1",
  "hypertension_v1",
  "lead_pad_v1",
  "obesity_v1",
  "ohs_v1",
  "osa_v1",
  "osteoarthritis_v1",
  "stroke_v1"
)

# Drug leaf specs, identified as "<composite object>/<component key>".
.released_drug_specs <- c(
  # spec_depression
  "spec_depression/maoi_v1",
  "spec_depression/other_v1",
  "spec_depression/snri_v1",
  "spec_depression/ssri_v1",
  "spec_depression/tca_v1",
  # spec_diabetes_type1
  "spec_diabetes_type1/amylin_v1",
  "spec_diabetes_type1/insulin_v1",
  # spec_diabetes_type2
  "spec_diabetes_type2/alpha_glucosidase_v1",
  "spec_diabetes_type2/amylin_v1",
  "spec_diabetes_type2/biguanide_v1",
  "spec_diabetes_type2/dpp4_v1",
  "spec_diabetes_type2/glp1_v1",
  "spec_diabetes_type2/insulin_v1",
  "spec_diabetes_type2/meglitinide_v1",
  "spec_diabetes_type2/sglt2_v1",
  "spec_diabetes_type2/sulfonylurea_v1",
  "spec_diabetes_type2/tzd_v1",
  # spec_hyperlipidemia
  "spec_hyperlipidemia/bile_acid_seq_v1",
  "spec_hyperlipidemia/ezetimibe_v1",
  "spec_hyperlipidemia/fibrate_v1",
  "spec_hyperlipidemia/niacin_v1",
  "spec_hyperlipidemia/pcsk9_v1",
  "spec_hyperlipidemia/statin_v1",
  # spec_hypertension
  "spec_hypertension/acei_v1",
  "spec_hypertension/acei_v2",
  "spec_hypertension/aldo_v1",
  "spec_hypertension/alpha_beta_v1",
  "spec_hypertension/alpha_beta_v2",
  "spec_hypertension/alpha_v1",
  "spec_hypertension/arb_v1",
  "spec_hypertension/arb_v2",
  "spec_hypertension/cardio_v1",
  "spec_hypertension/cardio_vasod_v1",
  "spec_hypertension/ccb_dhp_v1",
  "spec_hypertension/ccb_nondhp_v1",
  "spec_hypertension/central_v1",
  "spec_hypertension/central_v2",
  "spec_hypertension/int_sym_v1",
  "spec_hypertension/int_sym_v2",
  "spec_hypertension/ksparing_v1",
  "spec_hypertension/ksparing_v2",
  "spec_hypertension/loop_v1",
  "spec_hypertension/loop_v2",
  "spec_hypertension/noncardio_v1",
  "spec_hypertension/renin_v1",
  "spec_hypertension/thiazide_v1",
  "spec_hypertension/thiazide_v2",
  "spec_hypertension/vasodilators_v1",
  # spec_obesity
  "spec_obesity/glp1_v1",
  "spec_obesity/non_glp1_v1"
)

# ---- Discovery helpers ------------------------------------------------------

.private <- function(x) x$.__enclos_env__$private

# All package datasets (spec_* objects), forced, as a named list.
.all_specs <- function() {
  env <- getNamespaceInfo("peridefs", "lazydata")
  nms <- sort(ls(env), method = "radix")
  stats::setNames(lapply(nms, get, envir = env), nms)
}

# Condition leaf specs keyed by "<condition>_<version>".
.condition_leaves <- function(specs) {
  out <- list()
  add <- function(s) {
    id <- paste0(s$condition, "_", s$version %||% "NOVERSION")
    if (!is.null(out[[id]]) && !identical(.code_lines(out[[id]]), .code_lines(s))) {
      stop("Two different condition specs share the id ", id, call. = FALSE)
    }
    out[[id]] <<- s
  }
  for (s in specs) {
    if (inherits(s, "CodeSpec")) add(s)
    if (inherits(s, "CompositeCodeSpec")) for (cs in s$components()) add(cs)
  }
  out
}

# Drug leaf specs keyed by "<composite object>/<component key>" (or by the
# object name for a standalone DrugSpec dataset).
.drug_leaves <- function(specs) {
  out <- list()
  for (nm in names(specs)) {
    s <- specs[[nm]]
    if (inherits(s, "DrugSpec")) out[[nm]] <- s
    if (inherits(s, "CompositeDrugSpec")) {
      comps <- s$components()
      for (k in names(comps)) out[[paste0(nm, "/", k)]] <- comps[[k]]
    }
  }
  out
}

# ---- Serialisers ------------------------------------------------------------
#
# Output is plain text, sorted in C-locale (radix) order, so snapshots are
# identical across machines and diff cleanly in git.

.csv_field <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "NA"
  paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
}

.csv_lines <- function(df) {
  body <- do.call(paste, c(lapply(df, .csv_field), sep = ","))
  c(paste(names(df), collapse = ","), sort(body, method = "radix"))
}

.text_block <- function(heading, x) {
  if (is.null(x) || !length(x)) return(c(paste0("[", heading, "]"), "<none>", ""))
  nms <- names(x)
  val <- if (is.null(nms)) as.character(x) else paste0(nms, ": ", x)
  c(paste0("[", heading, "]"), val, "")
}

# One row per (type, code) with its condition/outcome membership flags.
.code_lines <- function(spec) {
  codes <- .private(spec)$.codes
  rows <- lapply(names(codes), function(k) {
    kd <- codes[[k]]
    n  <- length(kd$codes)
    if (length(kd$condition) != n || length(kd$outcome) != n) {
      stop("Flag vectors out of sync with codes for key ", k, call. = FALSE)
    }
    data.frame(type = rep(k, n), code = kd$codes,
               condition = kd$condition, outcome = kd$outcome,
               stringsAsFactors = FALSE)
  })
  df <- do.call(rbind, rows)
  if (is.null(df)) {
    df <- data.frame(type = character(), code = character(),
                     condition = logical(), outcome = logical())
  }
  .csv_lines(df)
}

# Everything about a condition spec other than its code rows.
.condition_meta_lines <- function(spec) {
  p     <- .private(spec)
  codes <- p$.codes
  excl  <- unlist(lapply(names(codes), function(k) {
    if (is.null(codes[[k]]$exclusions)) NULL else .text_block(paste0("exclusions: ", k), codes[[k]]$exclusions)
  }))
  c(
    paste0("condition: ", spec$condition),
    paste0("version: ", spec$version),
    paste0("label: ", spec$label),
    paste0("code types: ", paste(names(codes), collapse = ", ")),
    "",
    .text_block("defs: condition", p$.defs$condition),
    .text_block("defs: outcome", p$.defs$outcome),
    excl
  )
}

# One row per generic with its priority, condition tag, and brand names.
.drug_lines <- function(spec) {
  g <- .private(spec)$.generics
  df <- data.frame(
    generic   = g$generic,
    priority  = g$priority,
    condition = if (is.null(g$condition)) rep(NA_character_, nrow(g)) else g$condition,
    brand     = vapply(g$brand, function(b) {
      paste(sort(as.character(b), method = "radix"), collapse = "|")
    }, character(1L)),
    stringsAsFactors = FALSE
  )
  .csv_lines(df)
}

.drug_meta_lines <- function(spec) {
  c(
    paste0("drug_class: ", spec$drug_class),
    paste0("version: ", spec$version),
    paste0("label: ", spec$label),
    "",
    .text_block("defs", .private(spec)$.defs)
  )
}

# Structure of every composite spec: component keys and default sets.
.composite_lines <- function(specs) {
  is_comp <- vapply(specs, function(s) {
    inherits(s, c("CompositeCodeSpec", "CompositeDrugSpec"))
  }, logical(1L))
  unlist(lapply(names(specs)[is_comp], function(nm) {
    s  <- specs[[nm]]
    p  <- .private(s)
    by <- p$.components_by_variable_type
    c(
      paste0("## ", nm, " <", class(s)[1L], ">"),
      paste0("condition: ", s$condition %||% "<none>"),
      paste0("components: ", paste(names(s$components()), collapse = ", ")),
      if (is.null(by)) "default components: all" else
        paste0("default components (", names(by), "): ",
               vapply(by, paste, character(1L), collapse = ", ")),
      "",
      .text_block("defs", p$.defs)
    )
  }))
}

# Write lines as UTF-8 with LF endings (also on Windows) and snapshot them.
.expect_frozen <- function(lines, name) {
  path <- file.path(tempdir(), name)
  con  <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeLines(enc2utf8(lines), con, sep = "\n", useBytes = TRUE)
  close(con)
  on.exit()
  expect_snapshot_file(path, name = name, compare = compare_file_text)
}

# ---- Inventory --------------------------------------------------------------

.specs      <- .all_specs()
.cond_specs <- .condition_leaves(.specs)
.drug_specs <- .drug_leaves(.specs)

# ---- Manifest tests ---------------------------------------------------------

test_that("every released condition version still exists", {
  missing <- setdiff(.released_condition_specs, names(.cond_specs))
  expect(length(missing) == 0L, paste0(
    "Released condition version(s) missing from the package: ",
    paste(missing, collapse = ", "),
    ". Released versions must never be removed."
  ))
})

test_that("every condition version in the package is in the release manifest", {
  unlisted <- setdiff(names(.cond_specs), .released_condition_specs)
  expect(length(unlisted) == 0L, paste0(
    "Condition version(s) not in `.released_condition_specs`: ",
    paste(unlisted, collapse = ", "),
    ". Add them to the manifest in test-frozen-versions.R to freeze them."
  ))
})

test_that("every released drug version still exists", {
  missing <- setdiff(.released_drug_specs, names(.drug_specs))
  expect(length(missing) == 0L, paste0(
    "Released drug version(s) missing from the package: ",
    paste(missing, collapse = ", "),
    ". Released versions must never be removed."
  ))
})

test_that("every drug version in the package is in the release manifest", {
  unlisted <- setdiff(names(.drug_specs), .released_drug_specs)
  expect(length(unlisted) == 0L, paste0(
    "Drug version(s) not in `.released_drug_specs`: ",
    paste(unlisted, collapse = ", "),
    ". Add them to the manifest in test-frozen-versions.R to freeze them."
  ))
})

# ---- Frozen content ---------------------------------------------------------

for (.id in intersect(.released_condition_specs, names(.cond_specs))) {
  local({
    id   <- .id
    spec <- .cond_specs[[id]]
    test_that(paste0("released condition spec ", id, " is unchanged"), {
      .expect_frozen(.code_lines(spec), paste0("condition_", id, "_codes.csv"))
      .expect_frozen(.condition_meta_lines(spec), paste0("condition_", id, "_meta.txt"))
    })
  })
}

for (.id in intersect(.released_drug_specs, names(.drug_specs))) {
  local({
    id   <- .id
    spec <- .drug_specs[[id]]
    file <- gsub("/", "__", sub("^spec_", "drug_", id), fixed = TRUE)
    test_that(paste0("released drug spec ", id, " is unchanged"), {
      .expect_frozen(.drug_lines(spec), paste0(file, "_generics.csv"))
      .expect_frozen(.drug_meta_lines(spec), paste0(file, "_meta.txt"))
    })
  })
}

test_that("composite spec structure is unchanged", {
  .expect_frozen(.composite_lines(.specs), "composites.txt")
})

# ---- Getter binding ---------------------------------------------------------

test_that("each get_<condition>_<vN>_codes() returns the condition and version in its name", {
  getters <- grep("^get_.+_v[0-9]+_codes$", getNamespaceExports("peridefs"), value = TRUE)
  expect_gt(length(getters), 0L)

  for (g in sort(getters, method = "radix")) {
    parts <- regmatches(g, regexec("^get_(.+)_(v[0-9]+)_codes$", g))[[1L]]
    f     <- getExportedValue("peridefs", g)
    res   <- rbind(f(variable_type = "condition"), f(variable_type = "outcome"))

    expect_gt(nrow(res), 0L, label = paste0("rows returned by ", g, "()"))
    expect_equal(unique(res$version), parts[3L], label = paste0(g, "() version"))

    # Factory-built getters close over `spec`; the ASCVD component wrappers
    # report their condition in the `class` column instead.
    spec <- environment(f)$spec
    cond <- if (inherits(spec, "CodeSpec")) spec$condition else unique(res$class)
    expect_equal(cond, parts[2L], label = paste0(g, "() condition"))
  }
})
