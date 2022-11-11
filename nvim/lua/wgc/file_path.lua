utils = require('wgc.utils')

local constants = utils.table.protect {
  SEP = "/",
  TYPE = "__WGC__FP__",
  DIR_TYPE = "directory",
  FILE_TYPE = "file",
}

local M = {[constants.TYPE] = constants.TYPE}

M.__index = M

M.__eq = function(fp1, fp2)
  return fp1.path == fp2.path
end

local regexes = utils.table.protect {
  FILE_NAME = ("[^%s]+"):format(constants.SEP),
  PARENT = ("^(%s?.+)%s.*$"):format(constants.SEP, constants.SEP),
  ROOT = ("^(%s?)[^%s]+$"):format(constants.SEP, constants.SEP),
  TRIM_SEP = ("^(.+)%s$"):format(constants.SEP),
}

local function verify(...)
  local verified = ... and true
  for _,fp in ipairs{...} do
    verified = verified and fp[constants.TYPE] == constants.TYPE
  end
  return verified
end

local function concat(fp1, fp2)
  if verify(fp1, fp2) then
    if fp2:is_absolute() then
      error("fp2 must be relative")
    end
    return M:new(fp1.path..constants.SEP..fp2.path)
  else
    error("Error: file_path can only concat another file_path")
  end
end

M.__tostring = function(fp)
  return fp.path
end

M.__add = concat

M.__concat = concat

function M:new(path)
  local path_type = type(path)

  if path_type == "table" then
    if verify(path) then
      path = path.path
    else
      error("Invalid path")
    end
  elseif path_type ~= "string" then
      error("Invalid path")
  end

  --trim whitespace
  path = utils.string.trim(path)

  --trim trailing /
  path = path:match(regexes.TRIM_SEP) or path

  return setmetatable({path = path},self)
end

function M:parent()
  local new_path = self.path:match(regexes.PARENT)
  new_path = new_path or self.path:match(regexes.ROOT)
  return new_path and #new_path > 0 and M:new(new_path) or nil
end

function M:is_absolute()
  return self.path:sub(1,1) == constants.SEP
end

function M:exists(success, failure)
  vim.loop.fs_stat(self.path, function(err, stat)
    local ok = not err and stat
    if ok then
      success(stat)
    else
      failure(err)
    end
  end)
end

function M:is_directory(success, failure)
  self:exists(function(stat)
    if stat.type == constants.DIR_TYPE then
      success()
    else
      failure()
    end
  end,
  failure)
end

function M:is_file(success, failure)
  self:exists(function(stat)
    if stat.type == constants.FILE_TYPE then
      success()
    else
      failure()
    end
  end,
  failure)
end

function M:search_up(name, callback)
  self:exists(function()
    local needle = self..name
    needle:exists(function()
      callback(needle)
    end,
    function()
      local path = self:parent()
      if path then
        path:search_up(name, callback)
      else
        callback()
      end
    end)
  end,
  function(err)
    error(err)
  end)
end

function M:read(callback)
  vim.loop.fs_open(self.path, "r", 438, function(err, fd)
    assert(not err, err)
    vim.loop.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      vim.loop.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        vim.loop.fs_close(fd, function(err)
          assert(not err, err)
          callback(data)
        end)
      end)
    end)
  end)
end

return M


