<#
.SYNOPSIS
Install the inq CLI on Windows.

.DESCRIPTION
Downloads one release archive, checks it against the SHA-256 published beside
it, and puts inq.exe in a per-user directory. It installs nothing else: no
package manager is invoked and no administrator rights are needed.

The download is never installed unverified. Every way of failing to verify
stops the script.

.PARAMETER Dir
Where to put inq.exe. Defaults to $env:LOCALAPPDATA\Programs\inq.
Also read from INQ_INSTALL_DIR.

.PARAMETER Version
Release tag to install, such as v0.3.0. Defaults to the latest release.
Also read from INQ_VERSION.

.PARAMETER NoPathUpdate
Leave the user PATH alone. Also set by INQ_NO_PATH_UPDATE.

.EXAMPLE
irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1 | iex

.EXAMPLE
& ([scriptblock]::Create((irm https://github.com/Inq-Research/inq/raw/main/get-inq.ps1))) -Version v0.3.0
#>

[CmdletBinding()]
param(
    [string] $Dir,
    [string] $Version,
    [switch] $NoPathUpdate
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$Repo = 'Inq-Research/inq'
$Releases = "https://github.com/$Repo/releases"
$Issues = "https://github.com/$Repo/issues"

# ------------------------------------------------------------------- messages

# The console Windows PowerShell starts in is rarely UTF-8, so a check mark
# arrives as a stray question mark unless the encoding is set first.
try {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    $script:Tick = [char]0x2713
} catch {
    $script:Tick = '+'
}

function Write-Step([string] $Message) {
    Write-Host "  $script:Tick $Message"
}

function Write-Note([string] $Message) {
    Write-Host "  - $Message"
}

function Stop-Install([string] $Message, [string[]] $Detail) {
    Write-Host ''
    Write-Host "error $Message" -ForegroundColor Red
    foreach ($line in $Detail) {
        Write-Host "      $line"
    }
    exit 1
}

# ------------------------------------------------------------------- settings

if (-not $Dir) { $Dir = $env:INQ_INSTALL_DIR }
if (-not $Dir) { $Dir = Join-Path $env:LOCALAPPDATA 'Programs\inq' }

if (-not $Version) { $Version = $env:INQ_VERSION }
if (-not $Version) { $Version = 'latest' }

if ($env:INQ_NO_PATH_UPDATE) { $NoPathUpdate = $true }

Write-Host ''
Write-Host 'Installing inq'

# ------------------------------------------------------------------- platform

# Only one Windows target is built. Naming the architecture that was detected
# matters more than guessing, because an ARM64 device otherwise fails later
# with an unreadable executable rather than a clear refusal here.
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) { $architecture = $env:PROCESSOR_ARCHITEW6432 }

if ($architecture -ne 'AMD64') {
    Stop-Install "no Windows build for $architecture" @(
        'only x86_64 Windows is built today',
        "see $Releases"
    )
}

$target = 'x86_64-pc-windows-msvc'
$archive = "inq-$target.zip"
Write-Step "platform $target"

# ------------------------------------------------------------------- download

if ($Version -eq 'latest') {
    $base = "$Releases/latest/download"
} else {
    $base = "$Releases/download/$Version"
}

# PowerShell 5.1 defaults to protocols GitHub no longer accepts.
try {
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {
    # .NET versions that already negotiate TLS 1.2 do not expose the setting.
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("inq-install-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null

try {
    $archivePath = Join-Path $work $archive
    $checksumPath = "$archivePath.sha256"

    function Get-File([string] $Url, [string] $Path, [string] $What) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Path -UseBasicParsing
        } catch {
            Stop-Install "could not download $What" @(
                "checked $Url",
                $_.Exception.Message,
                "if you passed -Version, confirm that release exists: $Releases"
            )
        }
    }

    Get-File "$base/$archive" $archivePath $archive
    Write-Step "downloaded $archive"

    # --------------------------------------------------------------- verify

    Get-File "$base/$archive.sha256" $checksumPath "the checksum for $archive"

    # The published file is `HASH *NAME`; compare hashes rather than running a
    # checker, so the format and the working directory cannot matter.
    $published = (Get-Content -Path $checksumPath -Raw).Trim()
    $expected = ($published -split '\s+')[0]

    if (-not $expected -or $expected.Length -ne 64) {
        Stop-Install "the published checksum for $archive is unreadable" @(
            "received '$published'",
            "report this: $Issues"
        )
    }

    $actual = (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash

    if ($actual -ne $expected.ToUpperInvariant() -and
        $actual.ToLowerInvariant() -ne $expected.ToLowerInvariant()) {
        Stop-Install 'the download does not match its published checksum' @(
            "expected $expected",
            "received $actual",
            "delete nothing and report this: $Issues"
        )
    }
    Write-Step 'checksum verified'

    # -------------------------------------------------------------- install

    $unpacked = Join-Path $work 'unpacked'
    try {
        Expand-Archive -Path $archivePath -DestinationPath $unpacked -Force
    } catch {
        Stop-Install "could not unpack $archive" @($_.Exception.Message)
    }

    $binary = Get-ChildItem -Path $unpacked -Filter 'inq.exe' -Recurse -File |
        Select-Object -First 1
    if (-not $binary) {
        Stop-Install 'the archive did not contain inq.exe' @("report this: $Issues")
    }

    try {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    } catch {
        Stop-Install "could not create $Dir" @('choose another with -Dir')
    }

    $destination = Join-Path $Dir 'inq.exe'
    try {
        Copy-Item -Path $binary.FullName -Destination $destination -Force
    } catch {
        Stop-Install "could not write $destination" @(
            'close any running inq.exe and try again',
            $_.Exception.Message
        )
    }

    $installed = (& $destination --version) -join ' '
    Write-Step "installed $installed to $destination"
} finally {
    Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
}

# ----------------------------------------------------------------------- path

# Whether a directory is already reachable, comparing whole entries rather than
# substrings so that a prefix of another entry cannot look like a match.
function Test-OnPath([string] $Value, [string] $Directory) {
    if (-not $Value) { return $false }
    $wanted = $Directory.TrimEnd('\')
    foreach ($entry in $Value -split ';') {
        if ($entry -and $entry.TrimEnd('\') -ieq $wanted) { return $true }
    }
    return $false
}

# Windows has no equivalent of appending a line to a shell profile: the safe
# way to edit a user PATH is through the environment block, and `setx` silently
# truncates it at 1024 characters. So this edits it rather than printing a
# command that would be a trap to run.
if (Test-OnPath $env:Path $Dir) {
    Write-Host ''
    Write-Host 'Run inq howto for the built-in guides.'
} elseif ($NoPathUpdate) {
    Write-Host ''
    Write-Host 'Add it to your PATH'
    Write-Note "$Dir is not on your PATH, and -NoPathUpdate was set"
} else {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    if (-not (Test-OnPath $userPath $Dir)) {
        $updated = if ($userPath) { "$($userPath.TrimEnd(';'));$Dir" } else { $Dir }
        try {
            [Environment]::SetEnvironmentVariable('Path', $updated, 'User')
            Write-Step "added $Dir to your user PATH"
        } catch {
            Stop-Install 'could not update your user PATH' @(
                "add $Dir to it yourself, or re-run with -NoPathUpdate",
                $_.Exception.Message
            )
        }
    }

    $env:Path = "$env:Path;$Dir"
    Write-Host ''
    Write-Host 'Open a new terminal, then run inq howto for the built-in guides.'
}

Write-Host ''
