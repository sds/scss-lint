require 'scss_lint'
require 'nokogiri'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.before(:each) do
    # If running a linter spec, run the described linter against the CSS code
    # for each example. This significantly DRYs up our linter specs to contain
    # only tests, since all the setup code is now centralized here.
    if described_class < SCSSLint::Linter
      initial_indent = css[/\A(\s*)/, 1]
      normalized_css = css.gsub(/^#{initial_indent}/, '')
      subject.run(SCSSLint::Engine.new(normalized_css))
    end
  end
end
