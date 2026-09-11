# Hosted test workspaces

These small workspaces are published in the public `Inq-Research/inq` repository
for live Inq acquisition and registry tests. Each has its own `inq.toml` and is
independent of the repository's root workspace. Use a full, already-pushed
commit ID when acquiring a fixture.

[Test Alpha](test-alpha/overview.md) exercises a workspace below the Git root,
local dependency discovery through links, transitive materialization, and module
resource selection. Its `alpha-intro` module links through `alpha-reference` to
`alpha-leaf`. `alpha-unlinked` is intentionally outside that closure. The
introduction includes a selected note, linked SVG, and unlinked ambient CSV; its
draft is not module content.

Alpha has no external dependencies. Its sibling dependencies are resolved at
the requested repository commit. When a consumer adds `alpha-intro`, only the
consumer's chosen alias is added to its `inq.toml`;
transitive modules are placed in `_inq/_friends/` with their exact provenance.

[Test Beta](test-beta/overview.md) adds a publishing workspace with an exact
external dependency. Its `alpha-source` alias pins Alpha's `alpha-intro` at an
earlier public commit recorded in [Beta's manifest](test-beta/inq.toml).
Beta's `beta-intro` links that
dependency's selected note and ambient data, alongside its local `alpha-leaf`.
Beta's local leaf intentionally has the same canonical name as Alpha's leaf;
their workspace paths distinguish them. Importing Beta produces five exact
modules across two workspace paths and two commits, excluding each workspace's
unlinked module. The consumer needs only its own direct alias for `beta-intro`.

Beta's local leaf also bundles unlinked ambient binary data and opaque Markdown.
The Markdown contains deliberately unresolved links, including a link to the
unlinked module: those bytes must not be parsed, rewritten, or used to expand the
dependency closure. A neighboring binary draft is intentionally unselected.

Both workspaces commit `_inq/.inqcache` as portable resource anatomy. It can be
shared with readers and rebuilt by Inq; it contains no local filesystem
observations or absolute checkout paths. Beta also commits its materialized
Alpha dependencies and their provenance, so its links work directly on GitHub.

## Run the live CLI test

The automated harness lives in the development monorepo, which includes this
public repository as its `inq` submodule. From that monorepo's root, with Python
3.11 or newer installed, build the CLI and test the submodule's published commit:

```bash
cargo build --locked -p inq
python3.11 scripts/test_cli_github_live.py --commit "$(git -C inq rev-parse HEAD)"
python3.11 scripts/test_cli_github_live.py --fixture beta --commit "$(git -C inq rev-parse HEAD)"
```

The script defaults to Alpha; `--fixture beta` selects Beta's `beta-intro` at
the supplied commit. Each run creates a temporary consumer and a fresh canonical
cache, fetches the selected fixture, and validates aliases, the linked closure,
resource selection, traversable links in selected notes, and standalone archives
in both Markdown and Obsidian flavors. It checks the exact SHA-256 of ambient
resources in acquired copies, the canonical cache, and archives, including the
binary and opaque Markdown fixtures. It tests both offline sync from the
canonical cache and fresh GitHub reconstruction from the consumer's exact
manifest pins after deleting both the copies and cache. This is a network test,
separate from the ordinary offline test suite. It uses normal Git credentials
and does not publish registry observations.

For an SSH account configured under a host alias, select that host for this
process without changing global Git settings:

```bash
python3.11 scripts/test_cli_github_live.py \
  --commit "$(git -C inq rev-parse HEAD)" --ssh-host github.com-inq-t
python3.11 scripts/test_cli_github_live.py --fixture beta \
  --commit "$(git -C inq rev-parse HEAD)" --ssh-host github.com-inq-t
```

Pass `--keep-workspace` to retain the temporary consumer, canonical cache, and
archive for inspection. The test prints their parent directory.

To explore the publishing workspace locally, use a current CLI build from its
workspace root. These paths are relative to the public repository:

```bash
cd test-workspaces/test-alpha
inq list
inq inventory
inq describe alpha-intro
inq lint
```

For Beta, change to `test-workspaces/test-beta` and describe `beta-intro`.
