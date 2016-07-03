require 'test_helper'

User.default_load_data_infile_options = { foo: :override }

class LoadDataInfile2::ActiveRecordExtensionTest < Test::Unit::TestCase
  test 'ActiveRecord::Base has extension methods' do
    assert_respond_to ActiveRecord::Base, :load_data_infile
    assert_respond_to ActiveRecord::Base, :default_load_data_infile_options
  end

  test 'Should called LoadDataInfile2::ActiveRecord#import' do
    any_instance_of(LoadDataInfile2::ActiveRecord) do |klass|
      mock(klass).import.with('/path/to/csv', { key1: :value1 })
      User.load_data_infile('/path/to/csv', { key1: :value1 })
    end
  end

  sub_test_case 'Really import' do
    teardown do
      DbHelper.truncate('users')
    end

    def import(csv)
      User.load_data_infile(csv)
    end

    test 'success' do
      csv = File.expand_path('../../csv/users_valid.csv', __FILE__)
      import(csv)
      user = User.first
      assert_equal 1, user.id
      assert_equal 'nalabjp', user.name
      assert_equal 'nalabjp@gmail.com', user.email
    end

    test 'failure' do
      csv = File.expand_path('../../csv/users_invalid.csv', __FILE__)
      assert_raise_kind_of(ActiveRecord::StatementInvalid) { import(csv) }
      assert_raise_message(/Mysql2::Error: Row 1 doesn't contain data for all columns/) { import(csv) }
      assert_equal 0, User.count
    end
  end
end
