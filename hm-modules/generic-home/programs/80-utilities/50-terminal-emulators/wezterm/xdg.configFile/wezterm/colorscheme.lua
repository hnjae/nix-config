local M = {}

-- color_scheme = 'Vacuous 2 (terminal.sexy)', -- 블랙 글자가 잘 안보임
-- color_scheme = 'Classic Dark (base16)', -- Input Box안의 글자가 안보임.
-- color_scheme = "Github Dark",
-- color_scheme = "Vacuous 2 (terminal.sexy)",
-- color_scheme = "SeaShells",

-- opts.color_scheme_dirs =
--   { require("utils").get_xdg_home("data") .. "/wezterm/colors/" }
-- opts.color_scheme = "base24"

M.apply = function(opts)
  opts.color_scheme = "codedark"
  opts.bold_brightens_ansi_colors = "No"
end

return M
