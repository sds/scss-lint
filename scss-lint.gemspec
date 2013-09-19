# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'scss_lint/version'

Gem::Specification.new do |s|
  s.name        = 'scss-lint'
  s.version     = SCSSLint::VERSION
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Causes Engineering']
  s.email       = ['eng@causes.com', 'shane@causes.com']
  s.homepage    = 'http://github.com/causes/scss-lint'
  s.summary     = 'SCSS lint tool'
  s.description = 'Opinionated tool that tells you whether or not your SCSS is "bad"'

  s.files         = Dir['lib/**/*.rb']
  s.executables   = ['scss-lint']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'colorize'
  s.add_dependency 'sass', '3.2.10' # Hard dependency since we monkey patch AST

  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rspec'
end
