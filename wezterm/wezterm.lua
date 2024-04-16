local wezterm = require 'wezterm';
local act = wezterm.action;
local config = {}

config.color_scheme = 'catppuccin-mocha'
-- config.color_scheme = 'Catppuccin Mocha'
config.window_background_opacity = 0.95
config.font = wezterm.font "Hack Nerd Font"
config.font_size = 13.0
config.colors = {
  cursor_fg = "#11111b",
}

-- Make righ toption act as altgr on mac
config.send_composed_key_when_left_alt_is_pressed = true

config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key = "LeftArrow",  mods = "SUPER", action = wezterm.action { SendString = "\x1bb" } },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = "RightArrow", mods = "SUPER", action = wezterm.action { SendString = "\x1bf" } },
  -- Split pane shortcut
  {
    key = 'd',
    mods = 'SUPER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },

  -- Pane selection
  {
    key = 'l',
    mods = 'CMD',
    action = act.PaneSelect {
      -- alphabet = 'qsdfwxcv',
    },
  },
  {
    key = 'h',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'CTRL|SHIFT',
    action = act.ActivatePaneDirection 'Down',
  },
}


return config
