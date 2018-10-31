" vim: foldmethod=marker foldlevel=1
" The folding settings above make the {{{ and }}} sections fold up.


"#############################################################################
" Install / load plugins
"#############################################################################
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-plug'

" Interface
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle'  }
" PlugInstall and PlugUpdate will clone fzf in ~/.fzf and run install script
 Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
 Plug 'junegunn/fzf.vim'
" run rspec
Plug 'thoughtbot/vim-rspec'
" search (ack plugin, ag to actually search)
Plug 'mileszs/ack.vim'
" Rails
Plug 'tpope/vim-rails'
" Runing commands asynchronously in quickfix window
Plug 'skywind3000/asyncrun.vim'
" Vim Fugitive for Git
Plug 'tpope/vim-fugitive'
" Commenting
Plug 'tpope/vim-commentary'

call plug#end()

"#############################################################################
" Misc
"#############################################################################
filetype on
filetype plugin on
filetype plugin indent on
syntax on
let mapleader = " "
let maplocalleader = ";"

"#############################################################################
" Settings
"#############################################################################
" Disable Vi compatibility.
set nocompatible
" Backspace of newlines
set backspace=indent,eol,start
" Show existing tab with 2 spaces width
set tabstop=2
" When indenting with '>', use 2 spaces width
set shiftwidth=2
" On pressing tab, insert 2 spaces
set expandtab
" Always display the status line
set laststatus=2
" Keep 1024 lines of command line history
set history=1024
" Show the cursor position all the time
set ruler
" Display line numbers
set number
" Display incomplete commands
set showcmd
" Do incremental searching
set incsearch
" Search highlighting
set hlsearch
set sw=2 sts=2 ts=2  " 2 spaces
set t_Co=256 " Use 256 colors
set showmatch " Show matching braces
set listchars=trail:· " Show tabs and trailing whitespace only
set colorcolumn=100 " Show vertical column
" Use zsh
set shell=/usr/local/bin/zsh
" ctags
set tags=./tags,tags;

"#############################################################################
" Plugin configuration
"#############################################################################
" Use ag in ack
let g:ackprg = 'ag --vimgrep'
" Use AsyncRun to run Rspec
let g:rspec_command = 'AsyncRun rspec {spec}'
" AsyncRun quickfix window default to 8 line height
let g:asyncrun_open = 8

" Integrate asyncrun.vim with Fugitive
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

"#############################################################################
" Keymaps
"#############################################################################
" FZF / fzf.vim
nmap <Leader>t :FZF<CR>
" list recent opened files
nmap <silent> <leader>m :History<CR>


" File tree browser
map \ :NERDTreeToggle<CR>
" " File tree browser showing current file - pipe (shift-backslash)
map \| :NERDTreeFind<CR>

" Map jj to escape
inoremap jj <Esc>

" use <leader>nt to toggle the line number counting method
function! g:NumberToggle()
  if &relativenumber == 1
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
nnoremap <leader>nt :call g:NumberToggle()<cr>

" Window management - move cursor & open
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) "we havent moved
    if (match(a:key,'[jk]')) "were we going up/down
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction
map <leader>h              :call WinMove('h')<cr>
map <leader>k              :call WinMove('k')<cr>
map <leader>l              :call WinMove('l')<cr>
map <leader>j              :call WinMove('j')<cr>

" Window management - Move window
map <leader>H              :wincmd H<cr>
map <leader>K              :wincmd K<cr>
map <leader>L              :wincmd L<cr>
map <leader>J              :wincmd J<cr>

" Window management - resize
nmap <left>  :3wincmd <<cr>
nmap <right> :3wincmd ><cr>
nmap <up>    :3wincmd +<cr>
nmap <down>  :3wincmd -<cr>

" Alt - find spec file
" Run a given vim command on the results of alt from a given path.
function! AltCommand(path, vim_command)
  let l:alternate = system("alt " . a:path)
  if empty(l:alternate)
    echo "No alternate file for " . a:path . " exists!"
  else
    exec a:vim_command . " " . l:alternate
  endif
endfunction

" Find the alternate file for the current path and open it
nnoremap <leader>. :w<cr>:call AltCommand(expand('%'), ':e')<cr>

" RSpec.vim mappings
map <Leader>f :call RunCurrentSpecFile()<CR>
map <Leader>n :call RunNearestSpec()<CR>
map <Leader>la :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

" Ctags
map <Leader>h] :sp <CR>:exec("tag ".expand("<cword>"))<CR>
map <Leader>v] :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" File name and Path copy
" copy current file name/path (relative/absolute) to system clipboard
if has("mac") || has("gui_macvim") || has("gui_mac")
  " relative path  (src/foo.txt)
  nnoremap <leader>cf :let @*=expand("%")<CR>

  " absolute path  (/something/src/foo.txt)
  nnoremap <leader>cF :let @*=expand("%:p")<CR>

  " filename       (foo.txt)
  nnoremap <leader>ct :let @*=expand("%:t")<CR>

  " directory name (/something/src)
  nnoremap <leader>ch :let @*=expand("%:p:h")<CR>
endif

"#############################################################################
" Autocommands
"#############################################################################
" Strip trailing whitespace for code files on save
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Strip end of file empty lines
autocmd BufWritePre * :%s/\($\n\s*\)\+\%$//e

" auto reload vimrc to apply changes
augroup myvimrc
  au!
  au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" disable auto commenting
au FileType,BufNewFile,BufRead * se fo-=r fo-=o fo-=c fo-=q

" Highlight Ruby files
au BufRead,BufNewFile Gemfile* set filetype=ruby
au BufRead,BufNewFile *_spec.rb set syntax=ruby

" Word wrap without line breaks for text files
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=0 wrapmargin=0
