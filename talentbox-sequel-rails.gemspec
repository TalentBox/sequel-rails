# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "sequel-rails/version"

Gem::Specification.new do |s|
  s.name        = "talentbox-sequel-rails"
  s.version     = Rails::Sequel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brasten Sager (brasten)", "Jonathan TRON"]
  s.email       = ["brasten@gmail.com", "jonathan.tron@thetalentbox.com"]
  s.homepage    = "https://github.com/TalentBox/sequel-rails"
  s.description = "Integrate Sequel with Rails 3"
  s.summary     = "Use Sequel with Rails 3"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.add_runtime_dependency("sequel", ["~> 3.28"])
  s.add_runtime_dependency("rails", ["~> 3.2.0"])

  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("yard", ["~> 0.5"])
  s.add_development_dependency("rspec", ["~> 2.7.0"])
  s.add_development_dependency("autotest", ["~> 4.4.6"])
  s.add_development_dependency("rcov", ["~> 0.9.11"])
end
