set sw=2
set ts=2
set et
set iskeyword+=!,?,=
function! s:InsertInterpolation()
  let before = getline('.')[col('^'):col('.')]
  let after  = getline('.')[col('.'):col('$')]
  " check that we're in double-quotes string
  if before =~# '"' && after =~# '"'
    execute "normal! a{}\<Esc>h"
  endif
endfunction
inoremap <silent><buffer> # #<Esc>:call <SID>InsertInterpolation()<Cr>a

" Surround with #
if exists("g:loaded_surround")
  let b:surround_{char2nr('#')} = "#{\r}"
endif
