local M = {}

local utils = require('wgc.utils')
local file_path = require('wgc.file_path')
local cache, cache_constants = require('wgc.cache')()
local buf_git_dir_cache = cache:new()

local constants = utils.table.protect {
  GIT_DIR = file_path:new(".git"),
  HEAD = file_path:new("HEAD"),
  BRANCH_REGEX = "^.*/([^/\n]+)[%s\n]*$"
}

local current_branch
local current_git_dir
local file_watch = vim.loop.new_fs_event()

local function find_git_dir(file)
  local path = file_path:new(file)
  return path:search_up(constants.GIT_DIR)
end

local function parse_branch(HEAD)
  file_watch:stop()
  if HEAD:is_file() then
    HEAD:read_async(function(data)
      local branch = data:match(constants.BRANCH_REGEX) or data:sub(1,6)
      if branch then
        file_watch:start(HEAD.path, {}, vim.schedule_wrap(function()
          parse_branch(HEAD)
        end))
        current_branch = branch
      end
    end)
  end
end

local function update_current_branch(info)
  if not info or utils.string.is_empty(info.file) then return end
  local git_dir = buf_git_dir_cache:get(info.buf, function()
    return find_git_dir(info.file) or cache_constants.NO_VALUE
  end)
  if git_dir then
    if current_git_dir ~= git_dir then
      current_git_dir = git_dir
      local HEAD = git_dir..constants.HEAD
      parse_branch(HEAD)
    end
  else
    current_branch = nil
    current_git_dir = nil
  end
end

local group = vim.api.nvim_create_augroup("WgcGitBranch", {
  clear = true,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = update_current_branch,
})

M.git_branch = function(bufno)
  return current_branch
end

return M
