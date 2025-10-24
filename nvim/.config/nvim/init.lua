-- ~/.config/nvim/init.lua (Minimal - Copilot Only)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.opt.number = true

-- Create the plugins directory if it doesn't exist
vim.fn.system({"mkdir", "-p", vim.fn.stdpath("config") .. "/lua/plugins"})

-- Load plugins from lua/plugins/
require("lazy").setup("plugins")
