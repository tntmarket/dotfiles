set shell=/bin/bash
set encoding=utf8

" Source the vimrc file after saving it
augroup sourcing
  autocmd!
  autocmd bufwritepost .vimrc source $MYVIMRC
augroup END

vmap <C-c> "+y
vmap <C-x> "+c<ESC>

vmap <C-S-v> c<ESC>"+p
imap <C-S-v> <C-r><C-o>+

noremap  <C-s>      :update<CR>
vnoremap <C-s> <C-c>:update<CR>
inoremap <C-s> <C-o>:update<CR>

noremap  <C-z>      :undo<CR>
vnoremap <C-z> <C-c>:undo<CR>
inoremap <C-z> <C-o>:undo<CR>

com! W w
com! Q q
com! QQ qall!
cmap www w !sudo tee >/dev/null %


" use indentation for folds
set foldmethod=indent
set foldnestmax=5
set foldlevelstart=99
set foldcolumn=0

set colorcolumn=72

" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

" Leader key timeout
set tm=2000

" Kill the damned Ex mode.
nnoremap Q <nop>

" VIM user interface {{{

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu
" Tab-complete files up to longest unambiguous prefix
set wildmode=list:longest,full

" Always show current position
set ruler
set number

" Show trailing whitespace
set list
" But only interesting whitespace
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif

" Height of the command bar
set cmdheight=1

" Configure backspace so it acts as it should act
set backspace=eol,start,indent

" Ignore case when searching
" set ignorecase

" When searching try to be smart about cases
" set smartcase

set hlsearch
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set noeb vb t_vb=

map <silent> <leader>r :redraw!<CR>
map <silent> <leader>nh :noh<CR>

set mouse=a

syntax enable

" Use Unix as the standard file type
set ffs=unix,dos,mac

set expandtab
set smarttab
set scrolloff=3
set sidescrolloff=5
set shiftwidth=3
set tabstop=3
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" }}}

" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f', '')<CR>
vnoremap <silent> # :call VisualSelection('b', '')<CR>

function! CmdLine(str)
  exe "menu Foo.Bar :" . a:str
  emenu Foo.Bar
  unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'b'
    execute "normal ?" . l:pattern . "^M"
  elseif a:direction == 'gv'
    call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.' . a:extra_filter)
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  elseif a:direction == 'f'
    execute "normal /" . l:pattern . "^M"
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

nnoremap j gj
nnoremap k gk

noremap <c-h> <c-w>h
noremap <c-k> <c-w>k
noremap <c-j> <c-w>j
noremap <c-l> <c-w>l

" Return to last edit position when opening files (You want this!)
augroup last_edit
  autocmd!
  autocmd BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
       \   exe "normal! g`\"" |
       \ endif
augroup END
" Remember info about open buffers on close
set viminfo^=%

" Open window splits in various places
nmap <leader>sh :leftabove  vnew<CR>
nmap <leader>sl :rightbelow vnew<CR>
nmap <leader>sk :leftabove  new<CR>
nmap <leader>sj :rightbelow new<CR>

" don't close buffers when you aren't displaying them
set hidden

" Always show the status line
set laststatus=2

" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

augroup whitespace
  autocmd!
  autocmd BufWrite * :call DeleteTrailingWS()
augroup END

" magic that allows ctrl commands to get through
silent !stty -ixon > /dev/null 2>/dev/null
