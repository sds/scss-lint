require 'spec_helper'

describe SCSSLint::Reporter::DefaultReporter do
  subject { SCSSLint::Reporter::DefaultReporter.new(lints) }

  describe '#report_lints' do
    context 'when there are no lints' do
      let(:lints) { [] }

      it 'returns nil' do
        subject.report_lints.should be_nil
      end
    end

    context 'when there are lints' do
      let(:filenames)    { ['some-filename.scss', 'other-filename.scss'] }
      let(:lines)        { [5, 7] }
      let(:descriptions) { ['Description of lint 1', 'Description of lint 2'] }
      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          SCSSLint::Lint.new(filename, lines[index], descriptions[index])
        end
      end

      it 'prints each lint on its own line' do
        subject.report_lints.count("\n").should == 2
      end

      it 'prints a trailing newline' do
        subject.report_lints[-1].should == "\n"
      end

      it 'prints the filename for each lint' do
        filenames.each do |filename|
          subject.report_lints.scan(/#{filename}/).count.should == 1
        end
      end

      it 'prints the line number for each lint' do
        lines.each do |line|
          subject.report_lints.scan(/#{line}/).count.should == 1
        end
      end

      it 'prints the description for each lint' do
        descriptions.each do |description|
          subject.report_lints.scan(/#{description}/).count.should == 1
        end
      end
    end
  end
end
