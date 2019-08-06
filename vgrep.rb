require "tempfile"

module Vgrep
  DATA={}

  RGBS=[
    "AliceBlue", "gray", "MidnightBlue",
    "cyan", "DarkGreen", "green", "YellowGreen",
    "LightYello", "IndianRed", "OrangeRed", "LighPink",
    "VioletRed", "purple", "SkyBlue1", "maroon", "LightGreen"
  ]

  HI={}

  class Pat
    attr_reader :regexp

    def initialize(pat, hi_index, color_index)
      @pat = pat
      @regexp = Regexp.new(pat)
      @hi_index = hi_index
      @color_index = color_index
    end

    def syntax
      # puts "syntax match #{hi_name} \".*#{@pat}.*\""
      VIM.command("syntax match #{hi_name} \".*#{@pat}.*\"")
    end

    def hi
      VIM.command("hi #{hi_name} guibg=#{guibg}")
    end

    def nohi
      VIM.command("hi clear #{hi_name}")
    end

    def hi_name
      "GPAT_#{@hi_index}"
    end

    def guibg
      RGBS[@color_index]
    end
  end

  def self.find_hi_index
    i = 0
    while !HI[i].nil? do
      i = i + 1
    end

    i
  end

  def self.pat(pat)
    hi_index = find_hi_index
    HI[hi_index] = Pat.new(pat, hi_index, Random.rand(RGBS.length))
    HI[hi_index].syntax
    HI[hi_index].hi
  end

  def self.testPat
    pat = Pat.new("ERROR", 1, 1)
    HI[1] = pat
    puts pat.hi_name
    pat.syntax
    pat.hi
  end

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
      # pos = buf.line_nums.bsearch{ |x| x >= VIM::Window.current.cursor[0] }
      # if pos.nil?
        # pos = 1
      # end

      pos = buf.line_nums[ VIM::Window.current.cursor[0] ]

      0.upto(VIM::Window.count-1) do |wi|
        win = VIM::Window[wi]
        if win.buffer
          # puts win.buffer.name
          # puts win.buffer.number
        end
        if win.buffer&.number == buf.master_bufnr
          VIM.command("#{wi+1}wincmd w")
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
