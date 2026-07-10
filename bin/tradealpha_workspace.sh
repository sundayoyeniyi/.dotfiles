#!/bin/zsh

set -euo pipefail

export WEZTERM_TRADEALPHA_WORKSPACE=1

exec wezterm start --always-new-process --workspace TradeAlpha
