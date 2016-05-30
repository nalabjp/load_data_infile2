require 'load_data_infile2/version'
require 'load_data_infile2/client'

begin
  require 'rails'
  require 'load_data_infile2/railtie'
rescue LoadError
end

module LoadDataInfile2
  class << self
    def default_import_options
      @default_import_options ||= {
        fields_terminated_by: ',',          # CSV
        fields_optionally_enclosed_by: '"', # standard format of CSV
        fields_escaped_by: '"',             # standard format of CSV
        lines_terminated_by: "\\n",
        ignore_lines: 0
      }
    end
  end
end
