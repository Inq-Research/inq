# Install Inq on Windows

Run the PowerShell installer from a normal, non-administrator terminal:

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1 | iex"
```

The current release target is x86_64 Windows. The installer downloads that
archive and its published SHA-256 checksum, verifies the bytes, and writes
`inq.exe` to `%LOCALAPPDATA%\Programs\inq` by default. It adds that directory to
your user `PATH` without using `setx`, which can truncate long values.

Open a new terminal, then verify the command:

```powershell
inq --version
inq howto
```

To choose another directory or leave `PATH` unchanged, invoke the downloaded
script with options:

```powershell
$script = irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1
& ([scriptblock]::Create($script)) -Dir C:\tools\inq -NoPathUpdate
```

`INQ_INSTALL_DIR` and `INQ_NO_PATH_UPDATE` provide the same controls for
scripted environments. Close a running `inq.exe` before replacing it during a
later installation.
