module ClaudeCLI
  module Widgets
    # A numeric input widget. Only digits (and an optional leading "-"
    # and a single "." when allow_float is true) are accepted as
    # keystrokes. Enter confirms (running validation, including
    # optional min/max bounds), Esc cancels (returns nil).
    #
    #   age = Widgets::NumberInput.new(
    #     screen, title: "Enter your age", min: 0, max: 120
    #   ).run
    #   # => 42 (Integer), or a Float if allow_float and "." was typed
    #
    # validate: optional callable(value) with the same contract as
    #           TextInput's validate (called with the parsed number,
    #           after min/max checks pass).
    class NumberInput < Base
      def initialize(screen, title: "Enter a number", char: "#",
                     allow_float: true, min: nil, max: nil, validate: nil)
        super(screen, title: title, char: char)
        @buffer      = +""
        @allow_float = allow_float
        @min         = min
        @max         = max
        @validate    = validate
      end

      protected

      def render(buffer)
        buffer.box(char: @char, title: @title) do
          buffer.line("> #{@buffer}_")
          range = range_hint
          buffer.line(range) if range
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
          if numeric_char?(k)
            @buffer << k
            clear_error
          end
        end
      end

      private

      def range_hint
        return nil unless @min || @max
        if @min && @max
          "(range: #{@min} to #{@max})"
        elsif @min
          "(minimum: #{@min})"
        else
          "(maximum: #{@max})"
        end
      end

      def numeric_char?(key)
        return false unless key.is_a?(String) && key.length == 1
        return true if key =~ /[0-9]/
        return true if key == "-" && @buffer.empty?
        return true if @allow_float && key == "." && !@buffer.include?(".")
        false
      end

      def parsed_value
        return nil if @buffer.empty? || @buffer == "-"
        @allow_float && @buffer.include?(".") ? @buffer.to_f : @buffer.to_i
      end

      def try_confirm
        value = parsed_value
        if value.nil?
          set_error("Please enter a number")
          return
        end

        if @min && value < @min
          set_error("Must be at least #{@min}")
          return
        end

        if @max && value > @max
          set_error("Must be at most #{@max}")
          return
        end

        ok, message = Validation.run(@validate, value)
        if ok
          finish(value)
        else
          set_error(message)
        end
      end
    end
  end
end
