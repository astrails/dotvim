source ~/.vim/bindings.vim

if filereadable(expand("~/.vim_local"))
  echo "~/.vim_local is deprecated, please move it to ~/.local.vim"
  source ~/.vim_local
endif

if filereadable(expand("~/.local.vim"))
  source ~/.local.vim
endif
