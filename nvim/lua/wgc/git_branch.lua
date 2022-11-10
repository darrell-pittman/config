local M = {}

local utils = require('wgc.utils')
local file_path = require('wgc.file_path')

local constants = utils.table.protect {
  NO_VALUE = "__NO_VALUE__",
  GIT_DIR = file_path:new(".git"),
  HEAD = file_path:new("HEAD"),
}

local current_branch
local current_git_dir
local file_watch = vim.loop.new_fs_event()

local buf_git_dir_cache = {} --caches git dir for buffer

local function get_cached_value(cache, key, missing_callback)
  local val = cache[key]
  if val then
    if val ~= constants.NO_VALUE then
      return val
    end
  else
    val = missing_callback()
    cache[key] = val
    if val ~= constants.NO_VALUE then
      return val
    end
  end
end

local function find_git_dir(file)
  local path = file_path:new(file)
  return path:search_dir(constants.GIT_DIR)
end

local function parse_branch(HEAD)
  if HEAD:is_file() then
    local data = HEAD:read()
    local branch = data:match("^.*/([^/]+)$")
    if branch then
      file_watch:stop()
      file_watch:start(HEAD.path, {}, vim.schedule_wrap(function()
        parse_branch(HEAD)
      end))
      current_branch = branch
    end
  end
end

local function update_current_branch(info)
  current_branch = nil
  if not info then return end
  local git_dir = get_cached_value(buf_git_dir_cache,info.buf, function()
    return find_git_dir(info.file) or constants.NO_VALUE
  end)
  if git_dir and current_git_dir ~= git_dir then
    current_git_dir = git_dir
    local HEAD = git_dir..constants.HEAD
    parse_branch(HEAD)
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
