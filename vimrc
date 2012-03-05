source ~/.vim/vundles.vim
source ~/.vim/global.vim
source ~/.vim/settings.vim
source ~/.vim/plugins.vim

" bindings are loaded after all plugins in ./after/plugin/bindings.vim

if filereadable(expand("~/.vim_local"))
  source ~/.vim_local
endif
