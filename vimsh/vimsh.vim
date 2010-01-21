" file:     vimsh.vim
" purpose:  support file for vimsh, when sourced starts a vimsh buffer
"
" author:   brian m sturk   bsturk@adelphia.net,
"                           http://users.adelphia.net/~bsturk
" created:  12/20/01
" last_mod: 01/31/04
" version:  see vimsh.py
"
" usage:    :so[urce] vimsh.vim

function! VimShRedraw()
    redraw
endfunction

"  Use ':VimshNewBuf name' to open a new buffer '_name_'
command! -nargs=1 VimShNewBuf python spawn_buf( "_<args>_" )

" Only load vimsh.py once (don't reset variables)
if !exists("g:vimsh_loaded_python_file")
    pyfile <sfile>:p:h/vimsh.py
    let g:vimsh_loaded_python_file=1
endif

VimShNewBuf vimsh

"function! VimShReadUpdate()

    "  This function is a workaround until I can find
    "  a way to periodically check for more output
    "  for commands that continuously output until
    "  interrupted ( ping ) or slow ones ( ftp ).
    "  An ideal solution would be to have a function
    "  registered to be called when vim is 'idle'.
    "
    "  I've tried all kinds of solutions:
    "
    "       Threading
    "
    "  Most of the time I see this:
    "
    "   %$ Xlib: unexpected async reply (sequence 0x33d5)!
    "   Gdk-ERROR **: X connection to :0.0 broken (explicit kill or server shutdown).
    "
    "       Autocommands
    "           
    "           CursorHold doesn't work
    "           And defining a User one causes a stack-overflow
    "           in the regex engine, plus it's still a different
    "           thread trying to write and it causes above behavior.
    "
    "       SIGALRM
    "
    "           Works, but alarm is only 'realized' when executing
    "           python code, so until the user does something, like
    "           execute a command, we never see the signal.
    "
    "
    "  So this works and stays until I can
    "  do one of the above and have it work or some
    "  idle processing can be done.  The python script current
    "  does create another thread to check for more data to
    "  read but it *DOES NOT* write to the buffer, this causes
    "  all sorts of problems.  What happens is, if the conditions
    "  are right to check and there's more data to read this
    "  function is invoked via that thread using the client/
    "  server ability of vim.  It's a total hack, but it does
    "  work.
    "
    "  Being able to use this hackjob workaround depends
    "  on a few things being present.
    "  
    "  If I've read the docs right all that client/server stuff
    "  goes through the X server, so this will not work
    "  in pure console mode.  We also need to be compiled
    "  with client/server support...

    "if has( "gui_running" ) && has( "clientserver" )

    "python vim_shell.page_output( 0 )
    "
    " Unfortunately this doesn't work well enough either, I still get
    " the async errors mentioned above and other nasty side effects
    " happen.  So I guess for now, <F5> it is to see more output.

"endfunction
