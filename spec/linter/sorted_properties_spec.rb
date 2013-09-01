require 'spec_helper'

describe SCSSLint::Linter::SortedProperties do
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

  context 'when out-of-order property is the second last in the list of sorted properties' do
    let(:css) { <<-CSS }
      p {
        border: 0;
        border-radius: 3px;
        float: left;
        display: block;
      }
    CSS

    it { should report_lint line: 4 }
  end

  context 'when vendor-prefixed properties are ordered after the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        border-radius: 3px;
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when vendor-prefixed properties are ordered before the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
        border-radius: 3px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when vendor properties are ordered out-of-order before the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        -moz-border-radius: 3px;
        -webkit-border-radius: 3px;
        -o-border-radius: 3px;
        border-radius: 3px;
      }
    CSS

    it { should report_lint line: 3 }
  end
end
