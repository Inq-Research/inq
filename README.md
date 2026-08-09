# inq releases

This public repository hosts release downloads and installation metadata for
`inq`. The application source and release builds are maintained separately.

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
Commands that use a `github:` source require Git; check with `git --version`.
On macOS, install it with `xcode-select --install` or `brew install git`.
