module SequelRails
  module SpringSupport
    def disconnect_database
      Sequel::DATABASES.each(&:disconnect) if sequel_configured?
      super
    end

    private

    def sequel_configured?
      defined?(Sequel::DATABASES)
    end
  end
end
