source 'https://rubygems.org'

gemspec

gem 'actionpack'
gem 'fakefs', '>= 1.8.0', :require => 'fakefs/safe'

gem 'pry'

# MRI/Rubinius Adapter Dependencies
platform :ruby do
  gem 'mysql2'
  gem 'pg'
  gem 'sqlite3'
end

# JRuby Adapter Dependencies
platform :jruby do
  gem 'jdbc-mysql'
  gem 'jdbc-postgres'
  gem 'jdbc-sqlite3'
end
