" DESTROY MOUSE INTEGRATION "
" sed -i '/mouse=/d' $(ag -l mouse= /usr/share/vim/)
"
" FIRST TIME?
"   :PlugInstall
"   :GoInstallBinaries

filetype plugin indent on
syntax on

" highlight <keyword> [ cterm=<style> ] [ ctermbg=<color> ] [ ctermfg=<color> ]
"
"   <keyword> = {
"       ColorColumn |
"       Normal      |
"       NormalNC    |
"       CursorLine  |
"       ...
"   }
"
"   <style> = { none | underline | bold }
"
"   1 <= <color> <= 256
"

colorscheme challenger_deep

highlight Normal NONE
highlight Normal ctermfg=253 ctermbg=0


highlight clear CursorColumn
highlight       CursorColumn ctermbg=233
highlight clear ColorColumn
highlight link  ColorColumn CursorColumn
highlight clear CursorLine
highlight link  CursorLine CursorColumn

highlight clear NonText
highlight       NonText ctermbg=232 ctermfg=248
highlight clear EndOfBuffer
highlight link  EndOfBuffer NonText
highlight clear LineNr
highlight link  LineNr NonText
highlight clear LineNrAbove
highlight link  LineNrAbove NonText
highlight clear LineNrBelow
highlight link  LineNrBelow NonText

highlight clear Visual
highlight       Visual ctermbg=76 ctermfg=0 cterm=bold

highlight clear MatchParen
highlight       MatchParen ctermbg=0 ctermfg=207 cterm=bold,underline

highlight clear Todo
highlight       Todo ctermfg=0 ctermbg=159
highlight clear Comment
highlight       Comment ctermfg=248
highlight clear Keyword
highlight       Keyword ctermfg=203 cterm=bold
highlight clear Identifier
highlight       Identifier ctermfg=46
highlight clear Operator
highlight       Operator cterm=bold ctermfg=117
highlight clear Type
highlight       Type ctermfg=123

highlight clear CurSearch
highlight       CurSearch cterm=bold,underline ctermfg=234 ctermbg=220

highlight clear Search
highlight       Search cterm=underline ctermfg=0 ctermbg=223

highlight clear SignColumn

"""""

"highlight StatusLine                        ctermbg=52  ctermfg=214
"highlight StatusLineNC                      ctermbg=235 ctermfg=214
"highlight LineNR                            ctermbg=233 ctermfg=239
"highlight CursorLineNr                      ctermbg=214 ctermfg=52
"highlight MatchParen        cterm=none      ctermbg=256 ctermfg=214

let g:airline_theme='simple'


" Twiddlying the Frobbs
set showcmd
set showmatch
set hidden
set mouse=
set number
set numberwidth=1
set hlsearch
set incsearch
set autoindent
set cmdheight=1
set shiftwidth=4
set tabstop=4
set expandtab
set colorcolumn=81
set textwidth=80
set cursorline
set cursorcolumn
set virtualedit= virtualedit=all
set directory=.,~/.local/share/nvim/swap/
"Increases the memory limit from 50 lines to 1000 lines
set viminfo='100,<1000,s10,h
let g:go_fmt_command = "goimports"
set nowrap

autocmd BufEnter *.go setlocal textwidth=80




" Workaround shitty shit about shit (<ESC> behaviour in neovim does not
" "escape" immediately)
set notimeout nottimeout

if !exists("diegom_loaded")
    let diegom_loaded = 1

    function GoToBufAux( lst )
        let lst = filter( a:lst[1:], 'filereadable(bufname(v:val)) && buflisted(bufname(v:val))' )
        if len( lst ) > 1
            execute lst[0] . "buffer"
            return 1
        endif
        return 0
    endfunction

    function GoToPreviousListedBuffer()
        return GoToBufAux( reverse( range(1, winbufnr(0)) ) + reverse( range(winbufnr(0), bufnr("$") ) ) )
    endfunction

    function GoToNextListedBuffer()
        return GoToBufAux( range(winbufnr(0), bufnr("$") ) + range(1, winbufnr(0)))
    endfunction

    function CloseCurBuffer()
        if GoToPreviousListedBuffer()
            bdelete #
        else
            bdelete
        endif
    endfunction

    command! -complete=shellcmd -nargs=+ SHEX call s:RunShellCommand(<q-args>)
    function! s:RunShellCommand(cmdline)
        let expanded_cmdline = a:cmdline
        let l:logfile = expand('%') . '.log'

        for part in split(a:cmdline, ' ')
            if part[0] =~ '\v[%#<]'
                let expanded_part = fnameescape(expand(part))
            let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
            endif
        endfor

        if winnr() == 1
            wincmd l
            if bufname(winbufnr(0)) == 'vimfiler:default'
                wincmd h
                vsp
                wincmd l
            endif
        else
            wincmd h
        endif

        if bufname(winbufnr(0)) != l:logfile
            execute 'edit ' . l:logfile
        endif

        setlocal noswapfile nowrap buftype=nofile

        call append(line('$'), '=============================================')
        call append(line('$'), '===== Start time: ' . strftime("%F %T %Z"))
        call append(line('$'), 'CmdLine:          ' . a:cmdline)
        call append(line('$'), 'CmdLine Expanded: ' . expanded_cmdline)
        call append(line('$'), '')

        execute '$read !'. expanded_cmdline

        call append(line('$'), '')
        call append(line('$'), '===== End time:   ' . strftime("%F %T %Z"))
        call append(line('$'), '=============================================')
        call append(line('$'), '')
        $
    endfunction

    function! s:DiffWithSaved()
        let filetype=&ft
        diffthis
        vnew | r # | normal! 1Gdd
        diffthis
        exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    endfunction
    com! DiffSaved call s:DiffWithSaved()

    function FormatProto()
        sp
        %!clang-format-15 -style=file
        w
        q
    endfunction
    autocmd BufWritePre *.proto call FormatProto()

    " Fix YAML settings
    autocmd BufNewFile,BufRead *.yml setlocal shiftwidth=2 tabstop=2
endif

nmap k <Up><C-y>
"   In the following line replace the text after the '>' with <C-v><Down>
nmap j <Down><C-e>
nmap l :call GoToNextListedBuffer()<CR>
nmap h :call GoToPreviousListedBuffer()<CR>
nmap <F1> :tabprev<CR>
nmap <F2> :tabn<CR>
nmap <C-D> :GoDef<CR>
nmap <C-F> :GoRef<CR>
nmap <C-T> :GoDefType<CR>
nmap <F12> :call CloseCurBuffer()<CR>
nmap <C-C> :GoDoc<CR>
nmap <Tab> <C-w><C-w>
nmap <S-Tab> <C-w>W
nmap < <<
nmap > >>
nmap <F5> :buffers<CR>:buffer<Space>
nmap <F6> :cd %:p:h<CR>

nmap <PageDown> 20<Down>20<C-e>
nmap <PageUp> 20<Up>20<C-y>

nmap z zO
vmap z zf

tnoremap <Esc> <C-\><C-n>

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd!
  autocmd VimEnter * PlugInstall
endif


"
" VimPlug package manager
"

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')


" GTM Support (Git Time Metric): https://github.com/git-time-metric/gtm
" To initialize a project:
"   gtm init
" To push time metrics data into remote:
"   git pushgtm
" To fetch time metrics data from remote:
"   git fetchgtm
"Plug 'git-time-metric/gtm-vim-plugin'


" NERDTree: https://github.com/preservim/nerdtree
Plug 'scrooloose/nerdtree'


" Display git status flags in NERDTree:
" https://github.com/Xuyuanp/nerdtree-git-plugin
Plug 'Xuyuanp/nerdtree-git-plugin'


" Asynchronous completion framework: https://github.com/Shougo/deoplete.nvim
if has('nvim')
  "Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  "Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif


" Golang support: https://github.com/fatih/vim-go
" Also needed:
"   !which godoc && go get golang.org/x/tools/cmd/godoc
"   !which gocode && go get github.com/nsf/gocode
"   !which goimports && go get golang.org/x/tools/cmd/goimports
"   !which godef && go get github.com/rogpeppe/godef
"   !which gorename && go get golang.org/x/tools/cmd/gorename
"   !which golint && go get golang.org/x/lint/golint
"   !which errcheck && go get github.com/kisielk/errcheck
"   !which gotags && go get github.com/jstemmer/gotags
"   !which godep && go get github.com/tools/godep
"   !which gopls && GO111MODULE=on go get golang.org/x/tools/gopls@latest
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }


" vim-svelte (https://github.com/evanleck/vim-svelte)
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
let g:svelte_preprocessor_tags = [
  \ { 'name': 'ts', 'tag': 'script', 'as': 'typescript' }
  \ ]
let g:svelte_preprocessors = ['ts']


" TagBar (https://github.com/majutsushi/tagbar)
Plug 'majutsushi/tagbar'


" Lean & mean status/tabline: https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


" Git indicator (gutter):
" https://github.com/reubinoff/DotFiles/blob/master/.vimrc
Plug 'airblade/vim-gitgutter'


" Svelte
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}


" Initialize plugin system
call plug#end()


"
" Configure plugins
"


" Improve gitgutter response time
set updatetime=100
" Fix the gitgutter column
set signcolumn=yes:1


" Display time spent in current file in Airline
"let g:gtm_plugin_status_enabled = 1
"function! AirlineInit()
"  if exists('*GTMStatusline')
"    call airline#parts#define_function('gtmstatus', 'GTMStatusline')
"    let g:airline_section_b = airline#section#create([g:airline_section_b, ' ', '[', 'gtmstatus', ']'])
"  endif
"endfunction
"autocmd User AirlineAfterInit call AirlineInit()


" Enable deoplete at startup
"let g:deoplete#enable_at_startup = 1
" Instructs deoplete to use omni completion for Go files
"call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })


" Toggle NERDTree
nmap <F7> :NERDTreeToggle<CR>
" Open NERDTree automatically when no files are given on the command line or
" when only a directory is specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Open NERDTree automatically when a directory is given in the command line
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


" Toggle tagbar
nmap <F8> :TagbarToggle<CR>
" Open tagbar automatically
autocmd vimenter * TagbarToggle

" gotags (https://github.com/jstemmer/gotags) configuration for TagBar
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }
