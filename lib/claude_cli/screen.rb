module ClaudeCLI
  # The main entry point. Orchestrates the self-refreshing frame loop,
  # owns the Terminal and KeyReader, tracks registered key handlers, and
  # provides factory methods for widgets (menu, select, text_input,
  # number_input) which can be called either standalone or from within
  # the main render block (e.g. to pop up a menu while a live dashboard
  # keeps refreshing underneath).
  class Screen
    def initialize(interval: 0.5, out: $stdout, in_stream: $stdin,
                    hide_cursor: true, header: nil, &render_block)
      @interval     = interval
      @header       = header
      @render_block = render_block

      @terminal   = Terminal.new(out: out, in_stream: in_stream, hide_cursor: hide_cursor)
      @key_reader = KeyReader.new(@terminal)

      @tick_count = 0
      @running    = false
      @key_handlers = {}
      @printable_handler = nil
    end

    attr_reader :tick_count, :header, :interval, :terminal, :key_reader
    attr_accessor :key_handlers, :printable_handler

    def running?
      @running
    end

    def header=(text)
      @header = text
    end

    # ---------- keyboard handling (for the main loop) ----------

    def on_key(key, &callback)
      @key_handlers[key] = callback
    end

    def remove_key(key)
      @key_handlers.delete(key)
    end

    # ---------- widgets ----------
    #
    # Each returns its result directly (blocking until the user
    # confirms/cancels), and can be called from inside the main render
    # block without disrupting the outer refresh loop or its handlers.

    def menu(items, title: "Menu", char: "#")
      Widgets::Menu.new(self, items, title: title, char: char).run
    end

    def select(options, title: "Select an option", char: "#", validate: nil)
      Widgets::Select.new(self, options, title: title, char: char, validate: validate).run
    end

    def text_input(title: "Enter text", char: "#", validate: nil, mask: nil)
      Widgets::TextInput.new(self, title: title, char: char, validate: validate, mask: mask).run
    end

    def number_input(title: "Enter a number", char: "#", allow_float: true,
                      min: nil, max: nil, validate: nil)
      Widgets::NumberInput.new(
        self, title: title, char: char, allow_float: allow_float,
        min: min, max: max, validate: validate
      ).run
    end

    # ---------- lifecycle ----------

    def run
      @running = true
      @terminal.enter

      trap("INT") { stop }

      while @running
        @tick_count += 1
        buffer = Buffer.new
        draw_header(buffer)
        @render_block.call(self, buffer) if @render_block

        @terminal.draw(buffer.to_s)
        key = @key_reader.read(@interval)
        dispatch_key(key) if key
      end
    ensure
      @terminal.exit
      @running = false
    end

    def stop
      @running = false
    end

    # ---------- internals used by Widgets::Base ----------
    # (public so widgets in the same library can call them; not
    # intended as public API for consumers)

    def draw_header(buffer)
      return unless @header && !@header.to_s.empty?
      buffer.line(@header.to_s)
      buffer.line("=" * @header.to_s.length)
      buffer.blank
    end

    def dispatch_key(key)
      handler = @key_handlers[key]
      if handler
        handler.call
      elsif @printable_handler
        @printable_handler.call(key)
      end
    end
  end
end
