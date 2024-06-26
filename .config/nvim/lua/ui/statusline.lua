return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'cbochs/grapple.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local color = require 'ui.color.config'
      color.statusline.set_highlight_groups()

      local lualine = require('ui.navigation.config').lualine
      local fmt = lualine.fmt
      local grapple = lualine.unpack_grapple_statusline

      require('lualine').setup {
        options = {
          globalstatus = true,
          component_separators = { left = '', right = '' },
          section_separators = { left = ' ', right = ' ' },
          theme = color.lualine.theme,
        },
        sections = {
          lualine_a = { {
            'mode',
            fmt = fmt,
          } },
          lualine_b = { grapple { scope = 'git' } }, -- I don't know how to do this better
          lualine_c = {},
          lualine_x = {},
          lualine_y = { 'diff', 'branch' },
          lualine_z = {}, -- probably unused because of aesthetics
        },
      }
    end,
  },
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lualine/lualine.nvim',
    },
    config = function()
      local color = require('ui.color.config').incline

      require('incline').setup {
        window = {
          placement = {
            vertical = 'top',
            horizontal = 'right',
          },
          padding = 0, -- is only horizontal
          margin = { vertical = 2, horizontal = 0 },
        },
        hide = {
          cursorline = true,
        },
        render = function(props)
          local diagnostics = color.get_diagnostic_label(props)
          local dyn_space = (props.focused and #diagnostics > 0) and '' or ' '
          local diagnostics_indicator = #diagnostics > 0 and '  ' or ''
          diagnostics = props.focused and diagnostics or ''
          diagnostics = {
            diagnostics_indicator,
            diagnostics,
            group = 'StatusLineC',
          }
          local is_modified = vim.api.nvim_get_option_value('modified', { buf = props.buf })
          local dyn_asterisk = is_modified and '*' or ''
          local dyn_italic = is_modified and 'I' or ''

          local bufname = vim.api.nvim_buf_get_name(props.buf)
          local filename = vim.fn.fnamemodify(bufname, ':t')
          filename = filename == '' and '[No Name]' or filename
          filename = string.format('%s  %s%s  ', dyn_space, filename, dyn_asterisk)

          local buffer_group = props.focused and 'StatusLineB' or 'StatusLineA'
          buffer_group = string.format('%s%s', buffer_group, dyn_italic)

          local buffer = { filename, group = buffer_group }

          local row, col = unpack(vim.api.nvim_win_get_cursor(props.win))
          local pos = string.format('%s:%s', col, row)
          local position = { string.format(' %4s', pos), group = 'StatusLineA' }

          local grapple = require('ui.navigation.config').incline
          grapple = grapple.buf_info(props.buf)
          grapple = {
            grapple,
            group = 'StatusLineG',
          }

          return { diagnostics, buffer, position, grapple }
        end,
      }
    end,
  },
}
