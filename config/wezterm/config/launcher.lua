local wezterm = require("wezterm")
local projects = require("projects")

local M = {}

local event_name = "project-workspace-launcher"

function M.action()
  return wezterm.action.EmitEvent(event_name)
end

function M.register(_)
  wezterm.on(event_name, function(window, pane)
    local choices = {}

    for _, project in ipairs(projects.entries()) do
      table.insert(choices, {
        id = project.id,
        label = project.label,
      })
    end

    window:perform_action(
      wezterm.action.InputSelector({
        title = "Select workspace",
        choices = choices,
        fuzzy = true,
        action = wezterm.action_callback(function(selected_window, selected_pane, id)
          if id then
            projects.activate(id, selected_window, selected_pane)
          end
        end),
      }),
      pane
    )
  end)
end

return M
