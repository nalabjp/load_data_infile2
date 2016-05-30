require 'test_helper'

class LoadDataInfile2::SqlTest < Test::Unit::TestCase
  setup do
    @file = '/path/to/test_tables.csv'
    @table = '`test_tables`'
    @options = {}
    subject { LoadDataInfile2::Sql.new(@file, @table, @options).build }
  end

  sub_test_case 'Options is empty' do
    test 'File basename equal table name' do
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
    end
  end

  sub_test_case 'LOAD DATA INFILE statement' do
    sub_test_case 'When options has key of `:low_priority_or_concurrent`' do
      test 'When value of `:low_priority_or_concurrent` is `:low_priority`' do
        @options = { low_priority_or_concurrent: :low_priority }
        assert_equal "LOAD DATA LOW_PRIORITY INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
      end

      test 'When value of `:low_priority_or_concurrent` is `:conncurrent`' do
        @options = { low_priority_or_concurrent: :concurrent }
        assert_equal "LOAD DATA CONCURRENT INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
      end
    end

    sub_test_case 'When options has key of `:local_infile`' do
      test 'When value of `:local_infile` is `true`' do
        @options = { local_infile: true }
        assert_equal "LOAD DATA LOCAL INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
      end

      test 'When value of `:local_infile` is `false`' do
        @options = { local_infile: false }
        assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
      end
    end
  end

  sub_test_case 'REPLACE or IGNORE option' do
    test 'When value of `:replace_or_ignore` is `:replace`' do
      @options = { replace_or_ignore: :replace }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' REPLACE INTO TABLE `test_tables`;", subject
    end

    test 'When value of `:replace_or_ignore` is `:ignore`' do
      @options = { replace_or_ignore: :ignore }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' IGNORE INTO TABLE `test_tables`;", subject
    end
  end

  sub_test_case 'INTO TABLE clause' do
    test 'When table name is `another_test_tables`' do
      @table = '`another_test_tables`'
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `another_test_tables`;", subject
    end
  end

  sub_test_case 'PARTITION clause' do
    test 'When it has one partition' do
      @options = { partition: 'p0' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` PARTITION (p0);", subject
    end

    test 'When it has two partitions' do
      @options = { partition: %w(p0 p1) }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` PARTITION (p0, p1);", subject
    end
  end

  sub_test_case'CHARACTER SET clause' do
    test 'When value of `:charset` is `utf8`' do
      @options = { charset: 'utf8' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` CHARACTER SET utf8;", subject
    end
  end

  sub_test_case 'FIELDS clause' do
    test 'When value of `:fields_terminated_by` is `,`' do
      @options = { fields_terminated_by: ',' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` FIELDS TERMINATED BY ',';", subject
    end

    test'When value of `:fields_enclosed_by` is `"`' do
      @options = { fields_enclosed_by: '"' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` FIELDS ENCLOSED BY '\"';", subject
    end

    test 'When value of `:fields_optionally_enclosed_by` is `"`' do
      @options = { fields_optionally_enclosed_by: '"' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` FIELDS OPTIONALLY ENCLOSED BY '\"';", subject
    end

    test 'When value of `:fields_escaped_by` is `"`' do
      @options = { fields_escaped_by: '"' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` FIELDS ESCAPED BY '\"';", subject
    end
  end

  sub_test_case 'LINES clause' do
    test 'When value of `:lines_starting_by` is `***`' do
      @options = { lines_starting_by: '***' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` LINES STARTING BY '***';", subject
    end

    test 'When value of `:lines_terminated_by` is `\\n`' do
      @options = { lines_terminated_by: '\\n' }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` LINES TERMINATED BY '\\n';", subject
    end
  end

  sub_test_case 'IGNORE clause' do
    test 'When value of `:ignore_lines` is `0`' do
      @options = { ignore_lines: 0 }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables`;", subject
    end

    test 'When value of `:ignore_lines` is `1`' do
      @options = { ignore_lines: 1 }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` IGNORE 1 LINES;", subject
    end
  end

  sub_test_case 'columns' do
    test 'when it has one column' do
      @options = { columns: %w(col1) }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` (col1);", subject
    end

    test 'when it has two columns' do
      @options = { columns: %w(col1 col2) }
      assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` (col1, col2);", subject
    end
  end

  test 'SET clause' do
    @options = { set: { col1: "'specific value'", col2: '@var', col3: 'NOW()' } }
    assert_equal "LOAD DATA INFILE '/path/to/test_tables.csv' INTO TABLE `test_tables` SET col1 = 'specific value', col2 = @var, col3 = NOW();", subject
  end

  test 'Order of all options' do
    @options = {
      low_priority_or_concurrent: :low_priority,
      local_infile: true,
      replace_or_ignore: :replace,
      partition: %w(p0 p1),
      charset: 'utf8',
      fields_terminated_by: ',',
      fields_enclosed_by: '"',
      fields_escaped_by: '"',
      lines_starting_by: '***',
      lines_terminated_by: '\\n',
      ignore_lines: 1,
      columns: %w(col1 col2),
      set: { col1: "'specific value'", col2: '@var', col3: 'NOW()' }
    }
    assert_equal "LOAD DATA LOW_PRIORITY LOCAL INFILE '/path/to/test_tables.csv' REPLACE INTO TABLE `test_tables` PARTITION (p0, p1) CHARACTER SET utf8 FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' LINES STARTING BY '***' TERMINATED BY '\\n' IGNORE 1 LINES (col1, col2) SET col1 = 'specific value', col2 = @var, col3 = NOW();", subject
  end
end
