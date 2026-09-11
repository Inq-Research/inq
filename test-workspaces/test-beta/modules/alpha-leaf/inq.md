---
inq.module: alpha-leaf
inq.ambient:
  - './ambient/**'
inq.label.purpose:
  - 'test-fixture'
---
# Beta's local leaf

This leaf belongs to Test Beta. Its canonical name intentionally matches the
leaf in Test Alpha, so acquisition must use the full repository, workspace path,
module name, and commit identity to distinguish them.

Its ambient directory contains binary data and opaque Markdown. Neither is
linked from a selected note; both must travel unchanged with the module.
