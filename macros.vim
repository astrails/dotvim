" This file contains some mactos that I find useful.
" I recommend editing yoru macros in a vim buffer. to load a macro to a
" register you can 'yank' to it. for example if you have a line with the macro
" and cursor is at the beginning of it "ay$  will load the macro into register
" 'a', so that you will be able to execute it with @a

" 's' enclose selection in double * (bold in markdown)
let @s="S*gvS*"

" 'q' format paragraph
let @q="V}kQ"
