local file_path = require 'wgc-nvim-utils'.file_path
local utils = require 'wgc-nvim-utils'.utils
local runner = require 'wgc.run'

local branch_group = vim.api.nvim_create_augroup('WgcGitBranch', {
  clear = true,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = branch_group,
  callback = require('wgc.git_branch').update_current_branch,
})

local function create_run_command(info)
  local map = utils.make_mapper({ buffer = info.buf, silent = true })
  map('n', '<leader>rr', ':WgcRun<cr>')
  local file = file_path:new(info.file)
  local extension = file:extension()
  if extension == 'lua' then
    vim.api.nvim_buf_create_user_command(info.buf, 'WgcRun', function()
      runner.run_love_project(file)
    end,
      {})
  elseif extension == 'rs' then
    vim.api.nvim_buf_create_user_command(info.buf, 'WgcRun', function()
      runner.run_rust_project(file)
    end,
      {})
  end
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = runner.run_group,
  pattern = { '*.lua', '*.rs' },
  callback = create_run_command
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('WgcYankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
  group = highlight_group,
  pattern = '*',
})
