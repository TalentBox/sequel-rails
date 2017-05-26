module SequelRails
  VERSION = '1.0.0.alpha'
end

if RUBY_VERSION < '1.9'
  warn <<-NOTE
    NOTE: Support for Ruby 1.8 in sequel-rails is deprecated and will be
    dropped in a future release. If you really rely on it please complain at
    http://git.io/WgfgZQ to delay the inevitable.
  NOTE
end
