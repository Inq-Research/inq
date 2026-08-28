# Install Inq on macOS

Homebrew is the most convenient macOS installation path. The tap URL is
explicit because the repository is named `inq` rather than `homebrew-inq`.

```bash
brew tap Inq-Research/inq https://github.com/Inq-Research/inq
brew trust --formula Inq-Research/inq/inq
brew install Inq-Research/inq/inq
```

The formula supports Apple Silicon and Intel Macs. Confirm the installed
command before creating a workspace:

```bash
inq --version
inq howto
```

Without Homebrew, use the release installer shared with Linux:

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh | sh
```

It installs to `~/.local/bin` by default and prints the exact command needed if
that directory is not on `PATH`. The script verifies the archive's published
SHA-256 checksum before replacing any existing binary.

Git is needed only for `github:` module sources. Install it with
`xcode-select --install` or `brew install git` when you intend to use those
sources; local modules and one-shot ArXiv imports do not require it.
