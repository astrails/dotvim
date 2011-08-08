" old status line
" set statusline+=%<%1*%f%*\ %h%m%r%#warningmsg#%{SyntasticStatuslineFlag()}%*%=%-14.(%l,%c%V%)\ %P

set statusline =
set statusline+=%<      " truncate starts here
"set statusline+=%1*%f%* " filename with custom color
set statusline+=%f      " filename
set statusline+=        "                      " 
set statusline+=%h      " help buffer flag
set statusline+=%m      " modified flag
set statusline+=%r      " read only flag
set statusline+=%#warningmsg#%{SyntasticStatuslineFlag()}%* " syntax warnings
set statusline+=%=%-14.(%l,%c%V%)\ %P

" highlihgt status line file name
"hi User1 term=bold,reverse cterm=bold ctermfg=4 ctermbg=2 gui=bold guifg=Blue guibg=#44aa00
