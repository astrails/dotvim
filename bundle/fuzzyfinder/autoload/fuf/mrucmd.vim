"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_mrucmd') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_mrucmd = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#mrucmd#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#mrucmd#getSwitchOrder()
  return g:fuf_mrucmd_switchOrder
endfunction

"
function fuf#mrucmd#renewCache()
endfunction

"
function fuf#mrucmd#requiresOnCommandPre()
  return 1
endfunction

"
function fuf#mrucmd#onInit()
  call fuf#defineLaunchCommand('FufMruCmd', s:MODE_NAME, '""')
endfunction

"
function fuf#mrucmd#onCommandPre(cmd)
  if getcmdtype() =~# '^[:/?]'
    call s:updateInfo(a:cmd)
  endif
endfunction


" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:updateInfo(cmd)
  let info = fuf#loadInfoFile(s:MODE_NAME)
  let info.data = fuf#updateMruList(
        \ info.data, { 'word' : a:cmd, 'time' : localtime() },
        \ g:fuf_mrucmd_maxItem, g:fuf_mrucmd_exclude)
  call fuf#saveInfoFile(s:MODE_NAME, info)
endfunction

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  return fuf#formatPrompt(g:fuf_mrucmd_prompt, self.partialMatching)
endfunction

"
function s:handler.getPreviewHeight()
  return 0
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForNonPath',
        \                   self.partialMatching)
endfunction

"
function s:handler.makePreviewLines(word, count)
  return []
endfunction

"
function s:handler.getCompleteItems(patternPrimary)
  return self.items
endfunction

"
function s:handler.onOpen(word, mode)
  call s:updateInfo(a:word)
  call histadd(a:word[0], a:word[1:])
  call feedkeys(a:word . "\<CR>", 'n')
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  let self.items = copy(self.info.data)
  call map(self.items, 'fuf#makeNonPathItem(v:val.word, strftime(g:fuf_timeFormat, v:val.time))')
  call fuf#mapToSetSerialIndex(self.items, 1)
  call map(self.items, 'fuf#setAbbrWithFormattedWord(v:val, 1)')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
