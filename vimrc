" content of this file is loaded BEFORE all the plugins
source ~/.vim/bundles.vim  " vundle plugins list
source ~/.vim/global.vim   " general global configuration
source ~/.vim/plugins.vim  " configuration for plugins that needs to be set BEFORE plugins are loaded
source ~/.vim/macros.vim   " some macros
if has('gui_running')
  source ~/.vim/gvimrc     " gui specific settings
end
let g:formatprg_args_expr_javascript = '"-".(&expandtab ? "s ".&shiftwidth : "t").(&textwidth ? " -w ".&textwidth : "")." -"'
source ~/.vim/before.vim   " local BEFORE configs
source ~/.vim/.vimrc.after
" after.vim is loaded from ./after/plugin/after.vim
" which should place it AFTER all the other plugins in the loading order
" bindings.vim and local.vim are loaded from after.vim
" let g:lightline = {
       \ 'component_function': {
             \   'filetype': 'MyFiletype',
                   \ }
                         \ }

                         function! MyFiletype()
                           return winwidth(0) > 70 ? (strlen(&filetype) ?
                           &filetype . ' ' . WebDevIconsGetFileTypeSymbol() :
                           'no ft') : ''
                           endfunction)))
