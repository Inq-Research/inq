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

**macOS**

```bash
brew tap Inq-Research/inq https://github.com/Inq-Research/inq
brew trust --formula Inq-Research/inq/inq
brew install Inq-Research/inq/inq
```

The tap needs its URL spelled out because this repository is named `inq` rather
than `homebrew-inq`. Without Homebrew, use the Linux command below; it works on
macOS too.

**Linux**

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh | sh
```

One binary into `~/.local/bin`. The script prints the line to add that
directory to your `PATH` if it is not already there.

**Windows**

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1 | iex"
```

One binary into `%LOCALAPPDATA%\Programs\inq`, which is added to your user
`PATH`. Pass `-NoPathUpdate` to skip that.

Both scripts check the download against the SHA-256 published beside it and
install nothing if it does not match. Read
[`get-inq.sh`](https://github.com/Inq-Research/inq/blob/main/get-inq.sh) and
[`get-inq.ps1`](https://github.com/Inq-Research/inq/blob/main/get-inq.ps1)
before you pipe them.

Both accept a target directory and a release tag:

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh |
  sh -s - --dir /usr/local/bin --version v0.3.0
```

```powershell
& ([scriptblock]::Create((irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1))) -Dir C:\tools\inq -Version v0.3.0
```

`INQ_INSTALL_DIR` and `INQ_VERSION` do the same, which suits a Dockerfile.
Run either script with `--help` or `-?` for the rest.

## Upgrade

Run `inq upgrade` to see whether a newer release exists.

On macOS, `brew upgrade Inq-Research/inq/inq`. On Linux and Windows, run the
install command again; it replaces the binary in place.

To uninstall, delete the binary, or run `brew uninstall Inq-Research/inq/inq`.

## Start here

```bash
mkdir my-inquiry && cd my-inquiry

inq init         # this directory is now a workspace
inq new notes    # a module inside it
inq howto        # the guides, bundled with the binary
```

<details>
<summary>Manual downloads and Git</summary>

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
