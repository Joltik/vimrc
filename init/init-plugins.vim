call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'itchyny/lightline.vim'
Plug 'Yggdroot/indentLine'
Plug 'easymotion/vim-easymotion'
Plug 't9md/vim-choosewin'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Joltik/fzf-funky',{'on': 'FzfFunky'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'antoinemadec/coc-fzf'
Plug 'chiel92/vim-autoformat'
Plug 'prettier/vim-prettier', {'do': 'yarn install','for': ['javascript', 'typescript'] }
Plug 'scrooloose/nerdcommenter'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-rooter'
Plug 'voldikss/vim-floaterm'
Plug 'flazz/vim-colorschemes'
Plug 'norcalli/nvim-colorizer.lua'

call plug#end()

" lightline
let g:lightline = {
                  \ 'colorscheme': 'wombat',
                  \ 'active': {
                  \   'left': [ [ 'mode', 'paste' ],
                  \             ['git', 'readonly', 'filename', 'modified' ] ],
                  \   'right':[
                  \     [ 'filetype', 'fileencoding', 'lineinfo', 'percent' ],
                  \   ],
                  \ },
                  \ 'component_function': {
                  \   'git': 'fugitive#head',
                  \ },
                  \ }

" indentLine
let g:indentLine_fileTypeExclude = ['coc-explorer', 'startify']

" vim-easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

" coc
let g:coc_global_extensions = ['coc-explorer', 'coc-tsserver', 'coc-json', 'coc-vimlsp', 'coc-pairs', 'coc-fzf-preview']
autocmd FileType * let b:coc_pairs_disabled = ['<']
autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
      elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
      else
            execute '!' . &keywordprg . " " . expand('<cword>')
      endif
endfunction

" nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDCustomDelimiters = {
                  \ 'javascript': { 'left': '//', 'right': '', 'leftAlt': '{/*', 'rightAlt': '*/}' },
                  \}

" fzf
let fzf_float_rate = 0.6
let fzf_opt = '--layout=reverse'
let $FZF_DEFAULT_OPTS = fzf_opt
let g:fzf_layout = { 'window': { 'width': fzf_float_rate, 'height': fzf_float_rate } }
let g:fzf_preview_floating_window_rate = fzf_float_rate
let g:coc_fzf_preview = 'right'
let g:fzf_funky_opts = [fzf_opt]

" vim-bookmarks
let g:bookmark_no_default_key_mappings = 1

" floaterm
let g:floaterm_autoclose = 1
let g:floaterm_width = 0.3
let g:floaterm_height = 0.5
let g:floaterm_position = 'topright'
let g:floaterm_keymap_new = '<Leader>ta'
let g:floaterm_keymap_toggle = '<Leader>tt'
let g:floaterm_keymap_prev   = '<Leader>tp'
let g:floaterm_keymap_next   = '<Leader>tn'
let g:floaterm_keymap_kill = '<Leader>tk'

" vim-prettier
let g:prettier#quickfix_enabled = 0

" gitgutter
let g:gitgutter_map_keys = 0
let g:gitgutter_override_sign_column_highlight = 0

" vim-plug
let g:plug_window = 'vertical rightbelow new'

