	" Vim with all enhancements
	source $VIMRUNTIME/vimrc_example.vim

	" Use the internal diff if available.
	" Otherwise use the special 'diffexpr' for Windows.
	if &diffopt !~# 'internal'
	  set diffexpr=MyDiff()
	endif
	function MyDiff()
	  let opt = '-a --binary '
	  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
	  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
	  let arg1 = v:fname_in
	  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
	  let arg1 = substitute(arg1, '!', '\!', 'g')
	  let arg2 = v:fname_new
	  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
	  let arg2 = substitute(arg2, '!', '\!', 'g')
	  let arg3 = v:fname_out
	  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
	  let arg3 = substitute(arg3, '!', '\!', 'g')
	  if $VIMRUNTIME =~ ' '
	    if &sh =~ '\<cmd'
	      if empty(&shellxquote)
		let l:shxq_sav = ''
		set shellxquote&
	      endif
	      let cmd = '"' . $VIMRUNTIME . '\diff"'
	    else
	      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
	    endif
	  else
	    let cmd = $VIMRUNTIME . '\diff'
	  endif
	  let cmd = substitute(cmd, '!', '\!', 'g')
	  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
	  if exists('l:shxq_sav')
	    let &shellxquote=l:shxq_sav
	  endif
	endfunction

	" �������
	call plug#begin()

	Plug 'vim-airline/vim-airline'
	Plug 'xuyuanp/nerdtree-git-plugin'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-rhubarb'
        Plug 'rbong/vim-flog'
        Plug 'sindrets/diffview.nvim'
	Plug 'whiteinge/diffconflicts'
	Plug 'airblade/vim-gitgutter' 
	Plug 'tpope/vim-surround'
	Plug 'scrooloose/nerdtree'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'norcalli/nvim-colorizer.lua'
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'junegunn/fzf.vim'
	Plug 'aktersnurra/vim-retrobox' " ������� retrobox
	Plug 'itchyny/vim-gitbranch'

	call plug#end()

	" �������� ���������
	set number 
	set relativenumber
	set undofile
	set undodir=~/.vim/undo
	set nocompatible
	filetype plugin indent on
	syntax on
	set cursorline
	set nowrap
	set history=1000



	" �������� true-�����, ���� ��������������
	if has('termguicolors')
	  set termguicolors
	endif

	" ========== ������������ �������� ���� ==========
	" ��������� retrobox
	function! ApplyRetrobox()
	  colorscheme retrobox
	  " ������������ retrobox
	  highlight Comment gui=italic cterm=italic
	  highlight Visual guibg=#444444
	  highlight LineNr guifg=#777777
	  
	  " ��������� ���������� ��� retrobox
	  highlight Delimiter guifg=#ff8800 ctermfg=208 " �����, �������, ������
	  highlight Operator  guifg=#ff8800 ctermfg=208 " ���������
	  highlight Todo guifg=#03fc73

	  let g:airline_theme = 'minimalist'
	endfunction

	" ��������� murphy
	function! ApplyMurphy()
	  colorscheme murphy
	  " ������������ murphy
	  Comment gui=italic cterm=italic
	  highlight Visual guibg=#555577
  highlight LineNr guifg=#8888aa
  
  " ��������� ���������� ��� murphy
  highlight Delimiter guifg=#ffff00 ctermfg=226 " �����, �������, ������
  highlight Operator  guifg=#fc6203  ctermfg=226 " ���������
  
  let g:airline_theme = 'dark'
endfunction

" ��������� ����� �� ���������
call ApplyMurphy()

" ������������ ����� �������
let g:current_theme = 'murphy'
function! ToggleTheme()
  if g:current_theme == 'murphy'
    call ApplyRetrobox()
    let g:current_theme = 'retrobox'
  else
    call ApplyMurphy()
    let g:current_theme = 'murphy'
  endif
endfunction

nnoremap <F8> :call ToggleTheme()<CR>
" ===============================================

" ��������� Airline 
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_nr_show = 1

" ���������� ��������
nmap <leader>bn :bnext<CR>
nmap <leader>bp :bprevious<CR>
nmap <leader>bd :bdelete<CR>

" ��������� Colorizer
lua require 'colorizer'.setup()

" ========== ������������ ������� FZF ==========
" ����� ��������� �������� ����
function! s:list_colors()
  let schemes = globpath(&runtimepath, "colors/*.vim", 0, 1)
  return map(schemes, 'fnamemodify(v:val, ":t:r")')
endfunction

" ������� ������� ��� ����� �������� �����
command! ChangeColorScheme call fzf#run({
\ 'source': s:list_colors(),
\ 'sink':    'colo',
\ 'options': '--prompt="Color Scheme> "'
\ })

" ������� ��� ������������� �������� �����
command! PreviewColorScheme call fzf#run({
\ 'source': s:list_colors(),
\ 'sink':    function('s:preview_color_scheme'),
\ 'options': '--prompt="Preview Scheme> "'
\ })

" ������� �������������
function! s:preview_color_scheme(scheme)
  execute 'colorscheme ' . a:scheme
  redraw
  echo "Previewing: " . a:scheme
endfunction

" ������� �������
nnoremap <F9> :PreviewColorScheme<CR>
nnoremap <F10> :ChangeColorScheme<CR>
" ==============================================

" ��������� Coc
set hidden
set updatetime=300
set shortmess+=c
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"  
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"  

" �����
set hlsearch
nnoremap <silent> <C-l> :nohlsearch<CR><C-l> " ����� ��������� ����� ������

" ��������� ����� ������
nmap <silent> <C-k> :wincmd k<CR> 
nmap <silent> <C-l> :wincmd l<CR> 
nmap <silent> <C-h> :wincmd h<CR> 
nmap <silent> <C-j> :wincmd j<CR> 

" �������� ����� ����
nmap <leader>vs :vsplit<CR>   " ������������ ����������
nmap <leader>hs :split<CR>    " �������������� ����������

" ������� �������
map <F2> <Esc>:w<CR>
map <F4> <Esc>:q<CR>
map <C-p> <Esc>:NERDTreeToggle<CR>

" ========== ���������� �������������� ������ ==========
" ������� ��� ������
let s:session_dir = expand('$HOME/.vim/sessions')
let s:session_file = s:session_dir . '/last_session.vim'

" ������� �������, ���� �� ����������
if !isdirectory(s:session_dir)
  silent! call mkdir(s:session_dir, 'p', 0700)
endif

" ��������� ������ ��� ������ (������� ������� � ������������ ����)
autocmd VimLeave * execute 'mksession! ' . fnameescape(s:session_file)

" ��������� ������ ��� �������
if argc() == 0
  if filereadable(s:session_file)
    " ��������������� ������ �������� ���� ����� ��������� ������
    if has("gui_running")
      autocmd VimEnter * nested 
            \ execute 'set lines=' . s:gui_lines |
            \ execute 'set columns=' . s:gui_columns |
            \ execute 'source ' . fnameescape(s:session_file)
    else
      execute 'source ' . fnameescape(s:session_file)
    endif
  endif
endif

" ��������� ������� ���� ��� GUI
if has("gui_running")
  let s:gui_lines = &lines
  let s:gui_columns = &columns
endif

" �������������� ��������� �������
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent! loadview
" ========================================================

" ��������� GitGutter � ����������� ���������
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '?'
let g:gitgutter_sign_modified_removed = '~_'

" ��������� NERDTree Git
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : 'M',
    \ 'Staged'    : 'S',
    \ 'Untracked' : 'U',
    \ 'Renamed'   : 'R',
    \ 'Unmerged'  : '=',
    \ 'Deleted'   : 'D',
    \ 'Dirty'     : '!',
    \ 'Ignored'   : 'I',
    \ 'Clean'     : 'C',
    \ 'Unknown'   : '?'
\ }

" ��������� ����������� ����� � Airline
let g:airline#extensions#gitbranch#enabled = 1
set statusline+=%{gitbranch#name()}

" �������������� Git-�������
autocmd BufWritePost * GitGutter
autocmd FocusGained  * GitGutter

" �������� �������� ��� Git (WebStorm-like)
nnoremap <leader>gg :Git<CR>                 " ������ (������ Alt+9)
nnoremap <leader>gl :Flog<CR>                " ���� �������� (������ ������� Git)
nnoremap <leader>gL :Flog -all<CR>           " ���� ���� �����
nnoremap <leader>gb :Flogsplit -mode=0<CR>   " ������ �����
nnoremap <leader>gc :Git commit<CR>          " ������
nnoremap <leader>gp :Git push<CR>            " ���
nnoremap <leader>gP :Git pull<CR>            " ����
nnoremap <leader>gd :Gvdiffsplit!<CR>        " 3-way diff
nnoremap <leader>gD :DiffviewOpen<CR>        " �������� ���� ���������
nnoremap <leader>gh :GBrowse<CR>             " ������� � GitHub
nnoremap <leader>gH :GBrowse!<CR>            " ������� � GitHub (�� ������ �������)

" ������������ ����� ������� ����� � Flog
autocmd FileType floggraph nnoremap <buffer> <CR> :call flog#run_command('Git checkout ' . flog#get_commit_hash())<CR>

" �������� ����� �� Flog
autocmd FileType floggraph nnoremap <buffer> b :Git branch 

" ������������� �������������� (������ Ctrl+K � WebStorm)
nmap <leader>ga <Plug>(GitGutterStageHunk)   " �������� �����
nmap <leader>gu <Plug>(GitGutterUndoHunk)    " �������� ���������� �����

" ���������� ��������� ��� GitGutter
let g:gitgutter_sign_added = '?'
let g:gitgutter_sign_modified = '?'
let g:gitgutter_sign_removed = '?'
let g:gitgutter_sign_removed_first_line = '?'
let g:gitgutter_sign_modified_removed = '?'
let g:gitgutter_preview_win_floating = 1

" ��������� Diffview
nnoremap <leader>gdc :DiffviewClose<CR>
nnoremap <leader>gdh :DiffviewFileHistory %<CR>

" ������������ Diffview ����� ���������� ����������
autocmd BufWritePost * if &diff | DiffviewClose | endif

" ���������� �������� ��������
command! -nargs=* Glog execute 'Flog -format="%h %s [%an] %ar" -all ' . <q-args>

" ==================== ����� Git-���������� ====================


" ��������� Coc
let g:coc_global_extensions = [
  \ 'coc-tsserver', 
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-prettier',
\ ]

" ������������������
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx :call CocAction('format')

" �������� ��� Git
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

" ������� ����������� ����� �����������
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nnoremap <leader>gu :GitGutter<CR>

" ������� � �������
nnoremap <silent> <C-o> :call CocAction('jumpDefinition')<CR>
