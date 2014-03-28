require 'spec_helper'

describe SCSSLint::Linter::DuplicateProperty do
  context 'when rule set is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule set contains no duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule set contains duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
        margin: 1em;
      }
    CSS

    it { should report_lint line: 4 }
  end

  context 'when rule set contains duplicates but only on vendor-prefixed property values' do
    let(:css) { <<-CSS }
      p {
        background: -moz-linear-gradient(center top , #fff, #000);
        background: -ms-linear-gradient(center top , #fff, #000);
        background: -o-linear-gradient(center top , #fff, #000);
        background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#000));
        background: linear-gradient(center top , #fff, #000);
        margin: 1em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when placeholder contains duplicates but only on vendor-prefixed values' do
    let(:css) { <<-CSS }
      %cursor-grabbing {
        cursor: -moz-grabbing;
        cursor: -webkit-grabbing;
        cursor: grabbing;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when placeholder contains exact duplicates besides for vendor-prefixed values' do
    let(:css) { <<-CSS }
      %cursor-grabbing {
        cursor: grabbing;
        cursor: grabbing;
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when mixin contains duplicates but only on vendor-prefixed values' do
    let(:css) { <<-CSS }
      @mixin cursor-grabbing($num) {
        cursor: -moz-grabbing;
        cursor: -webkit-grabbing;
        cursor: grabbing;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when mixin contains duplicates besides for vendor-prefixed values' do
    let(:css) { <<-CSS }
      @mixin cursor-grabbing($num) {
        cursor: grabbing;
        cursor: grabbing;
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when rule set contains exact duplicates besides for vendor-prefixed property values' do
    let(:css) { <<-CSS }
      p {
        background: -moz-linear-gradient(center top , #fff, #000);
        background: -ms-linear-gradient(center top , #fff, #000);
        background: -o-linear-gradient(center top , #fff, #000);
        background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#000));
        background: linear-gradient(center top , #fff, #000);
        background: linear-gradient(center top , #fff, #000);
        margin: 1em;
      }
    CSS

    it { should report_lint line: 7 }
  end

  context 'when rule set contains non-exact duplicates besides for vendor-prefixed values' do
    let(:css) { <<-CSS }
      p {
        background: -moz-linear-gradient(center top , #fff, #000);
        background: -ms-linear-gradient(center top , #fff, #000);
        background: -o-linear-gradient(center top , #fff, #000);
        background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#000));
        background: linear-gradient(center top , #fff, #000);
        background: linear-gradient-b(center top , #fff, #000);
        margin: 1em;
      }
    CSS

    it { should report_lint line: 7 }
  end

  context 'when rule set contains multiple duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
        margin: 1em;
        margin: 2em;
      }
    CSS

    it { should report_lint line: 4 }
    it { should report_lint line: 5 }
  end

  context 'when rule set contains duplicate properties with interpolation' do
    let(:css) { <<-CSS }
      p {
        $direction: 'right';
        margin-\#{direction}: 0;
        $direction: 'left';
        margin-\#{direction}: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property contains a variable' do
    let(:css) { <<-CSS }
      p {
        color: $some-color;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property contains a duplicate variable' do
    let(:css) { <<-CSS }
      p {
        color: $some-color;
        color: $some-color;
      }
    CSS

    it { should report_lint line: 3 }
  end
end
