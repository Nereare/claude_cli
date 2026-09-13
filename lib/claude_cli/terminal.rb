# frozen_string_literal: true

module ClaudeCLI
  # Wraps all raw terminal I/O concerns: entering/exiting raw mode,
  # hiding/showing the cursor, and writing frames. Isolating this makes
  # the rest of the library testable without a real TTY.
  class Terminal
    ESC = "\e"

    def initialize(out: $stdout, in_stream: $stdin, hide_cursor: true)
      @out         = out
      @in          = in_stream
      @hide_cursor = hide_cursor
      @raw_depth   = 0
    end

    attr_reader :in_stream
    alias io in_stream

    # Enters raw mode / hides cursor. Reentrant: nested enter/exit pairs
    # (e.g. a widget loop started from within the main loop) are safe.
    def enter
      if @raw_depth.zero?
        @out.print "#{ESC}[?25l" if @hide_cursor
        @out.print "#{ESC}[2J"
        @in.raw! if @in.respond_to?(:raw!)
      end
      @raw_depth += 1
    end

    def exit
      @raw_depth -= 1
      return if @raw_depth.positive?

      @out.print "#{ESC}[?25h" if @hide_cursor
      @out.print "\n"
      @out.flush
      @in.cooked! if @in.respond_to?(:cooked!)
    end

    def draw(text)
      @out.print "#{ESC}[H"
      @out.print "#{ESC}[0J"
      @out.print text
      @out.flush
    end

    def wait_readable(seconds)
      @in.wait_readable(seconds)
    end

    def getc
      @in.getc
    end
  end
end
