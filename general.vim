" General options {{
if has('nvim') && !has("gui_running")
  set termguicolors
end
set hidden " allow buffer switch without saving
set history=1000
set wildmenu
set wildmode=list:longest,full
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set backspace=2
set autowrite
set autoread
set hlsearch
set incsearch
set regexpengine=2
let &termencoding=&encoding
set fileencodings=utf-8,gbk,ucs-bom,cp936
set mousehide
set nowritebackup
set noimdisable
set noswapfile
set nobackup
set undodir=~/.undodir
set undofile
set fileformats=unix,dos
set display+=lastline
set formatoptions+=j
set diffopt=vertical
"set sessionoptions+=winpos
"set sessionoptions+=resize
"set sessionoptions+=winsize
set sessionoptions+=winsize
set sessionoptions-=blank
set sessionoptions+=localoptions
set viewoptions=cursor,folds,slash,unix
set ttimeout
set ttimeoutlen=500
set ttimeoutlen=100
set tabpagemax=10
set scrolloff=3
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set wildignore+=*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*
set keywordprg=
set showtabline=2
set laststatus=2
set noshowmode
set updatetime=1000
" Formatting
set smarttab
set shiftwidth=2
set tabstop=2
set expandtab
set shiftround
set autoindent
set wrap
set guioptions-=r
set number
set relativenumber
set ttyfast
if executable('ag')
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
  let g:grep_using_git = 0
elseif executable('grepprg')
  set grepprg=grepprg\ $*
  set grepformat=%f:%l:%c:%m
  let g:grep_using_git = 1
endif
" }}

" Special options for macvim {{
if has('gui_running')
  if exists("*strftime")
    let h = strftime('%H')
    if h >= 17 || h < 8
      set background=dark
    else
      set background=dark
    endif
  else
    set background=light
  endif
  colorscheme gruvbox
  set guifont=Source\ Code\ Pro:h13
  set transparency=10
  set macmeta
  " better font render on Retina screen
  set antialias
else
  let g:solarized_termcolors=256
  set background=dark
  colorscheme gruvbox
endif
" }}

" Syntax related {{
" improve performance
syntax sync minlines=300
hi Pmenu  guifg=#333333 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE
" change default search highlight
hi Search guibg=#333333 guifg=#C5B569
" }}

" Complete config {{
set complete-=i
set complete+=k
set omnifunc=syntaxcomplete#Complete
set completeopt=menu,preview
" }}
" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{,}} foldmethod=marker foldlevel=0:
