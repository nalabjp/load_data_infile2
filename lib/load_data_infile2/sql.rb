module LoadDataInfile2
  class Sql
    # @param          [String]  file File name
    # @param          [String]  table Table name
    # @param          [Hash]    options Options for `LOAD DATA INFILE` query
    # @option options [Symbol]  :low_priority_or_concurrent :low_priority or :concurrent option
    # @option options [Symbol]  :replace_or_ignore :replace or :ignore for duplicated record
    # @option options [Boolean] :local_infile Use local file
    # @option options [Array]   :partition Partition names
    # @option options [String]  :charset Character set
    # @option options [String]  :fields_terminated_by Column delimiter
    # @option options [String]  :fields_enclosed_by Enclosure character, for example double quote
    # @option options [String]  :fields_optionally_enclosed_by If the input value is not necessarily enclosed, use OPTIONALLY
    # @option options [String]  :fields_escaped_by Escape character
    # @option options [String]  :lines_starting_by Common prefix for all lines to skip over the prefix, and anything before it
    # @option options [String]  :lines_terminated_by Line delimiter
    # @option options [String]  :ignore_lines Number of ignore lines from the start of the file
    # @option options [Array]   :columns Specify a column list, if the order of the fields in the input file differs from the order of the columns in the table
    #                                    The column list can contain either column names or user variables
    # @option options [Hash]    :set Key of Hash should have only column name, value of Hash can use a scalar subquery
    #
    # @see https://dev.mysql.com/doc/refman/5.6/en/load-data.html
    def initialize(file, table, options = {})
      @file = file
      @table = table
      @options = options
    end

    def build
      [
        load_data_infile,
        replace_or_ignore,
        into_table,
        partition,
        character_set,
        fields,
        lines,
        ignore_lines,
        columns,
        set
      ].compact.join(' ').concat(';')
    end

    private

    attr_reader :file, :table, :options

    def load_data_infile
      stmt = 'LOAD DATA '
      stmt.concat("#{options[:low_priority_or_concurrent].upcase} ") if %i(low_priority concurrent).include?(options[:low_priority_or_concurrent])
      stmt.concat('LOCAL ') if options[:local_infile]
      stmt.concat("INFILE '#{file}'")
      stmt
    end

    def replace_or_ignore
      options[:replace_or_ignore].to_s.upcase if %i(replace ignore).include?(options[:replace_or_ignore])
    end

    def into_table
      "INTO TABLE #{table}"
    end

    def partition
      "PARTITION (#{Array(options[:partition]).join(', ')})" if options[:partition] && options[:partition].size > 0
    end

    def character_set
      "CHARACTER SET #{options[:charset]}" if options[:charset]
    end

    def fields
      fields = [
        fields_terminated_by,
        fields_enclosed_by,
        fields_optionally_enclosed_by,
        fields_escaped_by
      ].compact

      return if fields.size == 0

      "FIELDS #{fields.join(' ')}"
    end

    def fields_terminated_by
      "TERMINATED BY '#{options[:fields_terminated_by]}'" if options[:fields_terminated_by]
    end

    def fields_enclosed_by
      "ENCLOSED BY '#{options[:fields_enclosed_by]}'" if options[:fields_enclosed_by]
    end

    def fields_optionally_enclosed_by
      "OPTIONALLY ENCLOSED BY '#{options[:fields_optionally_enclosed_by]}'" if options[:fields_optionally_enclosed_by]
    end

    def fields_escaped_by
      "ESCAPED BY '#{options[:fields_escaped_by]}'" if options[:fields_escaped_by]
    end

    def lines
      lines = [
        lines_starting_by,
        lines_terminated_by
      ].compact

      return if lines.size == 0

      "LINES #{lines.join(' ')}"
    end

    def lines_starting_by
      "STARTING BY '#{options[:lines_starting_by]}'" if options[:lines_starting_by]
    end

    def lines_terminated_by
      "TERMINATED BY '#{options[:lines_terminated_by]}'" if options[:lines_terminated_by]
    end

    def ignore_lines
      "IGNORE #{options[:ignore_lines].to_i} LINES" if options[:ignore_lines].to_i > 0
    end

    def columns
      "(#{options[:columns].join(', ')})" if options[:columns] && options[:columns].size > 0
    end

    def set
      if options[:set] && options[:set].size > 0
        s = options[:set].map {|col, val| "#{col} = #{val}" }.join(', ')
        "SET #{s}"
      end
    end
  end
end
