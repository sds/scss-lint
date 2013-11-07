require 'spec_helper'

describe SCSSLint::Reporter::XMLReporter do
  subject { SCSSLint::Reporter::XMLReporter.new(lints) }

  describe '#report_lints' do
    let(:xml) { Nokogiri::XML(subject.report_lints) }

    shared_examples_for 'XML document' do
      it 'has an encoding of UTF-8' do
        xml.encoding.should == 'utf-8'
      end

      it 'has an XML version of 1.0' do
        xml.version.should == '1.0'
      end

      it 'contains a <lint> root element' do
        xml.root.name.should == 'lint'
      end
    end

    context 'when there are no lints' do
      let(:lints) { [] }

      it_should_behave_like 'XML document'
    end

    context 'when there are lints' do
      let(:filenames)    { ['f1.scss', 'f2.scss', 'f1.scss'] }
      let(:lines)        { [5, 7, 9] }
      let(:descriptions) { ['lint 1', 'lint 2', 'lint 3'] }
      let(:severities)   { [:warning] * 3 }
      let(:lints) do
        filenames.each_with_index.map do |filename, index|
          SCSSLint::Lint.new(filename, lines[index], descriptions[index], severities[index])
        end
      end

      it_should_behave_like 'XML document'

      it 'contains an <issue> node for each lint' do
        xml.xpath('//issue').count.should == 3
      end

      it 'contains a <file> node for each file' do
        xml.xpath('//file').map { |node| node[:name] }.
          should =~ filenames.uniq
      end

      it 'contains <issue> nodes grouped by <file>' do
        xml.xpath('//file').map do |file_node|
          file_node.xpath('./issue').count
        end.should =~ [1, 2]
      end

      it 'marks each issue with a line number' do
        xml.xpath("//issue[@line]").map { |node| node[:line] }.
          should =~ lines.map(&:to_s)
      end

      it 'marks each issue with a reason containing the lint description' do
        xml.xpath("//issue[@reason]").map { |node| node[:reason] }.
          should =~ descriptions
      end

      context 'when lints are warnings' do
        it 'marks each issue with a severity of "warning"' do
          xml.xpath("//issue[@severity='warning']").count == 3
        end
      end

      context 'when lints are errors' do
        let(:severities) { [:error] * 3 }

        it 'marks each issue with a severity of "error"' do
          xml.xpath("//issue[@severity='error']").count == 3
        end
      end
    end
  end
end
