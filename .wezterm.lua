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

-- local mycolor_dark = wezterm.color.get_builtin_schemes()['rose-pine-moon']
-- local mycolor_light = wezterm.color.get_builtin_schemes()['rose-pine-dawn']
local mycolor_dark = wezterm.color.get_builtin_schemes()['iceberg-dark']
local mycolor_light = wezterm.color.get_builtin_schemes()['iceberg-light']

-- kitty key encoding to let neovim use command key
config.enable_kitty_keyboard = true
config.enable_csi_u_key_encoding = false

-- neovim integration
local wezterm_config_nvim = wezterm.plugin.require('https://github.com/winter-again/wezterm-config.nvim')
-- rest of your config
wezterm.on('user-var-changed', function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    overrides = wezterm_config_nvim.override_user_var(overrides, name, value)
    window:set_config_overrides(overrides)
end)

-- selection_bg is used as the conversion text, so make it different from conposition text for visibility
mycolor_dark.selection_bg = 'silver'
mycolor_light.selection_bg = 'gray'

config.color_schemes = {
    ['My Color Dark'] = mycolor_dark,
    ['My Color Light'] = mycolor_light,
}

-- enable scrollbar
config.enable_scroll_bar = true

-- do not show titles if linux
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
    config.window_decorations = "RESIZE"
end

-- do not show tab bar when there's only one tab
config.hide_tab_bar_if_only_one_tab = true

-- dim inactive pane
config.inactive_pane_hsb = {
    brightness = 0.3,
    saturation = 1,
}

config.color_scheme = "My Color Dark"

config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Hiragino Maru Gothic Pro" })

config.font_size = 11

config.enable_kitty_graphics = true

-- config.window_background_opacity = 0.95
-- config.text_background_opacity = 0.8


config.window_padding = {
    left = '0',
    right = '0',
    top = '0',
    bottom = '0',
}

config.scrollback_lines = 10000

config.warn_about_missing_glyphs = false

config.tab_bar_at_bottom = true

local act = wezterm.action
config.keys = {
    { key = 'Tab',       mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
    { key = 'Enter',     mods = 'ALT',        action = act.ToggleFullScreen },
    { key = '\"',        mods = 'SHIFT|CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '%',         mods = 'SHIFT|CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = ')',         mods = 'ALT',        action = act.ResetFontSize },
    { key = '+',         mods = 'ALT',        action = act.IncreaseFontSize },
    { key = '-',         mods = 'ALT',        action = act.DecreaseFontSize },
    { key = '0',         mods = 'ALT',        action = act.ResetFontSize },
    { key = '1',         mods = 'ALT',        action = act.ActivateTab(0) },
    { key = '2',         mods = 'ALT',        action = act.ActivateTab(1) },
    { key = '3',         mods = 'ALT',        action = act.ActivateTab(2) },
    { key = '4',         mods = 'ALT',        action = act.ActivateTab(3) },
    { key = '5',         mods = 'ALT',        action = act.ActivateTab(4) },
    { key = '6',         mods = 'ALT',        action = act.ActivateTab(5) },
    { key = '7',         mods = 'ALT',        action = act.ActivateTab(6) },
    { key = '8',         mods = 'ALT',        action = act.ActivateTab(7) },
    { key = '9',         mods = 'ALT',        action = act.ActivateTab(-1) },
    { key = 'UpArrow',   mods = 'SHIFT',      action = act.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'SHIFT',      action = act.ScrollToPrompt(1) },
    { key = 'Z',         mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
    { key = 'Enter',     mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
    -- { key = 't',         mods = 'ALT',        action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'h',         mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
    { key = 'l',         mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
    { key = 'k',         mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
    { key = 'j',         mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },

    { key = "UpArrow",   mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
    { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },

    { key = 'w',         mods = 'SUPER',      action = act.CloseCurrentPane { confirm = true } },
    -- Thank you https://zenn.dev/sankantsu/articles/e713d52825dbbb for the configuration below
    {
        key = 'c',
        mods = 'SUPER|SHIFT',
        action = act.PromptInputLine {
            description = "(wezterm) Create new workspace:",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace {
                            name = line,
                        },
                        pane
                    )
                end
            end),
        }
        ,
    },
    -- {
    --     key = 'k',
    --     mods = 'SUPER',
    --     action = wezterm.action_callback(function(win, pane)
    --         -- workspace のリストを作成
    --         local workspaces = {}
    --         for i, name in ipairs(wezterm.mux.get_workspace_names()) do
    --             table.insert(workspaces, {
    --                 id = name,
    --                 label = string.format("%d. %s", i, name),
    --             })
    --         end
    --         local current = wezterm.mux.get_active_workspace()
    --         -- 選択メニューを起動
    --         win:perform_action(act.InputSelector {
    --             action = wezterm.action_callback(function(_, _, id, label)
    --                 if not id and not label then
    --                     wezterm.log_info "Workspace selection canceled"               -- 入力が空ならキャンセル
    --                 else
    --                     win:perform_action(act.SwitchToWorkspace { name = id }, pane) -- workspace を移動
    --                 end
    --             end),
    --             title = "Select workspace",
    --             choices = workspaces,
    --             fuzzy = true,
    --             -- fuzzy_description = string.format("Select workspace: %s -> ", current), -- requires nightly build
    --         }, pane)
    --     end),
    -- },
    {
        key = 'r',
        mods = 'SUPER',
        action = act.PromptInputLine {
            description = 'Set workspace title:',
            action = wezterm.action_callback(function(win, pane, line)
                if line then
                    wezterm.mux.rename_workspace(
                        wezterm.mux.get_active_workspace(),
                        line
                    )
                end
            end),
        }
        ,
    }
}

return config
