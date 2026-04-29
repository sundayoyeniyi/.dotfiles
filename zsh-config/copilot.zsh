#!/bin/zsh

# Points Copilot CLI to additional instruction files in the ai-playbook-kit repo.
# COPILOT_CUSTOM_INSTRUCTIONS_DIRS is the env var the CLI uses to find extra instruction files.
# See: https://docs.github.com/copilot/concepts/agents/about-copilot-cli
_COPILOT_PLAYBOOK="$HOME/projects/ai-playbook-kit"

export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/.copilot/instructions"

# Link skills and agents from ai-playbook-kit into ~/.copilot so the CLI picks them
# up without any manual copying. Symlinks are created lazily: if the source does not
# exist (e.g. the repo is not cloned on this machine) nothing happens and no error
# is printed. If the destination already exists as a real directory, a warning is
# printed so the conflict is visible rather than silently ignored.
_copilot_link() {
  local src="$1" dst="$2"

  [[ -d "$src" ]] || return 0

  if [[ -L "$dst" ]]; then
    return 0
  fi

  if [[ -e "$dst" ]]; then
    echo "copilot.zsh: $dst already exists and is not a symlink — skipping" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
}

_copilot_link "$_COPILOT_PLAYBOOK/skills" "$HOME/.copilot/skills"
_copilot_link "$_COPILOT_PLAYBOOK/agents" "$HOME/.copilot/agents"
_copilot_link "$_COPILOT_PLAYBOOK/.github/instructions" "$HOME/.copilot/instructions"

unset _COPILOT_PLAYBOOK
unfunction _copilot_link
