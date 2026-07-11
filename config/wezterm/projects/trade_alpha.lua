local wezterm = require("wezterm")
local mux = wezterm.mux
local commands = require("utils.commands")
local workspaces = require("utils.workspaces")

local M = {
  workspace_name = "trade-alpha",
  display_name = "TradeAlpha",

  project_root = wezterm.home_dir .. "/projects/trade-alpha",
  frontend_dir = wezterm.home_dir .. "/projects/trade-alpha/frontend",
  backend_dir = wezterm.home_dir .. "/projects/trade-alpha",

  frontend_command = "npm run dev",
  backend_command = "./gradlew :platform:monolith:bootRun -PskipFrontendBuild=true",
  opencode_command = "opencode --model ollama/qwen3-coder:30b",
}

local function create_workspace()
  local tab, ollama_pane, window = mux.spawn_window({
    workspace = M.workspace_name,
    cwd = M.project_root,
    args = commands.zsh(commands.ollama_serve()),
  })
  tab:set_title(M.display_name)

  local opencode_pane = ollama_pane:split({
    direction = "Bottom",
    size = 0.42,
    cwd = M.project_root,
    args = commands.zsh(commands.wrap(M.opencode_command)),
  })

  local frontend_pane = ollama_pane:split({
    direction = "Right",
    size = 0.67,
    cwd = M.frontend_dir,
    args = commands.zsh(commands.wrap(M.frontend_command)),
  })

  frontend_pane:split({
    direction = "Right",
    size = 0.5,
    cwd = M.backend_dir,
    args = commands.zsh(commands.wrap(M.backend_command)),
  })

  local shell_tab = window:spawn_tab({
    cwd = M.project_root,
  })
  shell_tab:set_title("Shell")

  tab:activate()
  mux.set_active_workspace(M.workspace_name)

  local gui_window = window:gui_window()
  if gui_window then
    gui_window:maximize()
  end

  return opencode_pane
end

function M.activate(_, _)
  if workspaces.exists(M.workspace_name) then
    workspaces.activate(M.workspace_name)
    return
  end

  create_workspace()
end

return M
