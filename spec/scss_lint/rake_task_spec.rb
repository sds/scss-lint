require 'spec_helper'
require 'scss_lint/rake_task'
require 'tempfile'

describe SCSSLint::RakeTask do
  before(:all) do
    SCSSLint::RakeTask.new
  end

  before do
    STDOUT.stub(:write) # Silence console output
  end

  let(:file) do
    Tempfile.new(%w[scss-file .scss]).tap do |f|
      f.write(scss)
      f.close
    end
  end

  def run_task
    Rake::Task[:scss_lint].tap do |t|
      t.reenable # Allows us to execute task multiple times
      t.invoke(file.path)
    end
  end

  context 'when SCSS document is valid with no lints' do
    let(:scss) { '' }

    it 'does not call Kernel.exit' do
      expect { run_task }.not_to raise_error
    end
  end

  context 'when SCSS document is invalid' do
    let(:scss) { '.class {' }

    it 'calls Kernel.exit with the status code' do
      expect { run_task }.to raise_error SystemExit
    end
  end
end
