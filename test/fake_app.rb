module FakeApp
  Application = Class.new(Rails::Application) do
    config.root = __dir__
    config.eager_load = false
    config.active_support.deprecation = :log
  end.initialize!
end

class User < ActiveRecord::Base; end
