-- NOTE: ignores fontconfig  <2024-11-28>

local wezterm = require("wezterm")

local M = {}
local FONTS = {
  { family = "MesloLGM Nerd Font" },
  -- { family = "Prentendard" },
  -- { family = "Prentendard JP" },
  {
    family = "Noto Sans Mono CJK JP",
    scale = 0.95,
    weight = "Medium",
  },
  {
    family = "Noto Sans Mono CJK KR",
    scale = 0.95,
    weight = "Medium",
  },
  -- { family = "Noto Sans Mono CJK TC" },
  -- { family = "Noto Sans Mono CJK SC" },
  -- { family = "Noto Sans Mono CJK HK" },
  { family = "Noto Color Emoji" },
  -- NOTE: wezterm does not follows fontconfig's fallback font for unknown reason
  -- { family = "Monospace" },
  {
    family = "HanaMinA",
    scale = 0.95,
  },
  {
    family = "HanaMinB",
    scale = 0.95,
  },
  {
    family = "cutra_AppendingToHanaMin",
    scale = 0.95,
  },
  -- { family = "Plangothic P1" },
  -- { family = "Plangothic P2" },
}

M.get_font = function(wezterm)
  return wezterm.font_with_fallback(FONTS)
end

M.apply_to_config = function(opts)
  opts.font = M.get_font(wezterm)
  opts.font_size = 10
  opts.warn_about_missing_glyphs = true
end

return M
