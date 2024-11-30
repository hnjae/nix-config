local wezterm = require("wezterm")

local opts = wezterm.config_builder()

-- opts.term = "wezterm" -- default xterm-256color

require("colorscheme").apply(opts)
require("fonts").apply(opts, wezterm)
require("mouse-bindings").apply(opts, wezterm)
-- require("ui").apply(opts, wezterm)
-- -- require("gpu").apply(opts, wezterm)
opts.webgpu_power_preference = "LowPower"

-- local tabline =
--   wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
-- tabline.setup({
--   options = {
--     color_overrides = {
--       normal_mode = {
--         -- a = { fg = "#4d699b", bg = "#c7d7e0" },
--         a = { bg = "#4d699b", fg = "#d5cea3" },
--         b = { bg = "#d7e3d8", fg = "#4d699b" },
--         c = { bg = "#e7dba0", fg = "#545464" },
--       },
--       copy_mode = {
--         a = { bg = "#624c83", fg = "#f2ecbc" },
--         b = { bg = "#f2ecbc", fg = "#624c83" },
--         c = { bg = "#e7dba0", fg = "#545464" },
--       },
--       search_mode = {
--         a = { bg = "#cc6d00", fg = "#f2ecbc" },
--         b = { bg = "#f2ecbc", fg = "#cc6d00" },
--         c = { bg = "#e7dba0", fg = "#545464" },
--       },
--     },
--     section_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--     component_separators = {
--       left = wezterm.nerdfonts.pl_left_soft_divider,
--       right = wezterm.nerdfonts.pl_right_soft_divider,
--     },
--     tab_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--   },
--   sections = {
--     tabline_a = { "mode" },
--     tabline_b = { "workspace" },
--     tabline_c = { "" },
--     tab_active = {
--       "index",
--       { [1] = "parent", padding = 0 },
--       "/",
--       { [1] = "cwd", padding = { left = 0, right = 1 } },
--       { [1] = "zoomed", padding = 0 },
--     },
--     tab_inactive = {
--       "index",
--       { [1] = "process", padding = { left = 0, right = 1 } },
--     },
--     tabline_x = { "ram", "cpu" },
--     -- tabline_y = { "datetime", "battery" },
--     tabline_z = { "hostname" },
--   },
-- })
-- tabline.apply_to_config(opts)

return opts
