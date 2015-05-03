$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'scss_lint/constants'
require 'scss_lint/version'

Gem::Specification.new do |s|
  s.name             = 'scss_lint'
  s.version          = SCSSLint::VERSION
  s.license          = 'MIT'
  s.summary          = 'SCSS lint tool'
  s.description      = 'Configurable tool for writing clean and consistent SCSS'
  s.authors          = ['Brigade Engineering', 'Shane da Silva']
  s.email            = ['eng@brigade.com', 'shane.dasilva@brigade.com']
  s.homepage         = SCSSLint::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = ['scss-lint']

  s.files            = Dir['config/**/*.yml'] +
                       Dir['data/**/*'] +
                       Dir['lib/**/*.rb']

  s.test_files       = Dir['spec/**/*']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'rainbow', '~> 2.0'
  s.add_dependency 'sass', '~> 3.4.1'

  s.add_development_dependency 'nokogiri', '~> 1.6.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
