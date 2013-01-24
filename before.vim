" this file is loaded BEFORE plugins
if filereadable(expand("~/.local-before.vim"))
  echo "~/.local-before.vim is deprecated, please move it to ~/.vimrc.before"
  source ~/.local-before.vim
endif

if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

if has('gui_running')
  if filereadable(expand("~/.gvimrc.before"))
    source ~/.gvimrc.before
  endif
endif
