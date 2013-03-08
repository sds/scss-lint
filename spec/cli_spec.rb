require 'spec_helper'
require 'rexml/document'


describe SCSSLint::CLI do
  let(:files) { ['spec/data/dummy1.scss', 'spec/data/dummy2.scss'] }

  context 'receives a file list and some options' do
    let(:args) { files }
    subject { SCSSLint::CLI.new args }

    it 'works' do
      STDOUT.should_receive(:puts).with(
        "2 - Properties should be sorted in alphabetical order"
      )
      subject
    end
  end

  context 'when no files are given' do
    let(:args) { [] }
    subject { SCSSLint::CLI.new args }

    it 'raises an error' do
      lambda { subject }.should raise_error(SystemExit)
    end
  end

  context 'when files are passed but excluded' do
    let(:args) { files + ['-e', 'dummy1.scss,dummy2.scss'] }
    subject { SCSSLint::CLI.new args }

    it "doesn't do nothing" do
      STDOUT.should_not_receive(:puts).with(
        "2 - Properties should be sorted in alphabetical order"
      )
      lambda { subject }.should raise_error(SystemExit)
    end
  end

  context 'when XML output is required' do
    let(:args) { ['-x'] + files }
    subject { SCSSLint::CLI.new args }

    it 'just work' do
      subject
    end

    it 'outputs valid XML' do
      runner = SCSSLint::Runner.new
      runner.run files
      output = subject.xml_output runner.lints

      xml = REXML::Document.new output
      xml.root.has_name?("lint").should be_true
      xml_file = xml.root.children[0]
      xml_file.has_name?("file").should be_true
      xml_issue = xml_file.children[0]
      xml_issue.has_name?("issue").should be_true
      issue_attrs = xml_issue.attributes
      issue_attrs.include?("line").should be_true
      issue_attrs.include?("reason").should be_true
      issue_attrs.include?("severity").should be_true
    end
  end
end
