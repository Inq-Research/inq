# Interrogating an Inq workspace

Use this protocol to explore, search, and read an Inq workspace without
mistaking its overview documents or link graph for content boundaries. Run
`inq howto explore` to print it; `inq howto author` and `inq howto cli` cover
authoring and invocation mechanics.

Interrogation is read-only by default. Do not create, edit, move, or reorganize
files unless the task explicitly asks for changes.

## Mental model

An Inq workspace is a local collection described by the nearest `inq.toml`
containing a `[workspace]` table. Its `members` paths or globs locate module
directories; they do not contribute to module identity.

Each module is a self-identifying content bundle:

- `inq.toml` contains its locally unique `name`, configured Markdown `entry`,
  optional `include` patterns, and optional labels;
- the entry supplies the module overview, title, and summary;
- the manifest selects the content: the `include` patterns plus the manifest
  and entry are the module's resources, and nothing else beneath the root is;
- every included file is independently addressable content, whether or
  not the entry or another file links to it;
- generated live dependency views and static source clones under `_inq/` are
  not module resources and must not be mistaken for additional workspace
  members;
- module names are flat identifiers, while slashes identify a resource path
  inside one module.

The entry is not a content root, export surface, table of contents, or
reachability filter. Link traversal is one reading strategy. It never determines
which files belong to the module.

Module-name spelling is not a dependency graph. Prose and links express
intellectual, evidential, or operational relationships.

## Interrogation protocol

### 1. Establish the workspace

Find the nearest `inq.toml` containing `[workspace]`. Read its local membership,
dependency, and flavor policy, then inventory the admitted modules rather than
guessing project content from neighboring files.

### 2. Inventory modules before choosing one

Start with:

```bash
inq workspace list
```

`inq workspace list` is the at-a-glance workspace view: each module's
entry-derived title, local member path, short name, truncated description,
labels, direct links, and sorted included-resource inventory. There is no need
for a maintained table of contents; run it on the fly. Use `-d/--dir` to limit
the inventory to modules rooted at or below a real workspace directory:

```bash
inq workspace list -d modules
```

Use labels only as opaque, exact selectors unless the workspace documents a
local vocabulary:

```bash
inq workspace list -l purpose=reference
inq describe retry-policy
```

Do not assign built-in meanings to label keys or values. Core Inq defines no
exports and no built-in `prop`, `thought`, dependency, status, or evidence
categories.

### 3. Read the module overview

Inspect a candidate module by the member path or short name that
`inq workspace list` reports:

```bash
inq describe <TARGET> --entry
```

The overview should answer what the module is and why it may matter. Use it to
decide what to inspect next, not to decide what content exists.

`inq describe` resolves an existing filesystem path first — a module root or
any path inside one — and otherwise as a project module name, a direct
dependency alias, or an explicit hosted request. Logical dependency aliases use
the existing lock and live `_inq/` projection and never fetch. A hosted request
uses a matching current local binding when available, otherwise fetches through
its adapter; `--remote` forces the fetch. Remote inspection is ephemeral and
does not update the workspace. During hosted acquisition, source-workspace
dependency inheritance is resolved into concrete requests, so the described
canonical module is self-contained rather than dependent on its source
checkout. `describe` does not retrieve one arbitrary resource by logical
address.

### 4. Inventory exact resources and search with local tools

Get a pipeline-friendly path set for every selected module resource:

```bash
inq workspace inventory
inq workspace inventory --only-entry
inq workspace inventory -d modules -l stability=frozen
```

The command prints one workspace-relative path per line, globally sorted and
without decoration. `--only-entry` narrows the stream to each module's
designated entry. Directory and label filters select modules by the same rules
as `inq workspace list`.

Pipe that bounded set into the text search, indexer, parser, or file processor
appropriate to the task. For example, a shell loop preserves spaces in paths:

```bash
inq workspace inventory | while IFS= read -r path; do
  rg -n -- "<QUERY>" "$path"
done
```

An unlinked file is still module content. Before reporting that a module or
workspace is silent, try alternate terms and state the inventory filters and
search tool used. Generic text search may skip or only identify PDFs, images,
datasets, notebooks, and other binary formats; inspect a relevant resource
with an appropriate tool, or state that it was not inspected.

### 5. Read exact resources

Treat inventory paths, external search results, and links as routes to exact
files. Read the selected file itself and cite its module-relative path and
relevant heading when reporting a claim.

Within a module, ordinary relative Markdown links are valid. Across modules
gathered by the same workspace, prefer a complete logical resource address:

```text
retry-policy/decisions/failure-classification.md
```

The current CLI resolves an existing source-relative path first. If that path
does not exist, a clean reference may resolve through a unique workspace-path
suffix or complete module-name/resource alias. Explicit `./` and `../`
references remain strictly relative. Ambiguous references are errors; make
them more specific rather than guessing.

The CLI has no arbitrary-resource retrieval command. A hosted `describe`
request can fetch a module for ephemeral metadata inspection, but it does not
persist a readable module root. For local inspection, take the module root from
`inq describe <TARGET>` (or the member path from `inq workspace list`), then
read the module-relative resource path with the available file tools.

### 6. Filter bundle and relationship metadata deliberately

Descriptions and lists include the module inventory and direct relationship
graph by default. Mute fields when a narrower view helps choose exact
resources:

```bash
inq describe <TARGET>
inq describe <TARGET> --entry
inq describe <TARGET> --mute-links
inq workspace list --mute-description --mute-labels
```

`Resources` is the complete selected bundle as module-relative paths; it does
not depend on entry links. `Links` scans all selected Markdown and reports the
address of each distinct other module reached by a resolved local link. It does
not recursively describe those targets. Use the resulting module names and
resource paths to choose what to read next. The four independent filters are
`--mute-description`, `--mute-labels`, `--mute-links`, and
`--mute-resources`; both `workspace list` and `describe` accept them.

Without a target, `describe` starts from the current path and still returns at
most one module. Use `workspace list` to choose a different module, then pass
its exact path or name.

These views remain metadata: the resource inventory does not include file
bytes, and the link inventory does not substitute for reading linked resources
or linting the workspace.

### 7. Check workspace integrity separately

When link or authoring integrity matters, run:

```bash
inq lint
```

Linting captures the enclosing workspace once and checks every member. It
parses the workspace and module manifests, applies membership and resource
rules, enumerates every included Markdown file, resolves every supported local
link, and checks each link against the workspace's `obsidian` or
`markdown-strict` flavor. It is not seeded by the entry, and files the manifest
does not select are not content. External URLs are not fetched. Diagnostics are
strict by default. `inq lint --fix` applies safe link-flavor rewrites before
reporting on the resulting workspace, while `inq lint --warn` prints the same
findings but exits zero. The flags may be combined.

A clean lint result establishes structural consistency, not factual truth,
evidential support, freshness, or agreement between files.

## Selectors and names

An exact logical selector is a module's locally unique manifest name:

```text
retry-policy
```

`describe` additionally accepts a filesystem path, which resolves first but is
machine-local. The CLI does not interpret partial-name globs or infer
parentage from names.

Member paths only locate modules on this machine. Moving a module between
member directories or workspaces does not change the name declared in its own
`inq.toml`; a destination workspace may reject a duplicate.

## Evidence and reporting

Use workspace-relative file paths and headings for load-bearing claims. Keep
these categories distinct:

- statements explicitly made by current workspace files;
- statements established by an external source you actually inspected;
- your own inference or synthesis;
- missing, conflicting, stale, or uninspected support.

A link is a route, not evidence by itself. Read the target before relying on it.
When correctness depends on a PDF, script, dataset, notebook, generated
artifact, or external URL, inspect it with an appropriate tool or disclose that
you did not.

Prefer current maintained files over old chats, deleted material, releases, or
version-control history unless provenance or history is part of the task. If
current files conflict, report the conflict rather than silently choosing a
winner.

Do not load the entire workspace automatically. Start with discovery and module
overviews, then spend context on the exact resources the task requires. This is
a context-management practice, not a restriction on what counts as module
content.

## Command reference

```bash
inq workspace list [-d <DIRECTORY>]... [-l <KEY=VALUE>]... \
  [-s <MAX_CHAR_LENGTH>] \
  [--mute-description] [--mute-labels] [--mute-links] [--mute-resources] \
  [--json | --toml]
inq workspace inventory [-d <DIRECTORY>]... [-l <KEY=VALUE>]... [--only-entry]
inq describe [TARGET] [--entry] [--mute-description] \
  [--mute-labels] [--mute-links] [--mute-resources] \
  [--json | --toml] [--output FILE]
inq describe <TARGET> --remote
inq lint [--fix] [--warn]
```

Use `--json` where a command supports it, or `--toml` on `workspace list` and
`describe`, when structured output is easier to inspect. Resource inventory is
already newline-delimited for pipes. Do not invent commands or arguments that
`inq --help` does not show.

The discovery and context-selection commands in this guide are deterministic
and local except for adapter-prefixed `describe` fallback and `--remote`.
Remote description is ephemeral; `inq add` and `inq sync` are the networked
operations that persist dependency state.
