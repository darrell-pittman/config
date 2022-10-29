-- Map the leader key
vim.api.nvim_set_keymap('n','<Space>', '',{})
vim.g.mapleader = ' '
vim.g.maplocalleader = "'"

local utils = require('wgc.utils')
local t = utils.t

local map = utils.make_mapper { silent = true} 
local cmd_map = utils.make_mapper()

-- Use jk for escape in insert mode 
map('i','jk','<Esc>')

-- <leader>u to uppercase word
map('n', '<leader>u', 'gUiw')

cmd_map('n', '<leader>f', ':find<space>')

-- Turn off arrow keys
map('', '<left>','')
map('', '<right>','')
map('', '<up>','')
map('', '<down>','')
map('i', '<left>','')
map('i', '<right>','')
map('i', '<up>','')
map('i', '<down>','')

-- Completion

_G.wgc_smart_tab = function ()
  if vim.fn.pumvisible() == 1 then
    return t'<C-n>'
  else
    local col = vim.fn.col('.') - 1
    local backspace = (col == 0) or (vim.fn.getline('.'):sub(col,col):match('%s'))
    if backspace then
      return t'<Tab>'
    else
      return t'<C-x><C-o>'
    end
  end
end

local completion_map = utils.make_mapper { expr =  true }
completion_map('i', '<Tab>', 'v:lua.wgc_smart_tab()')


vim.cmd[[
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
]]
