require 'load_data_infile2/active_record_extension'

module LoadDataInfile2
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load :active_record do
      ::ActiveRecord::Base.extend LoadDataInfile2::ActiveRecordExtension
    end
  end
end
