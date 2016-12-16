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
                       Dir['lib/**/*.rb'] +
                       ['MIT-LICENSE']

  s.test_files       = Dir['spec/**/*']

  s.required_ruby_version = '>= 2'

  s.add_dependency 'rake', '>= 0.9', '< 13'
  s.add_dependency 'sass', '~> 3.4.20'
end
