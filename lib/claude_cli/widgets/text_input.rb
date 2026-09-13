module ClaudeCLI
  module Widgets
    # A free-text input widget. Type characters, backspace to edit,
    # Enter to confirm, Esc to cancel (returns nil).
    #
    #   name = Widgets::TextInput.new(
    #     screen, title: "Enter your name",
    #     validate: ->(v) { v.length.positive? || "Name cannot be empty" }
    #   ).run
    #
    # validate: optional callable(value) that returns:
    #   - true                      -> valid
    #   - false                     -> invalid, generic message
    #   - a String                  -> invalid, String is the message
    #   - [false, "message"]        -> invalid, explicit message
    #   - [true, ...]               -> valid
    class TextInput < Base
      def initialize(screen, title: "Enter text", char: "#", validate: nil, mask: nil)
        super(screen, title: title, char: char)
        @buffer   = +""
        @validate = validate
        @mask     = mask # optional char to display instead of typed text, e.g. "*"
      end

      protected

      def render(buffer)
        display = @mask ? @mask * @buffer.length : @buffer
        buffer.box(char: @char, title: @title) do
          buffer.line("> #{display}_")
          buffer.blank
          buffer.line("[Enter] confirm   [Esc] cancel")
        end
      end

      def bind_keys
        on_key(:enter)     { try_confirm }
        on_key("\r")       { try_confirm }
        on_key(:escape)    { finish(nil) }
        on_key(:backspace) { @buffer.chop!; clear_error }
        on_key("\u007f")   { @buffer.chop!; clear_error }

        on_printable do |k|
          if k.is_a?(String) && k.length == 1 && k.match?(/[[:print:]]/)
            @buffer << k
            clear_error
          end
        end
      end

      private

      def try_confirm
        ok, message = Validation.run(@validate, @buffer)
        if ok
          finish(@buffer)
        else
          set_error(message)
        end
      end
    end
  end
end
