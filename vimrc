call pathogen#runtime_append_all_bundles()

source ~/.vim/global.vim
source ~/.vim/status.vim
source ~/.vim/settings.vim
source ~/.vim/plugins.vim
" bindings are loaded after all plugins are loaded in ./after/plugin/bindings.vim

if filereadable(expand("~/.vim_local"))
  source ~/.vim_local
endif