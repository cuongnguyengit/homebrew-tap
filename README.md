# CC Auto Homebrew tap

Native Go CLI for macOS Apple Silicon and Intel. No Python required.

```sh
brew install cuongnguyengit/tap/cc-auto
cc-auto-setup
exec "$SHELL" -l
```

Install [Homebrew](https://brew.sh) first if needed. This is the project's own tap, not homebrew/core or the Mac App Store. If Homebrew asks for formula trust, trust only `cuongnguyengit/tap/cc-auto`.

Install the native [Claude Code CLI](https://code.claude.com/docs/en/setup) separately, then use `cc-account add work` and `cc-account login work`.

```sh
cc-account --help
cc-auto --help
cc-account doctor
cc-auto check --watch -n 0.1
```

Upgrade while preserving local profiles:

```sh
brew update
brew upgrade cuongnguyengit/tap/cc-auto
cc-auto-setup
```

Setup changes only your user integrations and never runs automatically during brew install. Reopen terminals and start new VS Code conversations after setup. Signing into Claude requires your own account. Keychain prompts may need your approval; real-account switching on macOS still needs live validation. See the [CLI guide](https://github.com/cuongnguyengit/cc-auto-apt/blob/main/docs/cli.md).

Binary archives are downloaded from the public distribution repository and verified with SHA-256. This tap does not require access to the private source repository.
