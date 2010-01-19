" Vim global plugin for drill-down search of a ctags file
" Last change: 20080217
" Version: 1.1.3
" Author: Basil Shkara <basil at oiledmachine dot com>
" License: This file is placed in the public domain
" 
" DrillCtg allows drill-down search by character across the pathnames in your current loaded ctags file.
" Upon first launching DrillCtg, if a ctags file is currently set, it will parse it and create a Vim list
" (an array).  This is a sorted array which contains all unique pathnames, able to searched quickly using
" Vim's match() function.
" 
" If a ctags file is not currently set upon launching DrillCtg, it will prompt you for the location of one.
" 
" If you set a different ctags file, upon the next call to DrillCtg, it will replace the contents of the old
" array with the new pathnames.
" 
" Currently this plugin only supports 1 loaded ctags file at a time.
" 
" Please direct all feature requests and bug reports to my email above.
" 
" Installation:
" -------------
" 1. Drop the plugin file (drillctg.vim) into your plugins directory.
" 2. Restart Vim to load DrillCtg.
" 3. To open the search box you can use the ":Drill" command.
" 4. To close the search box hit <Esc> and then :q.
" 
" Info on ctags file:
" -------------------
" Your generated ctags file may not contain all the files from your project as some files may be unsupported types.
" E.g. If you are generating a ctags file on a PHP project which also contains XML files, the XML files will not be
" appended to the ctags file.  So when you are searching for a filename across your ctags file using DrillCtg,
" you will not have access to these other files.
" You can solve this issue easily by appending these files manually yourself using something like:
" $ find project_dir -name '*.xml' >> ctags_file
" Vim will not use the extra pathname information but DrillCtg will.
" 
" Credits:
" --------
" The function OnCursorMovedI was adapted from Takeshi Nishida's fuzzyfinder.vim  script (script_id=1984).
" 
" Version History:
" ----------------
"  v1.1.3	Now checks if existing tag file is readable before prompting for new tags file.
"  v1.1.2	Added autocommand to clean up after unloading buffer.
"			Now uses new tab rather than new buffer to clean up ctags file resulting in cleaner exit.
"  v1.1.1	Fixed quitting bug.  Now you must quit the window with :q.
"			Added support for Takeshi Nishida's autocomplpop.vim.
"			Plugin now cleans up after itself.
"  v1.1		Added support for user-defined completion.


" check for Vim 7
if version < 700
	echo "\nDrillCtg requires Vim 7.0"
	echo "You currently have version: ".version
	echo "DrillCtg will not be active this session\n"
    finish
endif

"if plugin already loaded
if exists("loaded_drillctg")
	finish
endif
let loaded_drillctg = 1

"create ex command for toggling drill window
command! -nargs=0 -bar Drill call s:ToggleDrill()

function s:ToggleDrill()
    "if window is open then close it.
    let a:winnum = bufwinnr("DrillCtg")
    if a:winnum != -1
        execute "bd!".bufnr("DrillCtg")
		call s:CleanUp()
        return
    endif

	"open window
	call s:LoadList()

	let s:already_cleaned_up = 0
	"modify vim settings
	let s:save_cp = &cp
	let s:save_completeopt = &completeopt
	let s:save_ignorecase = &ignorecase
	let s:save_nu = &nu
	set nocp
	set completeopt=menuone
	set ignorecase
	set nonu
endfunction

function s:CleanUp()
	if s:already_cleaned_up == 0
		"restore vim settings
		let &cp = s:save_cp
		let &completeopt = s:save_completeopt
		let &ignorecase = s:save_ignorecase
		let &nu = s:save_nu
		unlet s:save_cp
		unlet s:save_completeopt
		unlet s:save_ignorecase
		unlet s:save_nu
		" comment out to keep tag list in memory for faster access
		" however Vim's memory usage skyrockets depending on how large your ctags file is
		unlet s:tag_list

		" resume autocomplpop.vim
		if exists(':AutoComplPopUnlock')
			:AutoComplPopUnlock
		endif

		let s:already_cleaned_up = 1
	endif
endfunction

function s:LoadList()
	"create list and open split if tags file exists
	"nb this will of course fail if more than 1 tags file is specified
	if (filereadable(&tags))
		if (!exists("s:tag_list") || s:loaded_tagname != &tags)
			"load tags file
			execute "tabnew ".&tags
	        set buftype=nofile 
	        set bufhidden=hide 
	        setlocal noswapfile 

			"remove tag_name<TAB>
			silent %s/^\w*\t//g
			"remove <TAB>ex_cmd<TAB>extension_fields
			silent %s/\s.*//g
			"remove any other junk
			silent %s/!_.*//g
			"sort the list alphabetically
			sort
			"remove blank lines
			silent %s/^[\ \t]*\n//g
			"remove duplicates 
			silent %s/^\(.*\)\(\n\1\)\+$/\1/
		
			"insert each line into list for indexing and searching
			let s:tag_list = getline("^", "$")
			"don't need buffer anymore
			bd!
			
			let s:loaded_tagname = &tags
			
			"show drill box
			call s:OpenDrillWindow()
		else
			"show drill box
			call s:OpenDrillWindow()
		endif		
	elseif !exists("s:tag_list")
		let s:choice = inputlist(['You have not yet loaded a ctags file.  Choose an option:', '1. Specify ctags file to load', '2. Cancel'])
		if s:choice == 1
			let s:userspec_tags = input("\nPlease enter the path of your ctags file: ", "", "file")
			execute ":set tags=".s:userspec_tags
			echo "\n".&tags." loaded"
			silent call s:LoadList()
		endif
	endif
endfunction

function s:OpenDrillWindow()
	1split DrillCtg
	setlocal bufhidden=wipe
	setlocal buftype=nofile
	setlocal noswapfile
	setlocal nobuflisted
	setlocal modifiable

	" suspend autocomplpop.vim
	if exists(':AutoComplPopLock')
		:AutoComplPopLock
	endif

    let s:lastInputLength = -1
	" mapping for selecting an entry in the popup menu
	inoremap <buffer><silent> <CR> <C-Y><C-C><C-W>gf :execute "bd!".bufnr("DrillCtg")<CR> :call <SID>CleanUp()<CR>
	" mapping for hitting backspace and then activating user-defined completion
	inoremap <buffer><silent> <BS> <C-E><BS><C-X><C-U>

	autocmd CursorMovedI <buffer> call <SID>OnCursorMovedI()
	autocmd BufUnload <buffer> call <SID>CleanUp()

    call feedkeys('i', 'n')

endfunction

function! s:OnCursorMovedI()
    let deltaInputLength  = strlen(getline('.')) - s:lastInputLength
    let s:lastInputLength = strlen(getline('.'))

    "if the line was changed and cursor is placed on the end of the line
    if deltaInputLength != 0 && col('.') > s:lastInputLength
        call feedkeys("\<C-X>\<C-U>", 'n')
    endif
endfunction

function! CompletePath(findstart, base)
	if a:findstart
		" locate the start of the word
		let line = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\S'
			let start -= 1
		endwhile
		return start
	else
		" find pathnames matching with "a:base"
		let res = []
		for m in s:tag_list
			let s:match_results = match(m, a:base)
			if (s:match_results > 0)
				let s:results = [a:base, m]
				call extend(res, s:results)
			endif
		endfor
		return res
	endif
endfunction
set completefunc=CompletePath
