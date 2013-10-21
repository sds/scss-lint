# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'scss_lint/version'

Gem::Specification.new do |s|
  s.name        = 'scss-lint'
  s.version     = SCSSLint::VERSION
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Causes Engineering', 'Shane da Silva']
  s.email       = ['eng@causes.com', 'shane@causes.com']
  s.homepage    = 'http://github.com/causes/scss-lint'
  s.summary     = 'SCSS lint tool'
  s.description = 'Opinionated tool to help write clean and consistent SCSS'

  s.files         = Dir['lib/**/*.rb']
  s.executables   = ['scss-lint']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'colorize', '0.5.8'
  s.add_dependency 'sass', '3.3.0.rc.1' # Hard dependency since we monkey patch AST

  s.add_development_dependency 'nokogiri', '1.6.0'
  s.add_development_dependency 'rspec', '2.13.0'
end
