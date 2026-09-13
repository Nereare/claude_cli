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

def run
  print "\e[?25l"
  trap('INT') { @running = false }
  @running = true

  while @running
    lines = []
    lines << "Tick: #{Time.now.strftime('%H:%M:%S')}"
    print "\e[H\e[0J"
    print lines.join("\n")
    sleep 0.5
  end
ensure
  print "\e[?25h\n"
end

run
