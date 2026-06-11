# get_defs() rejects non-spec objects

    Code
      get_defs("not a spec")
    Condition
      Error in `get_defs()`:
      ! `spec` must be a <CodeSpec>, <CompositeCodeSpec>, <DrugSpec>, or <CompositeDrugSpec> object.

