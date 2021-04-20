require'utils'

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
      name = 'COMMAND',
      color = '#98c379'
    },
    v = {
      name = 'VISUAL',
      color = '#c678dd'
    },
    V = {
      name = 'V-LINE',
      color = '#c678dd'
    },
    ['\22'] = {
      name = 'V-BLOCK',
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
      name = 'S-LINE',
      color = '#e5c07b'
    },
    [''] = {
      name = 'S-BLOCK',
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
  local mode_fg = vim.fn.synIDattr(vim.fn.hlID('PandaLineViMode'),'fg')
  vim.api.nvim_command('hi PandaLineViMode guibg=' .. mode_info.color .. ' guifg='..mode_fg)
  return name
end

function VIMode()
  local mode = '%#PandaLineViMode# '..[[%{luaeval('require("panda.pandaline").mode_name()')}]]..' %##'
  return mode
end

function FileSpace()
  local space = '%#PandaLineFile# '..'%##'
  return space
end

function FileName()
  local file_name = vim.fn.expand('%:t')
  local extension = file_extension(file_name)
  local icon, hl_group = require'utils.icons'.get_icon(file_name, extension)
  local show_name = FileSpace()..'%#PandaLineFile#'..file_name..'%m'..'%##'..FileSpace()
  if icon ~= nil then
    local icon_fg = vim.fn.synIDattr(vim.fn.hlID(hl_group),'fg')
    local icon_bg = vim.fn.synIDattr(vim.fn.hlID('PandaLineFile'),'bg')
    local icon_hl_group = 'PandaFileIcon'..hl_group
    vim.api.nvim_command('hi '..icon_hl_group..' guibg='..icon_bg..' guifg='..icon_fg)
    return FileSpace()..'%#'..icon_hl_group..'#'..icon..'%##'..show_name
  end
  return show_name
end

function FileType()
  local fileType = vim.bo.filetype:gsub("^%l", string.upper)
  local file_type = FileSpace()..'%#PandaLineFile#'..fileType..'%##'..FileSpace()
  return file_type
end

function GitSpace()
  local space = '%#PandaLineGit# '..'%##'
  return space
end

function GitBranch()
  local cwd = vim.loop.cwd()
  local git_branch = vim.fn.systemlist('cd "'..cwd..'" && git symbolic-ref --short -q HEAD')
  local branch_name = git_branch[1]
  if string.find(branch_name,'.git') == nil then
    local icon, hl_group = require'utils.icons'.get_icon('git', '')
    local icon_fg = vim.fn.synIDattr(vim.fn.hlID(hl_group),'fg')
    local icon_bg = vim.fn.synIDattr(vim.fn.hlID('PandaLineGit'),'bg')
    local icon_hl_group = 'PandaFileIcon'..hl_group
    vim.api.nvim_command('hi '..icon_hl_group..' guibg='..icon_bg..' guifg='..icon_fg)
    local show_name = GitSpace()..'%#PandaLineGit#'..branch_name..'%##'..GitSpace()
    return GitSpace()..'%#'..icon_hl_group..'#'..icon..'%##'..show_name
  else
    return ''
  end
end

function Fill()
  return '%#PandaLineFill#'
end

function RightSplit()
  return '%='
end

function LinePercent(is_hl)
  local hl_group = 'PandaLineDim'
  local sep_group = 'PandaLinePercentSeparatorDim'
  if is_hl then
    hl_group = 'PandaLinePercent'
    sep_group = 'PandaLinePercentSeparator'
  end
  local sep_fg = vim.fn.synIDattr(vim.fn.hlID(hl_group),'bg')
  local sep_bg = vim.fn.synIDattr(vim.fn.hlID('PandaLineFill'),'bg')
  vim.api.nvim_command('hi '..sep_group..' guibg='..sep_bg..' guifg='..sep_fg)
  return '%#'..sep_group..'#'..''..'%##'..'%#'..hl_group..'#'..' %p%% '..'%##'
end

function load_pandaline(is_hl)
  local is_empty = buffer_is_empty()
  if is_empty then
    vim.wo.statusline = ' '
    return
  end
  if vim.fn.winwidth(0) <= 40 then
    vim.wo.statusline = FileType()..Fill()..RightSplit()..LinePercent(is_hl)
    return
  end
  if not is_hl then
    vim.wo.statusline = FileName()..Fill()..RightSplit()..LinePercent(is_hl)
    return
  end
  vim.wo.statusline = VIMode()..FileName()..Fill()..RightSplit()..GitBranch()..LinePercent(is_hl)
end

function load_one_tabline(tab,is_hl)
  local win_nr = vim.fn.tabpagewinnr(tab.tabnr)
  local buf = vim.api.nvim_win_get_buf(tab.windows[win_nr])
  local paths = split(vim.fn.bufname(buf), '/')
  local file_name = paths[#paths]
  local group = 'PandaTabLineNomal'
  if is_hl then group = 'PandaTabLineSelected' end
  return '%#'..group..'#  '..file_name..'  %##'
end

function load_tabline()
  local tabline = ''
  local tabs = vim.fn.gettabinfo()
  local current_tab = vim.fn.tabpagenr()
  for i, tab in ipairs(tabs) do
    local name = load_one_tabline(tab, current_tab == tab.tabnr)
    tabline = tabline..name
  end
  if require'panda.pandatree'.is_exist_tab_pandatree() then
    tabline = '%#PandaTabLineExplorer#'..require'panda.pandatree'.tree_root_name()..' '..'%##'..tabline
  end
  vim.o.tabline = tabline..'%#PandaTabLineFill#'
end

function pandaline_augroup()
  local hl_events = {'BufEnter','WinEnter','BufDelete','FileChangedShellPost','VimResized'}
  local nohl_events = {'WinLeave','BufWinLeave'}
  local tab_events = {'WinEnter','BufEnter','BufDelete','TabEnter','BufWinLeave','TabLeave'}
  vim.api.nvim_command('augroup pandaline')
  vim.api.nvim_command('autocmd!')
  for _, v in ipairs(hl_events) do
    local command = string.format('autocmd %s * lua require("panda.pandaline").load_pandaline(true)', v)
    vim.api.nvim_command(command)
  end
  for _, v in ipairs(nohl_events) do
    local command = string.format('autocmd %s * lua require("panda.pandaline").load_pandaline(false)', v)
    vim.api.nvim_command(command)
  end
  for _, v in ipairs(tab_events) do
    local command = string.format('autocmd %s * lua require("panda.pandaline").load_tabline()', v)
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('augroup END')
end

return {
  pandaline_augroup = pandaline_augroup,
  load_pandaline = load_pandaline,
  load_tabline = load_tabline,
  mode_name = mode_name,
}