# frozen_string_literal: true

require_relative 'lib/claude_cli/meta'

Gem::Specification.new do |spec|
  spec.name        = ClaudeCLI::SLUG
  spec.version     = ClaudeCLI::VERSION
  spec.license     = ClaudeCLI::LICENSE
  spec.author      = ClaudeCLI::AUTHOR
  spec.email       = ClaudeCLI::AUTHOR_EMAIL
  spec.summary     = ClaudeCLI::DESCRIPTION
  spec.homepage    = 'https://github.com/Nereare/claude_cli'

  spec.required_ruby_version = '~> 3.2'

  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['bug_tracker_uri']       = 'https://github.com/Nereare/claude_cli/issues'
  spec.metadata['changelog_uri']         = 'https://github.com/Nereare/claude_cli/blob/master/CHANGELOG.md'
  spec.metadata['documentation_uri']     = 'https://nereare.github.io/claude_cli/'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir[
    'lib/**/*.rb',
    'sig/*',
    'spec/*.rb',
    '.ruby-version',
    'CHANGELOG.md',
    'LICENSE.md',
    'Rakefile'
  ]
  spec.require_paths = %w[lib]

  # spec.add_dependency 'uuid', '~> 2.3'

  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.86'
  spec.add_development_dependency 'rubocop-rake', '~> 0.7'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.9'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-rspec', '~> 0.1'
end
