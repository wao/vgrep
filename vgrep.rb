require "tempfile"

module Vgrep
  DATA={}

  class Buf
    attr_reader :bufnr, :master_bufnr, :line_nums, :temp_file
    def initialize(master_bufnr, line_nums, temp_file)
      @master_bufnr = master_bufnr
      @line_nums = line_nums
      @temp_file = temp_file

      show
    end

    def show
      VIM.command("vne #{@temp_file.path}")
      VIM.command("setlocal readonly")
      @bufnr = VIM::Window.current.buffer.number
      DATA[bufnr] = self
    end
  end

  def self.jump()
    buf = DATA[VIM::Buffer.current.number]
    
    if buf
      pos = buf.line_nums.bsearch{ |x| x >= VIM::Window.current.cursor[0] }
      if pos.nil?
        pos = 1
      end

      0.upto(VIM::Window.count-1) do |wi|
        win = VIM::Window[wi]
        if win.buffer
          puts win.buffer.name
          puts win.buffer.number
        end
        if win.buffer&.number == buf.master_bufnr
          puts "got matched win #{wi}"
          win.cursor = [ pos, 1 ]
        end
      end
    end
  end

  def self.grep(pat,bufnr)
      grep_to_file(pat, bufnr)
  end

  def self.grep_to_file(pat,bufnr)
    pattern = Regexp.new(pat)
    file = Tempfile.new("foo")
    buf = VIM::Buffer[bufnr-1]
    line_nrs = []
    1.upto(buf.count) do |i|
        line = buf[i]
        if pattern.match?(line)
            line_nrs << i
            file.puts(line)
        end
    end

    file.flush
    Buf.new(bufnr,line_nrs,file)
  end
end
