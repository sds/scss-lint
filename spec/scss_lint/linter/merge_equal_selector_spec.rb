require 'spec_helper'

describe SCSSLint::Linter::MergeEqualSelector do
  context 'when single root' do
    let(:scss) { <<-SCSS }
      p {
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when different roots' do
    let(:scss) { <<-SCSS }
      p {
        background: #000;
        margin: 5px;
      }
      a {
        background: #000;
        margin: 5px;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when there are duplicate rules nested in a rule set' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should report_lint }
  end

  context 'when different roots with matching inner rules' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should_not report_lint }
  end

  context 'when multi-selector roots and parital rule match' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should_not report_lint }
  end

  context 'when same class roots' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should report_lint }
  end

  context 'when same compond selector roots' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should report_lint }
  end

  context 'when same class roots separated by another class' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should report_lint }
  end

  context 'when rule in a mixin @include matches a root root' do
    let(:scss) { <<-SCSS }
      p {
        font-weight: bold;
      }
      @include enhance(small-tablet) {
        p {
          font-weight: normal;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule in a mixin definition matches a root rule' do
    let(:scss) { <<-SCSS }
      p {
        font-weight: bold;
      }
      @mixin my-mixin {
        p {
          font-weight: normal;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule in a media directive matches a root rule' do
    let(:scss) { <<-SCSS }
      p {
        font-weight: bold;
      }
      @media only screen and (min-device-pixel-ratio: 1.5) {
        p {
          font-weight: normal;
        }
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when rule in a keyframes directive matches a root rule' do
    let(:scss) { <<-SCSS }
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
    SCSS

    it { should_not report_lint }
  end

end
