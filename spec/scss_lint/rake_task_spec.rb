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

    it 'raises error when no files are specified' do
      lambda { subject.invoke.first.call }.should raise_error SystemExit
    end
  end
end
