-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices


-- For example, changing the color scheme:
config.color_scheme = 'iceberg-dark'


local iceberg = wezterm.color.get_builtin_schemes()['iceberg-dark']
-- selection_bg is used as the conversion text, so make it different from conposition text for visibility
iceberg.selection_bg = 'gray'

config.color_schemes = {
    ['My Iceberg'] = iceberg,
}
config.color_scheme = 'My Iceberg'

config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"

config.use_ime = true

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Hiragino Kaku Gothic Pro" })

config.font_size = 13

-- and finally, return the configuration to wezterm
return config
