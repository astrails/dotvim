" This file is loaded from after/plugin/after.vim
" which means it loads AFTER the rest of the plugins

source ~/.vim/bindings.vim
source ~/.vim/plugins-override.vim

if filereadable(expand("~/.vim_local"))
  echo "~/.vim_local is deprecated, please move it to ~/.local.vim"
  source ~/.vim_local
endif

if filereadable(expand("~/.local.vim"))
  echo "~/.local.vim is deprecated, please move it to ~/.local-after.vim or ~/.local-before.vim depending on the content.\nSee 'Local Configuration' section in the README.\n\n"
  source ~/.local.vim
endif

if filereadable(expand("~/.local-after.vim"))
  source ~/.local-after.vim
endif

if has('gui_running')
  if filereadable(expand("~/.local-gui.vim"))
    source ~/.local-gui.vim
  endif
end
