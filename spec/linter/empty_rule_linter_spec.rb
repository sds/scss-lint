require 'spec_helper'

describe SCSSLint::Linter::EmptyRuleLinter do
  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when rule contains an empty nested rule' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
        }
      }
    CSS

    it { should report_lint line: 6 }
  end
end
