
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'petra/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'petra-rails'
  spec.version       = Petra::Rails::VERSION
  spec.authors       = ['Stefan Exner']
  spec.email         = ['stex@sterex.de']

  spec.summary       = '[POC] Multi Request Transaction using petra'
  spec.homepage      = 'https://github.com/stex/petra-rails'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.5'

  spec.add_dependency 'rails', '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.53.0'
end
