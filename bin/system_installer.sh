#!/bin/zsh

set -euo pipefail

FORMULAE=(
  git
  gradle
  maven
  maven-shell
  jenv
  nvm
  kind
  hashicorp/tap/terraform
  tflint
  zsh
  zsh-completions
  qpdf
  uv
  awscli
  jq
  curl
  aiven-client
  doctl
  heroku/brew/heroku
  gh
  docker-completion
  docker-compose
  docker-machine
  mkcert
  lefthook
  aquasecurity/trivy/trivy
  tfsec
  semgrep
)

CASKS=(
  github
  whatsapp
  iterm2
  dbeaver-community
  google-chrome
  postman
  evernote
  intellij-idea
  zoom
  wireshark
  temurin@17
  temurin@21
  temurin@25
  anaconda
  microsoft-edge
  microsoft-teams
  visual-studio-code
  chatgpt-atlas
  codex-app
  redis-insight
)

REMOVED_FORMULAE=(
  node
)

REMOVED_CASKS=(
  apache-directory-studio
  codex
  corretto@17
  corretto@21
  dash
  visual-studio-code@insiders
)

GLOBAL_NPM_PACKAGES=(
  @github/copilot
  @openai/codex
)

MANUAL_CASKS=(
  docker
  teamviewer
)

print_help() {
  cat <<'EOF'
Usage: bin/system_installer.sh [flag ...]

Flags:
  --formula    Install or upgrade the configured Homebrew formulae.
  --casks      Install or upgrade the configured Homebrew casks.
  --info       Show the planned installs, upgrades, and removals with version info.
  --uninstall  Remove everything marked for removal.
  --all        Run formulae, casks, uninstall, post-install steps, and global npm package updates.
  --help       Show this help message.
  --post       Run only the post-install scripts.

Notes:
  - If no flag is provided, the script prints this help message.
  - You can combine: --formula, --casks, and --uninstall.
  - --all, --info, and --post are standalone modes.
  - Post-install scripts and NVM-backed global npm package updates run automatically after any install action.
EOF
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    if ! command -v gcc >/dev/null 2>&1; then
      echo "Installing XCode command-line tools before installing Homebrew ..."
      xcode-select --install
    fi

    echo "Installing Homebrew - package manager for mac"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Homebrew installation complete."
  fi
}

prepare_homebrew() {
  brew update
  brew tap hashicorp/tap
  brew tap aquasecurity/trivy
}

finalize_homebrew() {
  brew cleanup
}

upgrade_formula() {
  local formula="$1"

  if ! brew list --versions "$formula" >/dev/null 2>&1; then
    echo "Installing formula: $formula"
    brew install "$formula"
  else
    echo "Upgrading formula: $formula"
    brew upgrade "$formula"
  fi
}

upgrade_cask() {
  local cask="$1"

  if ! brew list --cask --versions "$cask" >/dev/null 2>&1; then
    echo "Installing cask: $cask"
    brew install --cask "$cask"
  else
    echo "Upgrading cask: $cask"
    brew upgrade --cask "$cask"
  fi
}

remove_formula() {
  local formula="$1"

  if brew list --versions "$formula" >/dev/null 2>&1; then
    echo "Removing formula: $formula"
    brew uninstall "$formula"
  else
    echo "Formula $formula not installed and can't be removed"
  fi
}

remove_cask() {
  local cask="$1"

  if brew list --cask --versions "$cask" >/dev/null 2>&1; then
    echo "Removing cask: $cask"
    brew uninstall --cask "$cask"
  else
    echo "Cask $cask not installed and can't be removed"
  fi
}

upgrade_npm_package() {
  local package="$1"

  if ! npm list -g --depth=0 "$package" >/dev/null 2>&1; then
    echo "Installing global npm package: $package"
    npm install -g "$package"
  else
    echo "Upgrading global npm package: $package"
    npm update -g "$package"
  fi
}

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"

  if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    . "/opt/homebrew/opt/nvm/nvm.sh"

    if [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
      . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    fi

    return 0
  fi

  echo "nvm.sh not found after Homebrew installation"
  return 1
}

run_post_install() {
  echo "> Post-install steps for managing non-brew installations"

  local zsh_root="${ZSH:-$HOME/.dotfiles}"
  local -a post_install_files

  setopt local_options null_glob
  post_install_files=("$zsh_root"/post-install/*.sh)

  for file in "${post_install_files[@]}"
  do
    "$file"
  done
}

manage_global_npm_packages() {
  if load_nvm && nvm use default >/dev/null 2>&1; then
    echo "> Managing global npm packages"
    for package in "${GLOBAL_NPM_PACKAGES[@]}"
    do
      upgrade_npm_package "$package"
    done
  else
    echo "Skipping global npm package management because the NVM default Node runtime is not active."
  fi
}

formula_current_version() {
  local formula="$1"
  local installed

  installed="$(brew list --versions "$formula" 2>/dev/null || true)"
  if [ -n "$installed" ]; then
    echo "${installed#${formula} }"
  fi
}

formula_target_version() {
  local formula="$1"
  local line

  line="$(brew info "$formula" 2>/dev/null | sed -n '1p' || true)"
  if [[ "$line" == *"stable "* ]]; then
    echo "$line" | sed -E 's/.*stable ([^ ,]+).*/\1/'
  else
    echo "unknown"
  fi
}

cask_current_version() {
  local cask="$1"
  local installed

  installed="$(brew list --cask --versions "$cask" 2>/dev/null || true)"
  if [ -n "$installed" ]; then
    echo "${installed#${cask} }"
  fi
}

cask_target_version() {
  local cask="$1"
  local line

  line="$(brew info --cask "$cask" 2>/dev/null | sed -n '1p' || true)"
  if [ -n "$line" ]; then
    echo "${line#*: }"
  else
    echo "unknown"
  fi
}

print_install_info() {
  local kind="$1"
  local name="$2"
  local current="$3"
  local target="$4"
  local action="install"

  if [ -n "$current" ]; then
    action="upgrade"
  fi

  printf "%-8s %-12s %-30s %s -> %s\n" "$action" "$kind" "$name" "${current:-not installed}" "$target"
}

print_remove_info() {
  local kind="$1"
  local name="$2"
  local current="$3"

  printf "%-8s %-12s %-30s %s\n" "remove" "$kind" "$name" "${current:-not installed}"
}

show_info() {
  echo "Planned installs and upgrades"
  echo

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed, so current and target versions are unavailable."
    echo
  fi

  echo "Formulae:"
  for formula in "${FORMULAE[@]}"
  do
    local current=""
    local target="unknown"

    if command -v brew >/dev/null 2>&1; then
      current="$(formula_current_version "$formula")"
      target="$(formula_target_version "$formula")"
    fi

    print_install_info "formula" "$formula" "$current" "$target"
  done

  echo
  echo "Casks:"
  for cask in "${CASKS[@]}"
  do
    local current=""
    local target="unknown"

    if command -v brew >/dev/null 2>&1; then
      current="$(cask_current_version "$cask")"
      target="$(cask_target_version "$cask")"
    fi

    print_install_info "cask" "$cask" "$current" "$target"
  done

  echo
  echo "Marked for removal:"
  for formula in "${REMOVED_FORMULAE[@]}"
  do
    local current=""

    if command -v brew >/dev/null 2>&1; then
      current="$(formula_current_version "$formula")"
    fi

    print_remove_info "formula" "$formula" "$current"
  done

  for cask in "${REMOVED_CASKS[@]}"
  do
    local current=""

    if command -v brew >/dev/null 2>&1; then
      current="$(cask_current_version "$cask")"
    fi

    print_remove_info "cask" "$cask" "$current"
  done

  echo
  echo "Managed manually for now:"
  for cask in "${MANUAL_CASKS[@]}"
  do
    printf "%-8s %-12s %-30s %s\n" "manual" "cask" "$cask" "Homebrew cask currently skipped"
  done

  echo
  echo "Post-install follow-ups after any install action:"
  echo "  - Run all scripts in \$HOME/.dotfiles/post-install"
  echo "  - Load NVM and update global npm packages: ${GLOBAL_NPM_PACKAGES[*]}"
}

run_formulae() {
  for formula in "${FORMULAE[@]}"
  do
    upgrade_formula "$formula"
  done
}

run_casks() {
  for cask in "${CASKS[@]}"
  do
    upgrade_cask "$cask"
  done
}

run_uninstall() {
  for formula in "${REMOVED_FORMULAE[@]}"
  do
    remove_formula "$formula"
  done

  for cask in "${REMOVED_CASKS[@]}"
  do
    remove_cask "$cask"
  done
}

run_install_followups() {
  run_post_install
  manage_global_npm_packages
}

main() {
  local run_formula_flag=false
  local run_cask_flag=false
  local run_uninstall_flag=false
  local run_post_flag=false
  local run_info_flag=false
  local saw_all_flag=false
  local arg

  if [ "$#" -eq 0 ]; then
    print_help
    exit 0
  fi

  for arg in "$@"
  do
    case "$arg" in
      --formula)
        run_formula_flag=true
        ;;
      --casks)
        run_cask_flag=true
        ;;
      --uninstall)
        run_uninstall_flag=true
        ;;
      --post)
        run_post_flag=true
        ;;
      --info)
        run_info_flag=true
        ;;
      --all)
        saw_all_flag=true
        run_formula_flag=true
        run_cask_flag=true
        run_uninstall_flag=true
        ;;
      --help)
        print_help
        exit 0
        ;;
      *)
        echo "Unknown flag: $arg" >&2
        echo >&2
        print_help
        exit 1
        ;;
    esac
  done

  if [ "$saw_all_flag" = true ] && [ "$#" -gt 1 ]; then
    echo "--all cannot be combined with other flags." >&2
    exit 1
  fi

  if [ "$run_info_flag" = true ] && [ "$#" -gt 1 ]; then
    echo "--info cannot be combined with other flags." >&2
    exit 1
  fi

  if [ "$run_post_flag" = true ] && [ "$#" -gt 1 ]; then
    echo "--post cannot be combined with other flags." >&2
    exit 1
  fi

  if [ "$run_info_flag" = true ]; then
    show_info
    exit 0
  fi

  if [ "$run_post_flag" = true ]; then
    run_post_install
    exit 0
  fi

  ensure_homebrew
  prepare_homebrew

  if [ "$run_formula_flag" = true ]; then
    run_formulae
  fi

  if [ "$run_cask_flag" = true ]; then
    run_casks
  fi

  if [ "$run_uninstall_flag" = true ]; then
    run_uninstall
  fi

  finalize_homebrew

  if [ "$run_formula_flag" = true ] || [ "$run_cask_flag" = true ]; then
    run_install_followups
  fi
}

main "$@"
