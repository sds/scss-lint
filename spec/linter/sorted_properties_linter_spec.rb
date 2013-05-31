require 'spec_helper'

describe SCSSLint::Linter::SortedPropertiesLinter do
  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in sorted order' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains mixins followed by properties in sorted order' do
    let(:css) { <<-CSS }
      p {
        @include border-radius(5px);
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains nested rules after sorted properties' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
          color: #555;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in random order' do
    let(:css) { <<-CSS }
      p {
        padding: 5px;
        display: block;
        margin: 10px;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when there are multiple rules with out of order properties' do
    let(:css) { <<-CSS }
      p {
        display: block;
        background: #fff;
      }
      a {
        margin: 5px;
        color: #444;
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 6 }
  end

  context 'when there are nested rules with out of order properties' do
    let(:css) { <<-CSS }
      p {
        display: block;
        background: #fff;
        a {
          margin: 5px;
          color: #444;
        }
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 5 }
  end
end
