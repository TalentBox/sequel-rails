require "sequel_rails/version"
require "sequel_rails/railtie" if defined? Rails

module SequelRails
  def self.jruby?
    @using_jruby ||= if defined?(RUBY_ENGINE)
      RUBY_ENGINE == "jruby"
    else
      defined?(JRUBY_VERSION)
    end
  end
end
