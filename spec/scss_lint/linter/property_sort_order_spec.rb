require 'spec_helper'

describe SCSSLint::Linter::PropertySortOrder do
  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in sorted order' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains mixins followed by properties in sorted order' do
    let(:css) { <<-CSS }
      p {
        @include border-radius(5px);
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains nested rules after sorted properties' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
          color: #555;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties in random order' do
    let(:css) { <<-CSS }
      p {
        padding: 5px;
        display: block;
        margin: 10px;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when there are multiple rules with out of order properties' do
    let(:css) { <<-CSS }
      p {
        display: block;
        background: #fff;
      }
      a {
        margin: 5px;
        color: #444;
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 6 }
  end

  context 'when there are nested rules with out of order properties' do
    let(:css) { <<-CSS }
      p {
        display: block;
        background: #fff;
        a {
          margin: 5px;
          color: #444;
        }
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 5 }
  end

  context 'when out-of-order property is the second last in the list of sorted properties' do
    let(:css) { <<-CSS }
      p {
        border: 0;
        border-radius: 3px;
        float: left;
        display: block;
      }
    CSS

    it { should report_lint line: 4 }
  end

  context 'when vendor-prefixed properties are ordered after the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        border-radius: 3px;
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when vendor-prefixed properties are ordered before the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        -moz-border-radius: 3px;
        -o-border-radius: 3px;
        -webkit-border-radius: 3px;
        border-radius: 3px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when using -moz-osx vendor-prefixed property' do
    let(:css) { <<-CSS }
      p {
        -moz-osx-font-smoothing: grayscale;
        -webkit-font-smoothing: antialiased;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when vendor properties are ordered out-of-order before the non-prefixed property' do
    let(:css) { <<-CSS }
      p {
        -moz-border-radius: 3px;
        -webkit-border-radius: 3px;
        -o-border-radius: 3px;
        border-radius: 3px;
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when include block contains properties in sorted order' do
    let(:css) { <<-CSS }
      @include some-mixin {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when include block contains properties not in sorted order' do
    let(:css) { <<-CSS }
      @include some-mixin {
        background: #000;
        margin: 5px;
        display: none;
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when @media block contains properties not in sorted order' do
    let(:css) { <<-CSS }
      @media screen and (min-width: 500px) {
        margin: 5px;
        display: none;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when if block contains properties in sorted order' do
    let(:css) { <<-CSS }
      @if $var {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when if block contains properties not in sorted order' do
    let(:css) { <<-CSS }
      @if $var {
        background: #000;
        margin: 5px;
        display: none;
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when if block contains properties in sorted order' do
    let(:css) { <<-CSS }
      @if $var {
        // Content
      } @else {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when else block contains properties not in sorted order' do
    let(:css) { <<-CSS }
      @if $var {
        // Content
      } @else {
        background: #000;
        margin: 5px;
        display: none;
      }
    CSS

    it { should report_lint line: 5 }
  end

  context 'when the order has been explicitly set' do
    let(:linter_config) { { 'order' => %w[position display padding margin width] } }

    context 'and the properties match the specified order' do
      let(:css) { <<-CSS }
        p {
          display: block;
          padding: 5px;
          margin: 10px;
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the properties do not match the specified order' do
      let(:css) { <<-CSS }
        p {
          padding: 5px;
          display: block;
          margin: 10px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and there are properties that are not specified in the explicit ordering' do
      let(:css) { <<-CSS }
        p {
          display: block;
          padding: 5px;
          font-weight: bold; // Unspecified
          margin: 10px;
          border: 0;         // Unspecified
          background: red;   // Unspecified
          width: 100%;
        }
      CSS

      context 'and the ignore_unspecified option is enabled' do
        let(:linter_config) { super().merge('ignore_unspecified' => true) }

        it { should_not report_lint }
      end

      context 'and the ignore_unspecified option is disabled' do
        let(:linter_config) { super().merge('ignore_unspecified' => false) }

        it { should report_lint }
      end
    end
  end

  context 'when sort order is set to a preset order' do
    let(:linter_config) { { 'order' => 'concentric' } }

    context 'and the properties match the order' do
      let(:css) { <<-CSS }
        p {
          display: block;
          position: absolute;
          float: left;
          clear: both;
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the properties do not match the order' do
      let(:css) { <<-CSS }
        p {
          clear: both;
          display: block;
          float: left;
          position: absolute;
        }
      CSS

      it { should report_lint }
    end
  end
end
