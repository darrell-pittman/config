local file_path = require 'wgc-nvim-utils'.file_path
local utils = require 'wgc-nvim-utils'.utils
local api = vim.api

vim.cmd('highlight link WgcRunHeader Title')
vim.cmd('highlight link WgcRunSubHeader Function')

local M = {}

M.run_group = vim.api.nvim_create_augroup("WgcRun", {
  clear = true,
})

local constants = utils.table.protect{
  WINDOW_TITLE = "WgcRun",
  WINDOW_WIDTH = 65,
}

local disp = nil

local function open_window(callback)
  if disp then
    if api.nvim_win_is_valid(disp.win) then
      api.nvim_win_close(disp.win, true)
    end
    disp = nil
  end
  disp = {}
  vim.cmd(('%svnew'):format(constants.WINDOW_WIDTH))
  disp.buf = api.nvim_get_current_buf()
  disp.win = api.nvim_get_current_win()

  vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted'..
  ' nolist noswapfile nowrap nospell nonumber norelativenumber'..
  ' nofoldenable signcolumn=no')

  local map = utils.make_mapper({
    buffer=disp.buf,
    silent=true,
    nowait=true,
  })
  map('n','q',':bwipeout<cr>')
  map('n','<esc>',':bwipeout<cr>')

  local noops = {'a','c','d','i','x','r','o','p',}
  for _,l in ipairs(noops) do
    map('n',l,'')
    map('n', string.upper(l),'')
  end

  api.nvim_buf_set_name(disp.buf, '[WgcRun]')
  api.nvim_buf_set_lines(disp.buf, 0, -1, false, {
    utils.string.center(constants.WINDOW_TITLE, constants.WINDOW_WIDTH),
    utils.string.center("::: press [q] or <esc> to close :::", constants.WINDOW_WIDTH),
    string.rep('━', constants.WINDOW_WIDTH),
    "",
  })
  api.nvim_buf_add_highlight(disp.buf,-1, 'WgcRunHeader', 0, 0, -1)
  api.nvim_buf_add_highlight(disp.buf,-1, 'WgcRunSubHeader', 1, 0, -1)
  callback()
end

local function default_runner(header, footer, cmd, buffered)
  local default_handler = function(_, data)
    if data then
      api.nvim_buf_set_lines(disp.buf,-1,-1,false,data)
    end
  end

  return function()
    api.nvim_buf_set_lines(disp.buf,-1,-1,false,header)
    vim.fn.jobstart(cmd, {
      on_stdout = default_handler,
      on_stderr = default_handler,
      on_exit = function()
        api.nvim_buf_set_lines(disp.buf,-1,-1,false, footer)
      end,
      stdout_buffered = buffered,
    })
  end
end

function M.run_love_project(file)
  file:search_up(file_path:new("main.lua"), vim.schedule_wrap(function(main_file)
    if main_file then
      open_window(default_runner({
        "LOVE2d output ...", ""
      }, {
        "--LOVE2d Finished!--",
      }, {
        "love",
        tostring(main_file:parent()),
      },
      false))
    else
      print("Failed to find main.lua")
    end
  end))
end

return M

