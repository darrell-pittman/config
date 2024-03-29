local utils = require('wgc-nvim-utils').utils

utils.options.set({
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  hidden = true,
  background = 'dark',
  termguicolors = false,
  syntax = 'on',
  directory = utils.constants.HOME .. '/backups/vim/swapfiles//',
  backupdir = utils.constants.HOME .. '/backups/vim/backup_files//',
  undofile = false,
  colorcolumn = '80',
  completeopt = 'menuone,noselect',
  hlsearch = false,
  listchars = { tab = '>-', trail = '.' },
  list = true,
  autoindent = true,
  smartindent = true,
  signcolumn = 'number',
  wrap = true,
  number = true,
  relativenumber = true,
  numberwidth = 2,
  laststatus = 3,
  statusline = "%!v:lua.require('wgc.status_line').status_line()",
  showmode = false,
  ignorecase = true,
  smartcase = true,
})

utils.options.append({
  path = { '.', '**' },
  wildignore = { '**/debug/**', '**/release/**', '**/.git/**' },
})
