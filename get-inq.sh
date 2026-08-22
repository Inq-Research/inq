#!/bin/sh
#
# get-inq.sh — install the inq CLI on macOS or Linux.
#
#   curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh | sh
#
# It downloads one release archive from this repository, checks it against the
# SHA-256 published beside it, and copies a single binary into place. It writes
# nothing else: no shell profile is edited, no package manager is invoked, and
# nothing runs as root.
#
# Options, as flags or environment variables:
#
#   --dir DIR        INQ_INSTALL_DIR   where to put the binary
#                                      (default: ~/.local/bin)
#   --version TAG    INQ_VERSION       release to install, such as v0.3.0
#                                      (default: the latest release)
#   --help
#
# Pass flags through a pipe after `-s -`:
#
#   curl -sSfL .../get-inq.sh | sh -s - --dir /usr/local/bin
#
set -eu

REPO="Inq-Research/inq"
BIN="inq"
RELEASES="https://github.com/$REPO/releases"

install_dir="${INQ_INSTALL_DIR:-$HOME/.local/bin}"
version="${INQ_VERSION:-latest}"
tmp=""

# ---------------------------------------------------------------- presentation

if [ -t 2 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != "dumb" ]; then
	bold=$(printf '\033[1m'); dim=$(printf '\033[2m')
	red=$(printf '\033[31m'); green=$(printf '\033[32m')
	reset=$(printf '\033[0m')
else
	bold=""; dim=""; red=""; green=""; reset=""
fi

say()  { printf '%s\n' "$*" >&2; }
step() { printf '  %s%s%s %s\n' "$green" "✓" "$reset" "$*" >&2; }
note() { printf '  %s%s%s\n' "$dim" "$*" "$reset" >&2; }

die() {
	printf '\n%serror%s %s\n' "$red" "$reset" "$1" >&2
	shift
	for line in "$@"; do
		[ -n "$line" ] && printf '      %s\n' "$line" >&2
	done
	exit 1
}

cleanup() { [ -n "$tmp" ] && rm -rf "$tmp"; }
trap cleanup EXIT HUP INT TERM

# Spelled out rather than read from $0, because the usual way to run this
# script is a pipe, where it cannot see its own source.
usage() {
	cat >&2 <<USAGE
${bold}get-inq.sh${reset} — install the inq CLI on macOS or Linux

  curl -sSfL https://github.com/$REPO/raw/main/get-inq.sh | sh

It downloads one release archive from this repository, checks it against the
SHA-256 published beside it, and copies a single binary into place. It edits no
shell profile, invokes no package manager, and needs no root.

${bold}Options${reset}
  --dir DIR        where to put the binary (default: \$HOME/.local/bin)
  --version TAG    release to install, such as v0.3.0 (default: latest)
  --help           show this text

${bold}Environment${reset}
  INQ_INSTALL_DIR  same as --dir
  INQ_VERSION      same as --version
  NO_COLOR         disable colored output

${bold}Passing options through a pipe${reset}
  curl -sSfL https://github.com/$REPO/raw/main/get-inq.sh | sh -s - --dir /usr/local/bin

Releases: https://github.com/$REPO/releases
USAGE
	exit 0
}

# ----------------------------------------------------------------- arguments

while [ $# -gt 0 ]; do
	case "$1" in
	--dir)     [ $# -ge 2 ] || die "--dir needs a directory";     install_dir="$2"; shift 2 ;;
	--version) [ $# -ge 2 ] || die "--version needs a release tag"; version="$2";   shift 2 ;;
	--dir=*)     install_dir="${1#--dir=}";     shift ;;
	--version=*) version="${1#--version=}";     shift ;;
	-h | --help) usage ;;
	*) die "unknown option: $1" "run with --help to see the supported options" ;;
	esac
done

# ------------------------------------------------------------------ platform

need() {
	command -v "$1" >/dev/null 2>&1 ||
		die "$1 is required but was not found" "install $1 and run this again"
}

need uname
need tar
need mkdir

# The downloader's own diagnostics are captured rather than printed, so a clean
# run stays quiet and a failure can quote the real reason underneath ours.
fetch_error="/dev/null"
if command -v curl >/dev/null 2>&1; then
	fetch() { curl -sSfL "$1" -o "$2" 2>"$fetch_error"; }
elif command -v wget >/dev/null 2>&1; then
	fetch() { wget -q "$1" -O "$2" 2>"$fetch_error"; }
else
	die "neither curl nor wget was found" "install one of them and run this again"
fi

# Why a download failed, as the downloader explained it.
fetch_reason() {
	[ -s "$fetch_error" ] || return 0
	sed 's/^/  /' "$fetch_error"
}

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
Darwin)
	case "$arch" in
	arm64 | aarch64) target="aarch64-apple-darwin" ;;
	x86_64) target="x86_64-apple-darwin" ;;
	*) die "unsupported macOS architecture: $arch" ;;
	esac
	;;
Linux)
	case "$arch" in
	x86_64 | amd64) target="x86_64-unknown-linux-gnu" ;;
	aarch64 | arm64)
		die "there is no published Linux ARM64 build yet" \
			"the releases carry x86_64 Linux, and both Intel and Apple Silicon macOS:" \
			"$RELEASES/latest"
		;;
	*) die "unsupported Linux architecture: $arch" ;;
	esac
	;;
MINGW* | MSYS* | CYGWIN* | Windows_NT)
	die "this script installs the macOS and Linux builds" \
		"on Windows, run the PowerShell installer instead:" \
		"irm $RELEASES/latest/download/inq-installer.ps1 | iex"
	;;
*)
	die "unsupported operating system: $os" "see $RELEASES/latest"
	;;
esac

archive="$BIN-$target.tar.xz"
if [ "$version" = "latest" ]; then
	base="$RELEASES/latest/download"
else
	base="$RELEASES/download/$version"
fi

say ""
say "${bold}Installing inq${reset}"
step "platform $target"

# ------------------------------------------------------------------ download

tmp="$(mktemp -d "${TMPDIR:-/tmp}/get-inq.XXXXXX")"
fetch_error="$tmp/fetch.err"

fetch "$base/$archive" "$tmp/$archive" ||
	die "could not download $archive" \
		"checked $base/$archive" \
		"$(fetch_reason)" \
		"if you passed --version, confirm that release exists: $RELEASES"
step "downloaded $archive"

# --------------------------------------------------------------------- verify

# Verification is not optional. An unverified binary is not installed, so every
# way of failing to verify has to stop the script rather than warn and continue.

if command -v sha256sum >/dev/null 2>&1; then
	sha256_of() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
	sha256_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
elif command -v openssl >/dev/null 2>&1; then
	sha256_of() { openssl dgst -sha256 "$1" | tr ' ' '\n' | tail -n 1; }
else
	die "no way to compute a SHA-256 checksum" \
		"install one of sha256sum, shasum, or openssl and run this again" \
		"the download is never installed unverified"
fi

fetch "$base/$archive.sha256" "$tmp/$archive.sha256" ||
	die "could not download the checksum for $archive" \
		"checked $base/$archive.sha256" \
		"$(fetch_reason)" \
		"the download is never installed unverified"

# The published file is `HASH *NAME`; compare hashes rather than running a
# checker, so the format and the working directory cannot matter.
expected="$(cut -d' ' -f1 <"$tmp/$archive.sha256")"
[ -n "$expected" ] ||
	die "the published checksum for $archive is empty" \
		"report this: https://github.com/$REPO/issues"

actual="$(sha256_of "$tmp/$archive")" ||
	die "could not compute the checksum of the download"

[ "$expected" = "$actual" ] ||
	die "the download does not match its published checksum" \
		"expected $expected" \
		"received $actual" \
		"delete nothing and report this: https://github.com/$REPO/issues"
step "checksum verified"

# -------------------------------------------------------------------- install

tar -xf "$tmp/$archive" -C "$tmp" ||
	die "could not unpack $archive" \
		"tar needs xz support; on Debian or Ubuntu, install xz-utils"

# The archive holds one directory named for the target, containing the binary.
found="$(find "$tmp" -type f -name "$BIN" -perm -u+x 2>/dev/null | head -n 1)"
[ -n "$found" ] || die "the archive did not contain an executable named $BIN"

mkdir -p "$install_dir" 2>/dev/null ||
	die "could not create $install_dir" "choose another with --dir DIR"

dest="$install_dir/$BIN"
previous=""
if [ -e "$dest" ]; then
	previous="$("$dest" --version 2>/dev/null || true)"
fi

# Replace through a temporary name so a running binary is never written into.
if ! { cp "$found" "$dest.new" && chmod 755 "$dest.new" && mv -f "$dest.new" "$dest"; }; then
	rm -f "$dest.new"
	die "could not write $dest" \
		"pick a directory you own with --dir DIR, for example:" \
		"  curl -sSfL $RELEASES/../raw/main/get-inq.sh | sh -s - --dir \"\$HOME/.local/bin\""
fi

installed="$("$dest" --version 2>/dev/null || true)"
[ -n "$installed" ] ||
	die "installed $dest but it did not run" \
		"the build may not match this machine; see $RELEASES/latest"

if [ -n "$previous" ] && [ "$previous" != "$installed" ]; then
	step "installed $installed to $dest ${dim}(replacing $previous)${reset}"
else
	step "installed $installed to $dest"
fi

# ----------------------------------------------------------------- next steps

on_path=no
case ":$PATH:" in *":$install_dir:"*) on_path=yes ;; esac

say ""
if [ "$on_path" = yes ]; then
	say "${bold}Try it${reset}"
	say "  mkdir my-inquiry && cd my-inquiry"
	say "  inq init                 ${dim}# a workspace in this directory${reset}"
	say "  inq new notes            ${dim}# a module inside it${reset}"
	say "  inq howto                ${dim}# the built-in guides${reset}"
else
	say "${bold}Add it to your PATH${reset}"
	case "$(basename "${SHELL:-sh}")" in
	fish) say "  fish_add_path $install_dir" ;;
	zsh)  say "  echo 'export PATH=\"$install_dir:\$PATH\"' >> ~/.zshrc && exec zsh" ;;
	bash)
		profile="$HOME/.bashrc"
		[ "$os" = Darwin ] && profile="$HOME/.bash_profile"
		say "  echo 'export PATH=\"$install_dir:\$PATH\"' >> $profile && exec bash"
		;;
	*) say "  export PATH=\"$install_dir:\$PATH\"" ;;
	esac
	say ""
	say "Then run ${bold}inq howto${reset} for the built-in guides."
fi
say ""
