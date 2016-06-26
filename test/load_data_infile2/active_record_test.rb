require 'test_helper'

class LoadDataInfile2::ActiveRecordTest < Test::Unit::TestCase
  setup do
    @db_config = DbConfig.to_hash
  end

  sub_test_case '#initialize' do
    setup do
      subject { LoadDataInfile2::ActiveRecord.new(User, @options) }
    end

    sub_test_case 'local_infile' do
      test 'Options has key named `:local_infile`' do
        @options = { local_infile: true }
        assert_true subject.instance_eval { load_data_infile_options[:local_infile] }
      end

      test 'Options does not have key named `:local_infile`' do
        @options = {}
        assert_false subject.instance_eval { ar_class.connection_config.has_key?(:local_infile) }
        assert_true subject.instance_eval { load_data_infile_options.has_key?(:local_infile) }
        assert_false subject.instance_eval { load_data_infile_options[:local_infile] }
      end
    end

    sub_test_case 'charset' do
      test 'Options does not have key named `:charset`' do
        @options = {}
        assert_equal 'utf8', DbConfig[:charset]
        assert_equal 'utf8', subject.instance_eval { load_data_infile_options[:charset] }
      end
    end
  end

  sub_test_case '#import' do
    setup do
      @client = LoadDataInfile2::ActiveRecord.new(User, { local: true })
    end

    teardown do
      DbHelper.truncate('users')
    end

    def import(csv)
      @client.import(csv)
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
