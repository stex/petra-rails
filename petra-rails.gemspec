$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'petra/rails/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'petra-rails'
  s.version     = Petra::Rails::VERSION
  s.authors     = ["Stefan Exner"]
  s.email       = ["stex@sterex.de"]
  s.homepage    = 'http://www.github.com/stex/petra-rails'
  s.summary     = 'Summary of PetraRails.'
  s.description = 'Description of PetraRails.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.2.5'
  s.add_dependency 'petra', '~> 0.0.1'

  s.add_development_dependency 'sqlite3'
end
