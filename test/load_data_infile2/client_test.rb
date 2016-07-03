require 'test_helper'

class LoadDataInfile2::ClientTest < Test::Unit::TestCase
  setup do
    @db_config = DbConfig.to_hash
  end

  sub_test_case '#initialize' do
    setup do
      subject { LoadDataInfile2::Client.new(@db_config, @options) }
    end

    sub_test_case 'local_infile' do
      test 'Options has key named `:local_infile`' do
        @options = { local_infile: true }
        assert_true subject.query_options[:local_infile]
        assert_true subject.load_data_infile_options[:local_infile]
      end

      sub_test_case 'removed :local_infile in @db_config' do
        setup do
          @old_db_config = @db_config
          @db_config = DbConfig.to_hash(local_infile: false)
        end

        teardown do
          @db_config = @old_db_config
        end

        test 'Options does not have key named `:local_infile`' do
          @options = {}
          assert_false subject.query_options.has_key?(:local_infile)
          assert_false subject.load_data_infile_options.has_key?(:local_infile)
        end
      end
    end

    sub_test_case 'charset' do
      test 'Options does not have key named `:charset`' do
        @options = {}
        assert_equal 'utf8', DbConfig[:charset]
        assert_equal 'utf8', subject.load_data_infile_options[:charset]
      end
    end
  end

  sub_test_case '#import' do
    teardown do
      DbHelper.truncate('users')
    end

    def import(csv)
      @client.import(csv, { table: 'users' })
    end

    sub_test_case 'local_infile: true' do
      setup do
        @client = LoadDataInfile2::Client.new(@db_config, local_infile: true)
      end

      test 'success' do
        csv = File.expand_path('../../csv/users_valid.csv', __FILE__)
        import(csv)
        res = @client.query('SELECT * FROM `users`;').first
        assert_equal 1, res['id']
        assert_equal 'nalabjp', res['name']
        assert_equal 'nalabjp@gmail.com', res['email']
      end

      test 'failure' do
        csv = File.expand_path('../../csv/users_invalid.csv', __FILE__)
        import(csv)
        res = @client.query('SELECT * FROM `users`;').to_a
        assert_equal 2, res.size
        assert_equal 1, res[0]['id']
        assert_equal 'nalabjp', res[0]['name']
        assert_equal '', res[0]['email']
        assert_equal 2, res[1]['id']
        assert_equal 'nalabjp2', res[1]['name']
        assert_equal 'nalabjp2@gmail.com', res[1]['email']
      end
    end

    unless ENV['TRAVIS']
      sub_test_case 'local_infile: false' do
        setup do
          @db_config = DbConfig.to_hash(local_infile: false)
          @client = LoadDataInfile2::Client.new(@db_config, local_infile: false)
        end

        test 'failure' do
          csv = File.expand_path('../../csv/users_invalid.csv', __FILE__)
          assert_raise_kind_of(Mysql2::Error) { import(csv) }
          assert_raise_message("Row 1 doesn't contain data for all columns") { import(csv) }
          res = @client.query('SELECT * FROM `users`;')
          assert_equal 0, res.size
        end
      end
    end
  end

  test '#quoted_table_name_for' do
    assert_equal 'ldi_test', DbConfig[:database]
    assert_equal '`ldi_test`.`users`', LoadDataInfile2::Client.new(@db_config).quoted_table_name_for('users')
  end
end
