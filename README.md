# Inq

Portable thinking for the machine age.

Inq helps you bundle, share, and weave together any kind of thought. It stays
out of your way, and has no opinions on how you, your colleagues, and your
agents work.

## Grab a thought

```bash
# An article from arxiv.org
inq add arxiv:2302.10778

# Peek at a module without installing it
inq describe github:inq-research/inq::overview

# Or grab this note you're reading right now
inq add github:inq-research/inq::overview
```

These commands copy files into your workstation. Think of it like "installing
knowledge."

AI agents are much happier & speedier when reading files on your own computer,
rather than making round-trip errands searching the internet.

## Install

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh | sh
```

One binary into `~/.local/bin`. No profile edits, no package manager, no root.
Run it again to upgrade; delete the binary to uninstall.

The script is
[`get-inq.sh`](https://github.com/Inq-Research/inq/blob/main/get-inq.sh) — read
it before you pipe it. Every download is checked against the SHA-256 published
beside it.

```bash
... | sh -s - --dir /usr/local/bin    # put it elsewhere
... | sh -s - --version v0.3.0        # pin a release
```

`INQ_INSTALL_DIR` and `INQ_VERSION` do the same, which suits a Dockerfile.
`--help` covers the rest.

## Start here

```bash
mkdir my-inquiry && cd my-inquiry

inq init         # this directory is now a workspace
inq new notes    # a module inside it
inq howto        # the guides, bundled with the binary
```

<details>
<summary>Homebrew, Windows, and manual downloads</summary>

### Homebrew (macOS and Linux)

```bash
brew tap Inq-Research/inq https://github.com/Inq-Research/inq
brew trust --formula Inq-Research/inq/inq
brew install Inq-Research/inq/inq
```

The explicit URL is needed once because this repository is named `inq` rather
than using Homebrew's conventional `homebrew-` prefix. Stable releases update
`Formula/inq.rb` here automatically.

### Windows

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/Inq-Research/inq/releases/latest/download/inq-installer.ps1 | iex"
```

### Manual

Grab an archive from the
[latest release](https://github.com/Inq-Research/inq/releases/latest), unpack
it, and put `inq` on your `PATH`. Each one ships with a `.sha256`.

```text
inq-aarch64-apple-darwin.tar.xz        Apple Silicon macOS
inq-x86_64-apple-darwin.tar.xz         Intel macOS
inq-x86_64-unknown-linux-gnu.tar.xz    x86_64 Linux
inq-x86_64-pc-windows-msvc.zip         x86_64 Windows
```

No Linux ARM64 build yet.

### Git

Only `github:` sources need it; local and arXiv content does not. On macOS,
`xcode-select --install` or `brew install git`.

</details>
