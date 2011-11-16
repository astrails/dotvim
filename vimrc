call pathogen#runtime_append_all_bundles()

source ~/.vim/global.vim
source ~/.vim/status.vim
source ~/.vim/settings.vim
source ~/.vim/plugins.vim
source ~/.vim/bindings.vim

if filereadable(expand("~/.vim_local"))
  source ~/.vim_local
endif