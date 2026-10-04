#!/usr/bin/env ruby
# frozen_string_literal: true

# demo.rb - exercises ClaudeCLI: header, menu, validated select/text/number
# inputs, and a self-refreshing dashboard that can pop up a menu mid-flight.

require_relative 'claude_cli'

=begin
screen = ClaudeCLI::Screen.new('Hello World!')
screen.on_key('q') { screen.stop }

screen.run do |_s, buffer|
  buffer.line 'Press \'q\' to quit.'
end
=end

module ClaudeCLI
  # Foo
  class Screen
    HIDE  = "\e[?25l"
    SHOW  = "\e[?25h\n"
    CLEAR = "\e[H\e[0J"

    attr_accessor :lines

    # Bar
    def initialize(*lines)
      @lines = lines
    end

    # Bar
    def run
      print HIDE
      loop do
        @lines[0] = "Tick: #{Time.now.strftime('%H:%M:%S')}"
        trap('INT') { return nil }
        print CLEAR
        print @lines.join("\n")
        sleep 0.5
      end
    ensure
      print SHOW
    end
  end
end

s = ClaudeCLI::Screen.new
s.run
