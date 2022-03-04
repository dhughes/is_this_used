# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'is_this_used/version'

Gem::Specification.new do |spec|
  spec.name = 'is_this_used'
  spec.version = IsThisUsed::VERSION
  spec.authors = ['Doug Hughes']
  spec.email = ['doug@doughughes.net']

  spec.summary = 'Provides a system to track method usage somewhat unobtrusively.'
  spec.description = 'Provides a system to track method usage somewhat unobtrusively.'
  spec.homepage = 'https://github.com/dhughes/is_this_used'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.2'

  spec.add_development_dependency 'appraisal', '~> 2.4.1'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'generator_spec', '~> 0.9.4'
  spec.add_development_dependency 'mysql2', '~> 0.5.3'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rails', '>= 5.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 5.0.2'
  spec.add_development_dependency 'rubocop', '~> 1.22.2'
  spec.add_development_dependency 'rubocop-rails', '~> 2.12.4'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.5.0'
end
