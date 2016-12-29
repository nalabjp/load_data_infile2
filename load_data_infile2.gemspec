lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'load_data_infile2/version'

Gem::Specification.new do |spec|
  spec.name          = 'load_data_infile2'
  spec.version       = LoadDataInfile2::VERSION
  spec.authors       = ['nalabjp']
  spec.email         = ['nalabjp@gmail.com']

  spec.summary       = "This gem provides MySQL's LOAD DATA INFILE for Mysql2 and ActiveRecord"
  spec.description   = "This gem provides MySQL's LOAD DATA INFILE for Mysql2 and ActiveRecord"
  spec.homepage      = 'https://github.com/nalabjp/load_data_infile2'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mysql2', '~> 0.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'test-unit-rails'
end
