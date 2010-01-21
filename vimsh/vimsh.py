#ls###############################################################################
#
# file:     vimsh.py
# purpose:  allows execution of shell commands in a vim buffer
#
# author:   brian m sturk   bsturk@adelphia.net,
#                           http://users.adelphia.net/~bsturk
# created:  12/02/01
# last_mod: 03/26/04
# version:  0.20
#
# usage, etc:   see vimsh.readme
# history:      see ChangeLog
# in the works: see TODO
#
###############################################################################

import vim, sys, os, string, signal, re, time

##  NOTE: If you're having a problem running vimsh, please
##        change the 0 to a 1 for _DEBUG_ and send me an email
##        of the output.

_DEBUG_   = 0
_BUFFERS_ = []

################################################################################

try:
    if sys.platform == 'win32':
        import popen2, stat
        use_pty   = 0

    else:
        import pty, tty, select
        use_pty   = 1

except ImportError:
    print 'vimsh: import error'

################################################################################
##                             class vimsh                                    ##
################################################################################

class vimsh:
    def __init__( self, _sh, _arg, _filename ):

        self.sh        = _sh
        self.arg       = _arg
        self.filename  = _filename

        self.prompt_line, self.prompt_cursor = self.get_vim_cursor_pos()

        self.password_regex   = [ '^\s*Password:',         ##  su, ssh, ftp
                                  'password:',             ##  ???, seen this somewhere
                                  'Password required' ]    ##  other ftp clients

        self.last_cmd_executed     = "foobar"
        self.keyboard_interrupt    = 0
        self.shell_exited          = 0
        self.buffer                = vim.current.buffer

################################################################################

    def setup_pty( self, _use_pty ):

        self.using_pty = _use_pty

        if _use_pty:

            ##  The lower this number is the more responsive some commands
            ##  may be ( printing prompt, ls ), but also the quicker others
            ##  may timeout reading their output ( ping, ftp )

            self.delay = 0.1

            ##  Hack to get pty name until I can figure out to get name
            ##  of slave pty using pty.fork() I've tried everything
            ##  including using all of the python src for pty.fork().
            ##  I'm probably trying to do something I can't do. However,
            ##  there does seem to be a std call named ptsname() which
            ##  returns the slave pty name i.e. /dev/pty/XX

            ##  Assumption is, that between the dummy call to
            ##  master_open is done and the pty.fork happens, we'll be
            ##  the next pty entry after the one from pty.master_open()
            ##  According to SysV docs it will look for the first
            ##  unused, so this shouldn't be too bad besides its looks.
            ##  Only have to make sure they're not already in use and
            ##  if it is try the next one etc.

            self.master, pty_name = pty.master_open()
            dbg_print ( 'setup_pty: slave pty name is ' + pty_name )

            self.pid, self.fd = pty.fork()

            self.outd = self.fd
            self.ind  = self.fd
            self.errd = self.fd

            signal.signal( signal.SIGCHLD, self.sigchld_handler )

            if self.pid == 0:

                ##  In spawned shell process, NOTE: any 'print'ing done within
                ##  here will corrupt vim.

                attrs = tty.tcgetattr( 1 )

                attrs[ 6 ][ tty.VMIN ]  = 1
                attrs[ 6 ][ tty.VTIME ] = 0
                attrs[ 0 ] = attrs[ 0 ] | tty.BRKINT
                attrs[ 0 ] = attrs[ 0 ] & tty.IGNBRK
                attrs[ 3 ] = attrs[ 3 ] & ~tty.ICANON & ~tty.ECHO

                tty.tcsetattr( 1, tty.TCSANOW, attrs )

                if self.arg != '':
                    os.execv( self.sh, [ self.sh, self.arg ] )

                else:
                    os.execv( self.sh, [ self.sh, ] )

            else:

                try:
                    attrs = tty.tcgetattr( 1 )

                    termios_keys = attrs[ 6 ]

                except:
                    dbg_print ( 'setup_pty: tcgetattr failed' )
                    return

                #  Get *real* key-sequence for standard input keys, i.e. EOF

                self.eof_key   = termios_keys[ tty.VEOF ]
                self.eol_key   = termios_keys[ tty.VEOL ]
                self.erase_key = termios_keys[ tty.VERASE ]
                self.intr_key  = termios_keys[ tty.VINTR ]
                self.kill_key  = termios_keys[ tty.VKILL ]
                self.susp_key  = termios_keys[ tty.VSUSP ]

        else:

            ##  Use pipes on Win32. not as reliable/nice. works OK but with limitations.

            self.delay = 0.2

            try:
                import win32pipe

                dbg_print ( 'setup_pty: using windows extensions' )
                self.stdin, self.stdout, self.stderr = win32pipe.popen3( self.sh + " " + self.arg )

            except ImportError:

                dbg_print ( 'setup_pty: not using windows extensions' )
                self.stdout, self.stdin, self.stderr = popen2.popen3( self.sh + " " + self.arg, -1, 'b' )

            self.outd = self.stdout.fileno()
            self.ind  = self.stdin.fileno ()
            self.errd = self.stderr.fileno()

            self.intr_key = ''
            self.eof_key  = ''

################################################################################

    def execute_cmd( self, _cmd = None, _null_terminate = 1 ):

        dbg_print ( 'execute_cmd: Entered cmd is ' + str( _cmd ) )

        if self.keyboard_interrupt:
            dbg_print( 'execute_cmd: keyboard interrupt earlier, cleaning up' )

            self.page_output( 1 )
            self.keyboard_interrupt = 0

            return

        ##  This is the main worker function

        try:
            print ""            ## Clears the ex command window

            cur = self.buffer
            cur_line, cur_row = self.get_vim_cursor_pos()

            if _cmd == None:

                ## Grab everything from the prompt to the current cursor position.

                _cmd    = cur[ self.prompt_line - 1 : cur_line ]        # whole line
                _cmd[0] = _cmd[0][ ( self.prompt_cursor - 1 ) : ]       # remove prompt, zero based slicing

            if re.search( r'^\s*\bclear\b', _cmd[0] ) or re.search( r'^\s*\bcls\b', _cmd[0] ):

                dbg_print ( 'execute_cmd: clear detected' )
                self.clear_screen( True )

            elif re.search( r'^\s*\exit\b', _cmd[0] ):

                dbg_print ( 'execute_cmd: exit detected' )
                self.handle_exit_cmd( _cmd )

            else:

                dbg_print ( 'execute_cmd: other command executed' )

                for c in _cmd:
                    if _null_terminate:
                        self.write( c + '\n' )

                    else:
                        self.write( c )

                self.end_exe_line()
                vim.command( "startinsert!" )

            self.last_cmd_executed = _cmd[0]

        except KeyboardInterrupt:

            dbg_print( 'execute_cmd: in keyboard interrupt exception, sending SIGINT' )

            self.keyboard_interrupt = 1

            ##  TODO: Sending Ctrl-C isn't working on Windows yet, so
            ##        executing something like 'findstr foo' will hang.

            if sys.platform != 'win32':
                self.send_intr()

################################################################################

    def end_exe_line( self ):

        ##  read anything that's on stdout after a command is executed

        dbg_print( 'end_exe_line: enter' )

        cur = self.buffer

        cur.append( "" )
        vim.command( "normal G$" )

        self.read( cur )
        self.check_for_passwd()

################################################################################

    def write( self, _cmd ):

        dbg_print( 'write: writing out --> ' + _cmd )

        os.write( self.ind, _cmd )

################################################################################

    def read( self, _buffer ):

        num_iterations       = 0      ##  counter for periodic redraw
        iters_before_redraw  = 10
        any_lines_read       = 0      ##  sentinel for reading anything at all

        if sys.platform == 'win32':
            iters_before_redraw = 1 

        while 1:
            if self.using_pty:
                r, w, e = select.select( [ self.outd ], [], [], self.delay )

            else:
                r = [1,]  ##  pipes, unused, fake it out so I don't have to special case

            for file_iter in r:

                lines = ''

                if self.using_pty:
                    lines = os.read( self.outd, 32 )

                else:
                    lines = self.pipe_read( self.outd, 2048 )

                if lines == '':
                    dbg_print( 'read: No more data on stdout pipe_read' )

                    r = []          ##  sentinel, end of data to read
                    break

                any_lines_read  = 1 
                num_iterations += 1

                lines = self.process_read( lines )
                self.print_lines( lines, _buffer )

                ##  Give vim a little cpu time, so programs that spit
                ##  output or are long operations seem more responsive

                if not num_iterations % iters_before_redraw:
                    dbg_print( 'read: Letting vim redraw' )
                    vim.command( 'call VimShRedraw()' )

            if r == []:
                dbg_print( 'read: end of data to self.read()' )
                self.end_read( any_lines_read )

                break

################################################################################

    def process_read( self, _lines ):

        dbg_print( 'process_read: Raw lines read from stdout:' )
        dbg_print( _lines )

        lines_to_print = string.split( _lines, '\n' )

        ##  On windows cmd is "echoed" and output sometimes has leading empty line

        if sys.platform == 'win32':
            m = re.search( re.escape( self.last_cmd_executed.strip() ), lines_to_print[ 0 ] )

            if m != None or lines_to_print[ 0 ] == "":
                dbg_print( 'process_read: Win32, removing leading blank line' )
                lines_to_print = lines_to_print[ 1: ]

        num_lines = len( lines_to_print )

        ##  Split on '\n' sometimes returns n + 1 entries

        if num_lines > 1:
            last_line = lines_to_print[ num_lines - 1 ].strip()

            if last_line == "":
                lines_to_print = lines_to_print[ :-1 ]

        errors = self.chk_stderr()

        if errors:
            dbg_print( 'process_read: Prepending stderr --> ' )
            lines_to_print = errors + lines_to_print

        return lines_to_print

################################################################################

    def print_lines( self, _lines, _buffer ):

        num_lines = len( _lines )

        dbg_print( 'print_lines: Number of lines to print--> ' + str( num_lines ) )

        for line_iter in _lines:

            dbg_print( 'print_lines: Current line is --> %s' % line_iter )

            m = None

            while re.search( '\r$', line_iter ):

                dbg_print( 'print_lines: removing trailing ^M' )

                line_iter = line_iter[ :-1 ]   #  Force it
                m = True

            ##  Jump to the position of the last insertion to the buffer
            ##  if it was a new line it should be 1, if it wasn't
            ##  terminated by a '\n' it should be the end of the string

            vim.command( "normal " + str( self.prompt_cursor ) + "|" )

            cur_line, cur_row = self.get_vim_cursor_pos()
            dbg_print( 'print_lines: After jumping to end of last cmd: line %d row %d' % ( cur_line, cur_row ) )

            dbg_print( 'print_lines: Pasting ' + line_iter + ' to current line' )
            _buffer[ cur_line - 1 ] += line_iter

            ##  If there's a '\n' or using pipes and it's not the last line

            if not self.using_pty or m != None:

                dbg_print( 'print_lines: Appending new line since ^M or not using pty' )
                _buffer.append( "" )

            vim.command( "normal G$" )
            vim.command( "startinsert!" )

            self.prompt_line, self.prompt_cursor = self.get_vim_cursor_pos()
            dbg_print( 'print_lines: Saving cursor location: line %d row %d ' % ( self.prompt_line, self.prompt_cursor ) )

################################################################################

    def end_read( self, any_lines_read ):

        cur_line, cur_row = self.get_vim_cursor_pos( )

        if not self.using_pty and any_lines_read:

            ##  remove last line for last read only if lines were
            ##  read from stdout.  TODO: any better way to do this?

            vim.command( 'normal dd' )

        vim.command( "normal G$" )
        vim.command( "startinsert!" )

        ##  Tuck away location, all data read is in buffer

        self.prompt_line, self.prompt_cursor = self.get_vim_cursor_pos()
        dbg_print( 'end_read: Saving cursor location: line %d row %d ' % ( self.prompt_line, self.prompt_cursor ) )

################################################################################

    def page_output( self, _add_new_line = 0 ):

        dbg_print( 'page_output: enter' )

        ##  read anything that's left on stdout

        cur = self.buffer

        if _add_new_line:

            cur.append( "" )
            vim.command( "normal G$" )

        self.read( cur )

        self.check_for_passwd()

        vim.command( "startinsert!" )

################################################################################

    def cleanup( self ):

        # NOTE: Only called via autocommand

        dbg_print( 'cleanup: enter' )

        # Remove autocommand so we don't get multiple calls

        vim.command( 'au! BufDelete ' + self.filename )

        remove_buf( self.filename )

        if self.shell_exited:
            dbg_print( 'cleanup: process is already dead, nothing to do' )
            return

        try:

            if not self.using_pty:
                os.close( self.ind )
                os.close( self.outd )

            os.close( self.errd )       ##  all the same if pty

            if self.using_pty:
                os.kill( self.pid, signal.SIGKILL )

        except:
            dbg_print( 'cleanup: Exception, process probably already killed' )

################################################################################

    def send_intr( self ):

        dbg_print( 'send_intr: enter' )

        if show_workaround_msgs == '1':
            print 'If you do NOT see a prompt in the vimsh buffer, press F5 or go into insert mode and press Enter'
            print 'If you need a new prompt press F4'
            print 'NOTE: To disable this help message set \'g:vimsh_show_workaround_msgs\' to 0 in your .vimrc'

        ##  This triggers another KeyboardInterrupt async

        try:
            dbg_print( 'send_intr: writing intr_key' )
            self.write( self.intr_key )

            self.page_output( 1 )

        except KeyboardInterrupt:

            dbg_print( 'send_intr: caught KeyboardInterrupt in send_intr' )
            pass

################################################################################

    def send_eof( self ):

        dbg_print( 'send_eof: enter' )

        try:     ## could cause shell to exit

            self.write( self.eof_key )
            self.page_output( 1 )

        except Exception, e:        

            dbg_print( 'send_eof: exception' )

            ## shell exited, self.shell_exited may not have been set yet in
            ## sigchld_handler.

            dbg_print( 'send_eof: shell_exited is ' + str( self.shell_exited ) )

            self.exit_shell()

################################################################################

    def handle_exit_cmd( self, _cmd ):

        ##  Exit was typed, could be the spawned shell, or a subprocess like
        ##  telnet/ssh/etc.

        dbg_print( 'handle_exit_cmd: enter' )

        if not self.shell_exited:           ##  process is still around

            try:    ## could cause shell to exit

                dbg_print ( 'handle_exit_cmd: shell is still around, writing exit command' )
                self.write( _cmd[0] + '\n' )

                self.end_exe_line()
                vim.command( "startinsert!" )

            except Exception, e:            

                dbg_print( 'handle_exit_cmd: exception' )

                ## shell exited, self.shell_exited may not have been set yet in
                ## sigchld_handler.

                dbg_print( 'handle_exit_cmd: shell_exited is ' + str( self.shell_exited ) )

                self.exit_shell()

################################################################################

    def exit_shell( self ):

        dbg_print( 'exit_shell: enter' )

        ##  when exiting this way can't have the autocommand
        ##  for BufDelete run.  It crashes vim.  TODO:  Figure this out.

        vim.command( 'stopinsert' )
        vim.command( 'au! BufDelete ' + self.filename )
        vim.command( 'bdelete! ' + self.filename )

        remove_buf( self.filename )

################################################################################

    def sigchld_handler( self, sig, frame ):

        dbg_print( 'sigchld_handler: caught SIGCHLD' )

        self.waitpid()

################################################################################

    def sigint_handler( self, sig, frame ):

        dbg_print( 'sigint_handler: caught SIGINT' )
        dbg_print( '' )

        self.waitpid()

################################################################################

    def waitpid( self ):

        ##  This routine cannot do anything except for marking that the original
        ##  shell process has gone away if it has.  This is due to the async
        ##  nature of signals.

        if os.waitpid( self.pid, os.WNOHANG )[0]:

            self.shell_exited = 1
            dbg_print( 'waitpid: shell exited' )

        else:

            dbg_print( 'waitpid: shell hasn\'t exited, ignoring' )

################################################################################

    def set_timeout( self ):

        timeout_ok = 0

        while not timeout_ok:

            try:
                vim.command( 'let timeout = input( "Enter new timeout in seconds (i.e. 0.1), currently set to ' + str( self.delay ) + ' :  " )' )

            except KeyboardInterrupt:
                return

            timeout = vim.eval( "timeout" )

            if timeout == "":               ##  usr cancelled dialog, break out
                timeout_ok = 1

            else:
                timeout = float( timeout )
            
                if timeout >= 0.1:
                    print '      --->   New timeout is ' + str( timeout ) + ' seconds'
                    self.delay = timeout
                    timeout_ok = 1

################################################################################

    def clear_screen( self, in_insert_mode ):

        dbg_print( 'clear_screen: insert mode is ' + str( in_insert_mode )  )

        self.write( "" + "\n" )    ##   new prompt

        if clear_all == '1':
            vim.command( "normal ggdG" )

        self.end_exe_line()

        if clear_all == '0':
            vim.command( "normal zt" )

        if in_insert_mode:
            vim.command( "startinsert!" )

        else:
            vim.command( 'stopinsert' )

################################################################################

    def new_prompt( self ):

        self.execute_cmd( [""] )        #  just press enter

        vim.command( "normal G$" )
        vim.command( "startinsert!" )

################################################################################

    def get_vim_cursor_pos( self ):

        cur_line, cur_row = vim.current.window.cursor
        
        return cur_line, cur_row + 1

################################################################################

    def check_for_passwd( self ):

        cur_line, cur_row = self.get_vim_cursor_pos()

        prev_line = self.buffer[ cur_line - 1 ]

        for regex in self.password_regex:

            if re.search( regex, prev_line ):

                try:
                    vim.command( 'let password = inputsecret( "Password? " )' )

                except KeyboardInterrupt:
                    return

                password = vim.eval( "password" )

                self.execute_cmd( [password] )       ##  recursive call here...

################################################################################

    def pipe_read( self, pipe, minimum_to_read ):

        ##  Hackaround since Windows doesn't support select() except for sockets.

        dbg_print( 'pipe_read: minimum to read is ' + str( minimum_to_read ) )
        dbg_print( 'pipe_read: sleeping for ' + str( self.delay ) + ' seconds' )

        time.sleep( self.delay )

        count = 0
        count = os.fstat( pipe )[stat.ST_SIZE]
            
        data = ''

        dbg_print( 'pipe_read: initial count via fstat is ' + str( count ) )

        while ( count > 0 ):

            tmp = os.read( pipe, 1 )
            data += tmp

            count = os.fstat( pipe )[stat.ST_SIZE]

            if len( tmp ) == 0:
                dbg_print( 'pipe_read: count ' + str( count ) + ' but nothing read' )
                break

            ##  Be sure to break the read, if asked to do so,
            ##  after we've read in a line termination.

            if minimum_to_read != 0 and len( data ) > 0 and data[ len( data ) -1 ] == '\n':

                if len( data ) >= minimum_to_read:
                    dbg_print( 'pipe_read: found termination and read at least the minimum asked for' )
                    break

                else:
                    dbg_print( 'pipe_read: not all of the data has been read: count is ' + str( count ) )

        dbg_print( 'pipe_read: returning' )

        return data

################################################################################

    def chk_stderr( self ):

        errors  = ''
        dbg_print( 'chk_stderr: enter' )

        if sys.platform == 'win32':

            err_txt  = self.pipe_read( self.errd, 0 )
            errors   = string.split( err_txt, '\n' )

            num_lines = len( errors )
            dbg_print( 'chk_stderr: Number of error lines is ' + `num_lines` )

            last_line = errors[ num_lines - 1 ].strip()

            if last_line == "":
                dbg_print( 'chk_stderr: Removing last line, it\'s empty' )
                errors = errors[ :-1 ]

        return errors

################################################################################

    #def thread_worker( self ):
 
        #self.idle = 0
        ## Not working 100% yet
        #thread.start_new_thread( self.thread_worker, () )

        #try:
            #while 1:

                #time.sleep( 5.0 )

                ## This doesn't seem to work
                ##  vim.command( 'let dummy = remote_send( v:servername, "<C-\><C-N>:python periodic( \'' + self.filename + '\' )<CR>" )' )

                ## Nor this
                #vim.command( 'let dummy = v:servername' )
                #servername = vim.eval( "dummy" )
                #os.system( 'gvim --remote-send --servername ' + servername + '"<C-\><C-N>:python periodic( ' + self.filename + ')<CR>"' )

                ## or this
                # os.system( 'gvim --remote-expr ":python periodic( \'' + self.filename + '\' )<CR>"' )

                ## This works well so far ( haven't testing thoroughly though )
                ## only problem is it changes to normal mode while the user may
                ## be typing.

                #os.system( 'gvim --remote-send "<C-\><C-N>:python periodic( \'' + self.filename + '\' )<CR>"' )

        #except:                        
            #pass

################################################################################
##                           Helper functions                                 ##
################################################################################
        
def test_and_set( vim_var, default_val ):

    ret = default_val

    vim.command( 'let dummy = exists( "' + vim_var + '" )' )
    exists = vim.eval( "dummy" )

    ##  exists will always be a string representation of the evaluation

    if exists != '0':
        ret = vim.eval( vim_var )
        dbg_print( 'test_and_set: variable ' + vim_var + ' exists, using supplied ' + ret )

    else:
        dbg_print( 'test_and_set: variable ' + vim_var + ' doesn\'t exist, using default ' + ret )

    return ret

################################################################################

def dump_str_as_hex( _str ):

    hex_str = ''

    print 'length of string is ' + str( len( _str ) )

    for x in range( 0, len( _str ) ):
        hex_str = hex_str + hex( ord( _str[x] ) ) + "\n"

    print 'raw line ( hex ) is:'
    print hex_str

################################################################################

def dbg_print( _str ):

    if _DEBUG_:
        print _str

################################################################################

def new_buf( _filename ):

    ##  If a buffer named vimsh doesn't exist create it, if it
    ##  does, switch to it.  Use the config options for splitting etc.

    filename = _filename

    try:
        vim.command( 'let dummy = buflisted( "' + filename + '" )' )
        exists = vim.eval( "dummy" )

        if exists == '0':
            dbg_print( 'new_buf: buffer ' + filename + ' doesn\'t exist' )

            if split_open == '0':
                vim.command( 'edit ' + filename )

            else:
                vim.command( 'new ' + filename )

            vim.command( 'setlocal buftype=nofile' )
            vim.command( 'setlocal bufhidden=hide' )
            vim.command( 'setlocal noswapfile' )
            vim.command( 'setlocal tabstop=4' )
            vim.command( 'setlocal modifiable' )
            vim.command( 'setlocal nowrap' )
            vim.command( 'setlocal textwidth=999' )
            vim.command( 'setfiletype vim_shell' )

            vim.command( 'au BufDelete ' + filename + ' :python lookup_buf( "' + filename + '" ).cleanup()' )

            vim.command( 'inoremap <buffer> <CR>  <ESC>:python lookup_buf( "' + filename + '" ).execute_cmd()<CR>' )

            vim.command( 'inoremap <buffer> ' + timeout_key + ' <ESC>:python lookup_buf( "' + filename + '" ).set_timeout()<CR>' )
            vim.command( 'nnoremap <buffer> ' + timeout_key + ' :python lookup_buf( "' + filename + '" ).set_timeout()<CR>' )

            vim.command( 'inoremap <buffer> ' + new_prompt_key + ' <ESC>:python lookup_buf ( "' + filename + '" ).new_prompt()<CR>' )
            vim.command( 'nnoremap <buffer> ' + new_prompt_key + ' :python lookup_buf( "' + filename + '" ).new_prompt()<CR>' )

            vim.command( 'inoremap <buffer> ' + page_output_key + ' <ESC>:python lookup_buf ( "' + filename + '" ).page_output()<CR>' )
            vim.command( 'nnoremap <buffer> ' + page_output_key + ' :python lookup_buf( "' + filename + '" ).page_output()<CR>' )

            vim.command( 'inoremap <buffer> ' + eof_signal_key + ' <ESC>:python lookup_buf ( "' + filename + '" ).send_eof()<CR>' )
            vim.command( 'nnoremap <buffer> ' + eof_signal_key + ' :python lookup_buf( "' + filename + '" ).send_eof()<CR>' )

            vim.command( 'inoremap <buffer> ' + intr_signal_key + ' <ESC>:python lookup_buf ( "' + filename + '" ).send_intr()<CR>' )
            vim.command( 'nnoremap <buffer> ' + intr_signal_key + ' :python lookup_buf( "' + filename + '" ).send_intr()<CR>' )

            vim.command( 'inoremap <buffer> ' + clear_key + ' <ESC>:python lookup_buf ( "' + filename + '" ).clear_screen( True )<CR>')
            vim.command( 'nnoremap <buffer> ' + clear_key + ' :python lookup_buf( "' + filename + '").clear_screen( False )<CR>' )

            return 0

        else:

            dbg_print( 'new_buf: file ' + filename + ' exists' )

            vim.command( "edit " + filename )
            return 1

    except:
        dbg_print( 'new_buf: exception!' + str( sys.exc_info()[0] ) )

################################################################################

def spawn_buf( _filename ):

    exists = new_buf( _filename )

    if not exists:

        dbg_print( 'spawn_buf: buffer doesn\'t exist so creating a new one' )
        
        cur = vim.current.buffer

        ## Make vimsh associate buffer with _filename and add to list of buffers
        vim_shell = vimsh( sh, arg, _filename )

        _BUFFERS_.append( ( _filename, vim_shell ) )
        vim_shell.setup_pty( use_pty )

        vim_shell.read( cur )
        cur_line, cur_row = vim_shell.get_vim_cursor_pos()

        ##  last line *should* be prompt, tuck it away for syntax hilighting
        hi_prompt = cur[ cur_line - 1 ]

    else:

        dbg_print( 'main: buffer does exist' )
        vim.command( "normal G$" )
        vim_shell = lookup_buf( _filename )

    vim.command( "startinsert!" ) 

################################################################################

def periodic( _filename ):

    print( 'periodic: enter for ' + _filename )
    print( 'testing' )

    if not use_pty:
        return

    vim_shell = lookup_buf( _filename )

    if vim_shell == None:
        dbg_print( 'periodic: couldn\'t find buffer' )
        return

    if vim_shell.idle:

        try:
            r, w, e = select.select( [ vim_shell.outd ], [], [], 0.1 )

            if r == []:
                return

            dbg_print( 'periodic: new data to read on pty' )

            vim_shell.page_output()

        except:
            pass

################################################################################

def lookup_buf( _filename ):

    for key, val in _BUFFERS_:

        if key == _filename:

            dbg_print( 'lookup_buf: found match ' + str( val ) )
            return val

    dbg_print( 'lookup_buf: couldn\'t find match for ' + _filename )

    return None

################################################################################

def remove_buf( _filename ):

    dbg_print ( 'remove_buf: looking for ' + _filename + ' to remove from buffer list' )

    idx = 0

    for key, val in _BUFFERS_:

        if key == _filename:
            break

        idx = idx + 1

    if ( len( _BUFFERS_ ) >= idx ) & ( len( _BUFFERS_ ) != 0 ):

        dbg_print ( 'remove_buf: removing buffer from list' )
        del _BUFFERS_[ idx ]

############################# customization ###################################
#
#  Don't edit the lines below, instead set the g:<variable> in your
#  .vimrc to the value you would like to use.  For numeric settings
#  *DO NOT* put quotes around them.  The quotes are only needed in
#  this script.  See vimsh.readme for more details
#
###############################################################################

##  Allow pty prompt override, useful if you have an ansi prompt, etc
#

prompt_override = int( test_and_set( "g:vimsh_pty_prompt_override", "1" ) )

##  Prompt override, used for pty enabled.  Just use a very simple prompt
##  and make no definitive assumption about the shell being used if
##  vimsh_prompt_pty is not set.  This will only be used if
##  vimsh_pty_prompt_override (above) is 1.
##
##  NOTE: [t]csh doesn't use an environment variable for setting the prompt so setting 
##        an override prompt will not work.
#

if use_pty:
    if prompt_override:
        new_prompt = test_and_set( 'g:vimsh_prompt_pty', r'> ' )

        os.environ['prompt'] = new_prompt
        os.environ['PROMPT'] = new_prompt
        os.environ['PS1']    = new_prompt

## shell program and supplemental arg to shell.  If no supplemental
## arg, just use ''
#

if sys.platform == 'win32':
    sh  = test_and_set( 'g:vimsh_sh',     'cmd.exe' )       # NT/Win2k
    arg = test_and_set( 'g:vimsh_sh_arg', '-i' )            

else:    
    sh  = test_and_set( 'g:vimsh_sh',     '/bin/sh' )       # Unix
    arg = test_and_set( 'g:vimsh_sh_arg', '-i' )

## clear shell command behavior
# 0 just scroll for empty screen
# 1 delete contents of buffer
#

clear_all  = test_and_set( "g:vimsh_clear_all", "0" )
                                
## new vimsh window behavior
# 0 use current buffer if not modified
# 1 always split
#

split_open = test_and_set( "g:vimsh_split_open", "1" )

## show helpful (hopefully) messages, mostly for issues that aren't resolved but
## have workarounds
# 0 don't show them, you know what your doing
# 1 show them
#

show_workaround_msgs = test_and_set( "g:vimsh_show_workaround_msgs", "1" )

##  Prompts for the timeouts for read( s )
#
#      set low for local usage, higher for network apps over slower link
#      0.1 sec is the lowest setting
#      over a slow link ( 28.8 ) 1+ seconds works well
#

timeout_key = test_and_set( "g:vimsh_timeout_key", "<F3>" )

##  Create a new prompt at the bottom of the buffer, useful if stuck.
##  Please try to give me a bug report of how you got stuck if possible.

new_prompt_key = test_and_set( "g:vimsh_new_prompt_key", "<F4>" )

##  If output just stops, could be because of short timeouts, allow a key
##  to attempt to read more, rather than sending the <CR> which keeps
##  spitting out prompts.

page_output_key = test_and_set( "g:vimsh_page_output_key", "<F5>" )

##  Send a process SIGINT (INTR) (usually control-C)

intr_signal_key = test_and_set( "g:vimsh_intr_key", "<C-c>" )

##  Send a process EOF (usually control-D) python needs it to
##  quit interactive shell.

eof_signal_key = test_and_set( "g:vimsh_eof_key", "<C-d>" )

##  Clear screen

clear_key = test_and_set( "g:vimsh_clear_key", "<C-l>" )

############################ end customization #################################
