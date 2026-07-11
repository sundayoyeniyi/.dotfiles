local wezterm = require("wezterm")

local M = {}

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end

  return tab_info.active_pane.title
end

function M.apply(_)
  wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
    local background = "#1a1b26"
    local foreground = "#c0caf5"

    if tab.is_active then
      background = "#7aa2f7"
      foreground = "#1a1b26"
    elseif hover then
      background = "#292e42"
    end

    local title = wezterm.truncate_right(tab_title(tab), max_width - 2)

    return {
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = " " .. title .. " " },
    }
  end)
end

return M
