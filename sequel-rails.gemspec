# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "sequel_rails/version"

Gem::Specification.new do |s|
  s.name        = "sequel-rails"
  s.version     = SequelRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brasten Sager (brasten)", "Jonathan TRON"]
  s.email       = ["brasten@gmail.com", "jonathan.tron@metrilio.com"]
  s.homepage    = "https://github.com/TalentBox/sequel-rails"
  s.description = "Integrate Sequel with Rails 3"
  s.summary     = "Use Sequel with Rails 3"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_runtime_dependency "sequel", [">= 3.28", "< 5.0"]
  s.add_runtime_dependency "railties", ">= 3.2.0"

  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "rspec", "~> 2.7.0"
  s.add_development_dependency "combustion", "~> 0.5.0"
  s.add_development_dependency "generator_spec", "~> 0.9.0"
end
