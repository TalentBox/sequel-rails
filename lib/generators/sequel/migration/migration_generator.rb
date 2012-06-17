require 'generators/sequel'

module Sequel
  module Generators

    class MigrationGenerator < Base

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :id, :type => :numeric, :desc => "The id to be used in this migration"

      def create_migration_file
        set_local_assigns!
        migration_template "migration.rb", "db/migrate/#{file_name}.rb"
      end

      attr_reader :migration_action, :table_action, :column_action, :use_change

      protected
      def set_local_assigns!
        if file_name =~ /^(create|drop)_(.*)$/
          @table_action   = $1
          @table_name     = $2.pluralize
          @column_action  = 'add'
          @use_change     = @table_action == 'create' ? true : false
        elsif file_name =~ /^(add|drop|remove)_.*_(?:to|from)_(.*)/
          @table_action   = 'alter'
          @table_name     = $2.pluralize
          @column_action  = $1 == 'add' ? 'add' : 'drop'
          @use_change     = @column_action == 'add' ? true : false
        else
          @table_action   = 'alter'
          if file_name =~ /^(alter)_(.*)/
            @table_name   = $2.pluralize
          else
            @table_name   = file_name.pluralize
          end
          @use_change     = false
          @column_action  = 'add'
        end
      end

    end

  end
end
