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

  def run_task_and_get_status
    Rake::Task[:scss_lint].reenable # Allows us to execute task multiple times

    begin
      Rake::Task[:scss_lint].invoke(file.path)
    rescue SystemExit => ex
      ex.status
    end
  end

  context 'when SCSS document is valid with no lints' do
    let(:scss) { '' }

    it 'executes successfully' do
      run_task_and_get_status.should == 0
    end
  end

  context 'when SCSS document is invalid' do
    let(:scss) { '.class {' }

    it 'returns an error status code' do
      run_task_and_get_status.should == 2
    end
  end
end
