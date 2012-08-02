source ~/.vim/bindings.vim
source ~/.vim/after-plugins.vim

if filereadable(expand("~/.vim_local"))
  echo "~/.vim_local is deprecated, please move it to ~/.local.vim"
  source ~/.vim_local
endif

if filereadable(expand("~/.local.vim"))
  source ~/.local.vim
endif

if has('gui_running')
  if filereadable(expand("~/.local-gui.vim"))
    source ~/.local-gui.vim
  endif
end
