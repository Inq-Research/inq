# Using the Inq CLI

This guide is the practical reference for invoking `inq` from a shell or an
agent tool call: how commands find the active project, how directory and label
filters select modules, and which flags produce machine-readable output.

It documents invocation mechanics only. For authoring habits run
`inq howto author`; for an interrogation protocol over an existing workspace run
`inq howto explore`.

## Fast path

Use this sequence when you are new to a workspace:

```bash
inq workspace list
inq workspace inventory
inq describe <MODULE_NAME> --entry
inq describe <MODULE_NAME>
inq lint
```

Use `--json` or `--toml` on `workspace list` and `describe` when a program or
agent needs structured records instead of terminal-oriented text. The sections
below define the selection and output details that matter when composing
commands.

## Project discovery

Local commands start from the current directory and find the nearest ancestor
`inq.toml` with `[workspace]`. That workspace is the project: it gathers the
admitted modules, owns `inq.lock`, and supplies dependency and link-flavor
context. Commands that need a current module choose the innermost admitted
module containing the invocation directory. An unregistered module manifest does
not establish another project.

`init [PATH]` starts discovery from its target. With no enclosing workspace it
creates a fresh workspace. An existing target below a workspace is initialized
and registered as a module. At an existing workspace root it fails with a prompt
to pass `--as-hybrid`; that explicit form preserves the workspace role while
adding `[module]`. `module init [PATH]` remains an explicit module-only
spelling, and `new` creates a new module directory. `howto` needs no project.
Every `workspace` subcommand deliberately requires an enclosing workspace.

## Label filters

Commands that advertise repeatable `-l KEY=VALUE` (`--label`) flags use them to
narrow module selections. Multiple filters must all match (AND semantics). Keys
and values are opaque strings; core Inq defines no built-in vocabulary.
`describe` does not accept a label filter because it resolves exactly one
explicit module target. `inq new` writes labels at creation time and accepts
`--label` with no short form.

## Inspecting

```bash
inq workspace list [-d DIRECTORY]... [-l KEY=VALUE]... \
  [-s MAX_CHAR_LENGTH] [--mute-description] [--mute-labels] \
  [--mute-links] [--mute-resources] [--json | --toml]
inq workspace inventory [-d DIRECTORY]... [-l KEY=VALUE]... [--only-entry]
inq describe [TARGET] [--entry] [--mute-description] \
  [--mute-labels] [--mute-links] [--mute-resources] \
  [--json | --toml] [--output FILE]
inq describe TARGET --remote
```

`workspace list` is the at-a-glance view of every module gathered by the active
workspace: title, member path from the workspace root, name, the entry-derived
summary shown as the description (truncated to 280 characters with an ellipsis
unless `-s/--summary-length` changes the limit), labels, directly linked module
addresses, and the complete included-resource inventory in portable path order.

`-d/--dir` accepts an existing directory, resolved relative to the current
directory, and includes modules whose roots are equal to or below it. The
directory must remain inside the active workspace. Repeated directories form an
additive allowlist, while `-l` label filters are conjunctive: a module must
match every supplied pair. Both kinds together intersect.

The default console view aligns module names and paths in a compact first row,
then indents title, description, labels, links, and resources; descriptions
wrap at 86 columns. Color appears only when stdout is an interactive terminal;
redirected output, `describe --output`, the global `--no-color` flag, the
`NO_COLOR` convention, and `TERM=dumb` all produce the same view without ANSI
escapes. `--json` and `--toml` select machine-readable serializers instead.

`describe` resolves an existing filesystem path first — a module root or any
path inside one, defaulting to the current path — and otherwise resolves a
logical name. Logical lookup checks active-project module names, then direct
dependency aliases from the innermost current module outward, and finally
workspace dependencies. An explicit supported hosted request is parsed before
path classification. It uses a matching current manifest, lock edge, and live
`_inq/` projection when available; otherwise it fetches through the adapter.
`--remote` forces that fetch and requires an explicit target. Remote inspection
is ephemeral and does not edit the manifest, lock, or `_inq/`. Without a
target, `describe` resolves the current path and still emits at most one module
record; use `workspace list` to choose another module before describing it.

`describe` prints the same compact module record as `workspace list`, filtered
to the resolved module. The default record includes description, labels,
direct links, and every selected resource, including the manifest, entry,
unlinked Markdown, and non-Markdown content. The four `--mute-*` flags
independently remove those sections from console and machine-readable output.
`--entry` is describe-only and appends the full entry document. Links are
distinct other modules reached by successfully resolved local links anywhere
in selected Markdown, never recursively traversed: a direct relationship view,
not link validation. Logical dependency aliases remain offline, verify their
lock edge and live `_inq/` projection, and direct missing derived state to
`inq sync`. `--output` writes to a new file and refuses to overwrite. A hybrid
root module displays the path `.`, and machine-readable project metadata
always identifies a `workspace` project.

## Resource inventory

`workspace inventory` emits every selected module resource as one
workspace-relative path per line, globally sorted and without headers, colors,
or record framing. It is intended for pipes into `rg`, `grep`, indexers, and
other resource-aware tools. `--only-entry` emits only each selected module's
designated entry path. `-d/--dir` and `-l/--label` use exactly the module
selection rules described for `workspace list`. Nonmember files, derived
live copies and private static clones under `_inq/` are not module resources
and do not appear.

## Linting

```bash
inq lint [--fix] [--warn]
```

`lint` always captures and checks the complete enclosing workspace, regardless
of the invocation directory. The capture supplies the workspace manifest,
optional workspace description, membership, module manifests, selected
resources, and Markdown records to the lint rules without rescanning for each
rule. It checks manifest syntax and schema, membership, unique names, module
roots, entries, authoring shape, portable resource types, every supported local
link target, and whether each local link uses the workspace's `obsidian` or
`markdown-strict` flavor.

A local target must resolve to an included resource inside an admitted module;
a file that exists but is excluded is an error naming the inclusion problem.
Workspace members may resolve into one another, while a path into an
unregistered neighboring module is a containment error. External URLs are not
fetched. Missing or stale dependency projections produce an actionable
diagnostic to run `inq sync` before linting again.

`--fix` first plans every equivalence-proven rewrite from a non-preferred local
link to the workspace flavor and applies all changed files atomically. When
files changed, it recaptures and lints the resulting workspace. Broken,
ambiguous, unsupported,
or lossy occurrences remain unchanged and appear in the final report. Link
flavor is the first fixable lint family; the flag is linter-wide so later rules
can add their own safe fixes without another command surface.

Linting is strict by default: any diagnostic exits 1. `--warn` prints the same
diagnostics but exits 0, which is useful while exploring or incrementally
cleaning an existing workspace. It may be combined with `--fix`; fixes are
still applied, but remaining findings do not make the command fail.

## Link resolution

Local Markdown links resolve with stable, deterministic precedence:

1. An existing path relative to the source Markdown file wins.
2. Otherwise, a reference containing only ordinary path components is matched
   against workspace-relative paths and module-name/resource references.
3. A unique trailing-component match resolves; multiple matches are an error
   that lists the candidates and asks for more path components.

A module stored in `modules/quark-notes/` and named `quarks` may link to its
internal file as `quarks/representations.md`. A unique `representations.md` also
resolves from elsewhere in the workspace. Explicit `./` and `../` links remain
strictly relative and never fall back to workspace search.

## Authoring

```bash
inq init [PATH] [-n MODULE_NAME] [--title TITLE] [--as-hybrid]
inq new PATH [-n MODULE_NAME] [-e ENTRY_FILE] \
  [--title TITLE] [--label KEY=VALUE]
inq module init [PATH] [-n MODULE_NAME] [-e ENTRY_FILE]
```

`init` creates a fresh workspace when its target has no enclosing workspace;
that path creates only an `inq.toml` holding `[workspace]` and its required
`name`, and refuses an existing manifest. The workspace name defaults to the
target directory's basename, `-n` overrides it, and a basename that is not a
portable module name fails with a prompt to pass `-n`. `--title`
applies only when the target is initialized as a module. For an existing target
below a workspace, `init` defaults the module name to the
target basename, reuses a valid existing entry byte for byte, and registers the
member. `-n` overrides the inferred module name. At an existing workspace root,
ordinary `init` fails and explains that `--as-hybrid` is required. The explicit
hybrid conversion preserves the workspace table and adds the root module role
with the default `entry.md` module entry. It refuses an already-hybrid root, and
no mode silently overwrites an entry.

`new` creates the destination directory
relative to the current working directory. The module name defaults to the
destination's basename, while `-n` overrides it when physical and logical names
should differ. It scaffolds an `inq.toml` with the authoring default
`include = ["**/*.md"]` plus a placeholder entry (`-e` renames it), and
registers the member when an enclosing workspace exists and no existing
workspace pattern already selects it. Without one, the new directory is a hybrid
one-module workspace whose workspace `name` repeats the module name. Add
`include` patterns for non-Markdown resources; files that match no pattern are
not module content.

`module init` adopts an existing directory. `PATH` defaults to the current
directory, the module name defaults to the target directory's basename, and `-n`
supplies a different name when that basename is unsuitable. The selected entry
defaults to `entry.md`: an existing regular UTF-8 Markdown entry with an H1 is
reused byte for byte, while a missing entry is scaffolded. `-e` selects another
relative Markdown path with the same reuse-or-create behavior. The command
writes an `inq.toml` with `include = ["**/*.md"]`. When an enclosing
workspace exists, it adds a literal member only when the workspace's existing
exact or glob rules do not already cover the target. Without an enclosing
workspace, the target becomes a hybrid workspace root and module. A
workspace-only root is not converted through this spelling; use
`inq init --as-hybrid` so that role change remains explicit. It refuses to
overwrite a manifest, initialize a missing directory, create nested or
overlapping modules, reuse a duplicate name, or point through a symbolic link.

## Adding module dependencies

```bash
inq add github:OWNER/REPO::MODULE_NAME[@SELECTOR] \
        [--as ALIAS] [-w|--workspace] [--ambient]
inq add arxiv:ARXIV_ID[@vN] [--as ALIAS] [-w|--workspace] [--ambient]
inq add workspace --as ALIAS [--ambient]
inq sync [--update]
inq module prune [--dry-run|--yes]
```

`add` declares and installs a dependency for the current project module. With a
hosted source, it records the concrete request under `[dependencies]` in that
module's `inq.toml`. With `-w` or `--workspace`, it instead records the concrete
request under `[workspace.dependencies]` and records
`ALIAS = { workspace = true }` in the current module, so other members may opt
into the same workspace selection later. `inq add workspace --as ALIAS` links
the current module to an already-declared same-named workspace slot without
changing that slot. Workspace forms require both an active workspace and a
current registered module. The alias defaults to the target module name for a
hosted source; the `workspace` source requires `--as`. Browser URL forms are
accepted as hosted input.

`--ambient` marks the current module's relationship as independently useful
context even when no included Markdown links through its alias; it never
changes the shared workspace slot, selected revision, or acquired bytes. The
command resolves declarations across the whole project. Its pending manifest
edit feeds both lock resolution and library planning, then the manifest, lock,
and `_inq/` libraries are published in one staged project transaction. A
successful `add` therefore materializes the new alias immediately rather than
requiring a second `sync`.

GitHub's optional selector is `branch:<ref>`, `tag:<ref>`, or
`commit:<object-id>`; an omitted selector means the default branch. arXiv uses a
floating latest version by default and accepts an exact `vN`; its browser URLs
are also accepted. The arXiv adapter synthesizes a module whose entry summary is
the abstract, whose namespaced `arxiv.*` labels carry authors, categories,
submission dates, and related DOI URLs, and whose remaining resources contain
the inert source projection. When resolution needs GitHub provider data, that
adapter uses the configured system Git with non-interactive HTTPS first and a
narrow SSH fallback for access failures. It shallowly fetches the requested
revision, finds the `inq.toml` that declares the requested name anywhere in the
repository — never by path, because paths are brittle — resolves the selector to
one exact commit, and records the edge in the `inq.lock` at the project root:
the normalized request pinned to one exact revision, plus one integrity digest
per selected projection. Resolution is conservative and scoped: an unchanged
request keeps its exact selection, a locked snapshot already on disk resolves
offline, and two modules may pin different revisions of the same dependency
because aliases live in their declaring module's scope. Fetched content is the
module's included resources, held to the resource rules: a symbolic link fails
the fetch, and so does an executable file the manifest selected.

Workspace members may also inherit an already-declared shared request from
`[workspace.dependencies]` in the same `inq.toml`: `[dependencies]` uses
`ALIAS = { workspace = true }` to select the same-named workspace slot, so every
member sharing an alias shares one selection. The substituted concrete request —
never the inheritance marker — is what enters the lock.

Hosted acquisition resolves inheritance in the source repository too. Before a
GitHub module leaves its container, the adapter replaces every inherited alias
with the concrete request in that repository's root
`[workspace.dependencies]`. The canonical module-only manifest is therefore
self-contained, and those effective requests participate in its integrity. A
missing source slot fails acquisition. Ambient intent is retained; clone intent
is discarded because it controls only the source workspace's local
materialization.

For a path-independent private source snapshot, a member may declare
`ALIAS = { workspace = true, clone = true }`. A same-named local workspace
module takes precedence; otherwise the alias uses the same-named remote
workspace slot. The canonical resources are copied to the declaring module's
`_inq/ALIAS/` directory without live-flavor rewriting.

`module prune` audits the current registered module's included Markdown and
offers dependencies that have no authored references and are neither ambient
nor cloned.
Broken references through an alias count as authored use and remain a
link-validation concern. The default prints the candidates and asks before
editing; `--dry-run` reports only and `--yes` accepts the complete set. A
successful prune publishes the edited manifest, recomputed lock, and resulting
libraries in one transaction. It never removes workspace dependency slots,
which may still serve other members. Run `inq sync` first when the command
reports that its dependency projections are missing or stale.

`sync` performs the install and cleanup half without editing a manifest. It
walks every module in the project, installs dependencies that are declared but
missing, replaces outdated copies, prunes stale `_inq/` entries, removes lock
roots for former or dependency-free members, and drops exact module nodes no
remaining root can reach. It resolves conservatively, so unchanged effective
requests retain their existing exact selections. The resulting lock is
canonical, and an unchanged second run does not rewrite it. With `--update`,
sync re-queries every reachable floating selector. A GitHub request with no
selector therefore checks the repository's current default branch, while an
unchanged `commit:<object-id>` pin remains fixed. Floating dependencies declared
by hosted modules are refreshed in the same pass.

Ordinary sync may create an absent `_inq/ALIAS/` clone, but it never overwrites
an existing clone or prunes stale clone aliases. `sync --update` is the explicit
refresh boundary: it recopies current local-module resources or newly selected
remote canonical resources and removes clone aliases no longer declared.

Every dependency materializes once in the project root's visible `_inq/`
library, whether the workspace table or one member declared it. Direct aliases
get friendly `_inq/ALIAS/` copies and the rest of the transitive closure is flat
under `_inq/_friends/`, keyed by precise exact-ID spellings. One alias is one
directory, so two members may name the same alias only for the same module;
naming two different modules is an error that asks you to rename one. Only a
`clone = true` snapshot sits in its declaring module's own `_inq/`. Authored
library links inside every copy are rewritten to this flat layout, so they
resolve in Obsidian and GitHub previews at any depth, and each copy carries a
`.inq-copy` marker naming the canonical ID and integrity it derives from. Every
project uses its workspace's configured flavor. Live projections under `_inq/`
are derived local state: never module content, ignored by validation and search,
and rebuilt or pruned by running `sync` (which `add` also performs). The
manifest declaration and `inq.lock` remain their authority. A hybrid one-module
project owns `inq.lock` and `_inq/` at the same root as its
module.

Static clones share `_inq/` with live projections but retain a conservative
update policy. Ordinary `sync` creates a missing clone and otherwise preserves
existing snapshots; `sync --update` refreshes declared clones and prunes stale
ones. These file-based build inputs may be committed for reproducible builds.

## Machine-readable output

`workspace list` and `describe` accept mutually exclusive `--json` and `--toml`
output engines; `workspace inventory` is already an undecorated
newline-delimited stream. Each successful machine-readable invocation writes
exactly one document to stdout. Commands exit 0 on success, 1 on operational or
lint errors, and 2 on command-line usage errors. `inq lint --warn` is the
explicit exception: it prints the complete text report but exits 0 when lint
findings exist.

## Archiving for a Markdown reader

```bash
inq workspace archive [DESTINATION]
                      [-d DIRECTORY]... [-l KEY=VALUE]...
                      [--preserve-structure]
                      [--format tar-gzip]
                      [--flavor obsidian|markdown-strict]
```

`workspace archive` creates a new tar-plus-gzip file that can be extracted and
opened directly as an Obsidian vault or ordinary Markdown directory. The
default archive is created at the
workspace root as `<workspace-name>.tar.gz`, using the required `[workspace]`
name; an existing destination is never overwritten. `tar-gzip` is the current
and default container format.

Local modules are flattened by portable module name unless
`--preserve-structure` is supplied. Direct acquired modules are collected under
`_external/`, transitive-only modules under `_external/_friends/`, and the
lock sits at the archive root. A declared workspace `description` is copied to
the archive root under its own basename. Markdown links are resolved before
anything moves and rewritten for the selected flavor, which defaults to the
workspace flavor. A filter that omits the target of a selected local link fails
instead of creating a broken handoff. Archive is offline; run `inq sync` first
when locked canonical content is absent from the local cache.

Every copied module entry receives an `inq.module` frontmatter property and one
array-valued `inq.label.<key>` property for each manifest label. Existing YAML
or TOML frontmatter is retained, while an archive-owned property collision
fails clearly. These properties exist only in the archive copy; authored notes
are unchanged.

## Guides

```bash
inq howto
inq howto author
inq howto cli
inq howto explore
```

Bare `inq howto` lists every embedded topic. Each topic prints one Markdown
guide to stdout, requires no workspace, and creates no files. To install the
interrogation protocol into a repository explicitly, run
`inq howto explore > AGENTS.md`.
