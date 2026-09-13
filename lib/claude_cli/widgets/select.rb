# frozen_string_literal: true

module ClaudeCLI
  module Widgets
    # A single-select widget: choose one item from a list using
    # up/down arrows and Enter to confirm.
    #
    #   choice = Widgets::Select.new(
    #     screen, ["Small", "Medium", "Large"], title: "Pick a size"
    #   ).run
    #   # => "Medium"
    #
    # validate: optional callable(value) -> true/false or [true/false, error_message]
    #           Since every option comes from a fixed list, validation
    #           here is mostly useful for things like "must not pick
    #           the disabled item" style checks.
    class Select < Base
      def initialize(screen, options, title: 'Select an option', char: '#', validate: nil)
        super(screen, title: title, char: char)
        @options  = options
        @index    = 0
        @validate = validate
      end

      protected

      def render(buffer)
        buffer.box(char: @char, title: @title) do
          @options.each_with_index do |opt, i|
            marker = i == @index ? '> ' : '  '
            buffer.line("#{marker}#{opt}")
          end
          buffer.blank
          buffer.line('[Up/Down] move   [Enter] confirm')
        end
      end

      def bind_keys
        on_key(:up) do
          @index = (@index - 1) % @options.length
          clear_error
        end
        on_key(:down) do
          @index = (@index + 1) % @options.length
          clear_error
        end
        on_key(:enter) { try_confirm }
        on_key("\r")   { try_confirm }
      end

      private

      def try_confirm
        value = @options[@index]
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
