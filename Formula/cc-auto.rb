class CcAuto < Formula
  desc "Multi-account manager and quota router for Claude Code"
  homepage "https://github.com/cuongnguyengit/cc-auto-apt"
  version "1.5.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/cuongnguyengit/cc-auto-apt/releases/download/v1.5.2/cc-auto-macos-1.5.2-arm64.tar.gz"
      sha256 "0f473d652659aa170eda673caf0840305322ed6cc4c2e7afde6764caf02b2989"
    end
    on_intel do
      url "https://github.com/cuongnguyengit/cc-auto-apt/releases/download/v1.5.2/cc-auto-macos-1.5.2-amd64.tar.gz"
      sha256 "60b969c64b9db34a21a452708bc73e40fefac887f799bbc85b846fe4c8d7df56"
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
    warmup = JSON.parse(shell_output("#{bin}/cc-auto warmup status --json"))
    assert_equal false, warmup.fetch("config").fetch("enabled")
    assert_equal ["05:00", "10:00", "15:00"], warmup.fetch("config").fetch("times")
    assert_equal 3, warmup.fetch("nextSlots").length
    output = shell_output("#{bin}/cc-auto check --json")
    assert_equal "monitoring", JSON.parse(output).fetch("selectionMode")
    assert_match "macOS quota monitoring", shell_output("#{bin}/cc-auto check")
    fixture = testpath/"home/.claude-accounts/profiles/detail-fixture"
    fixture.mkpath
    (fixture/".claude.json").write <<~JSON
      {"oauthAccount":{"emailAddress":"fixture@example.invalid","displayName":"Fixture Person","accessToken":"MUST_NOT_APPEAR"}}
    JSON
    output = shell_output("#{bin}/cc-account detail detail-fixture --json")
    assert_equal "fixture@example.invalid", JSON.parse(output).fetch("email")
    assert_equal "local_cache", JSON.parse(output).fetch("source")
    refute_includes output, "MUST_NOT_APPEAR"
  end
end
