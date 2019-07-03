$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'zahlen/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'zahlen'
  s.version     = Zahlen::VERSION
  s.authors     = ['Jorge Najera']
  s.email       = ['jorge.najera.t@gmail.com']
  # s.homepage    = 'TODO'
  s.summary     = 'Drop-in Rails engine for accepting payments with Conekta.'
  s.description = 'One-off and subscription payments for your Rails application.'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")

  s.add_dependency 'rails', '>= 4.2'

  s.add_dependency 'jquery-rails'
  s.add_dependency 'conekta', '>= 2.0.0'
  s.add_dependency 'aasm', '>= 4.0.7'
  s.add_dependency 'conekta_event', '>= 1.0.3'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
end
