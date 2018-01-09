hi Comment term=bold ctermfg=lightblue guifg=lightblue
let g:syntastic_mode_map = { 'mode': 'passive' }
nmap <F5> :SyntasticToggleMode<CR>
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
let $PAGER=''
set hlsearch
set scrolloff=5
set nocompatible
set ruler
set tabstop=4           " use 4 spaces to represent tab
set expandtab ts=4 sw=4 ai
set shiftwidth=4        " number of spaces to use for auto indent
set autoindent          " copy indent from current line when starting a new line
" make backspaces more powerfull
set backspace=indent,eol,start
syntax on
syntax enable
set history=700
set autoread
set backspace=eol,start,indent
set ignorecase
set smartcase
set incsearch
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set ul=100
set pastetoggle=<F2>
set clipboard=unnamed
nmap <F3> :set nu! rnu!<CR>
nmap <F7> :set spell spelllang=en_us<CR>
set number
"Disable arrow keys :(...good bye dear friend
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>
au FileType gitcommit set tw=72 | set spell
au FileType markdown set | set spell spelllang=en_us
au FileType ruby setl sw=2 sts=2 et
au FileType ansible setl sw=2 sts=2 et
au FileType yaml setl sw=2 sts=2 et
au FileType json setl sw=2 sts=2 et
au FileType python setl sw=4 sts=4 et

" Ansible-vim modifications
let g:ansible_attribute_highlight = "a"
let g:ansible_name_highlight = "b"

" Tell Vim to use an undo file
set undofile
" " set a directory to store the undo history
set undodir=~/.vim/undo/

filetype off                  " required
" Vundle stuff
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
"
Plugin 'Align'
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'gmarik/Vundle.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'millermedeiros/vim-statline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-syntastic/syntastic'

call vundle#end()
filetype plugin indent on
filetype plugin on


" Theme
set background=dark
colorscheme solarized
if filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
    let g:solarized_termcolors=256
    let g:solarized_termtrans=1
    let g:solarized_contrast="normal"
    let g:solarized_visibility="normal"
    color solarized             " Load a colorscheme
endif

" Minimal Configuration
set nocompatible
" syntax on
filetype plugin indent on
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Syntastic Config
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" (Optional)Remove Info(Preview) window
set completeopt-=preview

" (Optional)Hide Info(Preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1

" NerdTree
map <C-n> :NERDTreeToggle<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Auto change the directory to the current file I'm working on
" autocmd BufEnter * lcd %:p:h 

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
