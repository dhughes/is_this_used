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

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rails', '>= 5.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 5.0.2'
end
