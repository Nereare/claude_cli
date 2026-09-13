# frozen_string_literal: true

module ClaudeCLI
  # Wraps all raw terminal I/O concerns: entering/exiting raw mode,
  # hiding/showing the cursor, and writing frames. Isolating this makes
  # the rest of the library testable without a real TTY.
  class Terminal
    attr_reader :in_stream
    alias io in_stream

    ESC = "\e"

    # Initializes a new Terminal with the default input/output streams.
    def initialize
      @out         = $stdout
      @in          = $stdin
      @raw_depth   = 0
    end

    # Enters raw mode / hides cursor.
    def enter
      if @raw_depth.zero?
        @out.print "#{ESC}[?25l"
        @out.print "#{ESC}[2J"
        @in.raw! if @in.respond_to?(:raw!)
      end
      @raw_depth += 1
    end

    # Exits raw mode / shows cursor.
    def exit
      @raw_depth -= 1
      return if @raw_depth.positive?

      @out.print "#{ESC}[?25h"
      @out.print "\n"
      @out.flush
      @in.cooked! if @in.respond_to?(:cooked!)
    end

    # Draws a frame to the terminal, clearing the screen first.
    #
    # @param  text  [String]  The text to draw.
    def draw(text)
      @out.print "#{ESC}[H"
      @out.print "#{ESC}[0J"
      @out.print text
      @out.flush
    end

    # Waits for a readable input on the input stream.
    #
    # @param  seconds  [Float]         The number of seconds to wait.
    # @return          [Boolean, nil]  `true` if any input was received, `false` or `nil` if the timeout was reached without receiving input.
    def wait_readable(seconds)
      @in.wait_readable(seconds)
    end

    # Reads a single character from the input stream.
    #
    # @return          [String, nil]  The character read, or `nil` if end of input.
    def getc
      @in.getc
    end
  end
end
