# sequel-rails

[![Gem Version](https://badge.fury.io/rb/sequel-rails.svg)][gem]
[![Build Status](https://secure.travis-ci.org/TalentBox/sequel-rails.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/TalentBox/sequel-rails.svg)][codeclimate]

[gem]: https://rubygems.org/gems/sequel-rails
[travis]: http://travis-ci.org/TalentBox/sequel-rails
[codeclimate]: https://codeclimate.com/github/TalentBox/sequel-rails

This gem provides the railtie that allows
[sequel](http://github.com/jeremyevans/sequel) to hook into
[Rails (4.x and 5.x)](http://github.com/rails/rails) and thus behave like a
rails framework component. Just like activerecord does in rails,
[sequel-rails](http://github.com/talentbox/sequel-rails) uses the railtie API to
hook into rails. The two are actually hooked into rails almost identically.

The code for this gem was initially taken from the excellent
[dm-rails](http://github.com/datamapper/dm-rails) project.

This was originally a fork of [brasten](https://github.com/brasten)'s
[sequel-rails](https://github.com/brasten/sequel-rails) that has been updated to
support newer versions of rails.

Since January 2013, we've become the official maintainers of the gem after
[brasten](https://github.com/brasten) proposed us.

Using sequel-rails
==================

Using sequel with Rails (4.x or 5.x) requires a couple minor changes.

First, add the following to your Gemfile (after the `Rails` lines):

```ruby
# depending on you database
gem "pg"        # for PostgreSQL
gem "mysql2"    # for MySQL
gem "sqlite3"   # for Sqlite

gem "sequel-rails"
```

... be sure to run "bundle install" if needed!

Secondly, you'll need to require the different Rails components separately in
your `config/application.rb` file, and not require `ActiveRecord`.
The top of your `config/application.rb` will probably look something like:

```ruby
# require 'rails/all'

# Instead of 'rails/all', require these:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
```

Then you need to get rid of `ActiveRecord` configurations, that is if you
didn't generate the new app with `-O` (or the long form `--skip-active-record`):

For example in a fresh `Rails 5.0.0.1`, you would need to remove those lines:

```
config/initializers/new_framework_defaults.rb
line 18:  Rails.application.config.active_record.belongs_to_required_by_default = true
```

```
config/environments/development.rb
line 38:  config.active_record.migration_error = :page_load
```

```
config/environments/production.rb
line 85:  config.active_record.dump_schema_after_migration = false
```

Starting with sequel-rails 0.4.0.pre3 we don't change default Sequel behaviour
nor include any plugin by default, if you want to get back the previous
behaviour, you can create a new initializer (eg: `config/initializers/sequel.rb`)
with content:

```ruby
require "sequel_rails/railties/legacy_model_config"
```

After those changes, you should be good to go!

Features provided by `sequel-rails`
===================================

1. Connection management:

   `sequel-rails` will initiate the `Sequel` connection mechanism based on your
   configuration in `database.yml`.

2. Generators:

   You can use them just like `ActiveRecord`'s ones:

   Migration:

   ```ruby
   rails generate migration create_admin_users
   # Or
   rails generate migration CreateAdminUsers
   ```

   Model:

   ```ruby
   rails generate model User email:string
   ```

   Observer:

   ```ruby
   rails generate observer User
   ```

   Session:

   ```ruby
   rails generate sequel:session_migration
   ```

3. Rake tasks similar to `ActiveRecord`, see
   [Available sequel specific rake tasks](#available-sequel-specific-rake-tasks)

4. Add some `Sequel` and `sequel-rails` specific exceptions to `ActionDispatch`'s `rescue_responses`

   `Sequel::Plugins::RailsExtensions::ModelNotFound` is mapped to `:not_found`

   `Sequel::NoMatchingRow` is mapped to `:not_found`

   `Sequel::ValidationFailed` is mapped to `:unprocessable_entity`

   `Sequel::NoExistingObject` is mapped to `:unprocessable_entity`

5. Add a `i18n_scope` method to `Sequel::Model` which respond with `"sequel"`.
   This is used by `ActiveModel`.

6. Adding `Sequel` to `ActiveSupport::LogSubscriber`. This is what allows you to
   see SQL queries in the log and also allows us to implement the next item.

7. Add a hook in `ActionController::Base` so that the sum of SQL queries time
   for the current action is reported as `DB` for the controller's line in logs.

8. Provide a `ActionDispatch::Session::SequelStore` similar to the
   `ActiveRecord` one, which stores sessions in database backed by a `Sequel`
   model.

Configuration
=============
You can configure some options with the usual rails mechanism, in
`config/application.rb` and/or in `config/environments/*.rb`.

```ruby
    # Allowed options: :sql, :ruby.
    config.sequel.schema_format = :sql

    # Allowed options: true, false, default false
    config.sequel.allow_missing_migration_files = true

    # Whether to dump the schema after successful migrations.
    # Defaults to false in production and test, true otherwise.
    config.sequel.schema_dump = true

    # These override corresponding settings from the database config.
    config.sequel.max_connections = 16
    config.sequel.search_path = %w(mine public)

    # Configure whether database's rake tasks will be loaded or not.
    #
    # If passed a String or Symbol, this will replace the `db:` namespace for
    # the database's Rake tasks.
    #
    # ex: config.sequel.load_database_tasks = :sequel
    #     will results in `rake db:migrate` to become `rake sequel:migrate`
    #
    # Defaults to true
    config.sequel.load_database_tasks = false

    # This setting disabled the automatic connect after Rails init
    config.sequel.skip_connect = true

    # Configure if Sequel should try to 'test' the database connection in order
    # to fail early
    config.sequel.test_connect = true

    # Configure what should happend after SequelRails will create new connection with Sequel (applicable only for the first new connection)
    # config.sequel.after_connect = proc do
    #   Sequel::Model.plugin :timestamps, update_on_create: true
    # end

    # Configure what should happend after new connection in connection pool is created (applicable only for all connections)
    # to fail early
    # config.sequel.after_new_connection = proc do |db|
    #   db.execute('SET statement_timeout = 30000;')
    # end

    # If you want to use a specific logger
    config.sequel.logger = MyLogger.new($stdout)
```

The connection settings are read from the file `config/database.yml` and is
expected to be similar to `ActiveRecord`'s format.

Here's some examples:

1. For PostgreSQL:

    ```yaml
    development:
      adapter: postgresql
      database: a_database_name
      user: user_name # Also accept 'username' as key, if both are present 'username' is used
      password: password
      host: 10.0.0.2 # Optional
      port: 5432 # Optional
      owner: owner_name # Optional
      encoding: utf8 # Optional, also accept 'charset' as key, if both are present 'encoding' is used (defaults to 'utf8')
      maintenance_db: template2 # Optional
      locale: en_US.UTF-8 # Optional, equivalent to setting 'collation' and 'ctype' to the same value
      collation: en_US.UTF-8 # Optional
      ctype: en_US.UTF-8 # Optional
      template: template1 # Optional
      tablespace: non_default_tablespace_name # Optional
      max_connections: 20 # Optional, also accept 'pool' as key, if both are present 'max_connections' is used (default to nil, Sequel default is 4)
      url: "postgres://myuser:mypass@host/somedatabase" # Optional, if present it's passed to `Sequel.connect` with other config as options
                                                        # If url is not set in config file, environment variable `DATABASE_URL` is used
    ```

2. For MySQL:

    ```yaml
    development:
      adapter: mysql # Also accept mysql2
      database: a_database_name
      user: user_name # Also accept 'username' as key, if both are present 'username' is used
      password: password
      host: 10.0.0.2 # Optional
      port: 5432 # Optional
      charset: latin1 # Optional (defaults to 'utf8')
      collation: latin1_general_ci # Optional (defaults to 'utf8_unicode_ci')
      url: "mysql://myuser:mypass@host/somedatabase" # Optional, if present it's passed to `Sequel.connect` with other config as options
                                                     # If url is not set in config file, environment variable `DATABASE_URL` is used
    ```

2. For SQLite:

    ```yaml
    development:
      adapter: sqlite # Also accept sqlite3
      database: db/mydatabase.sqlite # Path to db relative to Rails root
    ```

  For in memory testing:

```yaml
     development:
      adapter: sqlite # Also accept sqlite3
      database: ":memory:"
```

after_connect hooks
================

There are 2 options how to set after_connect hooks in `config/application.rb`

  1. `config.sequel.after_connect` will be called only on the first new connection. It can be used for enabling plugins or to set some global sequel settings.
  ```ruby
    config.sequel.after_connect = proc do
      Sequel::Model.plugin :timestamps, update_on_create: true
    end
  ```

  2. `config.sequel.after_new_connection` will be called after every new connection in connection pool is created. It can be used to run some specific `SET` commands on every new connection. It's using default `after_connect` hook in sequel. https://sequel.jeremyevans.net/rdoc/classes/Sequel/ConnectionPool.html#attribute-i-after_connect
   ```ruby
    config.sequel.after_new_connection = proc do |db|
      db.execute('SET statement_timeout = 30000;')
    end
  ```

Enabling plugins
================

If you want to enable plugins for all your models, you should use the
after_connect configuration option in `config/application.rb` (0.6.2+):

```ruby
    config.sequel.after_connect = proc do
      Sequel::Model.plugin :timestamps, update_on_create: true
    end
```

This will ensure that these plugins are loaded before any Sequel models are
loaded. Loading plugins into `Sequel::Model` after subclasses are already
created is not supported by Sequel. You can also load extensions in
`after_connect` or perform any custom actions that you need.

Please note: some plugins require a `dataset` to work, which means they can't
be added via `Sequel::Model.plugin`, they need to be added to a `Sequel::Model`
subclass whose underlying table exists.

Using the `SequelStore` to store session in database
====================================================

If you want to store your session in the database you can use the provided
session store backed by a `Sequel` model. Edit your
`config/initializers/session.rb` file and replace the existing code with:

```ruby
YourAppName::Application.config.session_store :sequel_store
```

You can then generate a migration for the session table using the provided
generator:

```bash
rails generate sequel:session_migration
rake db:migrate
```

Optionally if you want to use your own `Sequel` model to handle the session,
you can do so in your `config/initializers/session.rb`:

```ruby
ActionDispatch::Session::SequelStore.session_class = MyCustomSessionModelClass
```

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
rake db:sessions:clear                # Delete all sessions from the database
rake db:sessions:trim[threshold]      # Delete all sessions older than `threshold` days (default to 30 days, eg: rake db:session:trim[10])
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

Improvements have been made by those awesome contributors:

* Benjamin Atkin (@benatkin)
* Gabor Ratky (@rgabo)
* Joshua Hansen (@binarypaladin)
* Arron Washington (@radicaled)
* Thiago Pradi (@tchandy)
* Sascha Cunz (@scunz)
* Brian Donovan (@eventualbuddha)
* Jack Danger Canty (@JackDanger)
* Ed Ruder (@edruder)
* Rafał Rzepecki (@dividedmind)
* Sean Sorrell (@rudle)
* Saulius Grigaliunas (@sauliusg)
* Jacques Crocker (@railsjedi)
* Eric Strathmeyer (@strathmeyer)
* Jan Berdajs (@mrbrdo)
* Robert Payne (@robertjpayne)
* Kevin Menard (@nirvdrum)
* Chris Heisterkamp (@cheister)
* Tamir Duberstein (@tamird)
* shelling (@shelling)
* a3gis (@a3gis)
* Andrey Chernih (@andreychernih)
* Nico Rieck (@gix)
* Alexander Birkner (@BirknerAlex)
* kr3ssh (@kressh)
* John Anderson (@djellemah)
* Larivact (@Larivact)
* Jan Berdajs (@mrbrdo)
* Lukas Fittl (@lfittl)
* Jordan Owens (@jkowens)
* Pablo Herrero (@pabloh)
* Henre Botha (@henrebotha)
* Mohammad Satrio (@tyok)
* Gencer W. Genç (@gencer)
* Steve Hoeksema (@steveh)
* Jester (@Jesterovskiy)
* ckoenig (@ckoenig)
* Rolf Timmermans (@rolftimmermans)
* Olivier Lacan (@olivierlacan)
* Dustin Byrne (@dsbyrne)
* Michael Coyne (@mjc-gh)
* p-leger (@p-leger)
* Semyon Pupkov (@artofhuman)
* Ben Koshy (@BKSpurgeon)
* Janko Marohnić (@janko)
* Adrián Mugnolo (@xymbol)
* Ivan (@AnotherRegularDude)

Credits
=======

The [dm-rails](http://github.com/datamapper/dm-rails) team wrote most of the original code, I just sequel-ized it, but since then most of it has been either adapted or rewritten.

Copyright
=========

Copyright (c) 2010-2013 The sequel-rails team. See [LICENSE](http://github.com/brasten/sequel-rails/blob/master/LICENSE) for details.
