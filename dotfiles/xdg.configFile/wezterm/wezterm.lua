local wezterm = require("wezterm")

local config = wezterm.config_builder()

require("colorscheme").apply_to_config(config)
require("fonts").apply_to_config(config)
require("mouse-bindings").apply_to_config(config)
require("ui").apply_to_config(config)

-- require("disable-tab").apply_to_config(config)

config.webgpu_power_preference = "LowPower"

config.launch_menu = {
  {
    label = "Bottom",
    args = { "btm" },
  },
  {
    label = "Yazi",
    args = { "yazi" },
  },
}

config.use_ime = true
config.audible_bell = "Disabled"

return config
