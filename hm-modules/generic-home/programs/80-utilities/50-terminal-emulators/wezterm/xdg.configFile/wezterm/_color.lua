local M = {}

M.apply = function(opts, wezterm)
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
  -- opts.use_fancy_tab_bar = false
  -- opts.hide_tab_bar_if_only_one_tab = true
end

return M
