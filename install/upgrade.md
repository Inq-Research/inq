# Upgrade or remove Inq

First ask the installed command whether a newer release exists:

```bash
inq upgrade
```

That command reports upgrade guidance; it does not silently replace the
executable. Apply the update through the same installation channel you chose.

On macOS with Homebrew:

```bash
brew update
brew upgrade Inq-Research/inq/inq
```

On Linux, macOS without Homebrew, or Windows, run the platform installer again.
Each installer verifies the new archive before replacing the existing binary.

To install a particular release, pass its tag explicitly:

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh |
  sh -s - --version vX.Y.Z
```

```powershell
$script = irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1
& ([scriptblock]::Create($script)) -Version vX.Y.Z
```

`INQ_VERSION` provides the same pin for scripted environments. Verify the final
state with `inq --version`.

To remove Inq, run `brew uninstall Inq-Research/inq/inq` for a Homebrew install.
For a direct install, delete the `inq` or `inq.exe` binary from the directory
you selected and remove that directory from `PATH` only if nothing else uses it.
