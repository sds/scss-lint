require 'spec_helper'

describe SCSSLint::Linter::NestingDepth do
  context 'and selectors are nested up to depth 3' do
    let(:scss) { <<-SCSS }
      .one {
        .two {
          .three {
            background: #f00;
          }
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'and selectors are nested greater than depth 3' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should report_lint line: 4 }
    it { should report_lint line: 7 }
  end

  context 'when max_depth is set to 1' do
    let(:linter_config) { { 'max_depth' => 1 } }

    context 'when nesting has a depth of one' do
      let(:scss) { <<-SCSS }
        .one {
          font-style: italic;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when nesting has a depth of two' do
      let(:scss) { <<-SCSS }
        .one {
          .two {
            font-style: italic;
          }
        }
        .one {
          font-style: italic;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when nesting has a depth of three' do
      let(:scss) { <<-SCSS }
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
      SCSS

      it { should report_lint line: 2 }
      it { should report_lint line: 7 }
      it { should_not report_lint line: 3 }
    end

    context 'when nesting properties' do
      let(:scss) { <<-SCSS }
        .one {
          font: {
            family: monospace;
            style: italic;
          }
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when sequence contains a @keyframe' do
      let(:scss) { <<-SCSS }
        @keyframe my-keyframe {
          0% {
            background: #000;
          }

          50% {
            background: #fff;
          }
        }
      SCSS

      it { should_not report_lint }
    end
  end
end
