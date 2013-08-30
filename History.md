0.5.2.dev
=========

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
