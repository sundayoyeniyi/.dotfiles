local wezterm = require("wezterm")
local mux = wezterm.mux
local commands = require("utils.commands")
local layout = require("config.tradalpha_layout")

local workspaces = require("utils.workspaces")

local M = {
  workspace_name = "trade-alpha",
  display_name = "TradeAlpha",

  project_root = wezterm.home_dir .. "/projects/trade-alpha",
  frontend_dir = wezterm.home_dir .. "/projects/trade-alpha/frontend",
  backend_dir = wezterm.home_dir .. "/projects/trade-alpha",

  dev_dependencies_command = "./scripts/start-dev-dependencies.sh",
  watch_backend_command = "./scripts/watch-dev-backend.sh",
  backend_command = "./scripts/start-dev-backend.sh",
  frontend_command = "./scripts/start-dev-frontend.sh",
  opencode_command = "opencode --model ollama/qwen3-coder:30b",
}

local function create_workspace()
  local tradealpha1_tab, ollama_pane, window = mux.spawn_window({
    workspace = M.workspace_name,
    cwd = M.project_root,
    args = commands.zsh(commands.ollama_serve()),
  })
  tradealpha1_tab:set_title("TradeAlpha1")

  ollama_pane:split({
    direction = "Bottom",
    size = 0.6,
    cwd = M.project_root,
      args = commands.zsh(M.opencode_command),

  })

  local tradealpha2_tab, dev_dependencies_pane = window:spawn_tab({
    cwd = M.project_root,
      args = commands.zsh(M.dev_dependencies_command),

  })
  tradealpha2_tab:set_title("TradeAlpha2")

  local watch_backend_pane = dev_dependencies_pane:split({
    direction = "Right",
    size = 0.5,
    cwd = M.project_root,
      args = commands.zsh(M.watch_backend_command),

  })

  dev_dependencies_pane:split({
    direction = "Bottom",
    size = 0.5,
    cwd = M.backend_dir,
      args = commands.zsh(M.backend_command),

  })

  watch_backend_pane:split({
    direction = "Bottom",
    size = 0.5,
    cwd = M.project_root,
      args = commands.zsh(M.frontend_command),

  })

  local shell_tab = window:spawn_tab({
    cwd = M.project_root,
  })
  shell_tab:set_title("Shell")

  tradealpha1_tab:activate()
  mux.set_active_workspace(M.workspace_name)

  local gui_window = window:gui_window()
  if gui_window then
    gui_window:maximize()
  end

  return ollama_pane
end

function M.activate(_, _)
  if workspaces.exists(M.workspace_name) then
    workspaces.activate(M.workspace_name)
    return
  end

  create_workspace()
end

return M
