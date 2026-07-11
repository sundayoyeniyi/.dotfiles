local wezterm = require("wezterm")

package.path = wezterm.config_dir .. "/?.lua;" .. wezterm.config_dir .. "/?/init.lua;" .. package.path

local config = wezterm.config_builder()

require("config.appearance").apply(config)
require("config.tabs").apply(config)
require("config.launcher").register(config)
require("config.keys").apply(config)

return config
