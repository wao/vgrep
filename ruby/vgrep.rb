module Vgrep
  VERSION = "0.0.1"

  class Pattern
    attr_reader :id, :name, :regexp, :color_id
  end

  class Color
    attr_reader :id, :name
  end

  class Group
    attr_reader :id, :name

    def add_pattern(pattern)
    end

    def remove_pattern(pattern)
    end
  end

  class Definition
    attr_reader :patterns, :groups
  end

  class Config
    attr_reader :dependend_definitions

    def cfg(pattern_or_group, colored, visiable)
    end
  end
end
