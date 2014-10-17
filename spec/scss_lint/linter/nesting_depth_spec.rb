require 'spec_helper'

describe SCSSLint::Linter::NestingDepth do
  context 'and selectors are nested up to depth 3' do
    let(:css) { <<-CSS }
      .one {
        .two {
          .three {
            background: #f00;
          }
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'and selectors are nested greater than depth 3' do
    let(:css) { <<-CSS }
      .one {
        .two {
          .three {
            .four {
              background: #f00;
            }
            .four-other {
              background: #f00;
            }
          }
        }
      }
    CSS

    it { should report_lint line: 4 }
    it { should report_lint line: 7 }
  end

  context 'when max_depth is set to 1' do
    let(:linter_config) { { 'max_depth' => 1 } }

    context 'when nesting has a depth of one' do
      let(:css) { <<-CSS }
        .one {
          font-style: italic;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when nesting has a depth of two' do
      let(:css) { <<-CSS }
        .one {
          .two {
            font-style: italic;
          }
        }
        .one {
          font-style: italic;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when nesting has a depth of three' do
      let(:css) { <<-CSS }
        .one {
          .two {
            .three {
              background: #f00;
            }
          }
          .two-other {
            font-style: italic;
          }
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 7 }
      it { should_not report_lint line: 3 }
    end

    context 'when nesting properties' do
      let(:css) { <<-CSS }
        .one {
          font: {
            family: monospace;
            style: italic;
          }
        }
      CSS

      it { should_not report_lint }
    end

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
end
