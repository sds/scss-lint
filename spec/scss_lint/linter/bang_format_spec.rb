require 'spec_helper'

describe SCSSLint::Linter::BangFormat do
  context 'when no bang is used' do
    let(:css) { <<-CSS }
      p {
        color: #000;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when !important is used correctly' do
    let(:css) { <<-CSS }
      p {
        color: #000 !important;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when !important has no space before' do
    let(:css) { <<-CSS }
      p {
        color: #000!important;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when !important has a space after' do
    let(:css) { <<-CSS }
      p {
        color: #000 ! important;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when !important has a space after and config allows it' do
    let(:linter_config) { { 'space_before_bang' => true, 'space_after_bang' => true } }

    let(:css) { <<-CSS }
      p {
        color: #000 ! important;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when !important has a space before but config does not allow it' do
    let(:linter_config) { { 'space_before_bang' => false, 'space_after_bang' => true } }

    let(:css) { <<-CSS }
      p {
        color: #000 ! important;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when !important has no spaces around and config allows it' do
    let(:linter_config) { { 'space_before_bang' => false, 'space_after_bang' => false } }

    let(:css) { <<-CSS }
      p {
        color: #000!important;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when ! appears within a string' do
    let(:css) { <<-CSS }
      p:before { content: "!important"; }
      p:before { content: "imp!ortant"; }
      p:after { content: '!'; }
      div:before { content: 'important!'; }
      div:after { content: '  !  '; }
      p[attr="foo!bar"] {};
      p[attr='foo!bar'] {};
      p[attr="!foobar"] {};
      p[attr='foobar!'] {};
      $foo: 'bar!';
      $foo: "bar!";
      $foo: "!bar";
      $foo: "b!ar";
    CSS

    it { should_not report_lint }
  end

  context 'when !<word> is not followed by a semicolon' do
    let(:css) { <<-CSS }
      .class {
        margin: 0 !important
      }
    CSS

    it 'does not loop forever' do
      subject.should_not report_lint
    end
  end
end
