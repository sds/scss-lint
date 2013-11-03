require 'spec_helper'

describe SCSSLint::Linter::SpaceAfterPropertyName do
  context 'when a property name is followed by a space' do
    let(:css) { <<-CSS }
      p {
        margin : 0;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property name is not followed by a space' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end
end
