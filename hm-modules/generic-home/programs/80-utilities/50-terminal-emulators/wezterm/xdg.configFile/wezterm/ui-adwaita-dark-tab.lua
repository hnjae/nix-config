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
    -- libadwaita color
    active_titlebar_bg = "#303030",
    active_titlebar_fg = "#ffffff",
    inactive_titlebar_bg = "#242424",
    inactive_titlebar_fg = "#919191",
    font = require("fonts").get_font(wezterm),
    font_size = 11,
    -- active_titlebar_bg = "#111111",
  }
  opts.colors = {
    tab_bar = {
      -- bg_color 212d3c
      background = "#303030",
      active_tab = {
        -- bg_color = "#212d3c",
        -- bg_color = "#1c71d8",
        bg_color = "#555555",
        fg_color = "#ffffff",
      },
      inactive_tab = {
        bg_color = "#303030",
        fg_color = "#ffffff",
      },
      inactive_tab_hover = {
        bg_color = "#3f3f3f",
        fg_color = "#ffffff",
        -- italic = false,
      },
      new_tab = {
        bg_color = "#303030",
        fg_color = "#ffffff",
      },
      new_tab_hover = {
        bg_color = "#3f3f3f",
        fg_color = "#ffffff",
      },
    },
  }
  opts.use_fancy_tab_bar = false
  opts.hide_tab_bar_if_only_one_tab = true

  -- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
  -- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
  -- tab_bar_style = {
  --   active_tab_left = wezterm.format {
  --     { Background = { Color = '#0b0022' } },
  --     { Foreground = { Color = '#2b2042' } },
  --     { Text = SOLID_LEFT_ARROW },
  --   },
  --   active_tab_right = wezterm.format {
  --     { Background = { Color = '#0b0022' } },
  --     { Foreground = { Color = '#2b2042' } },
  --     { Text = SOLID_RIGHT_ARROW },
  --   },
  --   inactive_tab_left = wezterm.format {
  --     { Background = { Color = '#0b0022' } },
  --     { Foreground = { Color = '#1b1032' } },
  --     { Text = SOLID_LEFT_ARROW },
  --   },
  --   inactive_tab_right = wezterm.format {
  --     { Background = { Color = '#0b0022' } },
  --     { Foreground = { Color = '#1b1032' } },
  --     { Text = SOLID_RIGHT_ARROW },
  --   },
  -- },
end

return M
