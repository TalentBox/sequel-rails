require 'rails/generators/named_base'
require 'rails/generators/migration'
require 'rails/generators/active_model'

module Sequel
  module Generators

    class Base < ::Rails::Generators::NamedBase #:nodoc:

      include ::Rails::Generators::Migration

      def self.source_root
        @_sequel_source_root ||=
        File.expand_path("../#{base_name}/#{generator_name}/templates", __FILE__)
      end

      protected

      # Sequel does not care if migrations have the same name as long as
      # they have different ids.
      #
      def migration_exists?(dirname, file_name) #:nodoc:
        false
      end

      # Implement the required interface for Rails::Generators::Migration.
      #
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
      end

    end

    class ActiveModel < ::Rails::Generators::ActiveModel #:nodoc:
      def self.all(klass)
        "#{klass}.all"
      end

      def self.find(klass, params=nil)
        "#{klass}[#{params}]"
      end

      def self.build(klass, params=nil)
        if params
          "#{klass}.new(#{params})"
        else
          "#{klass}.new"
        end
      end

      def save
        "#{name}.save"
      end

      def update_attributes(params=nil)
        "#{name}.update(#{params})"
      end

      def errors
        "#{name}.errors"
      end

      def destroy
        "#{name}.destroy"
      end
    end

  end
end

module Rails

  module Generators
    class GeneratedAttribute #:nodoc:
      def type_class
        return 'DateTime' if type.to_s == 'datetime'
        return type.to_s.camelcase
      end
    end
  end

end
