require 'spec_helper'
require 'scss_lint/rake_task'

describe SCSSLint::RakeTask do
  before do
    # Silence console output
    STDOUT.stub(:write)
  end

  describe '#run' do
    subject do
      SCSSLint::RakeTask.new
      Rake::Task['scss_lint']
    end

    it 'returns a successful exit code' do
      expect(subject.invoke.first.call).to be_truthy
    end
  end
end
