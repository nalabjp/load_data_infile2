require 'test_helper'

User.default_load_data_infile_options = { foo: :override }

class LoadDataInfile2::ActiveRecordExtensionTest < Test::Unit::TestCase
  test 'ActiveRecord::Base has extension methods' do
    assert_respond_to ActiveRecord::Base, :load_data_infile
    assert_respond_to ActiveRecord::Base, :default_load_data_infile_options
    assert_respond_to ActiveRecord::Base, :default_load_data_infile_options=
  end

  test 'Should called LoadDataInfile2::ActiveRecord#import' do
    any_instance_of(LoadDataInfile2::ActiveRecord) do |klass|
      stub(klass).initialize.with(User, { foo: :override })
      stub(klass).import.with('/path/to/csv', { key1: :value1 })
      User.load_data_infile('/path/to/csv', { key1: :value1 })
    end
  end
end
