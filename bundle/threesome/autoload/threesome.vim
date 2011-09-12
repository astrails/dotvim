" ============================================================================
" File:        threesome.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

" Vim version check {{{

if v:version < '703'
    function! s:ThreesomeDidNotLoad()
        echohl WarningMsg|echomsg "Threesome unavailable: requires Vim 7.3+"|echohl None
    endfunction
    command! -nargs=0 ThreesomeInit call s:ThreesomeDidNotLoad()
    finish
endif

"}}}
" Python version check {{{

if has('python')
    let s:has_supported_python = 2
python << ENDPYTHON
import sys, vim
if sys.version_info[:2] < (2, 5):
    vim.command('let s:has_supported_python = 0')
ENDPYTHON
else
    let s:has_supported_python = 0
endif

if !s:has_supported_python
    function! s:ThreesomeDidNotLoad()
        echohl WarningMsg|echomsg "Threesome requires Vim to be compiled with Python 2.5+"|echohl None
    endfunction
    command! -nargs=0 ThreesomeInit call s:ThreesomeDidNotLoad()
    finish
endif

"}}}
" Configuration variables {{{

if !exists('g:threesome_disable') "{{{
    let g:threesome_disable = 0
endif " }}}
if !exists('g:threesome_initial_mode') "{{{
    let g:threesome_initial_mode = 'grid'
endif "}}}
if !exists('g:threesome_initial_layout_grid') "{{{
    let g:threesome_initial_layout_grid = 0
endif "}}}
if !exists('g:threesome_initial_layout_loupe') "{{{
    let g:threesome_initial_layout_loupe = 0
endif "}}}
if !exists('g:threesome_initial_layout_compare') "{{{
    let g:threesome_initial_layout_compare = 0
endif "}}}
if !exists('g:threesome_initial_layout_path') "{{{
    let g:threesome_initial_layout_path = 0
endif "}}}
if !exists('g:threesome_initial_diff_grid') "{{{
    let g:threesome_initial_diff_grid = 0
endif "}}}
if !exists('g:threesome_initial_diff_loupe') "{{{
    let g:threesome_initial_diff_loupe = 0
endif "}}}
if !exists('g:threesome_initial_diff_compare') "{{{
    let g:threesome_initial_diff_compare = 0
endif "}}}
if !exists('g:threesome_initial_diff_path') "{{{
    let g:threesome_initial_diff_path = 0
endif "}}}
if !exists('g:threesome_initial_scrollbind_grid') "{{{
    let g:threesome_initial_scrollbind_grid = 0
endif "}}}
if !exists('g:threesome_initial_scrollbind_loupe') "{{{
    let g:threesome_initial_scrollbind_loupe = 0
endif "}}}
if !exists('g:threesome_initial_scrollbind_compare') "{{{
    let g:threesome_initial_scrollbind_compare = 0
endif "}}}
if !exists('g:threesome_initial_scrollbind_path') "{{{
    let g:threesome_initial_scrollbind_path = 0
endif "}}}

" }}}

" }}}
" Wrappers {{{

function! threesome#ThreesomeInit() "{{{
    let python_module = fnameescape(globpath(&runtimepath, 'autoload/threesome.py'))
    exe 'pyfile ' . python_module
    python ThreesomeInit()
endfunction "}}}

function! threesome#ThreesomeGrid() "{{{
    python ThreesomeGrid()
endfunction "}}}
function! threesome#ThreesomeLoupe() "{{{
    python ThreesomeLoupe()
endfunction "}}}
function! threesome#ThreesomeCompare() "{{{
    python ThreesomeCompare()
endfunction "}}}
function! threesome#ThreesomePath() "{{{
    python ThreesomePath()
endfunction "}}}

function! threesome#ThreesomeOriginal() "{{{
    python ThreesomeOriginal()
endfunction "}}}
function! threesome#ThreesomeOne() "{{{
    python ThreesomeOne()
endfunction "}}}
function! threesome#ThreesomeTwo() "{{{
    python ThreesomeTwo()
endfunction "}}}
function! threesome#ThreesomeResult() "{{{
    python ThreesomeResult()
endfunction "}}}

function! threesome#ThreesomeDiff() "{{{
    python ThreesomeDiff()
endfunction "}}}
function! threesome#ThreesomeDiffoff() "{{{
    python ThreesomeDiffoff()
endfunction "}}}
function! threesome#ThreesomeScroll() "{{{
    python ThreesomeScroll()
endfunction "}}}
function! threesome#ThreesomeLayout() "{{{
    python ThreesomeLayout()
endfunction "}}}
function! threesome#ThreesomeNext() "{{{
    python ThreesomeNext()
endfunction "}}}
function! threesome#ThreesomePrev() "{{{
    python ThreesomePrev()
endfunction "}}}
function! threesome#ThreesomeUse() "{{{
    python ThreesomeUse()
endfunction "}}}
function! threesome#ThreesomeUse1() "{{{
    python ThreesomeUse1()
endfunction "}}}
function! threesome#ThreesomeUse2() "{{{
    python ThreesomeUse2()
endfunction "}}}

" }}}
