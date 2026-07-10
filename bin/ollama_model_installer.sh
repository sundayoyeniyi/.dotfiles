#!/bin/zsh

set -euo pipefail

PULL_MODELS=(
  qwen3-coder:30b
  deepseek-r1:14b
  gpt-oss:20b
)

REMOVE_MODELS=(
  # Add one or more model names here before running --remove.
  # Example:
  # qwen-coder:30b
)

print_help() {
  cat <<'EOF'
Usage: bin/ollama_model_installer.sh [flag]

Flags:
  --pull     Pull or update models from PULL_MODELS.
  --remove   Remove models from REMOVE_MODELS when present.
  --list     Show the configured models and whether they are installed.
  --help     Show this help message.

Notes:
  - Ollama must be installed and the local Ollama service must be running.
  - Start the service with `ollama serve` or the Ollama desktop app before running this script.
  - Pulls can take a long time because the configured models are large.
  - PULL_MODELS and REMOVE_MODELS are intentionally separate so removal can be narrower.
EOF
}

ensure_ollama() {
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Ollama is not installed." >&2
    exit 1
  fi
}

ensure_ollama_service() {
  if ! ollama list >/dev/null 2>&1; then
    echo "Ollama is installed, but the local Ollama service is not reachable." >&2
    echo "Start it with: ollama serve" >&2
    exit 1
  fi
}

model_installed() {
  local model="$1"

  ollama show "$model" >/dev/null 2>&1
}

pull_models() {
  local model

  echo "> Pulling Ollama models"
  for model in "${PULL_MODELS[@]}"
  do
    if model_installed "$model"; then
      echo "Updating Ollama model: $model"
    else
      echo "Pulling Ollama model: $model"
    fi

    ollama pull "$model"
  done
}

remove_models() {
  local model

  if (( ${#REMOVE_MODELS[@]} == 0 )); then
    echo "No Ollama models configured for removal."
    echo "Add one or more model names to REMOVE_MODELS before running --remove."
    return
  fi

  echo "> Removing Ollama models"
  for model in "${REMOVE_MODELS[@]}"
  do
    if model_installed "$model"; then
      echo "Removing Ollama model: $model"
      ollama rm "$model"
    else
      echo "Ollama model not installed, skipping: $model"
    fi
  done
}

list_models() {
  local model

  echo "Configured Ollama models for pull/update:"
  for model in "${PULL_MODELS[@]}"
  do
    if model_installed "$model"; then
      echo "  installed  $model"
    else
      echo "  missing    $model"
    fi
  done

  echo
  echo "Configured Ollama models for removal:"
  if (( ${#REMOVE_MODELS[@]} == 0 )); then
    echo "  none"
    return
  fi

  for model in "${REMOVE_MODELS[@]}"
  do
    if model_installed "$model"; then
      echo "  installed  $model"
    else
      echo "  missing    $model"
    fi
  done
}

main() {
  if [ "$#" -eq 0 ]; then
    print_help
    exit 0
  fi

  if [ "$#" -gt 1 ]; then
    echo "Only one flag can be provided." >&2
    echo >&2
    print_help
    exit 1
  fi

  case "$1" in
    --pull)
      ensure_ollama
      ensure_ollama_service
      pull_models
      ;;
    --remove)
      ensure_ollama
      ensure_ollama_service
      remove_models
      ;;
    --list)
      ensure_ollama
      ensure_ollama_service
      list_models
      ;;
    --help)
      print_help
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo >&2
      print_help
      exit 1
      ;;
  esac
}

main "$@"
