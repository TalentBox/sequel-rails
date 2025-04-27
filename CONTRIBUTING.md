# Contribution Guidelines

## Development Setup

Run `bin/setup` to install development and testing dependencies with
Bundler and create the necessary local databases.

You will need mysql and PostgreSQL installed on your local machine for
Bundler to properly install and for the database to be created.

If you're using macOS you can easily install both mysql and Postgres
with [Homebrew][1]:

`brew install mysql postgresql`

Please pay close attention to the post-installation instructions given
to you by Homebrew since `bundle install` will not succeed until you
properly configure bundler to look for the appropriate build flags for
MySQL.

[1]: https://brew.sh/
