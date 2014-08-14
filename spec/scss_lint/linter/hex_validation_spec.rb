require 'spec_helper'

describe SCSSLint::Linter::HexValidation do
  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains valid hex codes or color keyword' do
    gradient_css = 'progid:DXImageTransform.Microsoft.gradient' \
                   '(startColorstr=#99000000, endColorstr=#99000000)'

    let(:css) { <<-CSS }
      p {
        background: #000;
        color: #FFFFFF;
        border-color: red;
        filter: #{gradient_css};
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains invalid hex codes' do
    let(:css) { <<-CSS }
      p {
        background: #dd;
        color: #dddd;
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 3 }
  end
end
