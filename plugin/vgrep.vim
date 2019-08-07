ruby require "./vgrep"

function Grep(pat,bufnr)
    ruby Vgrep.grep(VIM.evaluate("a:pat"), VIM.evaluate("a:bufnr"))
endfunction

function Gjump()
    ruby Vgrep.jump()
endfunction

function Reload()
    ruby $".delete "./vgrep"
    ruby require "./vgrep"
endfunction

" call Grep( "ERROR", 1 )

" call Gjump()

" ruby Vgrep.pat("ERROR")

ruby Vgrep.load
