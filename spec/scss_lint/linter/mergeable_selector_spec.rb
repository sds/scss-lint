require 'spec_helper'

describe SCSSLint::Linter::MergeableSelector do
  context 'when single root' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when different roots' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        margin: 5px;
      }
      a {
        background: #000;
        margin: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when different roots with matching inner rules' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        margin: 5px;
        .foo {
          color: red;
        }
      }
      a {
        background: #000;
        margin: 5px;
        .foo {
          color: red;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when multi-selector roots and parital rule match' do
    let(:css) { <<-CSS }
      p, a {
        background: #000;
        margin: 5px;
        .foo {
          color: red;
        }
      }
      a {
        background: #000;
        margin: 5px;
        .foo {
          color: red;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when nested and unnested selectors match' do
    let(:css) { <<-CSS }
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
    CSS

    context 'when force_nesting is enabled' do
      let(:linter_config) { { 'force_nesting' => true } }
      it { should report_lint }
    end

    context 'when force_nesting is disabled' do
      let(:linter_config) { { 'force_nesting' => false } }
      it { should_not report_lint }
    end
  end

  context 'when same class roots' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .warn {
        color: #f00;
        @extend .warn;
        a {
          color: #ccc;
        }
      }
    CSS

    it { should report_lint }
  end

  context 'when same compond selector roots' do
    let(:css) { <<-CSS }
      .warn .alert {
        font-weight: bold;
      }
      .warn .alert {
        color: #f00;
        @extend .warn;
        a {
          color: #ccc;
        }
      }
    CSS

    it { should report_lint }
  end

  context 'when same class roots separated by another class' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .foo {
        color: red;
      }
      .warn {
        color: #f00;
        @extend .warn;
        a {
          color: #ccc;
        }
      }
    CSS

    it { should report_lint }
  end

  context 'when rule in a mixin @include matches a root root' do
    let(:css) { <<-CSS }
      p {
        font-weight: bold;
      }
      @include enhance(small-tablet) {
        p {
          font-weight: normal;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule in a mixin definition matches a root rule' do
    let(:css) { <<-CSS }
      p {
        font-weight: bold;
      }
      @mixin my-mixin {
        p {
          font-weight: normal;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule in a media directive matches a root rule' do
    let(:css) { <<-CSS }
      p {
        font-weight: bold;
      }
      @media only screen and (min-device-pixel-ratio: 1.5) {
        p {
          font-weight: normal;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule in a keyframes directive matches a root rule' do
    let(:css) { <<-CSS }
      @keyframes slideouttoleft {
        from {
          transform: translateX(0);
        }

        to {
          transform: translateX(-100%);
        }
      }

      @keyframes slideouttoright {
        from {
          transform: translateX(0);
        }

        to {
          transform: translateX(100%);
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when there are duplicate rules nested in a rule set' do
    let(:css) { <<-CSS }
      .foo {
        .bar {
          font-weight: bold;
        }
        .baz {
          font-weight: bold;
        }
        .bar {
          color: #ff0;
        }
      }
    CSS

    it { should report_lint }
  end

  context 'when force_nesting is enabled' do
    let(:linter_config) { { 'force_nesting' => true } }

    context 'when one of the duplicate rules is in a comma sequence' do
      let(:css) { <<-CSS }
        .foo,
        .bar {
          color: #000;
        }
        .foo {
          color: #f00;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when rules start with the same prefix but are not the same' do
      let(:css) { <<-CSS }
        .foo {
          color: #000;
        }
        .foobar {
          color: #f00;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when a rule contains interpolation' do
      let(:css) { <<-CSS }
        .\#{$class-name} {}
        .foobar {}
      CSS

      it { should_not report_lint }
    end
  end
end
