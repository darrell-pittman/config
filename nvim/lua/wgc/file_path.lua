utils = require('wgc.utils')

local constants = utils.table.protect {
  SEP = "/",
  TYPE = "__WGC__FP__",
  DIR_TYPE = "directory",
  FILE_TYPE = "file",
}

local M = {[constants.TYPE] = constants.TYPE}
M.__index = M

local regexes = utils.table.protect {
  FILE_NAME = ("[^%s]+"):format(constants.SEP),
  PARENT = ("^(%s?.+)%s.*$"):format(constants.SEP, constants.SEP),
  ROOT = ("^(%s?)[^%s]+$"):format(constants.SEP, constants.SEP),
  TRIM = "^%s*(.*)%s*$",
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
    error("Args must be file_paths.")
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
  path = path:match(regexes.TRIM)

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

function M:exists()
  return vim.loop.fs_stat(self.path) and true
end

function M:is_directory()
  local stat = vim.loop.fs_stat(self.path)
  return stat and stat.type == constants.DIR_TYPE
end

function M:is_file()
  local stat = vim.loop.fs_stat(self.path)
  return stat and stat.type == constants.FILE_TYPE
end

function M:search_dir(dirname)
  local path = self
  if verify(dirname) and not dirname:is_absolute() then
    if path:is_file() then
      path = path:parent()
    end
    repeat
      local dir = path..dirname
      if dir:is_directory() then
        return dir
      end
      path = path:parent()
    until not path
  end
end

function M:read()
  if self:is_file() then
    local f = io.open(self.path)
    local data = f:read()
    f.close()
    return data
  end
end

return M


