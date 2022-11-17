local file_path = require('wgc-nvim-utils').file_path
local utils = require('wgc-nvim-utils').utils

local branch_group = vim.api.nvim_create_augroup("WgcGitBranch", {
  clear = true,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = branch_group,
  callback = require('wgc.git_branch').update_current_branch,
})

local function run_love_project(file)
  file:search_up(file_path:new("main.lua"), vim.schedule_wrap(function(main_file)
    if main_file then
      vim.fn.system({
        "love",
        tostring(main_file:parent())
      })
    else
      print("Failed to find main.lua")
    end
  end))
end

local function create_run_command(info)
  local file = file_path:new(info.file)
  local extension = file:extension()
  if extension == "lua" then
    vim.api.nvim_buf_create_user_command(info.buf, "WgcRun", function()
      run_love_project(file)
    end,
    {})
  end
end

local run_group = vim.api.nvim_create_augroup("WgcRun", {
  clear = true,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = run_group,
  pattern = {"*.lua","*.rs"},
  callback = create_run_command
})




