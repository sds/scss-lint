require 'spec_helper'

describe SCSSLint::Linter::NestingDepth do
  # default depth is 1
  context 'when nesting has a depth of zero' do
    let(:css) { <<-CSS }
      .zero {
        font-style: italic;
      }
    CSS
    it { should_not report_lint }
  end

  context 'when nesting has a depth of one' do
    let(:css) { <<-CSS }
      .zero {
        .zero-0 {
          font-style: italic;
        }
      }
      .one {
        font-style: italic;
      }
    CSS
    it { should_not report_lint }
  end

  context 'when nesting has a depth of two' do
    let(:css) { <<-CSS }
      .zero {
        .zero-0 {
          .zero-0-0 {
            background: #f00;
          }
        }
        .zero-1 {
          font-style: italic;
        }
      }
    CSS
    it { should report_lint }
  end

  # linter should only be concerned about the nesting selector depth
  context 'when nesting properties' do
    let(:css) { <<-CSS }
      .zero {
        .zero-0 {
          font: {
            family: monospace;
            style: italic;
          }
        }
      }
    CSS
    it { should_not report_lint }
  end

  # anim's should not be considered
  context 'when sequence contains a @keyframe' do
    let(:css) { <<-CSS }
      @keyframe my-keyframe {
        0% {
          background: #000;
        }

        50% {
          background: #fff;
        }
      }
    CSS

    it { should_not report_lint }
  end
end
