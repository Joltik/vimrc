local api = vim.api
local wo = vim.wo

require'tools'

local M = {
  mode = {
    n = {
      name = 'NORMAL',
      color = '#98c379'
    },
    i = {
      name = 'INSERT',
      color = '#61afef'
    },
    c = {
      name = 'Command',
      color = '#98c379'
    },
    v = {
      name = 'VISUAL',
      color = '#c678dd'
    },
    V = {
      name = 'V·Line',
      color = '#c678dd'
    },
    [''] = {
      name = 'VISUAL',
      color = '#c678dd'
    },
    ['\22'] = {
      name = 'V·Colum',
      color = '#c678dd'
    },
    R = {
      name = 'REPLACE',
      color = '#e06c75'
    },
    t = {
      name = 'TERMINAL',
      color = '#61afef'
    },
    s = {
      name = 'SELECT',
      color = '#e5c07b'
    },
    S = {
      name = 'S·LINE',
      color = '#e5c07b'
    }
  }
}

local buffer_is_empty = function()
  return vim.fn.empty(vim.fn.expand('%:t')) == 1
end

local function mode_name()
  local mode = vim.fn.mode()
  local mode_info = M.mode[mode]
  if mode_info == nil then return mode end
  local name = mode_info.name
  vim.api.nvim_command('hi PandaViMode guibg=' .. mode_info.color .. ' guifg=#eeeeee')
  return string.upper(name)
end

function load_pandaline(is_hl)
  local is_empty = buffer_is_empty()
  local wins = api.nvim_list_wins()
  local hl_name = 'PandaNomalStatusline'
  if #wins == 1 and is_empty then
    hl_name = 'PandaEmptyStatusline'
  end
  local bg = vim.fn.synIDattr(vim.fn.hlID(hl_name),'bg')
  local fg = vim.fn.synIDattr(vim.fn.hlID(hl_name),'fg')
  vim.api.nvim_command('hi statusline guibg='..bg..' guifg='..fg)
  local show_line = ' '
  if not is_empty then
    if vim.fn.winwidth(0) > 40 then
      show_line = '%#PandaViMode# '..[[%{luaeval('require("pandaline").mode_name()')}]]..' '..'%##'..'%#PandaFile# '..'%##'
      if not is_hl then show_line = '%#PandaFile# '..'%##' end
      local file_name = vim.fn.expand('%:t')
      local extension = file_extension(file_name)
      local icon, hl_group = require'nerd_icons'.get_icon(file_name, extension)
      if icon ~= nil then
        local icon_fg = vim.fn.synIDattr(vim.fn.hlID(hl_group),'fg')
        local icon_bg = vim.fn.synIDattr(vim.fn.hlID('PandaFile'),'bg')
        local icon_gl_group = 'PandaFileIcon'..hl_group
        vim.api.nvim_command('hi '..icon_gl_group..' guibg='..icon_bg..' guifg='..icon_fg)
        show_line = show_line..'%#'..icon_gl_group..'#'..icon..'%##'
      end
      show_line = show_line..'%#PandaFile# '..file_name..' '..'%##'..'%#PandaFile#'
    else
      show_line = '%#PandaFile#'..vim.bo.filetype..'%##'..'%#PandaFile#'
    end
    show_line = show_line..'%='..'%#PandaFile#'..' '..'%##'
  end
  wo.statusline = show_line
end

function pandaline_augroup()
  local hl_events = {'FileType','BufEnter','WinEnter','BufWinEnter','FileChangedShellPost','VimResized'}
  local nohl_events = {'WinLeave'}
  api.nvim_command('augroup pandaline')
  api.nvim_command('autocmd!')
  for _, v in ipairs(hl_events) do
    local command = string.format('autocmd %s * lua require("pandaline").load_pandaline(true)', v)
    vim.api.nvim_command(command)
  end
  for _, v in ipairs(nohl_events) do
    local command = string.format('autocmd %s * lua require("pandaline").load_pandaline(false)', v)
    vim.api.nvim_command(command)
  end
  api.nvim_command('augroup END')
end

return {
  pandaline_augroup = pandaline_augroup,
  load_pandaline = load_pandaline,
  mode_name = mode_name,
}
