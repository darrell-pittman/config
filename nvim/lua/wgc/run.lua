local file_path = require 'wgc-nvim-utils'.file_path
local utils = require 'wgc-nvim-utils'.utils
local api = vim.api

vim.cmd('highlight link WgcRunHeader Title')
vim.cmd('highlight link WgcRunSubHeader Function')

local M = {}
local current_job_id = nil

M.run_group = vim.api.nvim_create_augroup('WgcRun', {
  clear = true,
})

local constants = utils.table.protect {
  WINDOW_TITLE = 'WgcRun',
  WINDOW_WIDTH = 65,
  HEADER_SYM = '━',
  MARGIN = 1,
}

local function pad(l)
  return utils.string.pad(l, constants.MARGIN)
end

local function center(l)
  return utils.string.center(l, constants.WINDOW_WIDTH)
end

local function tbl_pad(t)
  return vim.tbl_map(pad, t)
end

local disp = nil

local function kill_job()
  if current_job_id then
    vim.fn.jobstop(current_job_id)
    api.nvim_buf_set_lines(disp.buf, -1, -1, false, {pad(string.format("Killed Job [ id = %d ]", current_job_id))})
    current_job_id = nil
  end
end

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

  vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted' ..
    ' nolist noswapfile nowrap nospell nonumber norelativenumber' ..
    ' nofoldenable signcolumn=no')

  local map = utils.make_mapper({
    buffer = disp.buf,
    silent = true,
    nowait = true,
  })
  map('n', 'q', ':bwipeout<cr>')
  map('n', '<esc>', ':bwipeout<cr>')
  map('n', '<C-c>', kill_job)

  local noops = { 'a', 'c', 'd', 'i', 'x', 'r', 'o', 'p', }
  for _, l in ipairs(noops) do
    map('', l, '')
    map('', string.upper(l), '')
  end

  api.nvim_buf_set_name(disp.buf, '[WgcRun]')
  api.nvim_buf_set_lines(disp.buf, 0, -1, false, {
    center(constants.WINDOW_TITLE),
    center('::: press [q] or <esc> to close (<C-c> to kill job) :::'),
    pad(string.rep(constants.HEADER_SYM, constants.WINDOW_WIDTH - 2 * constants.MARGIN)),
    '',
  })
  api.nvim_buf_add_highlight(disp.buf, -1, 'WgcRunHeader', 0, constants.MARGIN, -1)
  api.nvim_buf_add_highlight(disp.buf, -1, 'WgcRunSubHeader', 1, constants.MARGIN, -1)
  callback()
end

local function default_runner(header, footer, cmd, buffered)
  local default_handler = function(_, data)
    if data then
      data = vim.tbl_filter(utils.string.is_not_empty, data)
      if #data > 0 then
        data = tbl_pad(data)
        api.nvim_buf_set_lines(disp.buf, -1, -1, false, data)
      end
    end
  end

  return function()
    kill_job()
    api.nvim_buf_set_lines(disp.buf, -1, -1, false, header)
    current_job_id = vim.fn.jobstart(cmd, {
      on_stdout = default_handler,
      on_stderr = default_handler,
      on_exit = function()
        api.nvim_buf_set_lines(disp.buf, -1, -1, false, footer)
        current_job_id = nil
      end,
      stdout_buffered = buffered,
    })
    api.nvim_buf_set_lines(disp.buf, -1, -1, false, {pad(string.format("Started Job [ id = %d ]", current_job_id))})
  end
end

function M.run_love_project(file)
  file:search_up(file_path:new('main.lua'), vim.schedule_wrap(function(main_file)
    if main_file then
      open_window(default_runner(tbl_pad({
        'LOVE2d output ...', ''
      }), tbl_pad({
        '',
        '--LOVE2d Finished!--',
      }), {
        'love',
        tostring(main_file:parent()),
      },
        false))
    else
      print('Failed to find main.lua')
    end
  end))
end

function M.run_rust_project(file)
  file:search_up(file_path:new('main.rs'), vim.schedule_wrap(function(main_file)
    if main_file then
      open_window(default_runner(tbl_pad({
        'Cargo output ...', ''
      }), tbl_pad({
        '',
        '--Cargo Finished!--',
      }), {
        'cargo',
        'run',
      },
        false))
    else
      print('Failed to find main.rs')
    end
  end))
end

return M
