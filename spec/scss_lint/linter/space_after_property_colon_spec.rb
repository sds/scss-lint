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

  context 'when the colon after a property is followed by a space' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
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

    context 'when the colon after a property is followed by multiple spaces and values are aligned' do
      let(:css) { <<-CSS }
        p {
          margin:  bold;
          padding: 0;
          a {
            font-weight: bold;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is followed by multiple spaces but values are not aligned' do
      let(:css) { <<-CSS }
        p {
          border-color: #fff;
          margin:        bold;
          padding:     0;
          a {
            font-weight: bold;
            margin: 0;
          }
        }
      CSS

      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
      it { should_not report_lint line: 6 }
      it { should report_lint line: 7 }
    end
  end
end
