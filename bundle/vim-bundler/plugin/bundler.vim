" bundler.vim - Support for Ruby's Bundler
" Maintainer:   Tim Pope <http://tpo.pe/>

if exists('g:loaded_bundler') || &cp || v:version < 700
  finish
endif
let g:loaded_bundler = 1

" Utility {{{1

function! s:function(name) abort
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

function! s:sub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:shellesc(arg) abort
  if a:arg =~ '^[A-Za-z0-9_/.-]\+$'
    return a:arg
  else
    return shellescape(a:arg)
  endif
endfunction

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

function! s:shellslash(path)
  if exists('+shellslash') && !&shellslash
    return s:gsub(a:path,'\\','/')
  else
    return a:path
  endif
endfunction

function! s:completion_filter(results,A)
  let results = sort(copy(a:results))
  call filter(results,'v:val !~# "\\~$"')
  let filtered = filter(copy(results),'v:val[0:strlen(a:A)-1] ==# a:A')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'[^/:]','[&].*')
  let filtered = filter(copy(results),'v:val =~# "^".regex')
  if !empty(filtered) | return filtered | endif
  let filtered = filter(copy(results),'"/".v:val =~# "[/:]".regex')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'.','[&].*')
  let filtered = filter(copy(results),'"/".v:val =~# regex')
  return filtered
endfunction

function! s:throw(string) abort
  let v:errmsg = 'bundler: '.a:string
  throw v:errmsg
endfunction

function! s:warn(str)
  echohl WarningMsg
  echomsg a:str
  echohl None
  let v:warningmsg = a:str
endfunction

function! s:add_methods(namespace, method_names) abort
  for name in a:method_names
    let s:{a:namespace}_prototype[name] = s:function('s:'.a:namespace.'_'.name)
  endfor
endfunction

let s:commands = []
function! s:command(definition) abort
  let s:commands += [a:definition]
endfunction

function! s:define_commands()
  for command in s:commands
    exe 'command! -buffer '.command
  endfor
endfunction

augroup bundler_utility
  autocmd!
  autocmd User Bundler call s:define_commands()
augroup END

let s:abstract_prototype = {}

" }}}1
" Syntax highlighting {{{1

function! s:syntaxfile()
  syntax keyword rubyGemfileMethod gemspec gem source path git group platforms env
  hi def link rubyGemfileMethod Function
endfunction

function! s:syntaxlock()
  syn match gemfilelockHeading  '^[[:upper:]]\+$'
  syn match gemfilelockKey      '^\s\+\zs\S\+:'he=e-1 skipwhite nextgroup=gemfilelockUrl,gemfilelockRevision
  syn match gemfilelockRevision '[[:alnum:]._-]\+' contained
  syn match gemfilelockUrl      '\w\+://\S\+' contained
  syn match gemfilelockGem      '^\s\+\zs[[:alnum:]._-]\+\%([ !]\|$\)\@=' skipwhite nextgroup=gemfilelockVersions,gemfilelockBang
  syn match gemfilelockVersions '([^()]*)' contained contains=gemfilelockVersion
  syn match gemfilelockVersion  '[^,()]*' contained
  syn match gemfilelockBang     '!' contained

  hi def link gemfilelockHeading  PreProc
  hi def link gemfilelockKey      Identifier
  hi def link gemfilelockRevision Number
  hi def link gemfilelockUrl      String
  hi def link gemfilelockGem      Statement
  hi def link gemfilelockVersion  Type
  hi def link gemfilelockBang     Special
endfunction

augroup bundler_syntax
  autocmd!
  autocmd Syntax ruby if expand('<afile>:t') ==? 'gemfile' | call s:syntaxfile() | endif
  autocmd BufNewFile,BufRead [Gg]emfile.lock setf gemfilelock
  autocmd FileType gemfilelock set suffixesadd=.rb
  autocmd Syntax gemfilelock call s:syntaxlock()
augroup END

" }}}1
" Initialization {{{1

function! s:FindBundlerRoot(path) abort
  let path = s:shellslash(a:path)
  let fn = fnamemodify(path,':s?[\/]$??')
  let ofn = ""
  let nfn = fn
  while fn != ofn
    if filereadable(fn.'/Gemfile')
      return s:sub(simplify(fnamemodify(fn,':p')),'[\\/]$','')
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':h')
  endwhile
  return ''
endfunction

function! s:Detect(path)
  if !exists('b:bundler_root')
    let dir = s:FindBundlerRoot(a:path)
    if dir != ''
      let b:bundler_root = dir
    endif
  endif
  if exists('b:bundler_root')
    silent doautocmd User Bundler
  endif
endfunction

augroup bundler
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:Detect(expand('<amatch>:p'))
  autocmd FileType           netrw call s:Detect(expand('<afile>:p'))
  autocmd VimEnter * if expand('<amatch>')==''|call s:Detect(getcwd())|endif
augroup END

" }}}1
" Project {{{1

let s:project_prototype = {}
let s:projects = {}

function! s:project(...) abort
  let dir = a:0 ? a:1 : (exists('b:bundler_root') && b:bundler_root !=# '' ? b:bundler_root : s:FindBundlerRoot(expand('%:p')))
  if dir !=# ''
    if has_key(s:projects,dir)
      let project = get(s:projects,dir)
    else
      let project = {'root': dir}
      let s:projects[dir] = project
    endif
    return extend(extend(project,s:project_prototype,'keep'),s:abstract_prototype,'keep')
  endif
  call s:throw('not a Bundler project: '.expand('%:p'))
endfunction

function! s:project_path(...) dict abort
  return join([self.root]+a:000,'/')
endfunction

call s:add_methods('project',['path'])

function! s:project_gems() dict abort
  let time = getftime(self.path('Gemfile.lock'))
  if time != -1 && time != get(self,'_lock_time',-1)
    let self._gems = {}
    let output = system('ruby -C '.s:shellesc(self.path()).' -rubygems -e "require %{bundler}; Bundler.load.specs.map {|s| puts %[#{s.name} #{s.full_gem_path}]}"')
    if v:shell_error
      for line in split(output,"\n")
        if line !~ '^\t'
          call s:warn(line)
        endif
      endfor
    else
      for line in split(output,"\n")
        let self._gems[split(line,' ')[0]] = matchstr(line,' \zs.*')
      endfor
      let self._lock_time = time
      call self.alter_buffer_paths()
    endif
  endif
  return self._gems
endfunction

call s:add_methods('project',['gems'])

" }}}1
" Buffer {{{1

let s:buffer_prototype = {}

function! s:buffer(...) abort
  let buffer = {'#': bufnr(a:0 ? a:1 : '%')}
  call extend(extend(buffer,s:buffer_prototype,'keep'),s:abstract_prototype,'keep')
  if buffer.getvar('bundler_root') !=# ''
    return buffer
  endif
  call s:throw('not a Bundler project: '.expand('%:p'))
endfunction

function! bundler#buffer(...) abort
  return s:buffer(a:0 ? a:1 : '%')
endfunction

function! s:buffer_getvar(var) dict abort
  return getbufvar(self['#'],a:var)
endfunction

function! s:buffer_setvar(var,value) dict abort
  return setbufvar(self['#'],a:var,a:value)
endfunction

function! s:buffer_project() dict abort
  return s:project(self.getvar('bundler_root'))
endfunction

call s:add_methods('buffer',['getvar','setvar','project'])

" }}}1
" Bundle {{{1

function! s:push_chdir(...)
  if !exists("s:command_stack") | let s:command_stack = [] | endif
  let chdir = exists("*haslocaldir") && haslocaldir() ? "lchdir " : "chdir "
  call add(s:command_stack,chdir.s:fnameescape(getcwd()))
  exe chdir.'`=s:project().path()`'
endfunction

function! s:pop_command()
  if exists("s:command_stack") && len(s:command_stack) > 0
    exe remove(s:command_stack,-1)
  endif
endfunction

function! s:Bundle(bang,arg)
  let old_makeprg = &l:makeprg
  let old_errorformat = &l:errorformat
  call s:push_chdir()
  try
    let &l:makeprg = 'bundle'
    let &l:errorformat = ''
          \.'%+E%f:%l:\ parse\ error,'
          \.'%W%f:%l:\ warning:\ %m,'
          \.'%E%f:%l:in\ %*[^:]:\ %m,'
          \.'%E%f:%l:\ %m,'
          \.'%-C%\tfrom\ %f:%l:in\ %.%#,'
          \.'%-Z%\tfrom\ %f:%l,'
          \.'%-Z%p^,'
          \.'%-G%.%#'
    execute 'make! '.a:arg
    redraw
    call s:project().gems()
    if a:bang ==# ''
      return 'if !empty(getqflist()) | cfirst | endif'
    else
      return ''
    endif
  finally
    let &l:errorformat = old_errorformat
    let &l:makeprg = old_makeprg
    call s:pop_command()
  endtry
endfunction

function! s:BundleComplete(A,L,P)
  if a:L =~# '^\S\+\s\+\%(show\|update\) '
    return s:completion_filter(keys(s:project().gems()),a:A)
  endif
  return s:completion_filter(['install','update','exec','package','config','check','list','show','outdated','console','viz','benchmark'],a:A)
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:BundleComplete Bundle :execute s:Bundle('<bang>',<q-args>)")

" }}}1
" Bopen {{{1

function! s:Open(cmd,gem,lcd)
  if a:gem ==# '' && a:lcd
    return a:cmd.' `=bundler#buffer().project().path("Gemfile")`'
  elseif a:gem ==# ''
    return a:cmd.' `=bundler#buffer().project().path("Gemfile.lock")`'
  elseif has_key(s:project().gems(),a:gem)
    let exec = a:cmd.' `=bundler#buffer().project().gems()['.string(a:gem).']`'
    if a:cmd =~# '^pedit' && a:lcd
      let exec .= '|wincmd P|lcd %|wincmd p'
    elseif a:lcd
      let exec .= '|lcd %'
    endif
    return exec
  else
    let v:errmsg = "Can't find gem \"".a:gem."\" in bundle"
    return 'echoerr v:errmsg'
  endif
endfunction

function! s:OpenComplete(A,L,P)
  return s:completion_filter(keys(s:project().gems()),a:A)
endfunction

call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Bopen :execute s:Open('edit<bang>',<q-args>,1)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Bedit :execute s:Open('edit<bang>',<q-args>,0)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Bsplit :execute s:Open('split',<q-args>,<bang>1)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Bvsplit :execute s:Open('vsplit',<q-args>,<bang>1)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Btabedit :execute s:Open('tabedit',<q-args>,<bang>1)")
call s:command("-bar -bang -nargs=? -complete=customlist,s:OpenComplete Bpedit :execute s:Open('pedit',<q-args>,<bang>1)")

" }}}1
" Paths {{{1

function! s:build_path_option(paths,suffix) abort
  return join(map(copy(a:paths),'",".escape(s:shellslash(v:val."/".a:suffix),", ")'),'')
endfunction

function! s:buffer_alter_paths() dict abort
  if self.getvar('&suffixesadd') =~# '\.rb\>'
    let new = sort(values(self.project().gems()))
    let index = index(new, self.project().path())
    if index > 0
      call insert(new,remove(new,index))
    endif
    let old = type(self.getvar('bundler_paths')) == type([]) ? self.getvar('bundler_paths') : []
    if old !=# new
      for [option, suffix] in [['path', 'lib'], ['tags', 'tags']]
        let value = self.getvar('&'.option)
        if !empty(old)
          let drop = s:build_path_option(old,suffix)
          let index = stridx(value,drop)
          if index > 0
            let value = value[0:index-1] . value[index+strlen(drop):-1]
          endif
        endif
        call self.setvar('&'.option,value.s:build_path_option(new,suffix))
      endfor
      call self.setvar('bundler_paths',new)
    endif
  endif
endfunction

call s:add_methods('buffer',['alter_paths'])

function! s:project_alter_buffer_paths() dict abort
  for bufnr in range(1,bufnr('$'))
    if getbufvar(bufnr,'bundler_root') ==# self.path()
      let vim_parsing_quirk = s:buffer(bufnr).alter_paths()
    endif
  endfor
endfunction

call s:add_methods('project',['alter_buffer_paths'])

augroup bundler_path
  autocmd!
  autocmd User Bundler call s:buffer().alter_paths()
augroup END

" }}}1

" vim:set sw=2 sts=2:
