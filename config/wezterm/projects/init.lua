local trade_alpha = require("projects.trade_alpha")

local projects = {
  {
    id = trade_alpha.workspace_name,
    label = trade_alpha.display_name,
    activate = trade_alpha.activate,
  },
}

local M = {}

function M.entries()
  return projects
end

function M.activate(id, window, pane)
  for _, project in ipairs(projects) do
    if project.id == id then
      project.activate(window, pane)
      return
    end
  end
end

return M
