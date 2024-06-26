return {

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      indent = {
        -- highlight = { 'Pmenu', 'Whitespace' },
        highlight = { 'Whitespace' },
        -- tab_char = { '█', '█', '▉' },
        char = '',
      },
      whitespace = {
        highlight = { 'Pmenu', 'Whitespace' },
        remove_blankline_trail = true,
      },
      -- viewport_buffer = {
      --   min = -1,
      -- },
      -- scope = { enabled = false },
      exclude = { filetypes = { 'dashboard', 'oil', 'help' } },
    },
  },
}
