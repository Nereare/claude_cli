#!/usr/bin/env ruby
# frozen_string_literal: true

# demo.rb - exercises ClaudeCLI: header, menu, validated select/text/number
# inputs, and a self-refreshing dashboard that can pop up a menu mid-flight.

require_relative 'claude_cli'

screen = ClaudeCLI::Screen.new(header: 'ClaudeCLI Demo')

choice = screen.menu(
  [
    { key: '1', label: 'Enter your name (text_input + validation)' },
    { key: '2', label: 'Pick a size (select)' },
    { key: '3', label: 'Enter your age (number_input + min/max)' },
    { key: '4', label: "Run live dashboard (press 'm' for a menu, 'q' to quit)" },
    { key: 'q', label: 'Quit' }
  ],
  title: 'Main Menu'
)

case choice
when '1'
  name = screen.text_input(
    title: 'Your name',
    validate: ->(v) { v.strip.empty? ? 'Name cannot be empty' : true }
  )
  puts "You entered: #{name.inspect}"

when '2'
  size = screen.select(%w[Small Medium Large], title: 'Pick a size')
  puts "You picked: #{size}"

when '3'
  age = screen.number_input(
    title: 'Your age', min: 0, max: 120,
    validate: ->(v) { v.zero? ? "Age can't be zero" : true }
  )
  puts "You entered: #{age.inspect}"

when '4'
  dashboard = ClaudeCLI::Screen.new(interval: 0.2, header: 'Live Dashboard') do |s, buffer|
    buffer.box(char: '-', title: 'Status') do
      buffer.line "Tick: #{s.tick_count}"
      buffer.line "Time: #{Time.now.strftime('%H:%M:%S')}"
    end
    buffer.blank
    buffer.line '[m] menu   [q] quit'
  end

  dashboard.on_key('q') { dashboard.stop }
  dashboard.on_key('m') do
    _picked = dashboard.menu(
      [{ key: 'a', label: 'Option A' }, { key: 'b', label: 'Option B' }],
      title: 'Quick Menu'
    )
    # Handling here just for demonstration; dashboard resumes refreshing
    # automatically once the widget returns.
  end

  dashboard.run

else
  puts 'Goodbye.'
end
