" vim: set sw=2 ts=2 sts=2 et tw=78:

" Git commandline alias
command! -nargs=0 -bar C   :Glcd .
command! -nargs=0 -bar Gd  :call s:GitDiff()
command! -nargs=0 -bar Gp  :call s:Push()
command! -nargs=* -bar Gc  execute 'silent Gcommit '. expand('%') . " -m '<args>' " | echo 'done'
command! -nargs=0 -bar Gca execute 'silent Gcommit -a -v'
command! -nargs=0 -bar Gco :call s:CheckOut()

" add dictionary
command! -nargs=0 -bar Node    execute 'setl dictionary+=~/.vim/dict/node.dict'
command! -nargs=0 -bar Dom     execute 'setl dictionary+=~/.vim/dict/dom.dict'
command! -nargs=0 -bar Koa     execute 'setl dictionary+=~/.vim/dict/koa.dict'
command! -nargs=0 -bar Canvas  execute 'setl dictionary+=~/.vim/dict/canvas.dict'
command! -nargs=0 -bar Express execute 'setl dictionary+=~/.vim/dict/express.dict'

" Copy file to system clipboard
command! -nargs=0 -bar Copy     execute 'silent w !tee % | pbcopy > /dev/null'
" remove file from filesystem
command! -nargs=* -complete=file Rm       :call s:Remove(<f-args>)
command! -nargs=+ -bar Mdir     :call s:Mkdir(<f-args>)
command! -nargs=0 -bar Format   :call s:Format()
command! -nargs=0 -bar Jsongen  :call s:Jsongen()
command! -nargs=0 -bar Reset    :call s:StatusReset()
command! -nargs=0 -bar Emoji    execute 'setl completefunc=emoji#complete'
command! -nargs=0 -bar Date     execute 'r !date "+\%Y-\%m-\%d \%H:\%M:\%S"'
command! -nargs=0 -bar Qargs    execute 'args' s:QuickfixFilenames()
command! -nargs=0 -bar Standard execute '!standard --format %:p'
command! -nargs=1 -bang Qdo call s:Qdo(<q-bang>, <q-args>)
" search with ag and open quickfix window
command! -nargs=+ -complete=file Ag call g:Quickfix('ag', <f-args>)
command! -nargs=+ Ns call g:Quickfix('note', <f-args>)

" preview module files main/package.json/Readme.md
command! -nargs=1 -complete=custom,s:ListModules V     :call s:PreviewModule('<args>')
command! -nargs=1 -complete=custom,s:ListModules J     :call s:PreviewModule('<args>', 'json')
command! -nargs=1 -complete=custom,s:ListModules H     :call s:PreviewModule('<args>', 'doc')
command! -nargs=? -complete=custom,s:ListVimrc   E     :call s:EditVimrc(<f-args>)
command! -nargs=* -bar                         Update  execute "Start ~/.vim/vimrc/publish '<args>'"
command! -nargs=0 -bar                         Publish :call s:Publish()
command! -nargs=? -bar                         L       :call s:ShowGitlog('<args>')

function! g:Quickfix(type, ...)
  if a:type ==# 'ag'
    let pattern = s:FindPattern(a:000)
    let list = deepcopy(a:000)
    let g:grep_word = pattern[0]
    let list[pattern[1]] = shellescape(g:grep_word, 1)
    execute "silent grep! " . join(list, ' ')
  elseif a:type ==# 'note'
    let g:grep_word = a:1
    execute "silent SearchNote! " . join(a:000, ' ')
  endif
  execute "silent Unite -buffer-name=quickfix quickfix"
endfunction

function! s:Mkdir(...)
  for str in a:000
    call mkdir(str, 'p')
  endfor
endfunction

function! s:FindPattern(list)
  let l = len(a:list)
  for i in range(l)
    let word = a:list[i]
    if word !~# '^-'
      return [word, i]
    endif
  endfor
endfunction

function! s:ListVimrc(...)
  return join(map(split(globpath('~/.vim/vimrc/', '*.vim'),'\n'),
    \ "substitute(v:val, '" . expand('~'). "/.vim/vimrc/', '', '')")
    \ , "\n")
endfunction

function! s:EditVimrc(...)
  if !a:0
    execute 'e ~/.vimrc'
  else
    execute 'e ~/.vim/vimrc/' . a:1
  endif
endfunction

" L input:[all:day]
function! s:ShowGitlog(arg)
  let args = split(a:arg, ':', 1)
  let input = get(args, 0, '')
  let arg = get(args, 1, '') . ':' . get(args, 2, '')
  execute 'Unite gitlog:' . arg . ' -input=' . input . ' -buffer-name=gitlog'
endfunction

function! s:ListModules(A, L, p)
  let res = s:Dependencies()
  return join(res, "\n")
endfunction

function! s:Push()
  execute 'Start -dir='. expand('%:p:h') . ' git push'
endfunction

function! s:CheckOut()
  " check out current file
  let cwd = getcwd()
  execute 'silent w'
  let gitdir = fnamemodify(fugitive#extract_git_dir(expand('%:p')), ':h') . '/'
  execute 'silent cd ' . gitdir
  let file = substitute(expand('%:p'), gitdir, '', '')
  let command = 'git checkout -- ' . file
  let output = system(command)
  if v:shell_error && output !=# ''
    echohl WarningMsg | echon output
  endif
  execute 'silent cd ' . cwd
  execute 'silent edit! ' . expand('%:p')
endfunction

function! s:GitDiff()
  let gitdir = fugitive#extract_git_dir(expand('%:p'))
  let base = fnamemodify(gitdir, ':h')
  let cwd = getcwd()
  execute 'silent cd ' . base
  let tmpfile = tempname()
  let output = system('git --no-pager diff')
  if v:shell_error && output !=# ''
    echohl WarningMsg | echon output
    return
  endif
  if !len(output) | echom 'no change' | return | endif
  let lines = split(output, '\n')
  execute 'silent vsplit ' . tmpfile
  call setline(1, lines)
  file changes
  setlocal filetype=git buftype=nowrite readonly nomodified foldmethod=syntax foldlevel=99
  setlocal foldtext=fugitive#foldtext()
  setlocal bufhidden=delete
  nnoremap <buffer> <silent> q  :<C-U>bdelete<CR>
  execute 'silent cd ' . cwd
endfunction

function! s:Remove(...)
  if a:0 ==# 0
    let file = expand('%:p')
    let buf = bufnr('%')
    execute 'bwipeout ' . buf
    call system('rm -f'.file)
  else
    for str in a:000
      call system('rm -rf ' . str)
    endfor
  endif

endfunction

function! s:QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

" Remove hidden buffers and cd to current dir
function! s:StatusReset()
  let dir = fnameescape(expand('%:p:h'))
  execute 'cd '.dir
  " delete hidden buffers
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
      silent execute 'bwipeout' buf
  endfor
endf

function! s:PreviewModule(name, ...)
  if empty(a:name) | echo 'need module name' | return | endif
  let dir = s:GetPackageDir()
  let content = webapi#json#decode(join(readfile(dir . '/package.json')))
  if exists('content.browser')
    let name = get(content.browser, a:name, a:name)
  else
    let name = a:name
  endif
  let dir = dir . '/node_modules/' . name
  if !isdirectory(dir) | echo 'module not found' | return | endif
  let content = webapi#json#decode(join(readfile(dir . '/package.json')))
  if empty(a:000)
    let main = exists('content.main') ? content.main : 'index.js'
    let main = main =~# '\v\.js$' ? main : main . '.js'
    let file = dir . '/' . substitute(main, '\v^(./)?', '', '')
  else
    let type = a:000[0]
    if type ==? 'doc'
      for name in ['readme', 'Readme', 'README']
        if filereadable(dir . '/' . name . '.md')
          let file = dir . '/' . name . '.md'
          break
        endif
      endfor
    elseif type ==? 'json'
      let file = dir . '/package.json'
    endif
  endif
  if !exists('file') | echohl WarningMsg | echon 'not found' | return | endif
  let h = &previewheight
  let &previewheight = 40
  execute 'pedit ' . file
  let &previewheight = h
  execute "normal! \<c-w>k"
endfunction

" module publish
function! s:Publish()
  " file at ~/bin/publish
  let dir = s:GetPackageDir()
  execute 'Start -dir=' . dir . ' -title=publish publish'
endfunction

" package directory of current file
let s:home = expand('~')
function! s:GetPackageDir()
  let dir = expand('%:p:h')
  while 1
    if filereadable(dir . '/package.json')
      return dir
    endif
    let dir = fnamemodify(dir, ':h')
    if dir ==# s:home
      echohl WarningMsg | echon 'package.json not found' | echohl None
      return
    endif
  endwhile
endfunction

function! s:Dependencies()
  let dir = s:GetPackageDir()
  let obj = webapi#json#decode(join(readfile(dir . '/package.json'), ''))
  let browser = exists('obj.browser')
  let deps = browser ? keys(obj.browser) : []
  let vals = browser ? values(obj.browser) : []
  for key in keys(obj.dependencies)
    if index(vals, key) == -1
      call add(deps, key)
    endif
  endfor
  return deps
endfunction

function! s:Format()
  let types = ['javascript', 'html', 'xml', 'css', 'json']
  if index(types, &ft) == -1
    echohl WarningMsg | echon 'not supported filetype' | echohl None
    return
  endif
  call JsBeautify()
endfunction

function! s:Qdo(bang, command)
  if exists('w:quickfix_title')
    let in_quickfix_window = 1
    cclose
  else
    let in_quickfix_window = 0
  endif

  arglocal
  exe 'args '.s:QuickfixFilenames()
  exe 'argdo'.a:bang.' '.a:command
  argglobal

  if in_quickfix_window
    copen
  endif
endfunction

function! s:Jsongen()
  let file = expand('%')
  if !&filetype =~? 'handlebars$'
    echoerr 'file type should be handlebars'
    return
  endif
  let out = substitute(file, '\v\zs(\w*)\.hbs', '\1.json', '')
  echo out
  let output = system('Jsongen ' . file . ' > ' . out)
  if v:shell_error && output !=# ""
    echohl WarningMsg | echon output | echohl None
    return
  endif
  execute 'belowright vs ' . out
endfunction
