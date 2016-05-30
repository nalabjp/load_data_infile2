require 'yaml'

class DbConfig
  class << self
    def to_hash
      config
    end

    def [](key)
      config[key.to_s]
    end

    private

    def config
      @config ||= load_config
    end

    def load_config
      yaml = File.new(File.expand_path('../../config/database.yml', __FILE__))
      hash = YAML.load(ERB.new(yaml.read).result)
      hash.fetch('test')
    end
  end
end
