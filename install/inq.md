---
inq.module: install
inq.include:
  - './'
inq.label.purpose:
  - 'guide'
inq.label.subject:
  - 'cli'
---
# Install and upgrade Inq

Install the `inq` command safely on a supported platform, verify that your
shell can find it, and return here when a new release is available.

- [[install/macos|Install on macOS]]
- [[install/linux|Install on Linux]]
- [[install/windows|Install on Windows]]
- [[install/upgrade|Upgrade or remove Inq]]

The release installers download one platform archive, verify its published
SHA-256 checksum, and install only the `inq` executable. A failed verification
installs nothing.
