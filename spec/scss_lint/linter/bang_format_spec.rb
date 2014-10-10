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
end
