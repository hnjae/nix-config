local M = {}

M.apply = function(opts, wezterm)
  opts.window_padding = {
    left = "0.25cell",
    right = "0.25cell",
    top = 0,
    bottom = 0,
  }
  -- make window size to a multiple of the terminal cell size (true)
  -- only works on X11/Wayland/macOS
  opts.use_resize_increments = false
  opts.window_frame = {
    font = require("fonts").get_font(wezterm),
    font_size = 11,
  }
  opts.use_fancy_tab_bar = true
  opts.hide_tab_bar_if_only_one_tab = true
end

return M
