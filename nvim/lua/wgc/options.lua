local utils = require('wgc.utils')

utils.options.set({
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  hidden = true,
  background = 'dark',
  termguicolors = false,
  syntax = 'on',
  directory = utils.home()..'/backups/vim/swapfiles//',
  backupdir = utils.home()..'/backups/vim/backup_files//',
  undofile = false,
  colorcolumn = '80',
  completeopt = 'longest,menuone',--,noinsert,noselect',
  hlsearch = false,
  listchars = { tab = '>-', lead = '.', trail = '.' },
  autoindent = true,
  smartindent = true,
  signcolumn = 'yes',
  wrap = false,
  number = true,
  relativenumber = true,
  numberwidth = 3,
})

utils.options.append({
  path = {'.','**'},
  wildignore = {'**/debug/**', '**/release/**','**/.git/**'},
})
