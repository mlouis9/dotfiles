-- lua/plugins/visual-multi.lua
return {
  'mg979/vim-visual-multi',
  branch = 'master',
  lazy = false, -- This is important!
  init = function()
    -- You can set global keymap overrides here if you want
    -- For example, to set 'Ctrl+n' as the main key:
    -- vim.g.VM_maps = { ['Find Under'] = '<C-n>' }
  end,
}
