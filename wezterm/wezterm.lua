local wezterm = require 'wezterm';

return {
  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="SUPER", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="SUPER", action=wezterm.action{SendString="\x1bf"}},
  }
}
