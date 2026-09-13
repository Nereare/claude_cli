require_relative "claude_cli/terminal"
require_relative "claude_cli/key_reader"
require_relative "claude_cli/buffer"
require_relative "claude_cli/validation"
require_relative "claude_cli/widgets/base"
require_relative "claude_cli/widgets/menu"
require_relative "claude_cli/widgets/select"
require_relative "claude_cli/widgets/text_input"
require_relative "claude_cli/widgets/number_input"
require_relative "claude_cli/screen"

# A tiny, dependency-free, object-oriented Ruby library for building
# simple, customizable CLI screens that refresh in place instead of
# scrolling.
#
# ## Components
#
# - {ClaudeCLI::Terminal}             - raw terminal I/O (cursor, raw mode, draw)
# - {ClaudeCLI::KeyReader}            - parses keypresses into chars/symbols
# - {ClaudeCLI::Buffer}               - accumulates a frame's lines, draws boxes
# - {ClaudeCLI::Validation}           - normalizes widget validator return values
# - {ClaudeCLI::Widgets::Base}        - shared nested loop for interactive widgets
# - {ClaudeCLI::Widgets::Menu}        - hotkey-driven main menu
# - {ClaudeCLI::Widgets::Select}      - arrow-key single-select list
# - {ClaudeCLI::Widgets::TextInput}   - free text entry with validation
# - {ClaudeCLI::Widgets::NumberInput} - numeric entry with min/max + validation
# - {ClaudeCLI::Screen}               - orchestrates the refresh loop + widgets
#
# @example Basic usage
#
#   require_relative "live_screen"
#
#   screen = ClaudeCLI::Screen.new(interval: 0.2, header: "My App") do |s, buffer|
#     buffer.box(char: "*") do
#       buffer.line "Status: running"
#       buffer.line "Tick: #{s.tick_count}"
#     end
#   end
#
#   screen.on_key("q") { screen.stop }
#   screen.run
#
# Widgets can be called standalone, before `run`:
#
#   screen = ClaudeCLI::Screen.new(header: "Setup")
#   name = screen.text_input(
#     title: "Your name",
#     validate: ->(v) { v.strip.empty? ? "Name cannot be empty" : true }
#   )
#
# ...or from inside the main render block, so a live-updating dashboard
# can pop up a menu/input without losing its own refresh loop:
#
#   screen = ClaudeCLI::Screen.new(interval: 0.2, header: "Dashboard") do |s, buffer|
#     buffer.line "Uptime: #{s.tick_count}"
#   end
#
#   screen.on_key("m") do
#     choice = screen.menu([{ key: "a", label: "Option A" }], title: "Quick Menu")
#     # ... handle choice ...
#   end
#
#   screen.run
module ClaudeCLI
  # Main module
end
