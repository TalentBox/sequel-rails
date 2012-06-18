require 'sequel'

module Sequel
  module Plugins
    # The RailsExtensions plugin adds a single class method to Sequel::Model in
    # order to make its use in controllers a little more like ActiveRecord's.
    # The +find!+ method is added which will raise an exception if no object is
    # found. By adding the following code to a Railtie:
    #
    #   config.action_dispatch.rescue_responses.merge!(
    #    'SSequel::Plugins::RailsExtensions::ModelNotFound' => :not_found
    #   )
    # 
    # Usage:
    #
    #   # Apply plugin to all models:
    #   Sequel::Model.plugin :rails_extensions
    #
    #   # Apply plugin to a single model:
    #   Album.plugin :rails_extensions
    module RailsExtensions
      class ModelNotFound < Sequel::Error
      end
      
      module ClassMethods
        def find!(args)
          m = self[args]
          raise ModelNotFound, "Couldn't find #{self} matching #{args}." unless m
          m
        end
      end
      
    end
  end
end
