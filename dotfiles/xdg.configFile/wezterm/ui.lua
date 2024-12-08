local M = {}
local wezterm = require("wezterm")

M.apply_to_config = function(config)
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true
  config.tab_bar_at_bottom = true

  config.window_padding = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
    -- left = "0.25cell",
    -- right = "0.25cell",
    -- top = "0.25cell",
    -- bottom = "0.25cell",
  }

  -- make window size to a multiple of the terminal cell size (true)
  -- only works on X11/Wayland/macOS
  -- opts.use_resize_increments = false
  -- opts.window_frame = {
  --   font = require("fonts").get_font(wezterm),
  --   font_size = 11,
  -- }
  -- opts.hide_tab_bar_if_only_one_tab = true
end

return M
