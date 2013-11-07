require 'spec_helper'

describe SCSSLint::Linter::TrailingSemicolonAfterPropertyValue do
  context 'when a property does not end with a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property ends with a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a property ends with a space followed by a semicolon' do
    let(:css) { <<-CSS }
      p {
        margin: 0 ;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property ends with a semicolon and is followed by a comment' do
    let(:css) { <<-CSS }
      p {
        margin: 0;  // This is a comment
        padding: 0; /* This is another comment */
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a property contains nested properties' do
    context 'and there is a value on the namespace' do
      let(:css) { <<-CSS }
        p {
          font: 2px/3px {
            style: italic;
            weight: bold;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'and there is no value on the namespace' do
      let(:css) { <<-CSS }
        p {
          font: {
            style: italic;
            weight: bold;
          }
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when a nested property does not end with a semicolon' do
    let(:css) { <<-CSS }
      p {
        font: {
          weight: bold
        }
      }
    CSS

    it { should report_lint line: 3 }
  end
end
