# frozen_string_literal: true

module ClaudeCLI
  # Accumulates the lines of a single frame. Knows how to render plain
  # lines, blanks, and bordered boxes. Rendering to a final string is
  # separate from accumulation so widgets can capture/slice sub-ranges
  # (used by #box to wrap whatever was added inside its block).
  class Buffer
    def initialize
      @lines = []
    end

    attr_reader :lines

    def line(text = '')
      @lines << text.to_s
    end

    def to_s
      @lines.join("\n")
    end

    def blank
      line('')
    end

    # Draws a bordered box around whatever is added to the buffer inside
    # the block.
    #
    #   buffer.box(char: "*", width: 40, title: "Info") do
    #     buffer.line "Hello"
    #   end
    #
    # char:    single character used for the border (default "#")
    # width:   inner content width (default: longest inner line, or 40)
    # padding: spaces around content, left/right (default 1)
    # title:   optional title centered into the top border
    def box(char: '#', width: nil, padding: 1, title: nil)
      before = @lines.length
      yield if block_given?
      inner_lines = @lines.slice!(before..-1) || []

      content_width = width || [inner_lines.map(&:length).max || 0, 40].max
      total_width   = content_width + (padding * 2)

      @lines << top_border(char, total_width, title)
      inner_lines.each do |text|
        padded = text.to_s.ljust(content_width)
        @lines << "#{char}#{' ' * padding}#{padded}#{' ' * padding}#{char}"
      end
      @lines << (char * (total_width + 2))
    end

    private

    def top_border(char, total_width, title)
      plain = char * (total_width + 2)
      return plain unless title

      label = " #{title} "
      return plain if label.length >= plain.length - 2

      left  = (total_width + 2 - label.length) / 2
      right = (total_width + 2) - label.length - left
      "#{char * left}#{label}#{char * right}"
    end
  end
end
