# frozen_string_literal: true

module ClaudeCLI
  # Accumulates the lines of a single frame. Knows how to render plain
  # lines, blanks, and bordered boxes. Rendering to a final string is
  # separate from accumulation so widgets can capture/slice sub-ranges
  # (used by #box to wrap whatever was added inside its block).
  class Buffer
    attr_reader :lines

    # Initializes a new buffer with no lines.
    def initialize
      @lines = []
    end

    # Adds a line to the buffer. The line is converted to a string.
    #
    # @param  text  [String] The string to add.
    def line(text = '')
      @lines << text.to_s
    end

    # Converts the buffer to a string, joining all lines with newlines.
    #
    # @return       [String]  The string containing all lines joined with newlines.
    def to_s
      @lines.join("\n")
    end

    # Adds a blank line to the buffer.
    def blank
      line('')
    end
  end
end
