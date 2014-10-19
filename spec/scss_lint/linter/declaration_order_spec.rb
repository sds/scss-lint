require 'spec_helper'

describe SCSSLint::Linter::DeclarationOrder do
  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains only properties' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        margin: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains only mixins' do
    let(:css) { <<-CSS }
      p {
        @include border-radius(5px);
        @include box-shadow(5px);
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains no mixins or properties' do
    let(:css) { <<-CSS }
      p {
        a {
          color: #f00;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties after nested rules' do
    let(:css) { <<-CSS }
      p {
        a {
          color: #f00;
        }
        color: #f00;
        margin: 5px;
      }
    CSS

    it { should report_lint }
  end

  context 'when @extend appears before any properties or rules' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .error {
        @extend .warn;
        color: #f00;
        a {
          color: #ccc;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @extend appears after a property' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .error {
        color: #f00;
        @extend .warn;
        a {
          color: #ccc;
        }
      }
    CSS

    it { should report_lint }
  end

  context 'when nested rule set' do
    context 'contains @extend before a property' do
      let(:css) { <<-CSS }
        p {
          a {
            @extend foo;
            color: #f00;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'contains @extend after a property' do
      let(:css) { <<-CSS }
        p {
          a {
            color: #f00;
            @extend foo;
          }
        }
      CSS

      it { should report_lint }
    end

    context 'contains @extend after nested rule set' do
      let(:css) { <<-CSS }
        p {
          a {
            span {
              color: #000;
            }
            @extend foo;
          }
        }
      CSS

      it { should report_lint }
    end
  end

  context 'when @include appears' do
    context 'before a property and rule set' do
      let(:css) { <<-CSS }
        .error {
          @include warn;
          color: #f00;
          a {
            color: #ccc;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'after a property and before a rule set' do
      let(:css) { <<-CSS }
        .error {
          color: #f00;
          @include warn;
          a {
            color: #ccc;
          }
        }
      CSS

      it { should report_lint }
    end
  end

  context 'when @include that features @content appears' do
    context 'before a property' do
      let(:css) { <<-CSS }
        .foo {
          @include breakpoint("phone") {
            color: #ccc;
          }
          color: #f00;
        }
      CSS

      it { should report_lint }
    end

    context 'after a property' do
      let(:css) { <<-CSS }
        .foo {
          color: #f00;
          @include breakpoint("phone") {
            color: #ccc;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'before an @extend' do
      let(:css) { <<-CSS }
        .foo {
          @include breakpoint("phone") {
            color: #ccc;
          }
          @extend .bar;
        }
      CSS

      it { should report_lint }
    end

    context 'before a rule set' do
      let(:css) { <<-CSS }
        .foo {
          @include breakpoint("phone") {
            color: #ccc;
          }
          a {
            color: #fff;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'after a rule set' do
      let(:css) { <<-CSS }
        .foo {
          a {
            color: #fff;
          }
          @include breakpoint("phone") {
            color: #ccc;
          }
        }
      CSS

      it { should report_lint }
    end

    context 'with its own nested rule set' do
      context 'before a property' do
        let(:css) { <<-CSS }
          .foo {
            background: #fff;
            @include breakpoint("phone") {
              a {
                color: #000;
              }
              color: #ccc;
            }
          }
        CSS

        it { should report_lint }
      end

      context 'after a property' do
        let(:css) { <<-CSS }
          .foo {
            background: #fff;
            @include breakpoint("phone") {
              color: #ccc;
              a {
                color: #000;
              }
            }
          }
        CSS

        it { should_not report_lint }
      end
    end
  end

  context 'when the nesting is crazy deep' do
    context 'and nothing is wrong' do
      let(:css) { <<-CSS }
        div {
          ul {
            @extend .thing;
            li {
              @include box-shadow(yes);
              background: green;
              a {
                span {
                  @include border-radius(5px);
                  color: #000;
                }
              }
            }
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'and something is wrong' do
      let(:css) { <<-CSS }
        div {
          ul {
            li {
              a {
                span {
                  color: #000;
                  @include border-radius(5px);
                }
              }
            }
          }
        }
      CSS

      it { should report_lint }
    end
  end

  context 'when inside a @media query and rule set' do
    context 'contains @extend before a property' do
      let(:css) { <<-CSS }
        @media only screen and (max-width: 1px) {
          a {
            @extend foo;
            color: #f00;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'contains @extend after a property' do
      let(:css) { <<-CSS }
        @media only screen and (max-width: 1px) {
          a {
            color: #f00;
            @extend foo;
          }
        }
      CSS

      it { should report_lint }
    end

    context 'contains @extend after nested rule set' do
      let(:css) { <<-CSS }
        @media only screen and (max-width: 1px) {
          a {
            span {
              color: #000;
            }
            @extend foo;
          }
        }
      CSS

      it { should report_lint }
    end
  end

  context 'when a pseudo-element appears before a property' do
    let(:css) { <<-CSS }
      a {
        &:hover {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a pseudo-element appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        &:focus {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a chained selector appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        &.is-active {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a chained selector appears before a property' do
    let(:css) { <<-CSS }
      a {
        &.is-active {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a selector with parent reference appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        .is-active & {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a selector with parent reference appears before a property' do
    let(:css) { <<-CSS }
      a {
        .is-active & {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a pseudo-element appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        &:before {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a pseudo-element appears before a property' do
    let(:css) { <<-CSS }
      a {
        &:before {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a direct descendent appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        > .foo {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a direct descendent appears before a property' do
    let(:css) { <<-CSS }
      a {
        > .foo {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when an adjacent sibling appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        & + .foo {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an adjacent sibling appears before a property' do
    let(:css) { <<-CSS }
      a {
        & + .foo {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a general sibling appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        & ~ .foo {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a general sibling appears before a property' do
    let(:css) { <<-CSS }
      a {
        & ~ .foo {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end

  context 'when a descendent appears after a property' do
    let(:css) { <<-CSS }
      a {
        color: #fff;
        .foo {
          color: #000;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a descendent appears before a property' do
    let(:css) { <<-CSS }
      a {
        .foo {
          color: #000;
        }
        color: #fff;
      }
    CSS

    it { should report_lint }
  end
end
