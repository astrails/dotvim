" after/plugin/after.vim can get called multiple times when new bundles are
" installed. we want to only call our scripts once
if (exists("g:after_vim_loaded") && g:after_vim_loaded) || &cp
  finish
endif
let g:after_vim_loaded = 1
source ~/.vim/after.vim
