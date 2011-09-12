" ============================================================================
" File:        threesome.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

if !exists('g:threesome_debug') && (exists('g:threesome_disable') || exists('loaded_threesome') || &cp)
    finish
endif
let loaded_threesome = 1

" }}}
" Commands {{{

command! -nargs=0 ThreesomeInit call threesome#ThreesomeInit()

command! -nargs=0 ThreesomeGrid call threesome#ThreesomeGrid()
command! -nargs=0 ThreesomeLoupe call threesome#ThreesomeLoupe()
command! -nargs=0 ThreesomeCompare call threesome#ThreesomeCompare()
command! -nargs=0 ThreesomePath call threesome#ThreesomePath()

command! -nargs=0 ThreesomeOriginal call threesome#ThreesomeOriginal()
command! -nargs=0 ThreesomeOne call threesome#ThreesomeOne()
command! -nargs=0 ThreesomeTwo call threesome#ThreesomeTwo()
command! -nargs=0 ThreesomeResult call threesome#ThreesomeResult()

command! -nargs=0 ThreesomeDiff call threesome#ThreesomeDiff()
command! -nargs=0 ThreesomeDiffoff call threesome#ThreesomeDiffoff()
command! -nargs=0 ThreesomeScroll call threesome#ThreesomeScroll()
command! -nargs=0 ThreesomeLayout call threesome#ThreesomeLayout()
command! -nargs=0 ThreesomeNext call threesome#ThreesomeNext()
command! -nargs=0 ThreesomePrev call threesome#ThreesomePrev()
command! -nargs=0 ThreesomeUse call threesome#ThreesomeUse()
command! -nargs=0 ThreesomeUse1 call threesome#ThreesomeUse1()
command! -nargs=0 ThreesomeUse2 call threesome#ThreesomeUse2()

" }}}
