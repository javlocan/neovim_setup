return {
  require 'code.lsp.rust',

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',

    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              align = 'top',
              x_padding = 3,
              y_padding = 3,
              winblend = 100,
            },
          },
        },
      },
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('luv4tj-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>h', function()
            local is_enabled = vim.lsp.inlay_hint.is_enabled(event.buf)
            vim.lsp.inlay_hint.enable(event.buf, not is_enabled)
          end, 'Toggle Inlay [H]ints')

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>a', vim.lsp.buf.code_action, 'Code [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Do[K?]umentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          --
          -- neovim nighhtly inline hints
          if client and client.server_capabilities.inlayHintProvider then
            vim.g.inlay_hints_visible = true
            -- vim.lsp.inlay_hint.enable(event.buf, true)
          else
            print "There're no inlay hints"
          end

          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
          -- vim.api.nvim_create_autocmd('CursorHold', {
          --   buffer = event.buf,
          --   callback = function()
          --     local opts = {
          --       focusable = false,
          --       close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
          --       border = 'rounded',
          --       source = 'always',
          --       prefix = ' ',
          --       scope = 'cursor',
          --     }
          --     vim.diagnostic.open_float(nil, opts)
          --   end,
          -- })
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        tsserver = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                -- disable = { 'redefined-local' },
                -- disable = { 'missing-fields' },
              },
              completion = {
                callSnippet = 'Replace',
              },
              hint = {
                enable = true,
              },
            },
          },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
