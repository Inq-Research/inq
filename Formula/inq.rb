class Inq < Formula
  desc "Portable thinking for the machine age"
  homepage "https://github.com/Inq-Research/inq"
  version "0.3.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Inq-Research/inq/releases/download/v0.3.0/inq-aarch64-apple-darwin.tar.xz"
      sha256 "ee14bcc5853e2903d599d692c1fab9aeaae4590ce8f192d10f5d109971980cfd"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.3.0/inq-x86_64-apple-darwin.tar.xz"
      sha256 "3a92c47dd6a041223d9914cd533777668a370817317221d634375604a31edbb1"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/Inq-Research/inq/releases/download/v0.3.0/inq-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "98fbfa1966a65bdfba7f7fee4f3d9a743d32389795f78535e528ea92414e91b4"
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
