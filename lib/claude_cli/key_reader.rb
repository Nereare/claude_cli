# frozen_string_literal: true

module ClaudeCLI
  # Reads single keypresses from a Terminal and resolves multi-byte
  # escape sequences (arrows, escape, backspace, enter) into symbols.
  class KeyReader
    ESC = "\e"

    # Initializes a new KeyReader with the given Terminal.
    #
    # @param  terminal  [Terminal]  The Terminal to read from.
    def initialize(terminal)
      @terminal = terminal
    end

    # Blocks briefly (via wait_readable) for the given timeout; returns
    # nil if nothing arrived, otherwise the parsed key.
    #
    # @param  timeout   [Float]     The number of seconds to wait.
    # @return           [Symbol, String, nil]  The parsed key, or `nil` if nothing arrived.
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

    # Parses an escape sequence starting with the given first character.
    #
    # @param  first_char  [String]          The first character of the sequence.
    # @return             [Symbol, String]  The parsed key or the raw sequence.
    def parse_escape_sequence(first_char)
      seq = first_char
      if @terminal.wait_readable(0.01)
        seq << @terminal.getc
        seq << @terminal.getc if seq[-1] == '['
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
