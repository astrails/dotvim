" showmarks
let g:showmarks_enable = 0 " disabled by default by populardemand ;)
hi! link ShowMarksHLl LineNr
hi! link ShowMarksHLu LineNr
hi! link ShowMarksHLo LineNr
hi! link ShowMarksHLm LineNr

" syntastic
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

" delimitMate
let g:delimitMate_expand_space = 1
let g:delimitMate_expand_cr = 1

" nerdtree
" Ctrl-P to Display the file browser tree
nmap <C-P> :NERDTreeToggle<CR>
" ,p to show current file in the tree
nmap <leader>p :NERDTreeFind<CR>

" nerdcommenter
" ,/ to invert comment on the current line/selection
nmap <leader>/ :call NERDComment(0, "invert")<cr>
vmap <leader>/ :call NERDComment(0, "invert")<cr>

" ,t to show tags window
let Tlist_Show_Menu=1
nmap <leader>t :TlistToggle<CR>

" sessionman
nmap <leader>S :SessionList<CR>
nmap <leader>SS :SessionSave<CR>
nmap <leader>SA :SessionSaveAs<CR>

" minibufexpl
let g:miniBufExplVSplit = 25
let g:miniBufExplorerMoreThanOne = 100
let g:miniBufExplUseSingleClick = 1
" ,b to display current buffers list
nmap <Leader>b :MiniBufExplorer<cr>

let g:Conque_Read_Timeout = 50 " timeout for waiting for command output.
let g:Conque_TERM = 'xterm'
" ,sh shell window
nmap <Leader>sh :ConqueSplit bash<cr>
" ,r run command
nmap <Leader>R :ConqueSplit

" yankring
let g:yankring_replace_n_pkey = '<leader>['
let g:yankring_replace_n_nkey = '<leader>]'
" ,y to show the yankring
nmap <leader>y :YRShow<cr>

" rails
" completing Rails hangs a lot
"let g:rubycomplete_rails = 1

" command-t
"nmap <unique> <silent> <Leader>, :CommandT<CR>
"nmap <unique> <silent> <Leader>. :CommandTFlush<CR>:CommandT<CR>
"let g:CommandTMatchWindowAtTop=1

let g:ctrlp_map = '<leader>,'
let g:ctrlp_cmd = 'CtrlPMixed'

nmap <leader>. :CtrlPClearCache<cr>:CtrlP<cr>
nmap <leader>m :CtrlPBufTag<cr>
nmap <leader>M :CtrlPBufTagAll<cr>

" fine grain mappings for rails directories
map <leader>gf :CtrlPClearCache<cr>:CtrlP %%<cr>
map <leader>gv :CtrlPClearCache<cr>:CtrlP app/views<cr>
map <leader>gc :CtrlPClearCache<cr>:CtrlP app/controllers<cr>
map <leader>gm :CtrlPClearCache<cr>:CtrlP app/models<cr>
map <leader>gh :CtrlPClearCache<cr>:CtrlP app/helpers<cr>
map <leader>gl :CtrlPClearCache<cr>:CtrlP lib<cr>
map <leader>ga :CtrlPClearCache<cr>:CtrlP app/assets<cr>
map <leader>gs :CtrlPClearCache<cr>:CtrlP app/assets/stylesheets<cr>
map <leader>gj :CtrlPClearCache<cr>:CtrlP app/assets/javascripts<cr>

map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

let g:ctrlp_clear_cache_on_exit = 1
" ctrlp leaves stale caches behind if there is another vim process runnin
" which didn't use ctrlp. so we clear all caches on each new vim invocation
cal ctrlp#clra()

let g:ctrlp_max_height = 40

" show on top
"let g:ctrlp_match_window_bottom = 0
"let g:ctrlp_match_window_reversed = 0

" jump to buffer in the same tab if already open
let g:ctrlp_switch_buffer = 1

" if in git repo - use git file listing command, should be faster
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']

" open multiple files with <c-z> to mark and <c-o> to open. v - opening in
" vertical splits; j - jump to first open buffer; r - open first in current buffer
let g:ctrlp_open_multiple_files = 'vjr'

let g:ctrlp_extensions = ['tag', 'buffertag', 'quickfix', 'mixed']

" Fugitive
" ,g for Ggrep
nmap <leader>g :silent Ggrep<space>

" ,f for global git serach for word under the cursor (with highlight)
nmap <leader>f :let @/="\\<<C-R><C-W>\\>"<CR>:set hls<CR>:silent Ggrep -w "<C-R><C-W>"<CR>:ccl<CR>:cw<CR><CR>

" same in visual mode
:vmap <leader>f y:let @/=escape(@", '\\[]$^*.')<CR>:set hls<CR>:silent Ggrep -F "<C-R>=escape(@", '\\"#')<CR>"<CR>:ccl<CR>:cw<CR><CR>
" Ack
" ,a for Ack
nmap <leader>k :Ack<space>

" vim-indentobject
" add Markdown to the list of indentation based languages
let g:indentobject_meaningful_indentation = ["haml", "sass", "python", "yaml", "markdown"]

" indent-guides
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 5

" VimClojure
let g:vimclojure#ParenRainbow = 1
let g:vimclojure#DynamicHighlighting = 1

" Utl.vim
if has("mac")
  let g:utl_cfg_hdl_scm_http_system = "!open '%u'"
end
nmap <leader>o :Utl

" VimOrganizer
au! BufRead,BufWrite,BufWritePost,BufNewFile *.org
au BufEnter *.org call org#SetOrgFileType()

" Gundo
nmap <leader>u :GundoToggle<CR>
let g:gundo_close_on_revert = 1
