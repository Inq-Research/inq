# Install Inq on Linux

The release installer supports x86_64 Linux and places one executable in
`~/.local/bin`:

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh | sh
```

The script needs `curl` or `wget`, `tar` with xz support, and one SHA-256 tool:
`sha256sum`, `shasum`, or `openssl`. It downloads the archive and checksum from
the same GitHub release and refuses to install unverified bytes.

If `~/.local/bin` is not already on `PATH`, follow the shell-specific command
the installer prints. Then open a new shell when needed and verify the result:

```bash
inq --version
inq howto
```

Choose another writable destination with `--dir`:

```bash
curl -sSfL https://github.com/Inq-Research/inq/raw/main/get-inq.sh |
  sh -s - --dir /usr/local/bin
```

`INQ_INSTALL_DIR` provides the same setting for Dockerfiles and other scripted
environments. There is no published Linux ARM64 build yet; use a supported
release target rather than installing an x86_64 archive on an ARM machine.
