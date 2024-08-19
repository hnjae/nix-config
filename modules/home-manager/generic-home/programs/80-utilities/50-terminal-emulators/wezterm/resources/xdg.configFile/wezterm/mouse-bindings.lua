local M = {}

M.apply = function(opts, wezterm)
  local act = wezterm.action
  -- run wezterm show-keys [--lua]
  opts.mouse_bindings = {
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
