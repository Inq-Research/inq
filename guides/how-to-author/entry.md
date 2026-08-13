# Authoring useful modules with Inq

This guide presents practical habits for authoring Inq modules that remain easy
to discover, understand, inspect, move, publish, and compose.

It is an authoring guide, not an additional schema. The module format remains
small: a self-identifying module, one designated Markdown entry resource,
optional labels, and an arbitrary body of addressable resources. Everything
else in this guide is advice.

Run `inq howto author` to print this guide from the CLI.

## Fast path

For a healthy module, do these things first:

1. Run `inq workspace list`, inventory the relevant resources, and search them
   with your preferred local tools so you do not create a duplicate boundary.
2. Run `inq new <path> --title "<specific title>"` from the directory
   where a new module should live. To adopt an existing directory below a
   workspace, run `inq init [path] [-n <module-name>]` instead.
3. Replace the generated entry prompt with one concrete summary paragraph
   immediately after the first H1.
4. Add `include` patterns for every non-Markdown resource that belongs to the
   module; neighboring files that match no pattern are not content.
5. Link to exact resources when a claim depends on an exact file, and to an
   entry when the relationship is to a module as a whole.
6. Run `inq lint`.

The rest of this guide explains the choices behind that loop and the cases that
need more care.

## Begin with the right model

An Inq **module** is a portable, self-identifying directory and address space
for a coherent body of content.

A module contains:

- an `inq.toml` manifest;
- one Markdown resource designated as the module entry;
- any number of other resources, in any useful formats or directories.

This guide uses **resource** for any file selected into a module by its
manifest. The Inq specification and CLI may also call that item a module
**object**. A neighboring file that the manifest does not select is not a
resource.

Every resource is part of the module's content. Every resource has a
module-relative slash path and may be addressed, linked, fetched, cited, or
inspected directly. A consumer does not need to pass through the entry before
using another resource.

The current CLI excludes `.git/` and the `_inq/` dependency library—including
its live projections and private static clones—from content traversal. Do not
place authored module resources there.

The entry is special only as a module-level descriptive resource. It gives tools
one predictable, inexpensive Markdown file from which to derive the module
title, summary, preview, and search representation. It explains what the module
is about. It does not define a root, export surface, navigation tree, or
reachable subset of module content.

An Inq **workspace** is the local arrangement in which modules are worked on
together. Even a one-module project has a workspace: its root `inq.toml` carries
both `[workspace]` and `[module]` roles.

The distinction is fundamental:

```text
inq.toml [module]
  defines what the module is

inq.toml [workspace]
  defines which local module directories are available together
```

A workspace does not supply any part of a module's name. It does not own the
module, rename it, define its labels, or change its identity. Moving a module to
another directory, repository, workspace, or server does not change the module.

A hosting or publication system would add another layer:

```text
module
  portable identity, address space, and bundled resources

workspace
  required local editing and resolution context

hosting
  remote storage, publication history, and access policy
```

Do not collapse these concerns into one another. Most workspace commands are
local and offline. `inq add` and `inq sync` acquire and persist dependencies
through configured hosting adapters. An adapter-prefixed `inq describe` may
fetch a module for ephemeral inspection when no matching local projection
exists, or whenever `--remote` is supplied. The current CLI does not publish,
authenticate to a registry, manage channels, or enforce access policy.
Hosted snapshots, channels, and ACL mechanics are outside the current portable
format and command contract.

## What the module boundary provides

A module gives a body of material one stable identity and one
module-relative resource address space. It is also designed to be a sensible
future publication and access boundary.

The module is the unit that can be:

- selected as context;
- copied or moved;
- fetched or archived;
- published as an immutable snapshot;
- addressed by name;
- protected by an access policy;
- linked to at either the module or exact-resource level;
- composed with other modules and resources.

The entry makes the bundle cheaply legible to search engines, indexes, humans,
and agents. It does not determine how the module is traversed or which resources
count as part of it.

A module may be consumed in several ways:

| Operation | What is used | Why |
| --- | --- | --- |
| Search or preview | Module metadata and entry-derived title and summary | Decide whether the module is relevant |
| Exact resource access | One addressed PDF, Markdown file, image, dataset, code file, or other resource | Retrieve a known resource directly |
| Whole-module consumption | The complete published module snapshot | Fetch, mirror, index, audit, preserve, or reason over the bundle as a unit |

The whole module is the content unit. The entry is merely the preferred compact
representation of that unit when loading all bytes would be wasteful.

Resources are individually addressable; modules are designed as atomic
publication and policy boundaries.

In a hosting system that follows the module boundary, a direct resource request
would be resolved inside a module publication and authorized against the
enclosing module. A resource would not gain its own publication history or ACL
merely because it has its own address.

The entry is therefore **descriptive metadata expressed as ordinary Markdown**,
not an interface, root, index, or export declaration. It is not inherently
public, and non-entry resources are not inherently unrestricted. A future
hosting system may distinguish metadata, entry, and full-content access while
still treating the module as the atomic policy boundary.

## The minimum valid module

A module may be physically simple:

```text
retry-policy/
├── inq.toml
├── entry.md
├── decisions/
│   └── failure-classification.md
├── sources/
│   ├── http-semantics.pdf
│   └── retry-study.pdf
├── examples/
│   └── service-overrides.md
└── code/
    └── reference.ts
```

Its manifest might be:

```toml
[module]
name = "retry-policy"
entry = "entry.md"
include = [
  "**/*.md",
  "sources/*.pdf",
  "code/reference.ts",
]

[labels]
subject = ["http", "reliability"]
purpose = ["reference"]
```

Only the manifest and declared entry are structurally required — they are
always included. Everything else must be selected explicitly: `include` is an
allowlist of portable glob patterns (`*`
within one path segment, a complete `**` crossing segments, exact paths
welcome), and a neighboring file that matches no pattern is simply not module
content. `inq new` and `inq module init` scaffold the useful default
`include = ["**/*.md"]`; add patterns for the PDFs, images, datasets, or source
files that genuinely belong to the module. A valid pattern that matches
nothing is a warning so typos stay visible. Selecting a symbolic link,
executable file, or special file is an error. New modules should conventionally
use `entry.md`, while tools must follow the manifest's actual `entry` value
rather than guessing from filenames. The entry path must be a contained,
portable relative path using `/` separators and must resolve to a readable
UTF-8 `.md` or `.markdown` file.

The manifest does not duplicate the human title or summary. Those are derived
from the designated entry resource.

Every included file is part of the module's addressable content. For
example:

```text
retry-policy/entry.md
retry-policy/decisions/failure-classification.md
retry-policy/sources/http-semantics.pdf
retry-policy/code/reference.ts
```

The first happens to be the entry. The others are no less part of the module.

## Choose a useful module boundary

Create a module when the material deserves an independent identity, resource
address space, publication lifecycle, and access boundary.

### Selection test

Would a human or agent intentionally select this material without selecting all
of its neighbors?

### Description test

Can you give the bundle a useful title and concise module-level summary, even if
its principal value lies in PDFs, data, code, or other non-entry resources?

The entry may be a substantial explanation, a short catalog, an abstract, or a
curatorial note. It need not restate every resource.

### Portability test

Would it make sense to copy, fetch, archive, or publish this material as one
unit?

### Lifecycle test

Does the material change, stabilize, or get maintained together?

### Access test

Should all of the material share the same module-level access boundary?

This last test matters because core Inq does not assign separate access rules to
individual files inside one module. When two bodies of content need different
access policies, they should normally be separate modules.

Keep a resource inside an existing module when it belongs to that module's
coherent content body and does not need a separate identity, publication
lifecycle, or access boundary. A substantial PDF, dataset, or Markdown document
does not need module identity merely because it is independently addressable.

Avoid both extremes:

- one module per transient note creates needless manifest and naming overhead;
- one module for an entire discipline, organization, or product destroys the
  bounded context that makes modules useful.

There is no universal ideal size. A module may contain one essay or a dozen
ambient PDFs. The correct boundary is the smallest coherent bundle that remains
independently meaningful, portable, and maintainable.

## Give the module a stable local name

The module's `name` in `inq.toml` is its locally unique logical identity:

```toml
name = "retry-policy"
```

A module name matches this exact portable grammar:

```text
^[a-z0-9](?:[a-z0-9_-]{0,253}[a-z0-9])?$
```

In plain language: use 1 through 255 lowercase ASCII letters, digits, hyphens,
or underscores, and begin and end with a letter or digit. Dots, slashes,
uppercase letters, spaces, and Unicode are not valid. This conservative shape
works as one Unix directory component, one URL path segment, and one
object-storage key component without escaping, case folding, or Unicode
normalization. Provider-specific bucket names may impose additional rules.

Names are flat. Their punctuation never creates parentage, ownership, or a
namespace hierarchy. Organization and publication qualification belong to a
separate locator layer; the local CLI performs no DNS, registry, or ownership
lookup.

Use prose and links to express intellectual or operational relationships.

The local directory name is not authoritative identity. Conventionally keep it
equal to the module name:

```text
modules/retry-policy/
```

may contain:

```toml
name = "retry-policy"
```

Renaming the directory does not rename the module. Changing the manifest name
is an identity change and should be treated deliberately.

## Distinguish module names from resource paths

A module name identifies a module. Slashes identify a resource inside that
module.

```text
retry-policy
```

is a module name.

```text
decisions/failure-classification.md
```

is a module-relative resource path.

The combined logical resource reference is:

```text
retry-policy/decisions/failure-classification.md
```

Do not encode module identity or hierarchy with slash-separated names such as:

```text
platform/http/retry
```

That shape is ambiguous with a module-relative resource path and is not an Inq
module name. Dotted names such as `retry.http.platform` are also invalid;
module names do not encode a hierarchy.

Within a module, ordinary relative Markdown links are appropriate:

```markdown
[Failure classification](decisions/failure-classification.md)
```

Across modules gathered by one workspace, a logical Inq link may target the
other module's explicitly named entry path or any exact resource within it:

```markdown
The retry policy follows the bundled normative source,
[HTTP Semantics](http-standards/specifications/http-semantics.pdf).
```

Link to the entry when the relationship is module-level or the reader needs an
overview. Link directly to a non-entry resource when that exact PDF, dataset,
code file, image, or Markdown document is the actual source, dependency,
example, or artifact being referenced.

The current CLI requires a resource path after the module name. A bare
module name is a selector, not a Markdown resource link. To link to another
module's overview, use an explicit address such as:

```markdown
[HTTP standards overview](http-standards/entry.md)
```

Do not assume that a resource omitted from the entry is private, unstable, or
unaddressable. Once another module links to its path, that path is part of an
inter-module contract. After moving files or changing names, validate links
rather than relying on readers to infer the intended target.

For local links, the CLI gives an existing source-relative path precedence. If
that exact path does not exist, a clean reference may resolve through a unique
workspace-path suffix or a complete
`<module-name>/<module-relative-resource-path>` alias. Zero matches produce a
broken-link warning; multiple matches are an error. Prefer complete logical
addresses for cross-module references and make ambiguous short references more
specific.

The link examples in this guide use inline Markdown syntax. A workspace whose
`flavor` is `obsidian` — the default — authors the same references as
`[[target|label]]` wikilinks, and `inq lint --fix` converts safely between the
two.

## Use the entry to describe the module

The entry is the module's one designated Markdown resource. It gives generic
tools a predictable file from which to extract a human-readable account of what
the module is.

The entry is useful for:

- extracting the module title and summary;
- rendering previews and collection cards;
- providing a compact module-level search document;
- supplying a compact module-level description to a human or AI.

The entry is not:

- the only addressable resource;
- the only legitimate cross-module link target;
- a mandatory hop before another resource can be fetched;
- an exhaustive definition of the module's content;
- a separate publication or access-control boundary.

A good entry usually lets a cold reader answer:

1. What is this module?
2. Why might it be relevant?
3. What kind of content does the module contain?
4. What scope, provenance, or limitations matter when interpreting it?

How much more it should do depends on the module. An algorithm module may place
the maintained specification in its entry. A source archive may use a much
shorter entry that identifies the collection and summarizes its scope while the
primary content remains a set of PDFs. Neither choice changes which resources
belong to the module.

### Use the first H1 as the title

The first H1 is the module title:

```markdown
# HTTP retry policy
```

Use a title that names the module in ordinary, specific language. The title need
not repeat the manifest name; the manifest already supplies identity.

Weak:

```markdown
# Notes
```

Stronger:

```markdown
# HTTP retry policy
```

### Put the summary immediately after the H1

The ordinary prose paragraph immediately after the first H1 is the module
summary:

```markdown
# HTTP retry policy

This module defines the default retry behavior for outbound HTTP requests,
including retryable failures, backoff, request safety, and service-specific
override points.
```

The summary should work as a compact preview. It should name the subject and say
what role the module plays.

Weak:

> This module contains various notes about retries.

Stronger:

> This module defines the default retry behavior for outbound HTTP requests,
> including retryable failures, backoff, request safety, and service-specific
> override points.

An intervening list, heading, quote, code block, or thematic break means the
entry has no immediate summary and produces a validation warning. Keeping the
summary adjacent to the H1 is therefore both the CLI contract and the clearest
convention for human readers.

Leading YAML or TOML frontmatter is optional and ignored when locating the H1.
Core Inq assigns the frontmatter no meaning.

### Describe without pretending to enumerate the module

After the summary, include whatever module-level description is genuinely
useful. The entry should make the bundle identifiable and previewable; it need
not enumerate, route, or mediate the module's resources.

Depending on the module, the entry may include:

- the central specification, explanation, decision, map, or result;
- the intended use and audience;
- scope and important exclusions;
- prerequisites or assumptions;
- an optional catalog of notable resources;
- links to related modules or exact resources when useful;
- dates, versions, or compatibility boundaries when they affect meaning.

There is no mandatory entry template. Inq does not require sections such as
“current synthesis,” “open questions,” “confidence,” or “status.” A module may
be a specification, report, paper, dataset, course unit, design record, working
notebook, historical artifact, source collection, or another kind of content.
Its entry should accurately orient the reader to what it is.

One useful shape is:

```markdown
# HTTP retry policy

This module defines the default retry behavior for outbound HTTP requests,
including retryable failures, backoff, request safety, and service-specific
override points.

## Policy

State the rule or maintained content that most readers need.

## Scope

Explain where the policy applies and what it does not govern.

## Common resources

- [Failure classification](decisions/failure-classification.md) explains why
  particular outcomes are or are not retryable.
- [HTTP Semantics](sources/http-semantics.pdf) is the bundled normative source.
- [Retry study](sources/retry-study.pdf) supplies empirical background.
- [Service overrides](examples/service-overrides.md) shows approved exceptions.
- [Reference implementation](code/reference.ts) provides inert source code for
  inspection; Inq does not execute it.
```

The headings are illustrative, not required.

## Keep the entry compact and descriptive

The entry should earn its special treatment as the module's compact descriptive
representation.

An entry that says only “files are in this directory” provides a poor title,
summary, and preview. An entry that reproduces every bundled resource defeats
the purpose of having a compact description.

The right amount depends on the module. A maintained specification may put most
of its normative account in the entry. A paper or dataset bundle may need only
an abstract, scope note, and catalog.

A practical test is to inspect the entry alone. It should be sufficient to
identify and preview the module. It does not have to substitute for the exact
resources a task actually depends on.

## Treat every bundled resource as module content

An Inq module may contain arbitrary files:

- polished Markdown;
- rough notes;
- transcripts;
- source material;
- images and diagrams;
- PDFs;
- code;
- notebooks;
- data;
- generated artifacts;
- historical records.

This depth is a feature. The module can carry a large body of useful material
without requiring all of it to enter the initial context window.

The CLI enumerates every included `.md` and `.markdown` resource in every
workspace module. It does not discover this set by walking links from the entry. The entry
receives the strict module-description checks above; every other Markdown
record receives lint for the same H1-and-summary shape.

With `inq lint`, every Markdown record is also an independent link source. An
unlinked note with a broken local link is therefore diagnosed.
Destinations with URI schemes are treated as external and are not fetched or
checked for remote availability.

Do not use “supporting file” as though every non-entry resource were merely an
implementation detail. In some modules, the entry is the principal document and
the rest supports it. In others, the PDFs, datasets, images, or code are the
principal artifacts and the entry is only their compact description.

Every included resource should belong to the module's coherent content body. A
resource need not be linked from the entry to be valid, addressable, or part of
the bundle. Entry links are optional references, not an export declaration or
reachability map.

The resource body does not need a universal folder schema or a uniform level of
polish. It should, however, remain understandable enough to inspect.

Useful habits include:

- give resource paths names that remain intelligible when linked from elsewhere;
- treat path changes as potentially breaking changes for external references;
- split Markdown by reason to load, not by arbitrary length;
- link commonly needed resources from the entry or a local index;
- use links from any resource to any other relevant resource;
- add a brief explanation around raw or ambiguous artifacts;
- remove accidental duplicates and unrelated material;
- state in prose when a resource is historical, generated, provisional, or no
  longer used, when that distinction matters.

Do not turn those habits into a mandatory metadata ontology. Higher-level tools
or communities may define specialized conventions; the base module remains
content-neutral.

Inq treats resource bytes as inert data. It does not execute code, run a
notebook, validate a proof, parse every media format, or decide whether a source
supports a claim. A human, agent, or specialized application must perform those
operations explicitly.

## Use links to express real relationships

Module-name spelling does not express meaningful relationships.

Links may target another module's entry or any exact resource in that module.
The correct target depends on the relationship.

Link to an entry when you mean the module as a whole. Link directly to an exact
PDF, dataset, image, source file, or note when that resource is what the
sentence actually depends on.

Links and surrounding prose should say why the target matters.

Prefer:

```markdown
The default timeout is defined by the timeout module, while
[failure classification](decisions/failure-classification.md) determines which
timeout outcomes may be retried.
```

Over:

```markdown
See also [failure classification](decisions/failure-classification.md).
```

Useful relationship language includes:

- defines;
- implements;
- depends on;
- applies;
- extends;
- replaces;
- contrasts with;
- provides evidence for;
- records the decision behind;
- supplies examples for.

A link is a route, not proof. The target must still be inspected when correctness
depends on it.

Links may still be useful for expressing relationships, but link traversal is a
higher-level reading strategy, not the definition of module contents. A context
compiler may choose different starting material without establishing a
canonical content tree. The default `inq workspace list` and `inq describe`
records inventory the actual selected bundle without walking links and report
both declared dependency relationships and resource links across all selected
Markdown.
Neither section turns the entry into a content root or recursively chooses a
reading path; `--mute-resources` and `--mute-links` suppress them when they are
not useful.

Mark a dependency `ambient = true` when its complete module is intentionally
useful as background context even though authored notes are not expected to
link to particular resources. Ambient is retrieval and audit intent, not a
different installation mode, and it does not forbid precise links. This lets a
context compiler consider the dependency directly and prevents dependency
pruning from treating the absence of links as accidental.

Workspace inheritance is local coordination state, not a self-contained
published dependency. When a hosted adapter acquires a module from a repository
workspace, it replaces every `{ workspace = true }` dependency with the
concrete request from that repository's same-named
`[workspace.dependencies]` slot. A missing slot
fails acquisition instead of publishing an unresolved module. Ambient intent
survives this projection, while `clone = true` does not: cloning describes how
the source workspace materializes a build input, not what the acquired module
depends on.

Use `{ workspace = true, clone = true }` when a build tool or other file-based
consumer needs a private snapshot of a same-named workspace module. The copy
lives in the declaring module's own `_inq/<alias>/` — the one dependency copy
that is not in the shared workspace library — is not module content, and is not
a second authoring location. Ordinary `inq sync` preserves an existing clone; after editing the
source module, run `inq sync --update` to refresh it. Clone intent itself keeps
an unlinked dependency out of `inq module prune`.

## Write for discovery without making the entry a content boundary

The portable module format does not require a hosting service to implement
lexical, label, deep, semantic, PDF, or AI search. Those capabilities may be
supplied by local tools or independent index services.

The entry gives every module a cheap, predictable document for module-level
search, summary, and preview. It does not prevent a deeper index from indexing
all resources or returning an exact PDF, code file, Markdown document, or
dataset as the relevant result. `inq workspace inventory` supplies the exact
selected path set to local search and indexing tools without defining one
built-in search engine.

Authors should nevertheless make both the module and its resources easy to
discover across different indexes:

- use concrete nouns and names in the entry title and summary;
- use clear module-relative resource paths and local headings;
- expand unfamiliar acronyms at least once;
- include alternate terminology naturally when it is genuinely used;
- state scope, dates, units, versions, and environments when they distinguish
  otherwise similar material;
- avoid making essential meaning depend only on a directory name or label.

Write for a cold reader, not for a particular embedding model or keyword
algorithm.

## Use labels as optional opaque metadata

Labels belong to the module manifest:

```toml
[labels]
subject = ["http", "reliability"]
purpose = ["reference"]
```

The current CLI accepts arrays of unique strings, preserves their spelling and
array order, and assigns them no built-in meaning. Labels are not defined by
the workspace and are not inherited through module names. A hosting or
index service may offer label search without changing those portable
semantics.

Use a label when a recurring selection or application convention makes it
useful. Do not use labels as a substitute for the entry's prose.

A workspace, organization, index service, or application may document a label
vocabulary for its own purposes. That convention lives above the portable
module kernel; modules still carry their own label values when moved elsewhere.

Keep labels modest. A large speculative ontology usually produces more
maintenance burden than retrieval value.

## Use a workspace only for local coordination

A workspace is useful when several modules need to be edited, searched,
resolved, validated, or interrogated together.

A minimal workspace role in `inq.toml` is just a name:

```toml
[workspace]
name = "research-vault"
```

A fuller one adds local coordination policy:

```toml
[workspace]
name = "research-vault"
description = "overview.md"
flavor = "obsidian"

members = [
  "modules/**",
]
```

`name` is required. It is a local display name in the module-name grammar and
contributes nothing to any module's identity; `inq init` defaults it to the
target directory's basename.

Member values are workspace-relative module-directory paths or glob patterns.
`*` stays within one path segment and `**` may cross segments. Each selected
directory must contain `inq.toml`, and every member remains self-identifying
through that manifest. Invalid or unmatched patterns and overlapping member
roots are validation errors.

`flavor` is optional and defaults to `obsidian`; `markdown-strict` selects
source-relative Markdown links for ordinary previewers. Flavor belongs only to
the workspace table. Never put `flavor` in `[module]`. `inq lint` checks every
authored link against that policy, and `inq lint --fix` safely converts every
equivalence-proven mismatch before linting the result.

`description` is optional and names one workspace-local Markdown note that
orients a contributor to this checkout: what it is for, how its modules relate,
and which conventions apply. It is not a module entry, gives no module identity,
and does not need to appear in `members`. It must not be module content either:
pointing `description` at a file that a member module includes — or that a
hybrid root module names as its `entry` — is a validation error, because one
file cannot be both local coordination and a portable module resource. Most
workspaces do not need a description, and `inq init` does not create one.

A workspace may also contain arbitrary local files such as:

```text
overview.md
AGENTS.md
editor configuration
scripts
lockfiles
local aliases or overrides
external-module caches
arbitrary nonmodule files
```

These are ordinary workspace files. A local overview may explain goals,
recommended reading paths, and conventions. Unless the workspace names it as
`description`, it is not designated in the manifest at all, and it never becomes
a module resource unless a module selects it.

Nested workspaces are allowed. The CLI chooses the nearest workspace from the
invocation directory, while an ancestor workspace may still select modules
beneath the descendant workspace with its own `members` patterns. Avoid
operating the same physical modules through both contexts when possible:
module-local generated state may be rewritten from different workspace locks
or flavors, much like other package managers allow nested workspaces without
recommending overlapping ownership.

Modules may also nest: an inner module root stops the outer module's
inclusion patterns, so the innermost module owns each file and every included
file has exactly one owner. Both modules may be members. An outer `include`
pattern that reaches past the inner boundary selects nothing there; link to
the nested module's resources instead of absorbing them.

The scaffolding commands stay conservative: `inq new`, `inq init`, and
`inq module init` refuse to create a module root inside an existing one. To
nest deliberately, write the inner `inq.toml` by hand and admit it through a
member pattern. Nest only when the inner material carries its own identity;
sibling roots joined by links remain the simpler default:

```text
workspace/
├── inq.toml
├── modules/
│   ├── retry-policy/
│   ├── timeout-policy/
│   └── client-guidance/
└── ext/
```

One workspace may contain modules about entirely unrelated subjects. That is
normal. A workspace is a temporary local arrangement, not a naming authority.

## Compose modules explicitly

A composition module is useful when a new, independently selectable account can
be built from several existing modules.

Its entry should do more than list links. Explain:

- why the component modules belong together for this purpose;
- what role each component plays;
- what the composition adds that the components do not say separately;
- where a reader should descend for detail.

Do not infer dependency or composition from similar module names. Every module
is an independently authored unit.

Choose the link target at the right granularity. Link to a component entry when
the composition depends on the component's module-level account. Link directly
to a PDF, dataset, code file, image, or note when that exact resource is the
actual component.

Prefer linking over copying. Summarize only what the composition needs, identify
the relationship, and let the maintained original module retain the canonical
resource bytes.

Create the composition as its own module only when the synthesis itself deserves
independent selection, publication, or reuse. Otherwise, it may simply be a
workspace map or an internal document.

## Respect publication and access boundaries

The authoring boundary should anticipate how the module might be served, while
keeping hosting policy separate from the portable files. The current CLI
defines no publication protocol, channel, primary registry,
arbitrary-resource fetch, or ACL system; those mechanics are service
contracts, not assumptions authors can make about core Inq.

A service may authorize exact resource reads against the enclosing module. Do
not place confidential and unrestricted resources together while assuming
that an unspecified host will enforce separate path-level policies. The entry
is not synonymous with "public", and a direct link to a PDF does not make
that PDF public; authorization remains the host's responsibility.

Do not place secrets in a module merely because the current workspace is local.
Workspace membership and hosted access policy are separate concerns.

## A practical authoring loop

### 1. Look before creating

Search the active project for an existing module or exact resource that
already belongs to the subject:

```bash
inq workspace list
inq workspace inventory --only-entry
inq workspace inventory
```

Search the resulting bounded paths with the text, semantic, or format-specific
tool appropriate to the material.

Create a new module only when the material needs a genuinely independent
boundary.

### 2. Create the manifest and entry

From the directory that should contain the module, use the current CLI's
initializer:

```bash
inq new retry-policy \
  --title "HTTP retry policy" \
  --label subject=http \
  --label purpose=reference
```

The command creates the destination directory in the current working directory,
defaults the module name to that directory's basename, and writes `inq.toml`
and `entry.md`. Pass `--name` when the logical module name should differ from
the basename. Inside a workspace it also adds the member to the workspace
manifest; outside one, the new directory becomes a hybrid one-module workspace
whose workspace `name` repeats the module name.

When the directory and its notes already exist, initialize that directory
instead:

```bash
inq init existing/retry-notes --name retry-policy
```

`init` defaults to the current directory and infers its role from the target.
Below a workspace it infers the module name from the directory basename,
reuses an existing `entry.md` without changing it when it is valid entry
Markdown, or creates the entry when it is absent. It registers a literal member
only if no existing member pattern already covers the target. Outside a
workspace, the same command creates a fresh workspace instead, writing an
`inq.toml` whose only content is `[workspace]` and a `name` taken from the
target directory's basename. At an existing
workspace root it requires `--as-hybrid` before adding the root module role.
Use the explicit `inq module init --entry overview.md` spelling when adopting a
nondefault entry path. You may also create the ordinary files directly; any
directory carrying an `inq.toml` that a workspace member pattern selects is a
member.

At minimum, write:

```text
<module-directory>/inq.toml
<module-directory>/<declared-entry>.md
```

Give the manifest a valid module name and point `entry` to the actual
Markdown file.

### 3. Write the smallest useful module description

Add:

- a specific first H1;
- a concrete first prose paragraph;
- enough context to identify and preview the module;
- optional references to notable resources when they improve the description.

Do not make the entry pretend to contain, export, route, or define the whole
module.

### 4. Add resources deliberately

Bundle the PDFs, Markdown, images, code, data, notebooks, transcripts, or other
artifacts that belong to the module. Give them durable, intelligible paths.
Treat every path as potentially linkable from another module.

### 5. Inspect the module as a consumer

Describe the module by its directory path or name, then request the concrete
views useful to the task:

```bash
inq describe <TARGET> --entry
inq describe retry-policy
inq describe github:OWNER/REPOSITORY::MODULE --remote
inq describe retry-policy --mute-links
inq describe retry-policy --mute-description --mute-labels
```

Also test exact resource resolution using the object or resource retrieval
operation supplied by your hosting or archival system. The current CLI has no
dedicated resource-fetch command; it resolves exact resources through
Markdown links, `lint`, description inventories, and deep Markdown search.

Ask:

- Does the entry provide a useful module-level preview?
- Can an exact resource link be resolved without first opening the entry?
- Do direct cross-module links target the intended resource?
- Does any whole-module archival or publication process include every resource
  regardless of entry links?
- Can tools use the entry for search and preview without mistaking it for a
  content root?
- Are resource paths stable and intelligible enough to serve as references?
- Does any important relationship remain implicit?

### 6. Lint the local graph

```bash
inq lint
```

`inq lint` promotes every warning to an error, so any finding exits nonzero.
Use `inq lint --fix` to rewrite safe link-flavor mismatches. Fix broken,
escaping, ambiguous, unsupported, or lossy references deliberately rather than
depending on a human or agent to guess.

### 7. Revisit the boundary

Split a module when part of it develops its own identity, entry, lifecycle,
publication needs, or access requirements.

Keep substantial resources inside the module when independent addressability
is sufficient and a separate publication unit would add no value.

Module boundaries improve through maintenance; they do not have to be perfectly
predicted at creation time.

## Common failure modes

| Failure | Why it is a problem | Better practice |
| --- | --- | --- |
| Mixing “module” and another concrete unit name | Makes it unclear what the portable artifact actually is | Use **module** for both the concept and the directory described by `inq.toml` |
| Treating a workspace path as module identity | Moving the directory appears to rename the content | Put the stable name in the module's own manifest |
| Pointing a workspace `description` at module content | One file would be both local coordination and a portable module resource | Keep the workspace note outside every module, or describe the module in its own `entry` |
| Encoding hierarchy in a module name | Confuses identity with organization and resource paths | Use one flat portable name and express relationships with links and prose |
| Assuming a fixed entry filename | Readers and tools may open the wrong document | Follow the manifest's `entry` value |
| Treating the entry as the module's only interface or export | Exact PDFs, data, code, and other resources are hidden behind an unnecessary hop | Treat the entry as the module description and every resource as directly addressable module content |
| Linking to an entry when the dependency is an exact file | Readers must navigate and guess which resource matters | Link directly to the precise module/resource address |
| Assuming an unlisted resource is private or unstable | Other modules may already address it directly | Treat resource paths as part of the module's usable surface |
| A vague title or “contains notes” summary | Descriptors cannot distinguish the module | Name the subject and state the module's role |
| An entry with no useful title, summary, or orientation | Module-level previews cannot distinguish the bundle | Make the entry an effective module description |
| An entry that contains every detail | Every consumer pays the maximum context cost | Move optional depth behind explained links |
| Treating all non-entry resources as mere support | Primary PDFs, datasets, code, or media are conceptually demoted | Treat every bundled resource as first-class module content |
| An incoherent resource pile | The module is portable but has no meaningful bundle boundary | Include resources that genuinely belong to one identity and lifecycle |
| Treating similar names as dependency | Spelling resemblance is mistaken for meaning | Express dependencies and relationships through links and prose |
| Giving labels built-in semantics | Couples portable content to one application worldview | Treat labels as opaque metadata and define conventions above the kernel |
| Equating resource addressability with independent ACLs | Authors assume protections that core Inq does not define | Consult the host's policy and split modules when content needs different protection |
| Expecting an outer module to include a nested module's files | Inclusion stops at the inner root; the innermost module owns each file | Link to the nested module's resources instead of absorbing them |
| Copying the same source into many compositions | Corrections drift and provenance becomes unclear | Link to the maintained exact resource and summarize its role |
| Requiring every module to be a “current synthesis” | Excludes valid artifacts such as frozen reports, PDF collections, records, and datasets | Let the entry accurately state the module's actual purpose and status |

## Review checklist

Before considering a module healthy, ask:

- Does `inq.toml` contain a valid, locally unique module name, independent of
  the workspace and local directory, and free of workspace-only flavor policy?
- Does the manifest point to the real entry resource?
- Does the first H1 provide a specific module title, and the first prose
  paragraph a useful module-level summary?
- Does the entry describe the module without pretending to define exports,
  reachability, or the module content tree?
- Do `include` patterns select every resource that belongs to the module, and
  does every included resource genuinely belong?
- Are resource paths stable and intelligible enough for external references?
- Do links target the entry only for module-level relationships, exact
  resource paths otherwise, with important links explained in prose?
- Are labels optional, modest, and free of assumed kernel semantics?
- Would the complete resource body make sense under one publication and access
  boundary if a host uses the module that way?
- When modules nest, does the innermost module genuinely own its files?
- Does `inq lint` pass?

The goal is not a universally tidy folder tree or a mandatory theory of
knowledge. The goal is a portable, self-identifying content bundle with a
stable address space. Every resource belongs to the module wholesale. One
ordinary Markdown resource is merely designated to explain the module cheaply
for search, summary, and preview.
