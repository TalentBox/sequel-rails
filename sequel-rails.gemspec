# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'sequel_rails/version'

Gem::Specification.new do |s|
  s.name        = 'sequel-rails'
  s.version     = SequelRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Brasten Sager (brasten)', 'Jonathan TRON']
  s.email       = ['brasten@gmail.com', 'jonathan.tron@metrilio.com']
  s.homepage    = 'http://talentbox.github.io/sequel-rails/'
  s.description = 'Integrate Sequel with Rails (3.x and 4.x)'
  s.summary     = 'Use Sequel with Rails (3.x and 4.x)'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.rdoc_options = ['--charset=UTF-8']
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.2.2'
  s.required_rubygems_version = '>= 1.8.11'

  s.add_dependency 'activemodel', '>= 4.0.0'
  s.add_dependency 'railties', '>= 4.0.0'
  s.add_dependency 'actionpack', '>= 4.0.0'
  s.add_dependency 'sequel', ['>= 3.28', '< 6.0']

  s.add_development_dependency 'combustion', '~> 1.3'
  s.add_development_dependency 'generator_spec'
  s.add_development_dependency 'rake', '>= 0.8.7', '< 12.1'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '1.27.0'
  s.add_development_dependency 'ammeter', '1.1.5'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'nokogiri', '>= 1.13.4'
end
