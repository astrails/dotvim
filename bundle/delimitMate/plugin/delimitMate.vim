" ============================================================================
" File:        plugin/delimitMate.vim
" Version:     2.4.1
" Modified:    2010-07-31
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".

" Initialization: {{{

if exists("g:loaded_delimitMate") || &cp
	" User doesn't want this plugin or compatible is set, let's get out!
	finish
endif
let g:loaded_delimitMate = 1

if exists("s:loaded_delimitMate") && !exists("g:delimitMate_testing")
	" Don't define the functions if they already exist: just do the work
	" (unless we are testing):
	call s:DelimitMateDo()
	finish
endif

if v:version < 700
	echoerr "delimitMate: this plugin requires vim >= 7!"
	finish
endif

let s:loaded_delimitMate = 1
let delimitMate_version = "2.4.1"

function! s:option_init(name, default) "{{{
	let b = exists("b:delimitMate_" . a:name)
	let g = exists("g:delimitMate_" . a:name)
	let prefix = "_l_delimitMate_"

	if !b && !g
		let sufix = a:default
	elseif !b && g
		exec "let sufix = g:delimitMate_" . a:name
	else
		exec "let sufix = b:delimitMate_" . a:name
	endif
	if exists("b:" . prefix . a:name)
		exec "unlockvar! b:" . prefix . a:name
	endif
	exec "let b:" . prefix . a:name . " = " . string(sufix)
	exec "lockvar! b:" . prefix . a:name
endfunction "}}}

function! s:init() "{{{
" Initialize variables:

	" autoclose
	call s:option_init("autoclose", 1)

	" matchpairs
	call s:option_init("matchpairs", string(&matchpairs)[1:-2])
	call s:option_init("matchpairs_list", split(b:_l_delimitMate_matchpairs, ','))
	call s:option_init("left_delims", split(b:_l_delimitMate_matchpairs, ':.,\='))
	call s:option_init("right_delims", split(b:_l_delimitMate_matchpairs, ',\=.:'))

	" quotes
	call s:option_init("quotes", "\" ' `")
	call s:option_init("quotes_list", split(b:_l_delimitMate_quotes))

	" nesting_quotes
	call s:option_init("nesting_quotes", [])

	" excluded_regions
	call s:option_init("excluded_regions", "Comment")
	call s:option_init("excluded_regions_list", split(b:_l_delimitMate_excluded_regions, ',\s*'))
	let enabled = len(b:_l_delimitMate_excluded_regions_list) > 0
	call s:option_init("excluded_regions_enabled", enabled)

	" visual_leader
	let leader = exists('b:maplocalleader') ? b:maplocalleader :
					\ exists('g:mapleader') ? g:mapleader : "\\"
	call s:option_init("visual_leader", leader)

	" expand_space
	if exists("b:delimitMate_expand_space") && type(b:delimitMate_expand_space) == type("")
		echom "b:delimitMate_expand_space is '".b:delimitMate_expand_space."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_space' for more details."
		unlet b:delimitMate_expand_space
		let b:delimitMate_expand_space = 1
	endif
	if exists("g:delimitMate_expand_space") && type(g:delimitMate_expand_space) == type("")
		echom "delimitMate_expand_space is '".g:delimitMate_expand_space."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_space' for more details."
		unlet g:delimitMate_expand_space
		let g:delimitMate_expand_space = 1
	endif
	call s:option_init("expand_space", 0)

	" expand_cr
	if exists("b:delimitMate_expand_cr") && type(b:delimitMate_expand_cr) == type("")
		echom "b:delimitMate_expand_cr is '".b:delimitMate_expand_cr."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_cr' for more details."
		unlet b:delimitMate_expand_cr
		let b:delimitMate_expand_cr = 1
	endif
	if exists("g:delimitMate_expand_cr") && type(g:delimitMate_expand_cr) == type("")
		echom "delimitMate_expand_cr is '".g:delimitMate_expand_cr."' but it must be either 1 or 0!"
		echom "Read :help 'delimitMate_expand_cr' for more details."
		unlet g:delimitMate_expand_cr
		let g:delimitMate_expand_cr = 1
	endif
	if (&backspace !~ 'eol' || &backspace !~ 'start') &&
				\ ((exists('b:delimitMate_expand_cr') && b:delimitMate_expand_cr == 1) ||
				\ (exists('g:delimitMate_expand_cr') && g:delimitMate_expand_cr == 1))
		echom "delimitMate: In order to use the <CR> expansion, you need to have 'eol' and 'start' in your backspace option. Read :help 'backspace'."
		let b:delimitMate_expand_cr = 0
	endif
	call s:option_init("expand_cr", 0)

	" smart_quotes
	call s:option_init("smart_quotes", 1)

	" apostrophes
	call s:option_init("apostrophes", "")
	call s:option_init("apostrophes_list", split(b:_l_delimitMate_apostrophes, ":\s*"))

	" tab2exit
	call s:option_init("tab2exit", 1)

	" balance_matchpairs
	call s:option_init("balance_matchpairs", 0)

	let b:_l_delimitMate_buffer = []

	let b:loaded_delimitMate = 1

endfunction "}}} Init()

function! s:Map() "{{{
	" Set mappings:
	try
		let save_cpo = &cpo
		let save_keymap = &keymap
		let save_iminsert = &iminsert
		let save_imsearch = &imsearch
		set keymap=
		set cpo&vim
		if b:_l_delimitMate_autoclose
			call s:AutoClose()
		else
			call s:NoAutoClose()
		endif
		call s:VisualMaps()
		call s:ExtraMappings()
	finally
		let &cpo = save_cpo
		let &keymap = save_keymap
		let &iminsert = save_iminsert
		let &imsearch = save_imsearch
	endtry

	let b:delimitMate_enabled = 1

endfunction "}}} Map()
"}}}

" Mappers: {{{
function! s:NoAutoClose() "{{{
	" inoremap <buffer> ) <C-R>=delimitMate#SkipDelim('\)')<CR>
	for delim in b:_l_delimitMate_right_delims + b:_l_delimitMate_quotes_list
		exec 'silent! inoremap <unique> <silent> <buffer> ' . delim . ' <C-R>=delimitMate#SkipDelim("' . escape(delim,'"\|') . '")<CR>'
	endfor
endfunction "}}}

function! s:AutoClose() "{{{
	" Add matching pair and jump to the midle:
	" inoremap <silent> <buffer> ( ()<Left>
	let i = 0
	while i < len(b:_l_delimitMate_matchpairs_list)
		let ld = b:_l_delimitMate_left_delims[i]
		let rd = b:_l_delimitMate_right_delims[i]
		exec 'silent! inoremap <unique> <silent> <buffer> ' . ld . ' ' . ld . '<C-R>=delimitMate#ParenDelim("' . rd . '")<CR>'
		let i += 1
	endwhile

	" Exit from inside the matching pair:
	for delim in b:_l_delimitMate_right_delims
		exec 'silent! inoremap <unique> <silent> <buffer> ' . delim . ' <C-R>=delimitMate#JumpOut("\' . delim . '")<CR>'
	endfor

	" Add matching quote and jump to the midle, or exit if inside a pair of matching quotes:
	" inoremap <silent> <buffer> " <C-R>=delimitMate#QuoteDelim("\"")<CR>
	for delim in b:_l_delimitMate_quotes_list
		exec 'silent! inoremap <unique> <silent> <buffer> ' . delim . ' <C-R>=delimitMate#QuoteDelim("\' . delim . '")<CR>'
	endfor

	" Try to fix the use of apostrophes (kept for backward compatibility):
	" inoremap <silent> <buffer> n't n't
	for map in b:_l_delimitMate_apostrophes_list
		exec "silent! inoremap <unique> <silent> <buffer> " . map . " " . map
	endfor
endfunction "}}}

function! s:VisualMaps() " {{{
	let VMapMsg = "delimitMate: delimitMate is disabled on blockwise visual mode."
	let vleader = b:_l_delimitMate_visual_leader
	" Wrap the selection with matching pairs, but do nothing if blockwise visual mode is active:
	for del in b:_l_delimitMate_right_delims + b:_l_delimitMate_left_delims + b:_l_delimitMate_quotes_list
		exec "silent! vnoremap <unique> <silent> <buffer> <expr> " . vleader . del . ' delimitMate#Visual("' . escape(del, '")') . '")'
	endfor
endfunction "}}}

function! s:ExtraMappings() "{{{
	" If pair is empty, delete both delimiters:
	inoremap <silent> <Plug>delimitMateBS <C-R>=delimitMate#BS()<CR>
	" If pair is empty, delete closing delimiter:
	inoremap <silent> <expr> <Plug>delimitMateSBS delimitMate#WithinEmptyPair() ? "\<C-R>=delimitMate#Del()\<CR>" : "\<S-BS>"
	" Expand return if inside an empty pair:
	inoremap <silent> <Plug>delimitMateER <C-R>=delimitMate#ExpandReturn()<CR>
	" Expand space if inside an empty pair:
	inoremap <silent> <Plug>delimitMateES <C-R>=delimitMate#ExpandSpace()<CR>
	" Jump out ot any empty pair:
	inoremap <silent> <Plug>delimitMateSTab <C-R>=delimitMate#JumpAny("\<S-Tab>")<CR>
	" Change char buffer on Del:
	inoremap <silent> <Plug>delimitMateDel <C-R>=delimitMate#Del()<CR>
	" Flush the char buffer on movement keystrokes or when leaving insert mode:
	for map in ['Esc', 'Left', 'Right', 'Home', 'End']
		exec 'inoremap <silent> <expr> <Plug>delimitMate'.map.' exists("delimitMate_loaded") ? "\<C-R>=delimitMate#Finish()\<CR>\<'.map.'>" : "\<'.map.'>"'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMate'.map
		endif
	endfor
	" Except when pop-up menu is active:
	for map in ['Up', 'Down', 'PageUp', 'PageDown', 'S-Down', 'S-Up']
		exec 'inoremap <silent> <expr> <Plug>delimitMate'.map.' !pumvisible() && exists("delimitMate_loaded") ? "\<C-R>=delimitMate#Finish()\<CR>\<'.map.'>" : "\<'.map.'>"'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMate'.map
		endif
	endfor
	" Avoid ambiguous mappings:
	for map in ['LeftMouse', 'RightMouse']
		exec 'inoremap <silent> <expr> <Plug>delimitMateM'.map.' exists("delimitMate_loaded") ? "<C-R>=delimitMate#Finish()<CR><'.map.'>" : "<'.map.'>"'
		if !hasmapto('<Plug>delimitMate'.map, 'i')
			exec 'silent! imap <unique> <buffer> <'.map.'> <Plug>delimitMateM'.map
		endif
	endfor

	" Map away!
	if !hasmapto('<Plug>delimitMateDel', 'i')
		silent! imap <unique> <buffer> <Del> <Plug>delimitMateDel
	endif
	if !hasmapto('<Plug>delimitMateBS','i')
		silent! imap <unique> <buffer> <BS> <Plug>delimitMateBS
	endif
	if !hasmapto('<Plug>delimitMateSBS','i')
		silent! imap <unique> <buffer> <S-BS> <Plug>delimitMateSBS
	endif
	if b:_l_delimitMate_expand_cr != 0 && !hasmapto('<Plug>delimitMateER', 'i')
		silent! imap <unique> <buffer> <CR> <Plug>delimitMateER
	endif
	if b:_l_delimitMate_expand_space != 0 && !hasmapto('<Plug>delimitMateES', 'i')
		silent! imap <unique> <buffer> <Space> <Plug>delimitMateES
	endif
	if b:_l_delimitMate_tab2exit && !hasmapto('<Plug>delimitMateSTab', 'i')
		silent! imap <unique> <buffer> <S-Tab> <Plug>delimitMateSTab
	endif
	" The following simply creates an ambiguous mapping so vim fully processes
	" the escape sequence for terminal keys, see 'ttimeout' for a rough
	" explanation, this just forces it to work
	if !has('gui_running')
		imap <silent> <C-[>OC <RIGHT>
	endif
endfunction "}}}

function! s:Unmap() " {{{
	let imaps =
				\ b:_l_delimitMate_right_delims +
				\ b:_l_delimitMate_left_delims +
				\ b:_l_delimitMate_quotes_list +
				\ b:_l_delimitMate_apostrophes_list +
				\ ['<BS>', '<S-BS>', '<Del>', '<CR>', '<Space>', '<S-Tab>', '<Esc>'] +
				\ ['<Up>', '<Down>', '<Left>', '<Right>', '<LeftMouse>', '<RightMouse>'] +
				\ ['<Home>', '<End>', '<PageUp>', '<PageDown>', '<S-Down>', '<S-Up>']

	let vmaps =
				\ b:_l_delimitMate_right_delims +
				\ b:_l_delimitMate_left_delims +
				\ b:_l_delimitMate_quotes_list

	for map in imaps
		if maparg(map, "i") =~? 'delimitMate'
			exec 'silent! iunmap <buffer> ' . map
		endif
	endfor

	if !exists("b:_l_delimitMate_visual_leader")
		let vleader = ""
	else
		let vleader = b:_l_delimitMate_visual_leader
	endif
	for map in vmaps
		if maparg(vleader . map, "v") =~? "delimitMate"
			exec 'silent! vunmap <buffer> ' . vleader . map
		endif
	endfor

	if !has('gui_running')
		silent! iunmap <C-[>OC
	endif

	let b:delimitMate_enabled = 0
endfunction " }}} s:Unmap()

"}}}


" Functions: {{{

function! s:TestMappingsDo() "{{{
	if !exists("g:delimitMate_testing")
		silent call delimitMate#TestMappings()
	else
		let temp_varsDM = [b:_l_delimitMate_expand_space, b:_l_delimitMate_expand_cr, b:_l_delimitMate_autoclose]
		for i in [0,1]
			let b:delimitMate_expand_space = i
			let b:delimitMate_expand_cr = i
			for a in [0,1]
				let b:delimitMate_autoclose = a
				call s:init()
				call s:Unmap()
				call s:Map()
				call delimitMate#TestMappings()
				normal o
			endfor
		endfor
		let b:delimitMate_expand_space = temp_varsDM[0]
		let b:delimitMate_expand_cr = temp_varsDM[1]
		let b:delimitMate_autoclose = temp_varsDM[2]
		unlet temp_varsDM
	endif
	normal gg
endfunction "}}}

function! s:DelimitMateDo(...) "{{{
	" Initialize settings:
	call s:init()

	" Check if this file type is excluded:
	if exists("g:delimitMate_excluded_ft") &&
				\ index(split(g:delimitMate_excluded_ft, ','), &filetype, 0, 1) >= 0

			" Remove any magic:
			call s:Unmap()

			" Finish here:
			return 1
	endif

	" First, remove all magic, if needed:
	if exists("b:delimitMate_enabled") && b:delimitMate_enabled == 1
		call s:Unmap()
	endif

	" Now, add magic:
	call s:Map()

	if a:0 > 0
		echo "delimitMate has been reset."
	endif
endfunction "}}}

function! s:DelimitMateSwitch() "{{{
	call s:init()
	if exists("b:delimitMate_enabled") && b:delimitMate_enabled
		call s:Unmap()
		echo "delimitMate has been disabled."
	else
		call s:Unmap()
		call s:Map()
		echo "delimitMate has been enabled."
	endif
endfunction "}}}

function! s:Flush()
	call delimitMate#FlushBuffer()
endfunction

"}}}

" Commands: {{{

call s:DelimitMateDo()

" Let me refresh without re-loading the buffer:
command! DelimitMateReload call s:DelimitMateDo(1)

" Quick test:
command! DelimitMateTest silent call s:TestMappingsDo()

" Switch On/Off:
command! DelimitMateSwitch call s:DelimitMateSwitch()
"}}}

" Autocommands: {{{

augroup delimitMate
	au!
	" Run on file type change.
	"autocmd VimEnter * autocmd FileType * call <SID>DelimitMateDo()
	autocmd FileType * call <SID>DelimitMateDo()

	" Run on new buffers.
	autocmd BufNewFile,BufRead,BufEnter *
				\ if !exists("b:loaded_delimitMate") |
				\ 	call <SID>DelimitMateDo() |
				\ endif

	" Flush the char buffer:
	autocmd InsertEnter *
				\ if exists('delimitMate_loaded') |
				\ 	call <SID>Flush() |
				\ endif
	autocmd BufEnter *
				\ if exists('delimitMate_loaded') && mode() == 'i' |
				\ 	call <SID>Flush() |
				\ endif

augroup END

"}}}

" GetLatestVimScripts: 2754 1 :AutoInstall: delimitMate.vim
" vim:foldmethod=marker:foldcolumn=4
