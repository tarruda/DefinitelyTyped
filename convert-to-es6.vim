" convert typescript declarations use es6 module syntax
function! s:Main()
  set expandtab shiftwidth=4 tabstop=4
  " modules we don't want to touch
  let exclude = ['assert']

  " loop over external module declarations
  while search('\m^declare module "', 'eW') != 0
    " go to the word after the double quotes
    normal l
    if index(exclude, expand('<cword>')) != -1
      " excluded module, skip
      continue
    endif
    " append 'export default internal;' at the end of the module declaration
    exe "normal f{%O\<TAB>export default internal;"
    " add a closing bracket above
    exe "normal O\<TAB>}"
    " save current line
    let end = line('.')
    " go to the beginning of the module
    normal %
    mark a
    " process all imports
    while 1
      if !search('^\ \+import', 'W', end)
        break
      endif
      " every time we find an import, mark it
      mark a
      " replace the import to use the new syntax
      :silent s/import \+\(\w\+\) \+= \+require(\(['"]\)\(\w\+\)['"])/import \1 from \2\3\2/g
    endwhile
    " go to the last import
    normal g'a
    " wrap everything below into an internal module
    exe "normal o\<CR>\<TAB>module internal {"
    " indent the internal module
    exe "normal jV?{\<CR>%k>"
  endwhile
  %s/export = \(\w\+\)/export default \1/g
endfunction

call s:Main()
