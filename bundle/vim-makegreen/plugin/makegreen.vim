" plugin/makegreen.vim
" Author:   Rein Henrichs <reinh@reinh.com>
" License:  MIT License

" Install this file as plugin/makegreen.vim.

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if &cp || exists("g:makegreen_loaded") && g:makegreen_loaded
  finish
endif
let g:makegreen_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

hi GreenBar term=reverse ctermfg=white ctermbg=green guifg=white guibg=green
hi RedBar   term=reverse ctermfg=white ctermbg=red guifg=white guibg=red

function MakeGreen(...) "{{{1
  let arg_count = a:0
  if arg_count
    let make_args = a:1
  else
    let make_args = '%'
  endif

  silent! w
  let s:old_sp = &shellpipe
  if has('unix')
    set shellpipe=&> "quieter make output
  endif
  silent! exec "make " . make_args
  let &shellpipe = s:old_sp

  redraw!

  let error = s:GetFirstError()
  if error != ''
    call s:Bar("red", error)
  else
    call s:Bar("green","All tests passed")
  endif
endfunction
"}}}1
" Utility Functions" {{{1
function s:GetFirstError()
  if getqflist() == []
    return ''
  endif

  for error in getqflist()
    if error['valid']
      break
    endif
  endfor
  if ! error['valid']
    return ''
  endif
  let error_message = substitute(error['text'], '^ *', '', 'g')
  let error_message = substitute(error_message, "\n", ' ', 'g')
  let error_message = substitute(error_message, "  *", ' ', 'g')
  return error_message
endfunction

function s:Bar(type, msg)
  if a:type == "red"
    echohl RedBar
  else
    echohl GreenBar
  endif
  echon a:msg repeat(" ", &columns - strlen(a:msg) - 1)
  echohl None
endfunction

" }}}1
" Mappings" {{{1

if !hasmapto('MakeGreen')
  map <unique> <silent> <Leader>. :call MakeGreen()<cr>
endif
" }}}1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set sw=2 sts=2:
