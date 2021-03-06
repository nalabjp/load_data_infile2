require 'mysql2'
require 'load_data_infile2/sql'

module LoadDataInfile2
  class Client < ::Mysql2::Client
    attr_reader :load_data_infile_options

    def initialize(config, options = {})
      c = if options[:local_infile] && !config.has_key?(:local_infile) && !config.has_key?('local_infile')
            config.merge(local_infile: true)
          else
            config
          end
      super(c)

      @load_data_infile_options = LoadDataInfile2.default_import_options.merge(options)
      @load_data_infile_options[:charset] = query_options[:charset] unless options.has_key?(:charset)
    end

    def import(file, options = {})
      query(build_sql(file, options))
    end

    def quoted_table_name_for(table)
      [query_options[:database], table].compact.map!{|w| "`#{w}`"}.join('.')
    end

    private

    def build_sql(file, options = {})
      table = options[:table] || File.basename(file, '.*')
      LoadDataInfile2::Sql.new(file, quoted_table_name_for(table), load_data_infile_options.merge(options)).build
    end
  end
end
