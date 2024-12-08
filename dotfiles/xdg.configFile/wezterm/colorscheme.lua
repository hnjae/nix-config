local M = {}

-- color_scheme = 'Vacuous 2 (terminal.sexy)', -- 블랙 글자가 잘 안보임
-- color_scheme = 'Classic Dark (base16)', -- Input Box안의 글자가 안보임.
-- color_scheme = "Github Dark",
-- color_scheme = "Vacuous 2 (terminal.sexy)",
-- color_scheme = "SeaShells",

-- opts.color_scheme_dirs =
--   { require("utils").get_xdg_home("data") .. "/wezterm/colors/" }
-- opts.color_scheme = "base24"

M.apply_to_config = function(config)
  config.color_scheme = "base24"
  config.bold_brightens_ansi_colors = "No"
  config.set_environment_variables = {
    COLORFGBG = "0;15",
  }

  config.colors = {
    tab_bar = {
      -- background = "transparent",
      background = "#e7dba0",
      active_tab = {
        fg_color = "#e7dba0",
        bg_color = "#545464",
      },
      inactive_tab = {
        fg_color = "#545464",
        bg_color = "#e7dba0",
      },
      new_tab = {
        fg_color = "#545464",
        bg_color = "#e7dba0",
      },
      -- new_tab_hover = {
      --   fg_color = "#e7dba0",
      --   bg_color = "#43436c",
      --   italic = true,
      -- },
    },
  }
end

return M
