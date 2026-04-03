#! /bin/zsh

set -euo pipefail

current_shell="$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')"

if [[ "$current_shell" == */zsh ]]; then
  echo "ZSH is already the default shell: $current_shell"
  exit 0
fi

preferred_shells=(
  /opt/homebrew/bin/zsh
  /bin/zsh
)

for shell_path in "${preferred_shells[@]}"
do
  if [ -x "$shell_path" ] && grep -qx "$shell_path" /etc/shells; then
    echo "Making ZSH default shell: $shell_path"
    chsh -s "$shell_path"
    exit 0
  fi
done

echo "No supported zsh path was found in /etc/shells"
exit 1
