require 'scss_lint'
require 'nokogiri'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end

  config.mock_with :rspec do |c|
    c.syntax = :should
  end

  config.before(:each) do
    # If running a linter spec, run the described linter against the CSS code
    # for each example. This significantly DRYs up our linter specs to contain
    # only tests, since all the setup code is now centralized here.
    if described_class < SCSSLint::Linter
      initial_indent = css[/\A(\s*)/, 1]
      normalized_css = css.gsub(/^#{initial_indent}/, '')

      # Use the configuration settings defined by default unless a specific
      # configuration has been provided for the test.
      local_config = if respond_to?(:linter_config)
                       linter_config
                     else
                       SCSSLint::Config.default.linter_options(subject)
                     end

      subject.run(SCSSLint::Engine.new(normalized_css), local_config)
    end
  end
end
