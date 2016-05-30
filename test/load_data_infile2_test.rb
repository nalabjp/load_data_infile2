require 'test_helper'

class LoadDataInfile2Test < Test::Unit::TestCase
  test 'It has a version number' do
    assert_not_nil ::LoadDataInfile2::VERSION
  end

  test '.default_import_options' do
    opts = LoadDataInfile2.default_import_options
    assert_equal ',', opts[:fields_terminated_by]
    assert_equal '"', opts[:fields_optionally_enclosed_by]
    assert_equal '"', opts[:fields_escaped_by]
    assert_equal '\\n', opts[:lines_terminated_by]
    assert_equal 0, opts[:ignore_lines]
  end
end
