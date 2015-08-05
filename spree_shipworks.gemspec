# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_shipworks'
  s.version     = '3.0.0'
  s.summary     = 'Spree ShipWorks'
  s.description = "This project implements the ShipWorks 3.0 API endpoint as defined in 'ShipWorks 3.0: Store Integration Guide: version 1.0'."
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'M. Scott Ford'
  s.authors    = ['M. Scott Ford']
  s.email     = 'scott@railsdog.com'
  s.homepage  = 'http://railsdog.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.0'
  s.add_dependency 'nokogiri', '>= 1.6.0'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl', '~> 4.2.0'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.14.0'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry-rails'
end
