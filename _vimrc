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

	" Плагины
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
	Plug 'aktersnurra/vim-retrobox' " Добавим retrobox
	Plug 'itchyny/vim-gitbranch'

	call plug#end()

	" Основные настройки
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



	" Включить true-цвета, если поддерживается
	if has('termguicolors')
	  set termguicolors
	endif

	" ========== КАСТОМИЗАЦИЯ ЦВЕТОВЫХ СХЕМ ==========
	" Настройка retrobox
	function! ApplyRetrobox()
	  colorscheme retrobox
	  " Кастомизация retrobox
	  highlight Comment gui=italic cterm=italic
	  highlight Visual guibg=#444444
	  highlight LineNr guifg=#777777
	  
	  " Настройка пунктуации для retrobox
	  highlight Delimiter guifg=#ff8800 ctermfg=208 " Точки, запятые, скобки
	  highlight Operator  guifg=#ff8800 ctermfg=208 " Операторы
	  highlight Todo guifg=#03fc73

	  let g:airline_theme = 'minimalist'
	endfunction

	" Настройка murphy
	function! ApplyMurphy()
	  colorscheme murphy
	  " Кастомизация murphy
	  Comment gui=italic cterm=italic
	  highlight Visual guibg=#555577
  highlight LineNr guifg=#8888aa
  
  " Настройка пунктуации для murphy
  highlight Delimiter guifg=#ffff00 ctermfg=226 " Точки, запятые, скобки
  highlight Operator  guifg=#fc6203  ctermfg=226 " Операторы
  
  let g:airline_theme = 'dark'
endfunction

" Установка схемы по умолчанию
call ApplyMurphy()

" Переключение между схемами
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

" Настройка Airline 
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_nr_show = 1

" Управление буферами
nmap <leader>bn :bnext<CR>
nmap <leader>bp :bprevious<CR>
nmap <leader>bd :bdelete<CR>

" Настройка Colorizer
lua require 'colorizer'.setup()

" ========== ИСПРАВЛЕННЫЕ КОМАНДЫ FZF ==========
" Показ доступных цветовых схем
function! s:list_colors()
  let schemes = globpath(&runtimepath, "colors/*.vim", 0, 1)
  return map(schemes, 'fnamemodify(v:val, ":t:r")')
endfunction

" Простая команда для смены цветовой схемы
command! ChangeColorScheme call fzf#run({
\ 'source': s:list_colors(),
\ 'sink':    'colo',
\ 'options': '--prompt="Color Scheme> "'
\ })

" Команда для предпросмотра цветовой схемы
command! PreviewColorScheme call fzf#run({
\ 'source': s:list_colors(),
\ 'sink':    function('s:preview_color_scheme'),
\ 'options': '--prompt="Preview Scheme> "'
\ })

" Функция предпросмотра
function! s:preview_color_scheme(scheme)
  execute 'colorscheme ' . a:scheme
  redraw
  echo "Previewing: " . a:scheme
endfunction

" Горячие клавиши
nnoremap <F9> :PreviewColorScheme<CR>
nnoremap <F10> :ChangeColorScheme<CR>
" ==============================================

" Настройки Coc
set hidden
set updatetime=300
set shortmess+=c
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"  
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"  

" Поиск
set hlsearch
nnoremap <silent> <C-l> :nohlsearch<CR><C-l> " Снять выделение после поиска

" Навигация между окнами
nmap <silent> <C-k> :wincmd k<CR> 
nmap <silent> <C-l> :wincmd l<CR> 
nmap <silent> <C-h> :wincmd h<CR> 
nmap <silent> <C-j> :wincmd j<CR> 

" Создание новых окон
nmap <leader>vs :vsplit<CR>   " Вертикальное разделение
nmap <leader>hs :split<CR>    " Горизонтальное разделение

" Горячие клавиши
map <F2> <Esc>:w<CR>
map <F4> <Esc>:q<CR>
map <C-p> <Esc>:NERDTreeToggle<CR>

" ========== УЛУЧШЕННОЕ ВОССТАНОВЛЕНИЕ СЕССИИ ==========
" Каталог для сессий
let s:session_dir = expand('$HOME/.vim/sessions')
let s:session_file = s:session_dir . '/last_session.vim'

" Создаем каталог, если не существует
if !isdirectory(s:session_dir)
  silent! call mkdir(s:session_dir, 'p', 0700)
endif

" Сохраняем сессию при выходе (включая размеры и расположение окон)
autocmd VimLeave * execute 'mksession! ' . fnameescape(s:session_file)

" Загружаем сессию при запуске
if argc() == 0
  if filereadable(s:session_file)
    " Восстанавливаем размер главного окна перед загрузкой сессии
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

" Сохраняем размеры окон для GUI
if has("gui_running")
  let s:gui_lines = &lines
  let s:gui_columns = &columns
endif

" Восстановление положения курсора
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent! loadview
" ========================================================

" Настройка GitGutter с корректными символами
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '?'
let g:gitgutter_sign_modified_removed = '~_'

" Настройка NERDTree Git
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

" Настройка отображения ветки в Airline
let g:airline#extensions#gitbranch#enabled = 1
set statusline+=%{gitbranch#name()}

" Автообновление Git-статуса
autocmd BufWritePost * GitGutter
autocmd FocusGained  * GitGutter

" Основные маппинги для Git (WebStorm-like)
nnoremap <leader>gg :Git<CR>                 " Статус (аналог Alt+9)
nnoremap <leader>gl :Flog<CR>                " Граф коммитов (аналог вкладки Git)
nnoremap <leader>gL :Flog -all<CR>           " Граф всех веток
nnoremap <leader>gb :Flogsplit -mode=0<CR>   " Список веток
nnoremap <leader>gc :Git commit<CR>          " Коммит
nnoremap <leader>gp :Git push<CR>            " Пуш
nnoremap <leader>gP :Git pull<CR>            " Пулл
nnoremap <leader>gd :Gvdiffsplit!<CR>        " 3-way diff
nnoremap <leader>gD :DiffviewOpen<CR>        " Просмотр всех изменений
nnoremap <leader>gh :GBrowse<CR>             " Открыть в GitHub
nnoremap <leader>gH :GBrowse!<CR>            " Открыть в GitHub (на строку коммита)

" Переключение между ветками прямо в Flog
autocmd FileType floggraph nnoremap <buffer> <CR> :call flog#run_command('Git checkout ' . flog#get_commit_hash())<CR>

" Создание веток из Flog
autocmd FileType floggraph nnoremap <buffer> b :Git branch 

" Интерактивное индексирование (аналог Ctrl+K в WebStorm)
nmap <leader>ga <Plug>(GitGutterStageHunk)   " Добавить кусок
nmap <leader>gu <Plug>(GitGutterUndoHunk)    " Отменить индексацию куска

" Визуальные улучшения для GitGutter
let g:gitgutter_sign_added = '?'
let g:gitgutter_sign_modified = '?'
let g:gitgutter_sign_removed = '?'
let g:gitgutter_sign_removed_first_line = '?'
let g:gitgutter_sign_modified_removed = '?'
let g:gitgutter_preview_win_floating = 1

" Настройка Diffview
nnoremap <leader>gdc :DiffviewClose<CR>
nnoremap <leader>gdh :DiffviewFileHistory %<CR>

" Автозакрытие Diffview после разрешения конфликтов
autocmd BufWritePost * if &diff | DiffviewClose | endif

" Улучшенный просмотр коммитов
command! -nargs=* Glog execute 'Flog -format="%h %s [%an] %ar" -all ' . <q-args>

" ==================== Конец Git-интеграции ====================


" Настройка Coc
let g:coc_global_extensions = [
  \ 'coc-tsserver', 
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-prettier',
\ ]

" Автоформатирование
autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx :call CocAction('format')

" Шорткаты для Git
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

" Быстрое перемещение между изменениями
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nnoremap <leader>gu :GitGutter<CR>

" Перейти к функции
nnoremap <silent> <C-o> :call CocAction('jumpDefinition')<CR>
