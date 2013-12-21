require 'spec_helper'

describe SCSSLint::Linter::SelectorDepth do
  context 'when sequence has a depth of one' do
    let(:css) { 'p {}' }

    it { should_not report_lint }
  end

  context 'when sequence has a depth of three' do
    let(:css) { 'body article p {}' }

    it { should_not report_lint }

    context 'and contains a nested selector' do
      let(:css) { <<-CSS }
        body article p {
          i {
            font-style: italic;
          }
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and contains multiple nested selectors' do
      let(:css) { <<-CSS }
        body article p {
          b {
            font-weight: bold;
          }
          i {
            font-style: italic;
          }
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 5 }
    end
  end

  context 'when sequence has a depth of four' do
    let(:css) { 'body article p i {}' }

    it { should report_lint line: 1 }
  end

  context 'when sequence is made up of adjacent sibling combinators' do
    let(:css) { '.one + .two + .three + .four {}' }

    it { should_not report_lint }
  end

  context 'when sequence is made up of general sibling combinators' do
    let(:css) { '.one .two ~ .three ~ .four {}' }

    it { should_not report_lint }
  end

  context 'when sequence contains interpolation' do
    let(:css) { '.one #{$interpolated-string} .two .three {}' }

    it { should_not report_lint }
  end

  context 'when comma sequence contains no sequences exceeding depth limit' do
    let(:css) { <<-CSS }
      p,
      .one .two .three,
      ul > li {
      }
    CSS

    it { should_not report_lint }

    context 'and a nested selector causes one of the sequences to exceed the limit' do
      let(:css) { <<-CSS }
        p,
        .one .two .three,
        ul > li {
          .four {}
        }
      CSS

      it { should report_lint line: 4 }
    end
  end

  context 'when comma sequence contains a sequence exceeding the depth limit' do
    let(:css) { <<-CSS }
      p,
      .one .two .three .four,
      ul > li {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when sequence contains a nested selector with a parent selector' do
    context 'which does not exceed the depth limit' do
      let(:css) { <<-CSS }
        .one .two  {
          .three & {}
        }
      CSS

      it { should_not report_lint }

      context 'and the parent selector is chained' do
        let(:css) { <<-CSS }
          .one .two .three {
            &.chained {}
          }
        CSS

        it { should_not report_lint }
      end
    end

    context 'which does exceed the depth limit' do
      let(:css) { <<-CSS }
        .one .two {
          .three & & .four {}
        }
      CSS

      it { should report_lint line: 2 }

      context 'and the parent selector is chained' do
        let(:css) { <<-CSS }
          .one .two .three > .four {
            &.chained {}
          }
        CSS

        it { should report_lint line: 2 }
      end
    end
  end
end
