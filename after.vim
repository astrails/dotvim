" This file is loaded from after/plugin/after.vim
" which means it loads AFTER the rest of the plugins

source ~/.vim/bindings.vim
source ~/.vim/plugins-override.vim

if filereadable(expand("~/.local-after.vim"))
  echo "~/.local-after.vim is deprecated, please move it to ~/.vimrc.after"
  source ~/.local-after.vim
endif

if filereadable(expand("~/.vimrc.after"))
  source ~/.vimrc.after
endif

if has('gui_running')
  if filereadable(expand("~/.local-gui.vim"))
    echo "~/.local-gui.vim is deprecated, please move it to ~/.gvimrc.after"
    source ~/.local-gui.vim
  endif

  if filereadable(expand("~/.gvimrc.after"))
    source ~/.gvimrc.after
  endif
end
