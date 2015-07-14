require 'spec_helper'

describe SCSSLint::Linter::DisableLinterReason do
  context 'when no disabling instructions exist' do
    let(:scss) { <<-SCSS }
      // Comment.
      p {
        margin: 0;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when no reason accompanies a disabling comment' do
    let(:scss) { <<-SCSS }
      // scss-lint:disable BorderZero
      p {
        margin: 0;
      }
    SCSS

    it { should report_lint line: 1 }
  end

  context 'when a reason immediately precedes a disabling comment' do
    let(:scss) { <<-SCSS }
      // We like using `border: none` in our CSS.
      // scss-lint:disable BorderZero
      p {
        margin: 0;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when a reason precedes a disabling comment, at a distance' do
    let(:scss) { <<-SCSS }
      // We like using `border: none` in our CSS.

      // scss-lint:disable BorderZero
      p {
        margin: 0;
      }
    SCSS

    it { should_not report_lint }
  end
end
