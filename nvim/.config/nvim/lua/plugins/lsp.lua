-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "williamboman/mason.nvim",
    -- Ensure Mason runs setup
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    -- Ensure Mason-lspconfig runs setup
    config = function()
      -- We'll add server configuration here later if needed
      require("mason-lspconfig").setup({
         -- You can add servers you always want installed here
         -- ensure_installed = { "lua_ls", "clangd" }
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    -- Basic LSP config setup (keymaps etc. can be added later)
    config = function ()
       -- Add LSP keymaps later if desired
       -- vim.api.nvim_create_autocmd('LspAttach', { ... })
    end
  },
}
