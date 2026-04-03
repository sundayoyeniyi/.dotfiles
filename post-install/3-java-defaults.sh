#! /bin/zsh

set -euo pipefail

echo "> java installations"

export PATH="$HOME/.jenv/bin:$PATH"
jenv_root="$HOME/.jenv"

if ! command -v jenv >/dev/null 2>&1; then
  echo "jenv not found"
  exit 1
fi

temurin_homes=(
  /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
  /Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home
  /Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home
)

for java_home in "${temurin_homes[@]}"
do
  if [ -d "$java_home" ]; then
    jenv add "$java_home"
  fi
done

remove_stale_jenv_links() {
  local version_name="$1"
  local version_link="$jenv_root/versions/$version_name"

  if [ -L "$version_link" ]; then
    local target
    target="$(readlink "$version_link")"

    if [[ "$target" == *amazon-corretto* ]] || [ ! -e "$target" ]; then
      rm -f "$version_link"
    fi
  fi
}

ensure_temurin_aliases() {
  local full_version="$1"
  local java_home="$2"
  local major="${full_version%%.*}"
  local minor="${full_version%.*}"

  ln -sfn "$java_home" "$jenv_root/versions/$major"
  ln -sfn "$java_home" "$jenv_root/versions/$minor"
}

if command -v rg >/dev/null 2>&1; then
  corretto_versions=($(jenv versions --bare | rg '^corretto64-' || true))
else
  corretto_versions=($(jenv versions --bare | grep '^corretto64-' || true))
fi

for version in "${corretto_versions[@]}"
do
  if [ -n "$version" ]; then
    jenv remove "$version"
  fi
done

remove_stale_jenv_links 17
remove_stale_jenv_links 17.0
remove_stale_jenv_links 17.0.17
remove_stale_jenv_links 21
remove_stale_jenv_links 21.0
remove_stale_jenv_links 21.0.9

ensure_temurin_aliases 17.0.18 /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
ensure_temurin_aliases 21.0.10 /Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home
ensure_temurin_aliases 25.0.2 /Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home

jenv refresh-versions
jenv_global_version=""

while IFS= read -r version_name
do
  case "$version_name" in
    temurin64-21.*)
      jenv_global_version="$version_name"
      break
      ;;
    21.*)
      if [ -z "$jenv_global_version" ]; then
        jenv_global_version="$version_name"
      fi
      ;;
  esac
done <<EOF
$(jenv versions --bare)
EOF

if [ -z "$jenv_global_version" ]; then
  echo "Unable to find an installed Temurin 21 runtime in jenv"
  exit 1
fi

jenv global "$jenv_global_version"
jenv rehash
