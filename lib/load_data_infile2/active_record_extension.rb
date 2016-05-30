require 'load_data_infile2/active_record'

module LoadDataInfile2
  module ActiveRecordExtension
    def load_data_infile(file, options = {})
      LoadDataInfile2::ActiveRecord.new(self, default_load_data_infile_options).import(file, options)
    end

    def default_load_data_infile_options
      {}
    end
  end
end
