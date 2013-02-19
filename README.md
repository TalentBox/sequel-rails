sequel-rails
============

[![Build Status](https://travis-ci.org/TalentBox/sequel-rails.png?branch=master)](https://travis-ci.org/TalentBox/sequel-rails)
[![Code Climate](https://codeclimate.com/github/TalentBox/sequel-rails.png)](https://codeclimate.com/github/TalentBox/sequel-rails)

This gem provides the railtie that allows [sequel](http://github.com/jeremyevans/sequel) to hook into [rails3](http://github.com/rails/rails) and thus behave like a rails framework component. Just like activerecord does in rails, [sequel-rails](http://github.com/talentbox/sequel-rails) uses the railtie API to hook into rails. The two are actually hooked into rails almost identically.

The code for this gem was initially taken from the excellent [dm-rails](http://github.com/datamapper/dm-rails) project.

This was originally a fork of [brasten](https://github.com/brasten)'s [sequel-rails](https://github.com/brasten/sequel-rails) that has been updated to support newer versions of rails.

Since January 2013, we've became the official maintainers of the gem after [brasten](https://github.com/brasten) proposed us.

Using sequel-rails
==================

Using sequel with rails3 requires a couple minor changes.

First, add the following to your Gemfile (after the `Rails` lines):

```ruby
# depending on you database
gem "pg"        # for PostgreSQL
gem "mysql2"    # for MySQL
gem "sqlite3"   # for Sqlite

gem "sequel-rails"
```

... be sure to run "bundle install" if needed!

Secondly, you'll need to require the different Rails components separately in your `config/application.rb` file, and not require `ActiveRecord`.  The top of your `config/application.rb` will probably look something like:

```ruby
# require 'rails/all'

# Instead of 'rails/all', require these:
require "action_controller/railtie"
# require "active_record/railtie" 
require "action_mailer/railtie"
require "sprockets/railtie"
```

Starting with sequel-rails 0.4.0.pre3 we don't change default Sequel behaviour
nor include any plugin by default, if you want to get back the previous 
behaviour, you can create a new initializer (eg: `config/initializers/sequel.rb`) with content:

```ruby
require "sequel_rails/railties/legacy_model_config"
```

After those changes, you should be good to go!

Available sequel specific rake tasks
====================================

To get a list of all available rake tasks in your rails3 app, issue the usual in you app's root directory:

```bash
rake -T
```

or if you don't have hooks in place to run commands with bundle by default:

```bash
bundle exec rake -T
```

Once you do that, you will see the following rake tasks among others. These are the ones that sequel-rails added or replaced:

```bash
rake db:create[env]                   # Create the database defined in config/database.yml for the current Rails.env
rake db:create:all                    # Create all the local databases defined in config/database.yml
rake db:drop[env]                     # Create the database defined in config/database.yml for the current Rails.env
rake db:drop:all                      # Drops all the local databases defined in config/database.yml
rake db:force_close_open_connections  # Forcibly close any open connections to the test database 
rake db:migrate                       # Migrate the database to the latest version
rake db:migrate:down                  # Runs the "down" for a given migration VERSION.
rake db:migrate:redo                  # Rollbacks the database one migration and re migrate up.
rake db:migrate:reset                 # Resets your database using your migrations for the current environment
rake db:migrate:up                    # Runs the "up" for a given migration VERSION.
rake db:reset                         # Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.
rake db:schema:dump                   # Create a db/schema.rb file that can be portably used against any DB supported by Sequel
rake db:schema:load                   # Load a schema.rb file into the database
rake db:seed                          # Load the seed data from db/seeds.rb
rake db:setup                         # Create the database, load the schema, and initialize with the seed data 
rake db:test:prepare                  # Prepare test database (ensure all migrations ran, drop and re-create database then load schema). This task can be run in the same invocation as other task (eg: rake db:migrate db:test:prepare).
```

Note on Patches/Pull Requests
=============================

* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

The sequel-rails team
=====================

* Jonathan Tron (JonathanTron) - Current maintainer
* Joseph Halter (JosephHalter) - Current maintainer

Previous maintainer
===================

[Original project](https://github.com/brasten/sequel-rails):

* Brasten Sager (brasten) - Project creator

Contributors
============

Improvements has been made by those awesome contributors:

* Benjamin Atkin (benatkin)
* Gabor Ratky (rgabo)
* Joshua Hansen (binarypaladin)
* Arron Washington (radicaled)
* Thiago Pradi (tchandy)
* Sascha Cunz (scunz)

Credits
=======

The [dm-rails](http://github.com/datamapper/dm-rails) team wrote most of the original code, I just sequel-ized it, but since then most of it as been either adapted or rewritten.

Copyright
=========

Copyright (c) 2010-2013 The sequel-rails team. See [LICENSE](http://github.com/brasten/sequel-rails/blob/master/LICENSE) for details.
