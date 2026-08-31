#!/bin/zsh

set -euo pipefail

BREWFILE="${ZSH:-$HOME/.dotfiles}/Brewfile"

REMOVED_FORMULAE=(
  node
  osv-scanner
)

REMOVED_CASKS=(
  apache-directory-studio
  chatgpt-atlas
  codex-app
  corretto@17
  corretto@21
  dash
  evernote
)

GLOBAL_NPM_PACKAGES=(

)

# To remove a global npm package, move its entry from GLOBAL_NPM_PACKAGES to here.
REMOVED_NPM_PACKAGES=(
  @openai/codex
  @github/copilot
)

GLOBAL_PYTHON_PACKAGES=(
  # Format: "tool-name:requirement" where requirement is passed directly to uv tool install.
  # This supports Git sources and package extras while keeping the stable uv tool name explicit.
  # For ordinary PyPI tools without extras, use just the tool name with no colon.
  "specify-cli:git+https://github.com/github/spec-kit.git"
  "graphifyy:graphifyy[terraform,sql]"
)

# To remove a python package, move its entry from GLOBAL_PYTHON_PACKAGES to here.
# Uses the same "tool-name" or "tool-name:source" format; only the tool name matters for removal.
REMOVED_PYTHON_PACKAGES=(
)

MANUAL_CASKS=(
  docker
  microsoft-edge
  teamviewer
  visual-studio-code
  wireshark
)

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
  --formula    Install or upgrade Homebrew formulae from Brewfile.
  --casks      Install or upgrade Homebrew casks from Brewfile.
  --python     Install or upgrade the configured global python packages (GLOBAL_PYTHON_PACKAGES).
  --node       Install or upgrade the configured global node modules (GLOBAL_NPM_PACKAGES).
  --info       Show planned installs, upgrades, and removals.
  --uninstall  Remove everything marked for removal (REMOVED_FORMULAE, REMOVED_CASKS, REMOVED_PYTHON_PACKAGES, REMOVED_NPM_PACKAGES).
  --all        Run formulae, casks, uninstall, post-install steps, and global node/python package updates.
  --help       Show this help message.
  --post       Run only the post-install scripts.

Notes:
  - If no flag is provided, the script prints this help message.
  - You can combine: --formula, --casks, --python, --node, and --uninstall.
  - --all, --info, and --post are standalone modes.
  - Packages are managed via Brewfile at the repo root. Edit Brewfile to add/remove packages.
  - To mark a brew formula/cask for removal, move it into REMOVED_FORMULAE or REMOVED_CASKS in this script.
  - To remove a python package, move it from GLOBAL_PYTHON_PACKAGES to REMOVED_PYTHON_PACKAGES in this script.
  - To remove a global npm package, move it from GLOBAL_NPM_PACKAGES to REMOVED_NPM_PACKAGES in this script.
  - Post-install scripts run automatically after any install action.
  - Global npm/python package updates run only when explicitly requested via --node/--python.
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
  trust_brewfile_taps
}

# Homebrew 6.x refuses to load formulae/casks from third-party taps until the
# tap is explicitly trusted. Trust every tap declared in the Brewfile so
# `brew bundle install` can proceed without manual `brew trust`.
trust_brewfile_taps() {
  local tap
  echo "> Trusting third-party taps from Brewfile"

  while IFS= read -r tap; do
    [[ -z "$tap" ]] && continue
    brew trust --tap "$tap" >/dev/null 2>&1 || echo "  Could not trust tap: $tap"
  done < <(grep -E '^[[:space:]]*tap ' "$BREWFILE" | sed -E 's/.*tap "([^"]+)".*/\1/')
}

finalize_homebrew() {
  brew cleanup
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

remove_npm_package() {
  local package="$1"

  if npm list -g --depth=0 "$package" >/dev/null 2>&1; then
    echo "Removing global npm package: $package"
    npm uninstall -g "$package"
  else
    echo "npm package $package not installed and can't be removed"
  fi
}

remove_marked_npm_packages() {
  local package

  if (( ${#REMOVED_NPM_PACKAGES[@]} == 0 )); then
    return 0
  fi

  echo "> Removing deprecated global npm packages"
  for package in "${REMOVED_NPM_PACKAGES[@]}"
  do
    remove_npm_package "$package"
  done
}

remove_uv_package() {
  local entry="$1"
  local tool_name
  tool_name="$(uv_tool_name "$entry")"

  if ! command -v uv >/dev/null 2>&1; then
    echo "Cannot remove python package $tool_name: uv is not available"
    return
  fi

  if uv tool list 2>/dev/null | awk -v name="$tool_name" '$1 == name {found=1} END {exit !found}'; then
    echo "Removing global python package: $tool_name"
    uv tool uninstall "$tool_name"
  else
    echo "python package $tool_name not installed and can't be removed"
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

sync_nvm_default_packages() {
  local default_packages_file="${NVM_DIR:-$HOME/.nvm}/default-packages"

  printf '%s\n' "${GLOBAL_NPM_PACKAGES[@]}" > "$default_packages_file"
  echo "Synced $default_packages_file (${#GLOBAL_NPM_PACKAGES[@]} package(s) — auto-installed into every new nvm node version)"
}

manage_global_npm_packages() {
  if load_nvm && nvm use default >/dev/null 2>&1; then
    sync_nvm_default_packages
    remove_marked_npm_packages
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

  if [ -n "$source" ]; then
    echo "Installing or reconciling global python package: $tool_name"
    uv tool install --upgrade "$source"
    return
  fi

  if ! uv tool list 2>/dev/null | awk -v name="$tool_name" '$1 == name {found=1} END {exit !found}'; then
    echo "Installing global python package: $tool_name"
    uv tool install "$tool_name"
  else
    echo "Upgrading global python package: $tool_name"
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
    if [[ "$source" == git+* ]]; then
      echo "git-latest"
    else
      echo "$source"
    fi
  else
    echo "unknown"
  fi
}

manage_global_uv_packages() {
  if ! command -v uv >/dev/null 2>&1; then
    echo "Skipping global python package management because uv is not available."
    return
  fi
  echo "> Managing global python packages"
  for entry in "${GLOBAL_PYTHON_PACKAGES[@]}"
  do
    upgrade_uv_package "$entry"
  done
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

brewfile_brew_names() {
  grep -E '^[[:space:]]*brew ' "$BREWFILE" 2>/dev/null | sed -E 's/^[[:space:]]*brew "([^"]+)".*/\1/'
}

brewfile_cask_names() {
  grep -E '^[[:space:]]*cask ' "$BREWFILE" 2>/dev/null | sed -E 's/^[[:space:]]*cask "([^"]+)".*/\1/'
}

brew_formula_current_version() {
  local formula="$1"
  brew list --versions "$formula" 2>/dev/null | awk '{print $2}'
}

brew_formula_target_version() {
  local formula="$1"
  local stable revision
  if command -v jq >/dev/null 2>&1; then
    stable="$(brew info --formula "$formula" --json=v2 2>/dev/null | jq -r '.formulae[0].versions.stable' 2>/dev/null)"
    if [ -z "$stable" ]; then
      echo "unknown"
      return
    fi
    revision="$(brew info --formula "$formula" --json=v2 2>/dev/null | jq -r '.formulae[0].revision' 2>/dev/null)"
    if [ -n "$revision" ] && [ "$revision" != "0" ] && [ "$revision" != "null" ]; then
      echo "${stable}_${revision}"
    else
      echo "$stable"
    fi
  else
    echo "unknown"
  fi
}

brew_cask_current_version() {
  local cask="$1"
  # `brew list --cask --versions` does not accept a fully-qualified <tap>/<cask>
  # name, so strip any tap prefix and query by the short cask name.
  brew list --cask --versions "${cask##*/}" 2>/dev/null | awk '{print $2}'
}

brew_cask_target_version() {
  local cask="$1"
  local version
  if command -v jq >/dev/null 2>&1; then
    version="$(brew info --cask "$cask" --json=v2 2>/dev/null | jq -r '.casks[0].version' 2>/dev/null)"
    echo "${version:-unknown}"
  else
    echo "unknown"
  fi
}

print_package_status() {
  local kind="$1"
  local name="$2"
  local current="$3"
  local target="$4"
  local no_compare="${5:-false}"
  local action="current"

  if [ -z "$current" ]; then
    action="install"
  elif [ "$no_compare" = false ] && [ -n "$target" ] && [ "$target" != "unknown" ] && [ "$target" != "git-latest" ] && [ "$current" != "$target" ]; then
    action="upgrade"
  fi

  if [ "$action" = "current" ]; then
    printf "%s %-12s %-30s %s\n" "$(colorize_action "$action")" "$kind" "$name" "${current:-not installed}"
  else
    printf "%s %-12s %-30s %s -> %s\n" "$(colorize_action "$action")" "$kind" "$name" "${current:-not installed}" "$target"
  fi
}

show_info() {
  init_colors

  echo "Brewfile status:"
  if command -v brew >/dev/null 2>&1; then
    brew bundle check --file="$BREWFILE" --verbose || true
  else
    echo "  Homebrew is not installed."
  fi

  echo
  echo "Marked for removal:"
  for formula in "${REMOVED_FORMULAE[@]}"
  do
    local current=""
    if command -v brew >/dev/null 2>&1; then
      installed="$(brew list --versions "$formula" 2>/dev/null || true)"
      if [ -n "$installed" ]; then
        current="${installed#${formula} }"
      fi
    fi
    print_remove_info "formula" "$formula" "$current"
  done

  for cask in "${REMOVED_CASKS[@]}"
  do
    local current=""
    if command -v brew >/dev/null 2>&1; then
      installed="$(brew list --cask --versions "$cask" 2>/dev/null || true)"
      if [ -n "$installed" ]; then
        current="${installed#${cask} }"
      fi
    fi
    print_remove_info "cask" "$cask" "$current"
  done

  for entry in "${REMOVED_PYTHON_PACKAGES[@]}"
  do
    local current=""
    if command -v uv >/dev/null 2>&1; then
      current="$(uv_package_current_version "$entry")"
    fi
    print_remove_info "python" "$(uv_tool_name "$entry")" "$current"
  done

  if load_nvm && nvm use default >/dev/null 2>&1; then
    for package in "${REMOVED_NPM_PACKAGES[@]}"
    do
      local current=""
      current="$(npm_package_current_version "$package")"
      print_remove_info "npm" "$package" "$current"
    done
  fi

  echo
  echo "Managed manually (not in Brewfile):"
  for cask in "${MANUAL_CASKS[@]}"
  do
    printf "%s %-12s %-30s %s\n" "$(colorize_action "manual")" "cask" "$cask" "Homebrew cask currently skipped"
  done

  echo
  echo "Homebrew formulae (managed via --formula):"
  if command -v brew >/dev/null 2>&1; then
    local formula
    while IFS= read -r formula
    do
      [[ -z "$formula" ]] && continue
      print_package_status "formula" "$formula" "$(brew_formula_current_version "$formula")" "$(brew_formula_target_version "$formula")"
    done < <(brewfile_brew_names)
  else
    echo "  Homebrew is not installed."
  fi

  echo
  echo "Homebrew casks (managed via --casks):"
  if command -v brew >/dev/null 2>&1; then
    local cask
    while IFS= read -r cask
    do
      [[ -z "$cask" ]] && continue
      print_package_status "cask" "$cask" "$(brew_cask_current_version "$cask")" "$(brew_cask_target_version "$cask")"
    done < <(brewfile_cask_names)
  else
    echo "  Homebrew is not installed."
  fi

  echo
  echo "Global node modules (managed via --node):"
  if load_nvm && nvm use default >/dev/null 2>&1; then
    for package in "${GLOBAL_NPM_PACKAGES[@]}"
    do
      local current=""
      local target="unknown"
      if command -v npm >/dev/null 2>&1; then
        current="$(npm_package_current_version "$package")"
        target="$(npm_package_target_version "$package")"
      fi
      print_package_status "npm" "$package" "$current" "$target"
    done
  else
    echo "  Skipping node module preview because the NVM default Node runtime is not active."
  fi

  echo
  echo "Global python packages (managed via --python):"
  if command -v uv >/dev/null 2>&1; then
    for entry in "${GLOBAL_PYTHON_PACKAGES[@]}"
    do
      local current=""
      local target="unknown"
      local no_compare="false"
      current="$(uv_package_current_version "$entry")"
      target="$(uv_package_target_version "$entry")"
      if [ -n "$(uv_tool_source "$entry")" ]; then
        no_compare="true"
      fi
      print_package_status "python" "$(uv_tool_name "$entry")" "$current" "$target" "$no_compare"
    done
  else
    echo "  Skipping python package preview because uv is not available."
  fi

  echo
  echo "Post-install follow-ups after any install action:"
  echo "  - Run all scripts in \$HOME/.dotfiles/post-install"
  echo "  - Global node modules (--node): ${GLOBAL_NPM_PACKAGES[*]}"
  echo "  - Global python packages (--python): ${GLOBAL_PYTHON_PACKAGES[*]}"
}

run_formulae() {
  # Homebrew 6.x `bundle install` dropped --no-cask/--no-formula, so filter the
  # Brewfile (formulae + taps only) and install from a filtered stream.
  grep -vE '^[[:space:]]*cask ' "$BREWFILE" | brew bundle install --file=-
}

run_casks() {
  grep -E '^[[:space:]]*cask ' "$BREWFILE" | brew bundle install --file=-
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

  for entry in "${REMOVED_PYTHON_PACKAGES[@]}"
  do
    remove_uv_package "$entry"
  done

  if (( ${#REMOVED_NPM_PACKAGES[@]} > 0 )); then
    if load_nvm && nvm use default >/dev/null 2>&1; then
      remove_marked_npm_packages
      sync_nvm_default_packages
    else
      echo "Skipping npm package removal because the NVM default Node runtime is not active."
    fi
  fi
}

run_install_followups() {
  local run_node="$1"
  local run_python="$2"

  run_post_install

  # Global node/python packages are managed only when explicitly requested
  # via --node / --python (or --all, which enables both).
  if [ "$run_node" = true ]; then
    manage_global_npm_packages
  fi
  if [ "$run_python" = true ]; then
    manage_global_uv_packages
  fi
}

main() {
  local run_formula_flag=false
  local run_cask_flag=false
  local run_python_flag=false
  local run_node_flag=false
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
      --python)
        run_python_flag=true
        ;;
      --node)
        run_node_flag=true
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
        run_python_flag=true
        run_node_flag=true
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

  # --node/--python alone do not need Homebrew; handle them before the Homebrew setup.
  if [ "$run_formula_flag" = false ] && [ "$run_cask_flag" = false ] && [ "$run_uninstall_flag" = false ]; then
    if [ "$run_node_flag" = true ]; then
      manage_global_npm_packages
    fi
    if [ "$run_python_flag" = true ]; then
      manage_global_uv_packages
    fi
    if [ "$run_node_flag" = true ] || [ "$run_python_flag" = true ]; then
      exit 0
    fi
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

  if [ "$run_formula_flag" = true ] || [ "$run_cask_flag" = true ] || [ "$run_uninstall_flag" = true ]; then
    run_install_followups "$run_node_flag" "$run_python_flag"
  fi
}

main "$@"
