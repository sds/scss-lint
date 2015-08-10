require 'spec_helper'

describe SCSSLint::Linter::NestableSelector do

  context 'when nested and unnested selectors match' do
    let(:scss) { <<-SCSS }
      a.current {
        background: #000;
        margin: 5px;
        .foo {
          color: red;
        }
      }
      a {
        &.current {
          background: #000;
          margin: 5px;
          .foo {
            color: red;
          }
        }
      }
    SCSS

    it { should report_lint }
  end

  context 'when one of the duplicate rules is in a comma sequence' do
    let(:scss) { <<-SCSS }
        .foo,
        .bar {
          color: #000;
        }
        .foo {
          color: #f00;
        }
    SCSS

    it { should_not report_lint }
  end

  context 'when rules start with the same prefix but are not the same' do
    let(:scss) { <<-SCSS }
        .foo {
          color: #000;
        }
        .foobar {
          color: #f00;
        }
    SCSS

    it { should_not report_lint }
  end

  context 'when a rule contains interpolation' do
    let(:scss) { <<-SCSS }
        .\#{$class-name} {}
        .foobar {}
    SCSS

    it { should_not report_lint }
  end

end

