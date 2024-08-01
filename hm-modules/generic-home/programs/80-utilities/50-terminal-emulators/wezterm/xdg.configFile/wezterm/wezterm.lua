-- https://wezfurlong.org/wezterm/config/lua/config/use_ime.html

-- local act = wezterm.action
local wezterm = require("wezterm")

local opts = wezterm.config_builder()

opts.term = "wezterm" -- default xterm-256color

-- default_prog = {
--   "/usr/bin/env",
--   "bash",
-- },

opts.use_ime = true

require("colorscheme").apply(opts)
require("fonts").apply(opts, wezterm)
require("mouse-bindings").apply(opts, wezterm)
require("ui").apply(opts, wezterm)
require("gpu").apply(opts, wezterm)

local is_hm, hm = pcall(require, "hm-declared")
if is_hm then
  hm.apply(opts, wezterm)
end

return opts
