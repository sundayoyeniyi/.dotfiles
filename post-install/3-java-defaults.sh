#! /bin/zsh

set -euo pipefail

echo "> java installations"

export PATH="$HOME/.jenv/bin:$PATH"

if ! command -v jenv >/dev/null 2>&1; then
  echo "jenv not found"
  exit 1
fi

jenv enable-plugin export

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

jenv global 21
jenv rehash
