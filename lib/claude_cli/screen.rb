# frozen_string_literal: true

require 'pastel'
require 'tty-screen'

module ClaudeCLI
  # The main entry point. Orchestrates the self-refreshing frame loop,
  # owns the Terminal and KeyReader, tracks registered key handlers, and
  # provides factory methods for widgets (menu, select, text_input,
  # number_input) which can be called either standalone or from within
  # the main render block (e.g. to pop up a menu while a live dashboard
  # keeps refreshing underneath).
  class Screen
    attr_accessor :header, :printable_handler
    attr_reader :tick_count, :key_handlers, :interval, :terminal, :key_reader

    # Initialize a new Screen instance.
    #
    # @param  header        [String]  The header text to display at the top.
    # @param  kopts         [Hash]    Additional options.
    # @option kopts         [Float]           :interval           The refresh interval in seconds (default: `0.5`).
    # @option kopts         [Symbol, String]  :color              The color for the header text (default: `:blue`).
    # @option kopts         [Proc]            :render_block       A block to call on each refresh, which receives the screen and a buffer to draw into (default: `nil`).
    # @option kopts         [Proc]            :printable_handler  A block to call for printable keypresses (default: `nil`).
    def initialize(header = 'Claude CLI', **kopts)
      @interval          = kopts.fetch(:interval, 0.034) # Approximately 30fps.
      @header            = header
      @render_block      = kopts.fetch(:render_block, nil)

      @width, @height    = TTY::Screen.size

      @terminal          = Terminal.new
      @key_reader        = KeyReader.new(@terminal)
      @pastel            = Pastel.new(eachline: "\n")
      theme_color(kopts.fetch(:color, :blue))

      @tick_count        = 0
      @running           = false
      @key_handlers      = {}
      @printable_handler = kopts.fetch(:printable_handler, nil)
    end

    # Returns true if the screen is currently running (i.e. the main loop is active).
    #
    # @return       [Boolean]         `true` if the screen is running, `false` otherwise.
    def running?
      @running
    end

    # Set action for keypress.
    #
    # @param  key   [String, Symbol]  The key to listen for (e.g. `'q'`, `'a'`, `:up`).
    # @param  block [Proc]            The action to perform when the key is pressed.
    def on_key(key, &callback)
      @key_handlers[key] = callback
    end

    # Remove action for keypress.
    #
    # @param  key   [String, Symbol]  The key to stop listening for.
    def remove_key(key)
      @key_handlers.delete(key)
    end

    # CLI lifecycle.
    def run
      @running = true
      @terminal.enter

      trap('INT')      { stop }
      trap('SIGWINCH') { @width, @height = TTY::Screen.size }

      while @running
        @tick_count += 1
        buffer = Buffer.new
        draw_header(buffer)
        @render_block&.call(self, buffer)

        @terminal.draw(buffer.to_s)
        key = @key_reader.read(@interval)
        dispatch_key(key) if key
      end
    ensure
      @terminal.exit
      @running = false
    end

    # Stop the screen loop.
    def stop
      @running = false
    end

    private

    def wrap_text(text)
      text.gsub(/(.{1,#{@width - 2}})(\s+|\Z)/, "\\1\n").strip
    end

    # Set the theme color for the CLI.
    #
    # @param  color  [Symbol, String]  The color to set (default: `:blue`). Valid colors are those supported by the Pastel gem.
    def theme_color(color)
      # Normalize color to a symbol and check if it's a valid pastel color.
      main_color = color.downcase.to_sym
      main_color = :blue unless @pastel.valid?(color)
      supp_color = "bright_#{color}".downcase.to_sym

      # Set custom pastel styles
      @pastel.alias_color(:header, main_color, :bold)
      @pastel.alias_color(:highlight, supp_color)
      # Set currency pastel style
      if color == :yellow
        @pastel.alias_color(:money, :white, :bold, :on_yellow)
      else
        @pastel.alias_color(:money, :yellow)
      end
    end

    # Draw the header line into the buffer.
    #
    # @param  buffer  [Buffer]  The buffer to draw into.
    def draw_header(buffer)
      return unless @header && !@header.to_s.empty?

      buffer.line(@pastel.header(wrap_text("# #{@header} #")))
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
