source ~/.vim/bundles.vim
source ~/.vim/global.vim
source ~/.vim/plugins.vim
source ~/.vim/macros.vim
if has('gui_running')
    source ~/.vim/gvimrc
end

" vimrc is loaded BEFORE the plugins
source ~/.vim/before.vim

" after.vim is loaded from ./after/plugin/after.vim
" which should place it AFTER all the other plugins in the loading order
" bindings.vim and local.vim are loaded from after.vim
