local utils = {}

utils.home = (function()
  local home = vim.env.HOME
  return function()
    return home
  end
end)()

utils.t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

utils.make_mapper = function(key)
  local options = { noremap = true }

  if key then
    for i,v in pairs(key) do
      if type(i) == 'string' then options[i] = v end
    end
  end

  local buffer = options.buffer
  options.buffer = nil

  if buffer then
    return function(bufnr, mode, lhs, rhs)
      vim.api.nvim_buf_set_keymap(
      bufnr,
      mode,
      lhs,
      rhs,
      options
      )
    end
  else
    return function(mode, lhs, rhs)
      vim.api.nvim_set_keymap(
      mode,
      lhs,
      rhs,
      options
      )
    end
  end
end

local set_options = function(setter)
  return function(opts)
    for k,v in pairs(opts) do
      setter(k, v)
    end
  end
end

local option_setters = {
  set = function(k,v)
    vim.opt[k] = v
  end,
  append = function(k,v)
    vim.opt[k] = vim.opt[k] + v
  end,
  prepend = function(k,v)
    vim.opt[k] = vim.opt[k] ^ v
  end,
  remove = function (k,v)
    vim.opt[k] = vim.opt[k] - v
  end,
}

utils.options = {
  set = set_options(option_setters.set),
  append = set_options(option_setters.append),
  prepend = set_options(option_setters.prepend),
  remove = set_options(option_setters.remove),
}

return utils


