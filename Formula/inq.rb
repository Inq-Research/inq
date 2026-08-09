class Inq < Formula
  desc "Portable thinking for the machine age"
  homepage "https://github.com/Inq-Research/inq"
  version "0.2.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Inq-Research/inq/releases/download/v0.2.0/inq-aarch64-apple-darwin.tar.xz"
      sha256 "f31c5759aae6f382f1b2d215031beb491b993c2aa52a10b70511ee12d6623788"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.2.0/inq-x86_64-apple-darwin.tar.xz"
      sha256 "a476e70be8ef2c1ea245caafc416c6de68fc0d4f30a28ea1b6140ff3c3e89070"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.2.0/inq-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "f3130e04b6c647835c12f56c73d30abff0767f996f9745d797ddcf6cb5846cec"
    end
  end

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "x86_64-apple-darwin": {},
    "x86_64-pc-windows-gnu": {},
    "x86_64-unknown-linux-gnu": {}
  }

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      bin.install "inq"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "inq"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "inq"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
