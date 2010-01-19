"The behaviour details:
"
"    * The window layout must be kept in all circumstances.
"    * If there is an alternate buffer must be showing that.
"    * If there is not alternate buffer then must be showing the preious buffer.
"    * If there is no alternate nor previous buffer (it is the only buffer) must show an empty buffer. 

if exists('loaded_kwbd')
  finish
endif
let loaded_kwbd = 1

if !hasmapto('<Plug>Kwbd')
  map <unique> <Leader>bd <Plug>Kwbd
endif

noremap <unique> <script> <Plug>Kwbd  :call <SID>Kwbd(1)<CR>:<BS>

"delete the buffer; keep windows
function <SID>Kwbd(kwbdStage)
  if(a:kwbdStage == 1)
    let g:kwbdBufNum = bufnr("%")
    let g:kwbdWinNum = winnr()
    let g:kwbdEmptyBuffer=0

    " count the number of buffers in the buffer list
    let g:kwbdNumBuffers=0
    for i in range(1,bufnr('$'))
      if (getbufvar(i, '&buflisted') == 1 && getbufvar(i, '&modifiable') == 1)
        let g:kwbdNumBuffers = g:kwbdNumBuffers + 1
      endif
    endfor

    " switch all windows to another buffer
    windo call <SID>Kwbd(2)

    if (getbufvar(g:kwbdBufNum, '&buflisted') == 1)
      execute "bd! " . g:kwbdBufNum . ""
    endif

    " go back to the original window
    execute "normal " . g:kwbdWinNum . "\<c-w>\<c-w>"
  else
    " This part will be run for each window
    if(bufnr("%") == g:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(g:kwbdNumBuffers <= 1 && g:kwbdEmptyBuffer != 0)
        execute "b! ".g:kwbdEmptyBuffer . ""
      elseif(g:kwbdNumBuffers <= 1 && g:kwbdEmptyBuffer == 0)
        enew!
        let g:kwbdEmptyBuffer = bufnr('%')
      elseif(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != g:kwbdBufNum)
        b! #
      else
        bp!
      endif
    endif
  endif
endfunction
