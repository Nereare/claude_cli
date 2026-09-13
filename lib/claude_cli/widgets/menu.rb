# frozen_string_literal: true

module ClaudeCLI
  module Widgets
    # A main menu widget with settable hotkeys.
    #
    #   items = [
    #     { key: "s", label: "Start" },
    #     { key: "q", label: "Quit"  },
    #   ]
    #   choice = Widgets::Menu.new(screen, items, title: "Main Menu").run
    #   # => the :key of the chosen item, e.g. "s"
    class Menu < Base
      def initialize(screen, items, title: 'Menu', char: '#')
        super(screen, title: title, char: char)
        @items = items
      end

      protected

      def render(buffer)
        buffer.box(char: @char, title: @title) do
          @items.each { |item| buffer.line("[#{item[:key]}] #{item[:label]}") }
        end
      end

      def bind_keys
        @items.each do |item|
          on_key(item[:key]) { finish(item[:key]) }
        end
      end
    end
  end
end
