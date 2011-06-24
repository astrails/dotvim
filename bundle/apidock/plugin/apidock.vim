if has('mac')
  let g:browser = 'open '
else
  let g:browser = 'firefox -new-tab '
endif

function! OpenDoc(what)
  exec '!'.g:browser.' "http://apidock.com/'.a:what.'/search/quick?query='.expand('<cword>').'" &'
endfunction

noremap RB :call OpenDoc('ruby')<CR>
noremap RR :call OpenDoc('rails')<CR>
noremap RS :call OpenDoc('rspec')<CR>
