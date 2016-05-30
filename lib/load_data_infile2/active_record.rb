require 'load_data_infile2/sql'

module LoadDataInfile2
  class ActiveRecord
    def initialize(ar_subclass, options = {})
      @ar_class = ar_subclass
      options[:local_infile] = !!ar_class.connection_config[:local_infile] unless options.has_key?(:local_infile)
      options[:charset] = ar_class.connection_config[:charset] unless options.has_key?(:charset)
      @load_data_infile_options = LoadDataInfile2.default_import_options.merge(options)
    end

    def import(file, options = {})
      query(build_sql(file, options))
    end

    private

    attr_reader :ar_class, :load_data_infile_options

    def build_sql(file, options = {})
      LoadDataInfile2::Sql.new(file, ar_class.quoted_table_name, load_data_infile_options.merge(options)).build
    end

    def query(sql)
      ar_class.connection.execute(sql)
    end
  end
end
