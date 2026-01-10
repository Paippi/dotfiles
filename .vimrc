set nocompatible            " be iMproved, required
filetype on                 " required
syntax on

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
set clipboard=unnamedplus
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab
set number relativenumber
silent !mkdir --parents ~/.vim/backups
set backupdir=~/.vim/backups
set directory=~/.vim/backups
" Bindings
map <C-t> :TagbarToggle<CR>
map <F6> :setlocal spell! spelllang=en_us <CR>
map <F9> :!clear && python % <CR>
nmap ,c :%s///gn <CR>
nnoremap <C-LeftMouse> :ALEGoToDefinition<CR>
nnoremap <C-f> :NERDTreeFind<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <F3> :set hls! <CR>
nnoremap <F4> :set number! relativenumber! <CR>
nnoremap <F5> :set number! <CR>
nnoremap <Leader>f :CommandT<CR>
" No idea what this was for.
" autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Plugin settings
let g:ale_completion_enabled = 1
let g:ale_fixers = {'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'], 'python': ['black', 'trim_whitespace', 'remove_trailing_lines']}
let g:ale_linters = {'python': ['pylint']}
let g:ale_python_executable='python'
let g:ale_fix_on_save = 1
let g:CommandTPreferredImplementation='lua'
let mapleader = ","
let g:jedi#auto_initialization = 1
let g:jedi#popup_select_first = 1

" Plugins. Install using `PluginInstall`
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'rust-lang/rust.vim'
Plugin 'dense-analysis/ale'
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'preservim/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'wincent/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'davidhalter/jedi-vim'
Plugin 'auwsmit/vim-active-numbers'
Plugin 'preservim/nerdtree'
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
set runtimepath^=~/.vim/bundle/ctrlp.vim

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
" source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " Start NERDTree. If a file is specified, move the cursor to its window.
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
  " Exit Vim if NERDTree is the only window remaining in the only tab.
  autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif
  autocmd BufWinEnter * if !(&buftype == "quickfix" || &buftype == "nofile") && getcmdwintype() == '' | silent NERDTreeMirror | endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

fu! MyTabLabel(n)
let buflist = tabpagebuflist(a:n)
let winnr = tabpagewinnr(a:n)
let string = fnamemodify(bufname(buflist[winnr - 1]), ':t')
return empty(string) ? '[unnamed]' : string
endfu

fu! MyTabLine()
let s = ''
for i in range(tabpagenr('$'))
" select the highlighting
    if i + 1 == tabpagenr()
    let s .= '%#TabLineSel#'
    else
    let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    "let s .= '%' . (i + 1) . 'T'
    " display tabnumber (for use with <count>gt, etc)
    let s .= ' '. (i+1) . ' ' 

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '

    if i+1 < tabpagenr('$')
        let s .= ' |'
    endif
endfor
return s
endfu
set tabline=%!MyTabLine()

set completeopt=menu,menuone,preview,noselect,noinsert

" Theme
set t_Co=256
set background=dark
colorscheme PaperColor
