ruby require "tempfile"

function Grep(pat,bufnr)
ruby << EOF
    pattern = Regexp.new(VIM.evaluate("a:pat"))
    file = Tempfile.new("foo")
    buf = VIM::Buffer[VIM.evaluate("a:bufnr")-1]
    1.upto(buf.count) do |i|
        line = buf[i]
        if pattern.match?(line)
            file.write(line)
        end
    end
    file.flush
    VIM.command("vne #{file.path}")
    VIM.command("setlocal readonly")
EOF
endfunction

call Grep( "Tk", 1 )
