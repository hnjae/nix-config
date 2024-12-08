local M = {}

local wezterm = require("wezterm")
M.apply_to_config = function(config)
  local act = wezterm.action
  -- run wezterm show-keys [--lua]
  config.mouse_bindings = {
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      -- action = wezterm.action({ SelectTextAtMouseCursor = "Cell" }),
      action = act.CopyTo("PrimarySelection"),
    },
    {
      event = { Up = { streak = 2, button = "Left" } },
      mods = "NONE",
      action = act.CopyTo("PrimarySelection"),
      -- action = wezterm.action({ SelectTextAtMouseCursor = "Cell" }),
    },
    {
      event = { Up = { streak = 3, button = "Left" } },
      mods = "NONE",
      action = act.CopyTo("PrimarySelection"),
      -- action = wezterm.action({ SelectTextAtMouseCursor = "Cell" }),
    },
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = act.OpenLinkAtMouseCursor,
    },
  }
end

return M
