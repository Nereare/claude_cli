# frozen_string_literal: true

module ClaudeCLI
  module Widgets
    # Base class for interactive widgets (Menu, Select, TextInput,
    # NumberInput). Each widget runs its own nested draw/input loop by
    # borrowing the owning Screen's terminal, key reader, and frame
    # interval, while temporarily taking over key handling so it doesn't
    # interfere with the screen's own handlers or with other widgets.
    #
    # Subclasses implement:
    #   #render(buffer)     - draw the widget's current state into buffer
    #   #bind_keys           - register on_key handlers for this widget
    #
    # and call #finish(value) when the widget has a result, or
    # #finish(nil) to cancel.
    class Base
      def initialize(screen, title:, char: '#')
        @screen = screen
        @title  = title
        @char   = char
        @error  = nil
        @result = nil
        @done   = false
      end

      # Runs the widget's loop to completion and returns its result.
      def run
        standalone = !@screen.running?
        @screen.terminal.enter if standalone

        prev_handlers = @screen.key_handlers
        @screen.key_handlers = {}
        @screen.printable_handler = nil
        bind_keys

        until @done
          buffer = Buffer.new
          @screen.draw_header(buffer)
          render(buffer)
          render_error(buffer)
          @screen.terminal.draw(buffer.to_s)

          key = @screen.key_reader.read(@screen.interval)
          @screen.dispatch_key(key) if key
        end

        @result
      ensure
        @screen.key_handlers = prev_handlers
        @screen.printable_handler = nil
        @screen.terminal.exit if standalone
      end

      protected

      # Subclasses call this to end the widget loop with a value
      # (or nil to indicate cancellation).
      def finish(value)
        @result = value
        @done = true
      end

      # Subclasses call this to show a validation error and keep the
      # widget loop running (does not finish).
      def set_error(message)
        @error = message
      end

      def clear_error
        @error = nil
      end

      def on_key(key, &block)
        @screen.key_handlers[key] = block
      end

      def on_printable(&block)
        @screen.printable_handler = block
      end

      def render_error(buffer)
        return unless @error

        buffer.blank
        buffer.line("! #{@error}")
      end

      # Subclasses must implement:
      def render(_buffer)
        raise NotImplementedError
      end

      def bind_keys
        raise NotImplementedError
      end
    end
  end
end
