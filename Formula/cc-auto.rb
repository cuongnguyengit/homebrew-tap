class CcAuto < Formula
  desc "Multi-account manager and quota router for Claude Code"
  homepage "https://github.com/cuongnguyengit/cc-auto-apt"
  version "1.3.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/cuongnguyengit/cc-auto-apt/releases/download/v1.3.1/cc-auto-macos-1.3.1-arm64.tar.gz"
      sha256 "b4b1aea55602ef7fbaa99bc27319a239bafd5f64c39b4f8464ea3df68e81524c"
    end
    on_intel do
      url "https://github.com/cuongnguyengit/cc-auto-apt/releases/download/v1.3.1/cc-auto-macos-1.3.1-amd64.tar.gz"
      sha256 "f1fcf1cbb0f1e2683743edf4a29ee935ff76079a73b9cb5e19c6114f885a72f7"
    end
  end

  depends_on :macos

  def install
    libexec.install "cc-auto", "cc-account", "accounts.sh"
    bin.install_symlink libexec/"cc-auto", libexec/"cc-account"
    (bin/"cc-auto-setup").write <<~SH
      #!/bin/sh
      set -eu
      exec "#{opt_libexec}/cc-auto" install --system-package --source "#{opt_libexec}" "$@"
    SH
  end

  def caveats
    <<~EOS
      Run cc-auto-setup as your own user, then reopen your terminal.
      Install the native Claude Code CLI separately to sign in.
      Python is not required. Existing profiles are preserved.
      After brew upgrade, rerun cc-auto-setup to refresh integrations.
      See cc-account --help, cc-auto --help and cc-account doctor.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/cc-auto --version").strip
    assert_equal version.to_s, shell_output("#{bin}/cc-account --version").strip
    assert_match "--watch", shell_output("#{bin}/cc-auto --help")
    assert_match "least-used", shell_output("#{bin}/cc-account --help")
    system bin/"cc-auto", "install", "--target-home", testpath/"home", "--system-package",
           "--source", opt_libexec, "--no-service", "--no-vscode"
    assert_path_exists testpath/"home/.config/claude-accounts/accounts.sh"
    assert_equal version.to_s, shell_output("#{testpath}/home/.local/bin/cc-auto --version").strip
    ENV["CLAUDE_ACCOUNTS_ROOT"] = (testpath/"home/.claude-accounts").to_s
    output = shell_output("#{bin}/cc-auto check --json")
    assert_equal "monitoring", JSON.parse(output).fetch("selectionMode")
    assert_match "macOS quota monitoring", shell_output("#{bin}/cc-auto check")
  end
end
