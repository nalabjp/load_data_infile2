require 'load_data_infile2/sql'

module LoadDataInfile2
  class ActiveRecord
    def initialize(ar_subclass, options = {})
      @ar_class = ar_subclass
      if options[:local_infile]
        raise "Require option as `local_infile: true` in config/database.yml" unless @ar_class.connection.instance_variable_get(:@connection).query_options[:local_infile]
      end

      @load_data_infile_options = LoadDataInfile2.default_import_options.merge(options)
      @load_data_infile_options[:charset] = @ar_class.connection_config[:charset] unless options.has_key?(:charset)
    end

    def import(file, options = {})
      query(build_sql(file, options))
    end

    private

    def build_sql(file, options = {})
      LoadDataInfile2::Sql.new(file, @ar_class.quoted_table_name, @load_data_infile_options.merge(options)).build
    end

    def query(sql)
      @ar_class.connection.execute(sql)
    end
  end
end
