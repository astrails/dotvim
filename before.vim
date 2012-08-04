" this file is loaded BEFORE plugins
if filereadable(expand("~/.local-before.vim"))
  source ~/.local-before.vim
endif
