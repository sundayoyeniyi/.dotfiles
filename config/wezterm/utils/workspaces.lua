local wezterm = require("wezterm")

local M = {}

function M.exists(name)
  for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
    if workspace == name then
      return true
    end
  end

  return false
end

function M.activate(name)
  wezterm.mux.set_active_workspace(name)
end

return M
