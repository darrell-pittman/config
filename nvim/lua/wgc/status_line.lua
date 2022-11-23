local utils = require('wgc-nvim-utils').utils
local git_branch = require('wgc.git_branch').git_branch

local M = {}

local mode_symbols = {
  ['i'] = ' ',
  ['n'] = ' ',
  ['c'] = ' ',
  ['v'] = ' ',
  ['V'] = ' ',
  [utils.t('<C-V>')] = '濾',
  ['r'] = ' ',
  ['nt'] = ' ',
  ['t'] = ' ',
}

local function get_mode()
  return mode_symbols[vim.api.nvim_get_mode().mode] or ' '
end

M.status_line = function()
  local filename = vim.api.nvim_buf_get_name(0)
  local branch = git_branch()

  return table.concat({
    ' ',
    get_mode(),
    branch and string.format('   %s', branch) or '',
    '   %-f',
    utils.string.is_empty(filename) and '' or '  %-y %-m %-r ',
    '%=',
    '  %l, %c  %p%% ',
    '  %n ',
  })
end

return M

