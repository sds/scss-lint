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

  context 'when interpolation within single quotes is followed by inline property' do
    context 'and property name is followed by a space' do
      let(:css) { "[class~='\#{$test}'] { width: 100%; }" }

      it { should_not report_lint }
    end

    context 'and property name is not followed by a space' do
      let(:css) { "[class~='\#{$test}'] { width : 100%; }" }

      it { should report_lint }
    end
  end
end
