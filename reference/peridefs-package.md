# peridefs: Perisphere Medical Code Definitions

Provides structured, versioned medical code definitions (ICD-9, ICD-10,
HCPCS, CPT, Revenue codes, and drug generic names) for use in
claims-based research. Bundled code sets are pre-expanded and accessible
through a consistent R6-based API covering medical conditions and drug
classes.

## Main classes

- [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md):
  Versioned ICD/HCPCS/CPT code sets for a medical condition.

- [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md):
  Versioned generic drug name (GNN) and NDC sets for a drug class.

- [CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md):
  Union of multiple
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  objects (e.g., ASCVD).

- [CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md):
  Union of multiple
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  objects (e.g., antihypertensives).

## ICD-10-PCS expansion

The
[`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
function resolves prefix patterns (e.g., `"0210xxx"`) to all matching
valid ICD-10-PCS codes using the bundled FY2026 CMS reference table.

## See also

Useful links:

- <https://perisphere-rwe.github.io/peridefs>

- <https://github.com/perisphere-rwe/peridefs>

- <https://perisphere-rwe.github.io/peridefs/>

- Report bugs at <https://github.com/perisphere-rwe/peridefs/issues>

## Author

**Maintainer**: Perisphere <info@perisphere-rwe.com>
