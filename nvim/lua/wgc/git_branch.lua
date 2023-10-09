local M = {}

local utils = require('wgc-nvim-utils').utils
local file_path = require('wgc-nvim-utils').file_path
local cache, cache_constants = require('wgc-nvim-utils').cache()
local buf_git_dir_cache = cache:new()

local constants = utils.table.protect {
  GIT_DIR = file_path:new('.git'),
  HEAD = file_path:new('HEAD'),
  BRANCH_REGEX = '^.*/([^/\n]+)[%s\n]*$',
  SUBMODULE_REGEX = '^gitdir:%s+([^\n]+)[%s\n]*$',
  NOT_SET = '__WGC_NOT_SET__'
}

local current_branch = constants.NOT_SET
local current_git_dir
local file_watch = vim.loop.new_fs_event()

local function set_branch(branch)
  if branch ~= current_branch then
    current_branch = branch
    vim.schedule(function()
      vim.opt.statusline = vim.opt.statusline:get()
    end)
  end
end

local function clear()
  current_git_dir = nil
  set_branch(nil)
end

local function find_git_dir(file, callback)
  local path = file_path:new(file)
  path:search_up(constants.GIT_DIR, function(git_dir)
    if git_dir then
      git_dir:is_directory(
        function()
          callback(git_dir)
        end,
        function()
          -- '.git' is a file. This happens with submodules
          git_dir:read(function(data)
            local path = data:match(constants.SUBMODULE_REGEX)
            if path then
              path = file_path:new(path)
              if not path:is_absolute() then
                path = git_dir:parent() .. path
              end
              callback(path)
            else
              clear()
            end
          end)
        end)
    else
      callback()
    end
  end)
end

local function parse_branch(HEAD)
  file_watch:stop()
  HEAD:is_file(function()
    HEAD:read(function(data)
      local branch = data:match(constants.BRANCH_REGEX) or data:sub(1, 6)
      if branch then
        file_watch:start(tostring(HEAD), {}, function()
          parse_branch(HEAD)
        end)
        set_branch(branch)
      end
    end)
  end)
end

local function handle_git_dir(git_dir)
  if git_dir == cache_constants.NO_VALUE then
    clear()
  else
    if current_git_dir ~= git_dir then
      current_git_dir = git_dir
      git_dir:is_directory(
        function()
          local HEAD = git_dir .. constants.HEAD
          parse_branch(HEAD)
        end,
        clear)
    end
  end
end

M.update_current_branch = function(info)
  if not info or utils.string.is_empty(info.file) then return end

  local git_dir = buf_git_dir_cache:get(info.buf)
  if git_dir then
    handle_git_dir(git_dir)
  else
    find_git_dir(info.file, function(found)
      found = found or cache_constants.NO_VALUE
      buf_git_dir_cache:set(info.buf, found)
      handle_git_dir(found)
    end)
  end
end

M.git_branch = function(bufno)
  if current_branch == constants.NOT_SET then
    current_branch = nil
    bufno = bufno or 0
    vim.schedule(function()
      local file = vim.api.nvim_buf_get_name(bufno)
      M.update_current_branch { buf = bufno, file = file }
    end)
  end

  return current_branch
end

return M
