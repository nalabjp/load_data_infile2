# LoadDataInfile2

[![Build Status](https://travis-ci.org/nalabjp/load_data_infile2.svg?branch=master)](https://travis-ci.org/nalabjp/load_data_infile2)
[![Code Climate](https://codeclimate.com/github/nalabjp/load_data_infile2/badges/gpa.svg)](https://codeclimate.com/github/nalabjp/load_data_infile2)
[![Test Coverage](https://codeclimate.com/github/nalabjp/load_data_infile2/badges/coverage.svg)](https://codeclimate.com/github/nalabjp/load_data_infile2/coverage)
[![Dependency Status](https://gemnasium.com/nalabjp/load_data_infile2.svg)](https://gemnasium.com/nalabjp/load_data_infile2)

Import the data at a high speed to the table from a text file, using the [MySQL `LOAD DATA INFILE` statement](http://dev.mysql.com/doc/refman/5.7/en/load-data.html).

This gem is dependent on [mysql2](https://github.com/brianmario/mysql2).

By using mysql2, as well as plugin of ActiveRecord, it is possible to use in pure Ruby script.

## Installation

Add to your Gemfile:

```ruby
gem 'load_data_infile2'
```

And bundle.

## Examples
### Basic Usage

Database configuration:

```ruby
db_config = {
  host: 'localhost'
  database: 'ldi_test'
  username: 'root'
}
```

Create client:

```ruby
ldi_client = LoadDataInfile2::Client.new(db_config)
```

Import from CSV file:

```ruby
ldi_client.import('/path/to/data.csv')
```

[Default options](https://github.com/nalabjp/load_data_infile2/blob/master/lib/load_data_infile2.rb#L10-L22) are CSV format:

```ruby
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
```

### TSV format

If you are using TSV format:

```ruby
opts = {
  fileds_terminated_by: "\\t",
  fields_optionally_enclosed_by: "",
  fields_escaped_by: "\\"
}
ldi_client = LoadDataInfile2::Client.new(db_config, opts)
ldi_client.import('/path/to/data.tsv')
```

### LOAD DATA LOCAL INFILE

If you use `LOCAL` option:

```ruby
opts = { local_infile: true }
ldi_client = LoadDataInfile2::Client.new(db_config, opts)
ldi_client.import('/path/to/data.csv')
# => Execute "LOAD DATA LOCAL INFILE '/path/to/data.csv' INTO TABLE `ldi_test`.`data`;"
```

### SQL Options
Support all options of LOAD DATA INFILE statement on MySQL 5.7 .

see: http://dev.mysql.com/doc/refman/5.7/en/load-data.html

For examples:

```ruby
opts = { local_infile: true }
sql_opts = { table: 'special_users', ignore_lines: 1 }
ldi_client = LoadDataInfile2::Client.new(db_config, opts)
ldi_client.import('/path/to/users.csv', sql_opts)
```

#### Mappings
|MySQL|LoadDataInfile2|
| --- | --- |
| LOW_PRIORITY | low_priority_or_concurrent: :low_priority |
| CONCURRENT | low_priority_or_concurrent: :concurrent |
| LOCAL | local_infile: true |
| REPLACE | replace_or_ignore: :replace |
| IGNORE | replace_or_ignore: :ignore |
| *tbl_name* | table: 'special_table_name' |
| PARTITION | partition: 'p0' / ['p0', 'p1', ...] |
| CHARCTER SET | charset: 'utf8' |
| FIELDS TERMINATED BY | fields_terminated_by: ',' |
| FIELDS ENCLOSED BY | fields_enclosed_by: '"' |
| FIELDS OPTIONALLY ENCLOSED BY | fields_optionally_enclosed_by: '"' |
| FIELDS ESCAPED BY | fields_escaped_by: '"' |
| LINES STARTING BY | lines_starting_by: '***' |
| LINES TERMINATED BY | lines_terminated_by: '\\n' |
| IGNORE LINES | ignore_lines: 1 |
| *col_name_or_user_var* | columns: ['col1', 'col2', '@var3', ...] |
| SET *col_name* = *expr* | set: { col1: "'specific value'", col2: '@var', col3: 'NOW()' } |

### In Rails

Subclass of ActiveRecord is added `.load_data_infile`.

For example, in the case of User model, you can call the class method named `load_data_infile` from the User model.

```ruby
User.load_data_infile('/path/to/data.csv')
```

If you want to pass options to the initialization of `LoadDataInfile2::ActiveRecord`, you can use the accessor of class variable named `.default_load_data_infile_options`.

```ruby
User.default_load_data_infile_options = { ignore_lines: 1 }
User.load_data_infile('/path/to/data.csv')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nalabjp/load_data_infile2.

## License

MIT License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
