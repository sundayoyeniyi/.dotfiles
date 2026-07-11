local wezterm = require("wezterm")
local act = wezterm.action
local launcher = require("config.launcher")
local projects = require("projects")

local M = {}

function M.apply(config)
  config.keys = {
    {
      key = "Enter",
      mods = "CMD",
      action = act.ToggleFullScreen,
    },
    {
      key = "t",
      mods = "CMD",
      action = act.SpawnTab("CurrentPaneDomain"),
    },
    {
      key = "w",
      mods = "CMD",
      action = act.CloseCurrentTab({ confirm = true }),
    },
    {
      key = "d",
      mods = "CMD",
      action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "d",
      mods = "CMD|SHIFT",
      action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "1",
      mods = "CMD|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        projects.activate("trade-alpha", window, pane)
      end),
    },
    {
      key = "W",
      mods = "CMD|SHIFT",
      action = launcher.action(),
    },
    {
      key = "P",
      mods = "CMD|SHIFT",
      action = act.ShowLauncher,
    },
    {
      key = "LeftArrow",
      mods = "CMD|OPT",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "RightArrow",
      mods = "CMD|OPT",
      action = act.ActivatePaneDirection("Right"),
    },
    {
      key = "UpArrow",
      mods = "CMD|OPT",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "DownArrow",
      mods = "CMD|OPT",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "LeftArrow",
      mods = "CMD|SHIFT",
      action = act.AdjustPaneSize({ "Left", 5 }),
    },
    {
      key = "RightArrow",
      mods = "CMD|SHIFT",
      action = act.AdjustPaneSize({ "Right", 5 }),
    },
    {
      key = "UpArrow",
      mods = "CMD|SHIFT",
      action = act.AdjustPaneSize({ "Up", 3 }),
    },
    {
      key = "DownArrow",
      mods = "CMD|SHIFT",
      action = act.AdjustPaneSize({ "Down", 3 }),
    },
    {
      key = "[",
      mods = "CMD",
      action = act.ActivatePaneDirection("Prev"),
    },
    {
      key = "]",
      mods = "CMD",
      action = act.ActivatePaneDirection("Next"),
    },
  }
end

return M
