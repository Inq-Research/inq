# Inq

Portable thinking for the machine age.

Inq helps you bundle, share, and weave together any kind of thought. It stays
out of your way, and has no opinions on how you, your colleagues, and your
agents work.

## Grab a thought

Use `inq` for acquisition.

```bash
# Grab an article from arxiv.org
inq add arxiv:2302.10778

# Preview a module without downloading it
inq describe github:inq-research/inq::zen

# Or grab this note you're reading right now
inq add github:inq-research/inq::overview
```

These commands copy files into your workstation. Think of it like "installing
knowledge."

AI agents are much happier & speedier when reading files on your own computer,
rather than making round-trip errands searching the internet.

## Install

### Homebrew (macOS and Linux)

```bash
brew tap Inq-Research/inq https://github.com/Inq-Research/inq
brew trust --formula Inq-Research/inq/inq
brew install Inq-Research/inq/inq
```

The explicit URL is needed once because this distribution repository is named
`inq`, rather than using Homebrew's conventional `homebrew-` prefix. Stable
releases update `Formula/inq.rb` in this repository automatically.

### Shell installer (macOS and Linux)

```bash
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/Inq-Research/inq/releases/latest/download/inq-installer.sh | sh
```

### PowerShell installer (Windows)

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/Inq-Research/inq/releases/latest/download/inq-installer.ps1 | iex"
```

Stable downloads are available from the
[`latest` release](https://github.com/Inq-Research/inq/releases/latest).

Git is not required to install `inq` or work with local and arXiv content.
Commands that use a `github:` source require Git; check with `git --version`. On
macOS, install it with `xcode-select --install` or `brew install git`.
