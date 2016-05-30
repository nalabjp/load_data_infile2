ENV['RAILS_ENV'] ||= 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

begin
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
rescue LoadError
end

begin
  require 'pry'
rescue LoadError
end

require 'rails'
require 'active_record'
require 'active_record/railtie'
require 'load_data_infile2'
require 'load_data_infile2/active_record'
require 'fake_app'
require 'test/unit/rails/test_help'

Dir[File.join(File.dirname(__FILE__), 'support/**/**.rb')].each {|f| require f }

DbHelper.restore_database
DbHelper.restore_tables
