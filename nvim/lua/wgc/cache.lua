local utils = require('wgc.utils')

local M = {}
M.__index = M

local constants = utils.table.protect {
  NO_VALUE = "__WGC_NO_VALUE__"
}

local function verify_key(key)
  if utils.string.is_empty(key) then
    error("Key is required")
  end
end

function M:new()
  return setmetatable({}, self)
end

function M:get(key, miss_callback)
  verify_key(key)
  local val = self[key]
  if val then
    if val ~= constants.NO_VALUE then
      return val
    end
  else
    if miss_callback then
      val = miss_callback()
      self[key] = val
      if val ~= constants.NO_VALUE then
        return val
      end
    end
  end
end

function M:remove(key)
  verify_key(key)
  local val = self[key]
  self[key] = nil
  return val
end

return function()
  return M, constants
end
