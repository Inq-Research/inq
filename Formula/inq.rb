class Inq < Formula
  desc "Portable thinking for the machine age"
  homepage "https://github.com/Inq-Research/inq"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Inq-Research/inq/releases/download/v0.1.0/inq-aarch64-apple-darwin.tar.xz"
      sha256 "cd8a449b3a9fc67880d21a59fd552ed376e66ecb4a16a341c2d1f59105a261f4"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.1.0/inq-x86_64-apple-darwin.tar.xz"
      sha256 "57ca9a6239cd045e2d4bb39bb376d018c56ae8bb5ba4e946f09cbdd5a33d3b1c"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.1.0/inq-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "50563abfe34b42a301187f4b13e12fac8e6319ea500180cf917844569498e7af"
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
