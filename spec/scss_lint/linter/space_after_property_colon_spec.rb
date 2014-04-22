require 'spec_helper'

describe SCSSLint::Linter::SpaceAfterPropertyColon do
  context 'when the colon after a property is not followed by space' do
    let(:css) { <<-CSS }
      p {
        margin:0;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when the colon after a property is not followed by space and the semicolon is missing' do
    let(:css) { <<-CSS }
      p {
        color:#eee
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when the colon after a property is followed by a space' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when the colon after a property is surrounded by spaces' do
    let(:css) { <<-CSS }
      p {
        margin : bold;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when the colon after a property is followed by multiple spaces' do
    let(:css) { <<-CSS }
      p {
        margin:  bold;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when `allow_extra_spaces` option is true' do
    let(:linter_config) { { 'allow_extra_spaces' => true } }

    context 'when the colon after a property is not followed by space' do
      let(:css) { <<-CSS }
        p {
          margin:0;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when the colon after a property is followed by a space' do
      let(:css) { <<-CSS }
        p {
          margin: 0;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is followed by multiple spaces' do
      let(:css) { <<-CSS }
        p {
          margin:  bold;
        }
      CSS

      it { should_not report_lint }
    end
  end
end
