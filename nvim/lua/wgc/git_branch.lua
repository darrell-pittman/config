local M = {}

local utils = require('wgc.utils')

local constants = utils.table.protect({
  git_update_freq = 2000,
  git_branch_regex = '^%*%s+([%g]+).*$',
})

local branch = nil

local run_git_job = function()
  vim.fn.jobstart({"git","branch"}, {
    stdout_buffered = true,
    on_stdout = function(_,data)
      for _,line in ipairs(data) do
        branch = string.match(line, constants.git_branch_regex)
        if branch then
          break
        end
      end
    end,
  })
end

run_git_job()

local timer = vim.loop.new_timer()

timer:start(
  constants.git_update_freq, 
  constants.git_update_freq, 
  vim.schedule_wrap(run_git_job)
)

local group =vim.api.nvim_create_augroup("WgcKillGitBranchTimer", {
  clear = true,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = 'Kills Git Branch Timer',
  group = group,
  callback = function()
    timer:stop()
    timer:close()
    return true
  end
})

M.git_branch = function()
  return branch
end

return M
