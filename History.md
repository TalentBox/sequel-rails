Dev (unreleased)
================

* Fix `rails db:create`/`rails db:create:all` (@tycooon)
  [#190](https://github.com/TalentBox/sequel-rails/pull/190)
* Update github pages (Stefan Vermaas)
  [#189](https://github.com/TalentBox/sequel-rails/pull/189)

1.2.0 (2022-04-15)
==================

* Migrate CI to Github actions (Jonathan Tron)
* Add a new sequel-rails hook: `after_new_connection` which
  sets `Sequel`'s `after_connect`, and is triggered for every
  new connection (@kamilpavlicko)
  [#186](https://github.com/TalentBox/sequel-rails/pull/186)
* Database drop fix for Sequel (>= 5.38.0) (@AnotherRegularDude)
  [#184](https://github.com/TalentBox/sequel-rails/pull/184)
* Fix for simplified Spring integration (Janko Marohnić, Adrián Mugnolo)
  [#181](https://github.com/TalentBox/sequel-rails/pull/181)
* Simplify Spring integration (Janko Marohnić)
  [#180](https://github.com/TalentBox/sequel-rails/pull/180)

1.1.1 (2020-06-08)
==================

* When using SQL schema dump in MySQL, don't output the generation date in order
  to have the same output if nothing changed. (Joseph Halter)
* Fix readme formatting (Ben Koshy)
  [#175](https://github.com/TalentBox/sequel-rails/pull/175)
* Add frozen_string_literal to migration template (Semyon Pupkov)
  [#174](https://github.com/TalentBox/sequel-rails/pull/174)
* Add allow_missing_migration_files option (Semyon Pupkov)
  [#172](https://github.com/TalentBox/sequel-rails/pull/172)
  [#173](https://github.com/TalentBox/sequel-rails/pull/173)

1.1.0 (2019-10-29)
==================

* Add test_connect option (p-leger)
  [#165](https://github.com/TalentBox/sequel-rails/pull/165)
* Silence logger for sessions store (Michael Coyne)
  [#171](https://github.com/TalentBox/sequel-rails/pull/171)
* Add db:sessions:clear and db:sessions:trim rake tasks (Michael Coyne)
  [#170](https://github.com/TalentBox/sequel-rails/pull/170)
* Allow 'servers' to propagate to Sequel connection (Dustin Byrne)
  [#169](https://github.com/TalentBox/sequel-rails/pull/169)

1.0.1 (2018-02-27)
==================

* Check that db/ exists before running db:schema:load (Olivier Lacan)
  [#157](https://github.com/TalentBox/sequel-rails/pull/157)
* Raise useful exception when db/migrate directory is absent (Olivier Lacan)
  [#156](https://github.com/TalentBox/sequel-rails/pull/156)
* Test Ruby 2.5.0 on Travis CI (Olivier Lacan)
  [#155](https://github.com/TalentBox/sequel-rails/pull/155)
* Fix Sequel::DatabaseConnectionError on db:create:all task (Olivier Lacan)
  [#154](https://github.com/TalentBox/sequel-rails/pull/154)
* Enable skip_connect in db:create rake task (Olivier Lacan)
  [#148](https://github.com/TalentBox/sequel-rails/pull/148)
* Update controller tests to cope with `ActionDispatch::IntegrationTest`
  params handling change.
* Fix db:create rake tasks (Rolf Timmermans)
  [#145](https://github.com/TalentBox/sequel-rails/pull/145)

1.0.0 (2017-11-20)
==================

* Support for Sequel ~> 5.0 (@Jesterovskiy and @ckoenig)
  [#143](https://github.com/TalentBox/sequel-rails/pull/143)
* Better handling of missing database when using Postgresql (Steve Hoeksema)
  [#140](https://github.com/TalentBox/sequel-rails/pull/140)
* Bump version to 1.0.0.alpha
* Drop CI testing with Rubies < 2.2 and Rails < 4.0, add Rails 5.1, and add
  minimal Ruby (>= 2.2) and Rubygems (>= 1.8.11) version to gemspec
* Fix arguments for the shell exec commands on windows (Gencer W. Genç)
  [#134](https://github.com/TalentBox/sequel-rails/pull/134)

0.9.16 (2017-06-22)
===================

* Better handling of missing database when using Postgresql (Steve Hoeksema)
  [#140](https://github.com/TalentBox/sequel-rails/pull/140)

0.9.15 (2017-04-11)
===================

** This will be the last version to support Ruby < 2.2 **

* Remove `alias_method_chain` usage for Rails 5.1 compatibility (Mohammad Satrio)
  [#132](https://github.com/TalentBox/sequel-rails/issues/132)
* Fix string interpolation syntax in error message for db:migrate task (Henre Botha)
  [#133](https://github.com/TalentBox/sequel-rails/issues/133)

0.9.14 (2016-08-15)
===================

* Fix permissions on files and release new version
  [#121](https://github.com/TalentBox/sequel-rails/issues/121)

0.9.13 (2016-08-11)
===================

* Remove some trailing spaces (Pablo Herrero)
  [#119](https://github.com/TalentBox/sequel-rails/pull/119)
* Update session store for Rails 5/Rack 2.0 compatibility (Jordan Owens)
  [#110](https://github.com/TalentBox/sequel-rails/pull/110)
* Make logging compatible with the Sequel master
  [#109](https://github.com/TalentBox/sequel-rails/issues/109)
* Ensure `url` database config is used in Rake task as well (Lukas Fittl)
  [#106](https://github.com/TalentBox/sequel-rails/pull/106)

0.9.12 (2016-01-18)
===================

* Remove `-i` option from `pg_dump`, removed in PostgreSQL 9.5 (Joseph Halter)
* Add support for [Spring](https://github.com/rails/spring) (Jan Berdajs) [#99](https://github.com/TalentBox/sequel-rails/pull/99)
* Allow `config.sequel.logger` to be overridden by environments [#98](https://github.com/TalentBox/sequel-rails/issues/98)
* Allow Rake tasks `db:` namespace to be reconfigured to something else (John Anderson) [#89](https://github.com/TalentBox/sequel-rails/pull/89)

0.9.11 (2015-03-13)
===================

* Track query count in `SequelRails::Railties::LogSubscriber.count`

0.9.10 (2015-02-26)
===================

* Set `search_path` on PostgreSQL when dumping migration informations
[#86](https://github.com/TalentBox/sequel-rails/pull/86)
* Add `ActiveSupport.on_load :sequel` support (kr3ssh) [#85](https://github.com/TalentBox/sequel-rails/pull/85)
* Added option to skip connect after Rails initialize with new option
  `config.sequel.skip_connect = true`. (Alexander Birkner) [#83](https://github.com/TalentBox/sequel-rails/pull/83)

0.9.9 (2015-01-04)
==================

* Fix deprecation notice to only be displayed when installed on deprecated Ruby.

0.9.8 (2015-01-04)
==================

* Add Ruby < 1.9.3 deprecation notice via Gem's `post_install_message` [#80](https://github.com/TalentBox/sequel-rails/pull/78)
* Support running without database.yml, for 12 factor compliance (Rafał Rzepecki) [#78](https://github.com/TalentBox/sequel-rails/pull/78)

0.9.7 (2014-12-18)
==================

* Fix ActiveModel I18n integration (Nico Rieck) [#77](https://github.com/TalentBox/sequel-rails/pull/77)
* Improve CI speed by using docker and caching on Travis

0.9.6 (2014-11-30)
==================

* Run CI with Rails 4.2.0.rc1
* Update RSpec to 3.1
* Do not attempt to destroy session record if it's not persisted (Andrey Chernih) [#72](https://github.com/TalentBox/sequel-rails/pull/72)

0.9.5 (2014-08-14)
==================

* Use `DATABASE_URL` environment variable even if there's no config (Rafał Rzepecki) [#71](https://github.com/TalentBox/sequel-rails/pull/71)
* Fix spelling error in README (a3gis) [#70](https://github.com/TalentBox/sequel-rails/pull/70)

0.9.4 (2014-07-24)
==================

* Put a note in README about plugins which could not be added to `Sequel::Model`
  (Thanks to Dave Myron) [#68](https://github.com/TalentBox/sequel-rails/issues/68)
* Implements `rake db:rollback` and fix `rake db:migrate:redo`
  [#67](https://github.com/TalentBox/sequel-rails/issues/67)

0.9.3 (2014-05-18)
==================

* Use `ENV['DATABASE_URL']` for connection if set
  [#66](https://github.com/TalentBox/sequel-rails/issues/66)

0.9.2 (2014-02-11)
==================

* Update SequelRails::Railties::ControllerRuntime to be up-to-date with how
  ActiveRecord 4.0.x do the DB time calculation. It should fix some
  inconsistencies with the reported time in logs where View + DB time was
  sometimes less than Total time.

0.9.1 (2013-12-31)
==================

* Map `ActiveRecord`'s `pool` key to `Sequel`'s `max_connections` in YAML
  configuration [#59](https://github.com/TalentBox/sequel-rails/issues/59)
* Run tests on Ruby 2.1.0

0.9.0 (2013-11-16)
==================

* Add `require 'english'` to ensure we have access to english equivalents of
  Ruby's special variable [#57](https://github.com/TalentBox/sequel-rails/issues/57)
* Rename `SequelRails::SessionStore` as `ActionDispatch::Session::SequelStore`
  and fix methods to be compatible with `Rails` >= 3.2.

  Previous sequel session store did not work and should be enabled using:

  ```ruby
  MyApplication::Application.config.session_store SequelRails::SessionStore
  ```

  now you can enable it using:

  ```ruby
  MyApplication::Application.config.session_store :sequel_store
  ```

  A basic integration spec was added to ensure it works as expected. [#56](https://github.com/TalentBox/sequel-rails/issues/56)

0.8.0 (2013-11-10)
==================

* Simplify and improve TravisCI config (Tamir Duberstein) [#51](https://github.com/TalentBox/sequel-rails/issues/51)
* Add Rubocop and fix syntax violations (Tamir Duberstein) [#51](https://github.com/TalentBox/sequel-rails/issues/51)
* Update RSpec and use the new 'expect' syntax (Tamir Duberstein) [#51](https://github.com/TalentBox/sequel-rails/issues/51)
* Add session_migration generator and cleanup old code [#56](https://github.com/TalentBox/sequel-rails/issues/56)

0.7.0 (2013-10-11)
==================

* Add more information in the README, related to features of SequelRails [#54](https://github.com/TalentBox/sequel-rails/issues/54)
* Refactor storage shell command construction/execution/escaping [#55](https://github.com/TalentBox/sequel-rails/issues/55)
* Handle more options from database.yml for PostgreSQL when creating/dropping/loading/dumping database [#55](https://github.com/TalentBox/sequel-rails/issues/55)
* Allow dumping the schema even if there aren't any migrations to run. (Kevin Menard) [#53](https://github.com/TalentBox/sequel-rails/pull/53)
* Fix Postgres rake tasks under JRuby (Kevin Menard, Chris Heisterkamp) [#52](https://github.com/TalentBox/sequel-rails/pull/52) [#38](https://github.com/TalentBox/sequel-rails/pull/38)
* Fix SQL schema dumps using timestamp migration (Joshua Hansen) [#50](https://github.com/TalentBox/sequel-rails/pull/50)
* Apply all migrations in the schema.rb file when loading it (Robert Payne) [#49](https://github.com/TalentBox/sequel-rails/pull/49)
* Make dump_schema_information compatible with integer based migration (Robert Payne) [#48](https://github.com/TalentBox/sequel-rails/pull/48) [#47](https://github.com/TalentBox/sequel-rails/issues/47)
* Add an `after_connect` hook (Jan Berdajs) [#46](https://github.com/TalentBox/sequel-rails/pull/46)
* Update license dates and add license to gemspec [#45](https://github.com/TalentBox/sequel-rails/issues/45)

0.6.1 (2013-09-16)
==================

* Use a `SequelRails::Configuration` from the start in `app.config.sequel` [#44](https://github.com/TalentBox/sequel-rails/issues/41)

0.6.0 (2013-09-12)
==================

* Do not try to construct `url` from config if data config already contains one `url` [#35](https://github.com/TalentBox/sequel-rails/issues/41)
* Add setting to allow disabling database's rake tasks to be loaded [#41](https://github.com/TalentBox/sequel-rails/issues/41)
* Loosen the Sequel dependencies to `< 5.0` (Joshua Hansen) [#39](https://github.com/TalentBox/sequel-rails/pull/39)
* Fix regexp to extract root url when using JDBC (Eric Strathmeyer) [#40](https://github.com/TalentBox/sequel-rails/pull/40)

0.5.1 (2013-08-05)
==================

* Allow setting if schema should be dumped (Rafał Rzepecki) [#37](https://github.com/TalentBox/sequel-rails/issues/37)
* Allow `rake db:dump` and `rake db:load` to work on `sqlite3` [#31](https://github.com/TalentBox/sequel-rails/issues/31)
* Append migrations schema information to `schema.rb` and `structure.sql` [#31](https://github.com/TalentBox/sequel-rails/issues/31)
* Allow setting the search path in app config (Rafał Rzepecki) [#36](https://github.com/TalentBox/sequel-rails/issues/36)

0.5.0 (2013-07-08)
==================

* Loosen dependency to allow `Sequel` versions `~> 4.0.0`
* Add ruby 2.0.0 to TravisCI

0.4.4 (2013-06-06)
==================

* Fix schema_dumper extension inclusion to remove deprecation warning in
  Sequel 3.48 (Jacques Crocker)
* Add support for dumping/loading sql schema for MySQL (Saulius Grigaliunas)
* Add support for configuring max connections in app config (Rafał Rzepecki)

0.4.3 (2013-04-03)
==================

* Handle `Sequel::NoMatchingRow` exception to return a `404`.

  As of `Sequel` `3.46.0`, this new standard exception class has been added.
  The main use case is when no row is found when using the new `Dataset#first!`
  method, this new method raise an exception instead of returning `nil` like
  `Dataset#first`.

* Ensure migration tasks points to migration directory's full path (Sean Sorrell)

0.4.2 (2013-03-18)
==================

* Add schema dump format option and sql dump/load for Postgresql (Rafał Rzepecki)

  To make `rake db:dump` and `rake db:load` use sql format for schema instead
  of the default ruby version, put in your `config/application.rb`:
  ```ruby
  config.sequel.schema_format = :sql
  ```
* Improve detection of JRuby (Ed Ruder)

0.4.1 (2013-03-12)
==================

* DRY config in rake task and fix usage under JRUBY (Ed Ruder)
* Enable JRuby in TravisCI
* Run JDBC specs when jruby is detected
* Fix problems with JDBC support when running in 1.9 mode
* Fix JDBC support for mysql and postgresql and add specs on
  `SequelRails::Configuration` (Jack Danger Canty)
* Rescue exception when dropping database [#20](https://github.com/TalentBox/sequel-rails/issues/20)

0.4.0 (2013-03-06)
==================

* Ensure we've dropped any opened connection before trying to drop database (Ed Ruder)
* Make dependency on railtie looser (`>= 3.2.0`)
* Do not add any Sequel plugin by default anymore. Plugins could not be removed
  so it is safer to let the user add them via an initializer. Furthermore, we
  were changing the default Sequel behaviour related to 'raise on save'.
  All the previous plugins/behaviours of sequel-rails can be restored by
  creating an initializer with:

  ```ruby
  require "sequel_rails/railties/legacy_model_config"
  ```

  Thanks to @dlee, for raising concerns about this behaviour in
  [#11](https://github.com/TalentBox/sequel-rails/pull/11)

0.4.0.pre2
==========

* Remove `rake db:forward` and `rake db:rollback` as it makes not much sense
  when using the TimeStampMigration which is how this gem generates migrations
* Ensure rake tasks returns appropriate code on errors
* Ensure PostgreSQL adapter passes the right options to both create and drop
  database (Sascha Cunz)

0.4.0.pre1
==========

* Fix `rake db:drop` and `rake db:schema:load` tasks (Thiago Pradi)

0.4.0.pre
==========

* Add [Travis-CI](http://travis-ci.org) configuration
* Ensure file name for migration are valid
* **BIG CHANGE** rename `Rails::Sequel` module as `SequelRails`, this becomes
  the namespace for all sequel-rails related classes.
* Split `Rails::Sequel::Storage` class in multiple adapter for each db
* Only log queries if logger level is set to :debug (matching ActiveRecord
  default).
* Correctly display time spent in models in controller logs.
* Add simple `ActiveSupport::Notification` support to Sequel using logger
  facility. This is done by monkey patching `Sequel::Database#log_yield`, so
  it does not yield directly if no loggers configured and instrument the yield
  call. Note that this does not allow to know from which class the query comes
  from. So it still does not display the `Sequel::Model` subclass like
  `ActiveRecord` does (eg: User load).
* Add spec for Sequel::Railties::LogSubscriber
* Add initial specs for railtie setup

0.3.10
======

* Add post_install_message to notify users to switch to sequel-rails gem

0.3.9
=====

* Correctly pass option to MySQL CLI and correctly escape them (Arron Washington)

0.3.8
=====

* Fix bug in `db:force_close_open_connections` and make it work with
  PostgreSQL 9.2.
* Ensure `db:test:prepare` use `execute` instead of `invoke` so that tasks
  already invoked are executed again. This make the following work as expected:
    `rake db:create db:migrate db:test:prepare`

0.3.7
=====

* Check migration directory exists before checking if migration are pending

0.3.6
=====

* Ensure some tasks use the right db after setting `Rails.env`:
  - `db:schema:load`
  - `db:schema:dump`
  - `db:force_close_open_connections`
* Add check for pending migrations before running task depending on schema:
  - `db:schema:load`
  - `db:test:prepare`
* Make database task more like what rails is doing:
  - `db:load` do not create the db anymore
  - `db:create` don't create the test db automatically
  - `db:drop` don't drop the test db automatically
  - `db:test:prepare` don't depend on `db:reset` which was loading `db:seed` (Sean Kirby)
* Make `rake db:setup` load schema instead of running migrations (Markus Fenske)
* Depends on `railties` instead of `rails` to not pull `active_record`
  as dependency (Markus Fenske)

0.3.5
=====

* Fix `rake db:schema:load` (Markus Fenske)

0.3.4
=====

* Make `rake db:schema:dump` generate a schema file which contains foreign_keys
  and uses db types instead of ruby equivalents. This ensure loading the schema
  file will result in a correct db

* Map some Sequel specific exceptions to `ActiveRecord` equivalents, in
  `config.action_dispatch.rescue_responses`. This allows controllers to behave
  more like `ActiveRecord` when Sequel raises exceptions. (Joshua Hansen)

* New Sequel plugin added to all `Sequel::Model` which allows to use
  `Sequel::Model#find!` which will raise an exception if record does not exists.
  This method is an alias to `Sequel::Model#[]` method. (Joshua Hansen)

0.3.3
=====

* Fix generators and use better model and migration template (Joshua Hansen)

0.3.2
=====
* Ignore environments without `database` key (like ActiveRecord do it), to allow
  shared configurations in `database.yml`.
* Fix db creation commands to let the `system` method escape the arguments
* Fix error when using `mysql2` gem

0.3.1
=====
* Make `db:schema:dump` Rake task depends on Rails `environment` task (Gabor Ratky)

0.3.0
=====
* Update dependency to Rails (~> 3.2.0)

0.2.3
=====
* Set `PGPASSWORD` environment variable before trying to create DB using `createdb`

0.2.2
=====
* Ensure Sequel is disconnected before trying to drop a db

0.2.1
=====
* Make dependency on Sequel more open (~> 3.28)

0.2.0
=====
* Fix deprecation warning for config.generators
* Update dependency to Rails 3.1.1
* Update dependency to Sequel 3.28.0
* Update dependency to RSpec 2.7.0

0.1.4
=====
* Merged in changes to rake tasks and timestamp migrations

0.1.3
=====
* update sequel dependency, configuration change

0.1.2
=====
* fixed log_subscriber bug that 0.1.1 was -supposed- to fix.
* fixed controller_runtime bug

0.1.1
=====
* bug fixes, no additional functionality

0.1.0
=====
* initial release
