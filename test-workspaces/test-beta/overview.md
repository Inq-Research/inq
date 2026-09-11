# Test Beta

A publishing workspace that combines a local dependency with an exact external
dependency on Test Alpha. Start with the [introduction](modules/beta-intro/inq.md).

Beta's [local leaf](modules/alpha-leaf/inq.md) deliberately has the same canonical
module name as Alpha's leaf. Their different workspace paths keep their exact
identities distinct, even when both appear in one consumer's dependency closure.
The [unlinked module](modules/beta-unlinked/inq.md) remains outside that closure.

The pinned [Alpha introduction](_inq/alpha-source/inq.md) and its transitive
copies are committed under `_inq/` so this collection is traversable directly on
GitHub. The workspace's `inq.toml` is sufficient to reconstruct those copies.
