# Runtime Operator Runbook

This runbook is the operator checklist for keeping the local machine aligned to the supported runtime baseline:

- Java: Eclipse Temurin `21` as default, with Temurin `17` and `25` also installed
- Node: `24` through `nvm`
- Desktop app: `codex-app`
- Global Node CLIs: installed against the NVM default runtime
- `docker` is currently treated as a manual app because the active Homebrew cask is failing validation
- `teamviewer` is currently treated as a manual app because the active Homebrew cask is failing validation

## 1. Preflight

- [ ] Move to the dotfiles repo.

```bash
cd /Users/sundayoyeniyi/projects/dotfiles
```

- [ ] Review the installer modes and planned changes.

```bash
bin/system_installer.sh --help
bin/system_installer.sh --info
```

- [ ] Confirm you are happy with the planned installs, upgrades, and removals.

## 2. Apply The Runtime Toolchain

- [ ] Run the full installer.

```bash
bin/system_installer.sh --all
```

- [ ] If you want a staged execution instead, run the install/uninstall actions directly.

```bash
bin/system_installer.sh --formula --casks --uninstall
```

- [ ] Open a fresh shell after the installer finishes.

## 3. Verify Java

- [ ] Confirm Java resolves through `jenv`.

```bash
java -version
jenv versions
jenv version
/usr/libexec/java_home -V
```

- [ ] Confirm the active default is Temurin `21`.
- [ ] Confirm Temurin `17`, `21`, and `25` are available.
- [ ] Confirm Corretto is no longer the active default and no stale Corretto `jenv` entries remain.

## 4. Verify Node

- [ ] Confirm Node resolves through `nvm`.

```bash
node -v
npm -v
which node
which npm
nvm current
nvm alias default
nvm ls
```

- [ ] Confirm `node -v` reports `v24.x`.
- [ ] Confirm `which node` points to `~/.nvm/...`, not `/opt/homebrew/bin/node`.
- [ ] Confirm the default NVM alias is `24`.

## 5. Verify Global CLIs

- [ ] Confirm the expected global Node CLIs are available on the NVM default runtime.

```bash
npm list -g --depth=0
copilot --version
codex --version
```

- [ ] Confirm `@github/copilot` and `@openai/codex` are installed globally.
- [ ] Confirm `codex-app` remains installed for desktop usage.
- [ ] If you use Docker Desktop, confirm it still launches and self-updates outside Homebrew.
- [ ] If you use TeamViewer, confirm it still launches and self-updates outside Homebrew.

## 6. Follow-Up Operations

- [ ] Use post-install only if you need to rerun local setup scripts without reinstalling Brew packages.

```bash
bin/system_installer.sh --post
```

- [ ] Use `--info` before future upgrades so you can review version drift safely.

```bash
bin/system_installer.sh --info
```

## 7. Done Criteria

- [ ] Temurin `21` is the default Java runtime.
- [ ] Temurin `17` and `25` are available for secondary checks.
- [ ] `nvm` is the active Node selector.
- [ ] Node `24` is the default Node runtime.
- [ ] Brew-managed `node` is no longer the active runtime path.
- [ ] Global Copilot and Codex CLIs work under the NVM-managed default Node.
- [ ] `codex-app` remains installed for desktop usage.
