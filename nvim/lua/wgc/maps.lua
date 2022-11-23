--Map the leader key
vim.api.nvim_set_keymap('n', '<Space>', '', {})
vim.g.mapleader = ' '
vim.g.maplocalleader = "'"

local utils = require('wgc-nvim-utils').utils
local t = utils.t

local map = utils.make_mapper { silent = true }
local cmd_prompt_map = utils.make_mapper { nowait = true }

map('i', 'jk', '<Esc>') --use jk for escape in insert mode
map('t', 'jk', '<C-\\><C-N>') --use jk for escape in terminal mode

map = utils.make_mapper { silent = true, nowait = true }

--Leader Mappings
map('n', '<leader>u', 'gUiw') --uppercase word
map('n', '<leader>x', '<cmd>Lex 20<CR>') --Open Left Explorer
cmd_prompt_map('n', '<leader>f', ':find<space>') --Start find in command window
map('n', '<leader>p', '"0p') --Paste last thing not deleted
map('n', '<leader>P', '"0P') --       "
map('n', '<leader>w', '<cmd>up<CR>') --Write only if buffer changed
map('n', '<leader>m', '<C-W>_<C-W>|') --Maximize current window
cmd_prompt_map('n', '<leader><leader>x', ':source %<CR>')

--Misc
cmd_prompt_map('', ';', ':') --Switch : and ;
map('', ':', ';') --           "
map('n', 'q;', 'q:') --        "

--Turn off arrow keys
map('', '<left>', '')
map('', '<right>', '')
map('', '<up>', '')
map('', '<down>', '')
map('i', '<left>', '')
map('i', '<right>', '')
map('i', '<up>', '')
map('i', '<down>', '')

--Windows

--Navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

--Resizing
map('n', '<C-Up>', '<cmd>resize +2<CR>')
map('n', '<C-Down>', '<cmd>resize -2<CR>')
map('n', '<C-Right>', '<cmd>vertical resize +2<CR>')
map('n', '<C-Left>', '<cmd>vertical resize -2<CR>')

vim.cmd [[
map <F4> <cmd>execute 'vimgrep /' . expand('<cword>') . '/j **' <Bar> cw<CR>
]]
