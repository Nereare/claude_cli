module ClaudeCLI
  # Reads single keypresses from a Terminal and resolves multi-byte
  # escape sequences (arrows, escape, backspace, enter) into symbols.
  class KeyReader
    ESC = "\e"

    def initialize(terminal)
      @terminal = terminal
    end

    # Blocks briefly (via wait_readable) for the given timeout; returns
    # nil if nothing arrived, otherwise the parsed key.
    def read(timeout)
      return nil unless @terminal.wait_readable(timeout)

      char = @terminal.getc
      return nil unless char

      case char
      when "\r", "\n" then return :enter
      when "\u007f", "\b" then return :backspace
      end

      if char == ESC
        parse_escape_sequence(char)
      else
        char
      end
    end

    private

    def parse_escape_sequence(first_char)
      seq = first_char
      if @terminal.wait_readable(0.01)
        seq << @terminal.getc
        seq << @terminal.getc if seq[-1] == "["
      end

      case seq
      when "#{ESC}[A" then :up
      when "#{ESC}[B" then :down
      when "#{ESC}[C" then :right
      when "#{ESC}[D" then :left
      when ESC        then :escape
      else seq
      end
    end
  end
end
