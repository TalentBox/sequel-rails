module Sequel
  singleton_class.send(:alias_method, :oldModel, :Model)
  def self.Model(*args)
    # for backward compatibility -- probably not necessary
    if args.count == 1
      if (args[0].is_a? String) || (args[0].is_a? Symbol)
        table_name = args[0].to_s
        dbconfs = Rails.configuration.database_configuration
        prefix = dbconfs[Rails.env]['prefix'].to_s
        prefix << '_' unless prefix.empty?
        return oldModel((prefix + table_name).to_sym)
      elsif !args[0].is_a? Hash
        return oldModel(args[0])
      end
    end
    # end backward compatibiility
    settings = nil
    if args[0].is_a? Hash
      settings = args[0]
    else
      settings = { :table => args[0] }
      settings.merge! args[1] if args[1].is_a? Hash
    end
    klass = Class.new(Model)
    klass.preconfig settings
    klass
  end # self.Model

  class Model
    @preinherit_config = nil
    def self.preconfig(config)
      if @preinherit_config.nil?
        @preinherit_config = config
      else
        @preinherit_config.merge! config
      end
    end
    def self.inherited(subclass)
      super
      return if self == Sequel::Model
      return unless p = @preinherit_config # for backward compatibility only.
      dbconfs = Rails.configuration.database_configuration
      dbc = ''
      unless p.empty?
        dbc = p[:db].to_s
        prefix = p[:prefix]
        table_name = p[:table].to_s
      end
      dbc.empty? || dbc << '_'
      dbconf = dbconfs["#{dbc}#{Rails.env}"]
      prefix = dbconf['prefix'] if prefix.nil?
      prefix << '_' unless prefix.to_s.empty?
      table_name = subclass.implicit_table_name if table_name.empty?
      table_name = prefix + table_name unless prefix.to_s.empty?
      subclass.db = Sequel.connect(dbconf)
      subclass.set_dataset(table_name.to_sym)
    end
  end # class Model
end # module Sequel
