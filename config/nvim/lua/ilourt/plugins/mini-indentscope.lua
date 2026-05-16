return {
  'echasnovski/mini.indentscope',
  version = '*',
  opts = function()
    local indentscope = require('mini.indentscope')
    return {
      draw = {
        animation = indentscope.gen_animation.none()
      }
    }
  end,
}
