function! IndentIgnoringBlanks(child)
  while v:lnum > 1 && getline(v:lnum-1) == ""
    normal k
    let v:lnum = v:lnum - 1
  endwhile
  if a:child == ""
    if v:lnum <= 1 || ! &autoindent
      return 0
    elseif &cindent
      return cindent(v:lnum)
    else
      return indent(v:lnum-1)
    endif
  else
    exec "let indent=".a:child
    return indent==-1?indent(v:lnum-1):indent
  endif
endfunction
augroup IndentIgnoringBlanks
  au!
  au FileType * if match(&indentexpr,'IndentIgnoringBlanks') == -1 |
        \ let &indentexpr = "IndentIgnoringBlanks('".
        \ substitute(&indentexpr,"'","''","g")."')" |
        \ endif
augroup END
