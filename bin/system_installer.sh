#!/bin/zsh

set -euo pipefail

FORMULAE=(
  aiven-client
  aquasecurity/trivy/trivy
  awscli
  curl
  docker-completion
  docker-compose
  docker-machine
  doctl
  gh
  git
  gradle
  hashicorp/tap/terraform
  heroku/brew/heroku
  jenv
  jq
  kind
  lefthook
  maven
  maven-shell
  mkcert
  nvm
  qpdf
  semgrep
  tfsec
  tflint
  uv
  zsh
  zsh-completions
)

CASKS=(
  anaconda
  chatgpt-atlas
  codex-app
  dbeaver-community
  evernote
  github
  google-chrome
  intellij-idea
  iterm2
  microsoft-teams
  postman
  redis-insight
  temurin@17
  temurin@21
  temurin@25
  whatsapp
  zoom
)

REMOVED_FORMULAE=(
  node
  osv-scanner
)

REMOVED_CASKS=(
  apache-directory-studio
  codex
  corretto@17
  corretto@21
  dash
)

# To remove a uv tool, move its entry from GLOBAL_UV_PACKAGES to here.
# Uses the same "tool-name" or "tool-name:source" format; only the tool name matters for removal.
REMOVED_UV_PACKAGES=(
)

GLOBAL_NPM_PACKAGES=(
  @openai/codex
  @github/copilot
)

GLOBAL_UV_PACKAGES=(
  # Format: "tool-name:source" where source is a --from argument (git URL, etc.)
  # For PyPI packages, use just the tool name with no colon.
  # Note: source is only used on first install; upgrades always use uv tool upgrade.
  "specify-cli:git+https://github.com/github/spec-kit.git"
)

MANUAL_CASKS=(
  docker
  microsoft-edge
  teamviewer
  visual-studio-code
  visual-studio-code@insiders
  wireshark
)

typeset -a OUTDATED_FORMULAE=()
typeset -a OUTDATED_CASKS=()

COLOR_RESET=""
COLOR_BOLD=""
COLOR_DIM=""
COLOR_GREEN=""
COLOR_YELLOW=""
COLOR_RED=""
COLOR_CYAN=""

print_help() {
  cat <<'EOF'
Usage: bin/system_installer.sh [flag ...]

Flags:
  --formula    Install or upgrade the configured Homebrew formulae.
  --casks      Install or upgrade the configured Homebrew casks.
  --uv         Install or upgrade the configured global uv tools (GLOBAL_UV_PACKAGES).
  --info       Show the planned installs, upgrades, and removals with version info.
  --uninstall  Remove everything marked for removal (REMOVED_FORMULAE, REMOVED_CASKS, REMOVED_UV_PACKAGES).
  --all        Run formulae, casks, uninstall, post-install steps, and global npm/uv tool updates.
  --help       Show this help message.
  --post       Run only the post-install scripts.

Notes:
  - If no flag is provided, the script prints this help message.
  - You can combine: --formula, --casks, --uv, and --uninstall.
  - --all, --info, and --post are standalone modes.
  - To remove a uv tool, move it from GLOBAL_UV_PACKAGES to REMOVED_UV_PACKAGES in this script.
  - Post-install scripts and NVM-backed global npm/uv tool updates run automatically after any install action.
EOF
}

init_colors() {
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BOLD=$'\033[1m'
    COLOR_DIM=$'\033[2m'
    COLOR_GREEN=$'\033[32m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_RED=$'\033[31m'
    COLOR_CYAN=$'\033[36m'
  fi
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

remove_uv_package() {
  local entry="$1"
  local tool_name
  tool_name="$(uv_tool_name "$entry")"

  if ! command -v uv >/dev/null 2>&1; then
    echo "Cannot remove uv tool $tool_name: uv is not available"
    return
  fi

  if uv tool list 2>/dev/null | awk -v name="$tool_name" '$1 == name {found=1} END {exit !found}'; then
    echo "Removing global uv tool: $tool_name"
    uv tool uninstall "$tool_name"
  else
    echo "uv tool $tool_name not installed and can't be removed"
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
    zsh "$file"
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

uv_tool_name() {
  echo "${1%%:*}"
}

uv_tool_source() {
  local entry="$1"
  if [[ "$entry" == *:* ]]; then
    echo "${entry#*:}"
  fi
}

upgrade_uv_package() {
  local entry="$1"
  local tool_name source
  tool_name="$(uv_tool_name "$entry")"
  source="$(uv_tool_source "$entry")"

  if ! uv tool list 2>/dev/null | awk -v name="$tool_name" '$1 == name {found=1} END {exit !found}'; then
    echo "Installing global uv tool: $tool_name"
    if [ -n "$source" ]; then
      uv tool install "$tool_name" --from "$source"
    else
      uv tool install "$tool_name"
    fi
  else
    echo "Upgrading global uv tool: $tool_name"
    uv tool upgrade "$tool_name"
  fi
}

uv_package_current_version() {
  local entry="$1"
  local tool_name version
  tool_name="$(uv_tool_name "$entry")"
  version="$(uv tool list 2>/dev/null | awk -v name="$tool_name" '$1 == name {print $2; exit}' || true)"
  if [ -n "$version" ]; then
    echo "${version#v}"
  fi
}

uv_package_target_version() {
  local entry="$1"
  local source
  source="$(uv_tool_source "$entry")"
  if [ -n "$source" ]; then
    echo "git-latest"
  else
    echo "unknown"
  fi
}

manage_global_uv_packages() {
  if ! command -v uv >/dev/null 2>&1; then
    echo "Skipping global uv tool management because uv is not available."
    return
  fi
  echo "> Managing global uv tools"
  for entry in "${GLOBAL_UV_PACKAGES[@]}"
  do
    upgrade_uv_package "$entry"
  done
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

npm_package_current_version() {
  local package="$1"
  local installed

  installed="$(npm list -g --depth=0 "$package" 2>/dev/null | grep -E " ${package}@" | head -n 1 || true)"
  if [ -n "$installed" ]; then
    echo "${installed##*@}"
  fi
}

npm_package_target_version() {
  local package="$1"

  npm view "$package" version 2>/dev/null || echo "unknown"
}

load_outdated_indices() {
  if ! command -v brew >/dev/null 2>&1; then
    return 0
  fi

  OUTDATED_FORMULAE=("${(@f)$(brew outdated --formula --quiet 2>/dev/null || true)}")
  OUTDATED_CASKS=("${(@f)$(brew outdated --cask --quiet 2>/dev/null || true)}")
}

array_contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"
  do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done

  return 1
}

install_action() {
  local kind="$1"
  local name="$2"
  local current="$3"

  if [ -z "$current" ]; then
    echo "install"
    return 0
  fi

  if [ "$kind" = "formula" ] && array_contains "$name" "${OUTDATED_FORMULAE[@]}"; then
    echo "upgrade"
    return 0
  fi

  if [ "$kind" = "cask" ] && array_contains "$name" "${OUTDATED_CASKS[@]}"; then
    echo "upgrade"
    return 0
  fi

  echo "current"
}

colorize_action() {
  local action="$1"

  case "$action" in
    install)
      printf "%s%-8s%s" "$COLOR_GREEN" "$action" "$COLOR_RESET"
      ;;
    upgrade)
      printf "%s%-8s%s" "$COLOR_YELLOW" "$action" "$COLOR_RESET"
      ;;
    remove)
      printf "%s%-8s%s" "$COLOR_RED" "$action" "$COLOR_RESET"
      ;;
    manual)
      printf "%s%-8s%s" "$COLOR_CYAN" "$action" "$COLOR_RESET"
      ;;
    current)
      printf "%s%-8s%s" "$COLOR_DIM" "$action" "$COLOR_RESET"
      ;;
    *)
      printf "%-8s" "$action"
      ;;
  esac
}

print_install_info() {
  local kind="$1"
  local name="$2"
  local current="$3"
  local target="$4"
  local action

  action="$(install_action "$kind" "$name" "$current")"

  printf "%s %-12s %-30s %s -> %s\n" "$(colorize_action "$action")" "$kind" "$name" "${current:-not installed}" "$target"
}

print_remove_info() {
  local kind="$1"
  local name="$2"
  local current="$3"
  local action="remove"

  if [ -z "$current" ]; then
    action="absent"
  fi

  printf "%s %-12s %-30s %s\n" "$(colorize_action "$action")" "$kind" "$name" "${current:-not installed}"
}

show_info() {
  init_colors

  echo "Planned installs and upgrades"
  echo

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed, so current and target versions are unavailable."
    echo
  else
    load_outdated_indices
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

  for entry in "${REMOVED_UV_PACKAGES[@]}"
  do
    local current=""

    if command -v uv >/dev/null 2>&1; then
      current="$(uv_package_current_version "$entry")"
    fi

    print_remove_info "uv-tool" "$(uv_tool_name "$entry")" "$current"
  done

  echo
  echo "Managed manually for now:"
  for cask in "${MANUAL_CASKS[@]}"
  do
    printf "%s %-12s %-30s %s\n" "$(colorize_action "manual")" "cask" "$cask" "Homebrew cask currently skipped"
  done

  echo
  echo "Global npm packages:"
  if load_nvm && nvm use default >/dev/null 2>&1; then
    for package in "${GLOBAL_NPM_PACKAGES[@]}"
    do
      local current=""
      local target="unknown"

      if command -v npm >/dev/null 2>&1; then
        current="$(npm_package_current_version "$package")"
        target="$(npm_package_target_version "$package")"
      fi

      print_install_info "npm" "$package" "$current" "$target"
    done
  else
    echo "Skipping npm package preview because the NVM default Node runtime is not active."
  fi

  echo
  echo "Global uv tools:"
  if command -v uv >/dev/null 2>&1; then
    for entry in "${GLOBAL_UV_PACKAGES[@]}"
    do
      local current=""
      local target="unknown"
      current="$(uv_package_current_version "$entry")"
      target="$(uv_package_target_version "$entry")"
      print_install_info "uv-tool" "$(uv_tool_name "$entry")" "$current" "$target"
    done
  else
    echo "Skipping uv tool preview because uv is not available."
  fi

  echo
  echo "Post-install follow-ups after any install action:"
  echo "  - Run all scripts in \$HOME/.dotfiles/post-install"
  echo "  - Load NVM and update global npm packages: ${GLOBAL_NPM_PACKAGES[*]}"
  echo "  - Update global uv tools: ${GLOBAL_UV_PACKAGES[*]}"
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

  for entry in "${REMOVED_UV_PACKAGES[@]}"
  do
    remove_uv_package "$entry"
  done
}

run_install_followups() {
  run_post_install
  manage_global_npm_packages
  manage_global_uv_packages
}

main() {
  local run_formula_flag=false
  local run_cask_flag=false
  local run_uv_flag=false
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
      --uv)
        run_uv_flag=true
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

  # --uv alone does not need Homebrew; handle it before the Homebrew setup.
  if [ "$run_uv_flag" = true ] && [ "$run_formula_flag" = false ] && [ "$run_cask_flag" = false ] && [ "$run_uninstall_flag" = false ]; then
    manage_global_uv_packages
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

  if [ "$run_formula_flag" = true ] || [ "$run_cask_flag" = true ] || [ "$run_uv_flag" = true ]; then
    run_install_followups
  fi
}

main "$@"
