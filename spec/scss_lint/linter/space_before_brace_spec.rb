require 'spec_helper'

describe SCSSLint::Linter::SpaceBeforeBrace do
  context 'with a @at-root block' do
    context 'when brace is preceded by a space' do
      let(:css) { <<-CSS }
        .parent {
          @at-root .child {
          }
        }
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should report_lint line: 1 }
        it { should report_lint line: 2 }
      end
    end

    context 'when brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        .parent {
          @at-root .child  {
          }
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when brace is not preceded by a space' do
      let(:css) { <<-CSS }
        .parent {
          @at-root .child{
          }
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when brace is preceded by a new line' do
      let(:css) { <<-CSS }
        .parent
        {
          @at-root .child
          {
          }
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 4 }

      context 'and the `style` option is `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'with an @each block' do
    context 'when brace is preceded by a space' do
      let(:css) { <<-CSS }
        @each $item in $list {
        }
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should report_lint line: 1 }
      end
    end

    context 'when brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        @each $item in $list  {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is not preceded by a space' do
      let(:css) { <<-CSS }
        @each $item in $list{
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is preceded by a new line' do
      let(:css) { <<-CSS }
        @each $item in $list
        {
        }
      CSS

      it { should report_lint line: 2 }

      context 'and the `style` option is `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'with a @for block' do
    context 'when brace is preceded by a space' do
      let(:css) { <<-CSS }
        @for $i from $start to $end {
        }
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should report_lint line: 1 }
      end
    end

    context 'when brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        @for $i from $start to $end  {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is not preceded by a space' do
      let(:css) { <<-CSS }
        @for $i from $start to $end{
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is preceded by a new line' do
      let(:css) { <<-CSS }
        @for $i from $start to $end
        {
        }
      CSS

      it { should report_lint line: 2 }

      context 'and the `style` option is `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'with a @while block' do
    context 'when brace is preceded by a space' do
      let(:css) { <<-CSS }
        @while $condition {
        }
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should report_lint line: 1 }
      end
    end

    context 'when brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        @while $condition  {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is not preceded by a space' do
      let(:css) { <<-CSS }
        @while $condition{
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is preceded by a new line' do
      let(:css) { <<-CSS }
        @while $condition
        {
        }
      CSS

      it { should report_lint line: 2 }

      context 'and the `style` option is `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'with a rule selector' do
    context 'when brace is preceded by a space' do
      let(:css) { <<-CSS }
        p {
        }
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should report_lint line: 1 }
      end
    end

    context 'when brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        p  {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is not preceded by a space' do
      let(:css) { <<-CSS }
        p{
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is in a single line rule set' do
      let(:css) { <<-CSS }
        .single-line-selector{color: #f00;}
      CSS

      it { should report_lint line: 1 }
    end

    context 'when brace is following a multi-selector rule set' do
      let(:css) { <<-CSS }
        .selector1,
        .selector2,
        .selector3{
        }
      CSS

      it { should report_lint line: 3 }
    end

    context 'when brace is preceded by a new line' do
      let(:css) { <<-CSS }
        p
        {
        }
      CSS

      it { should report_lint line: 2 }

      context 'and the `style` option is `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'with a function declaration' do
    context 'with arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @function func($arg, $arg2) {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @function func($arg, $arg2)  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @function func($arg, $arg2){
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @function func($arg, $arg2)
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end

    context 'without arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @function func() {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @function func()  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @function func(){
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @function func()
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end
  end

  context 'with a mixin declaration' do
    context 'with arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @mixin mixin($arg, $arg2) {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @mixin mixin($arg, $arg2)  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @mixin mixin($arg, $arg2){
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @mixin mixin($arg, $arg2)
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end

    context 'without arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @mixin mixin {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @mixin mixin  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @mixin mixin{
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @mixin mixin
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end
  end

  context 'with a mixin include with braces' do
    context 'with arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @include mixin(arg, arg2) {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @include mixin(arg, arg2)  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @include mixin(arg, arg2){
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @include mixin(arg, arg2)
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end

    context 'without arguments' do
      context 'when brace is preceded by a space' do
        let(:css) { <<-CSS }
          @include mixin {
          }
        CSS

        it { should_not report_lint }

        context 'and the `style` option is set to `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should report_lint line: 1 }
        end
      end

      context 'when brace is preceded by multiple spaces' do
        let(:css) { <<-CSS }
          @include mixin  {
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is not preceded by a space' do
        let(:css) { <<-CSS }
          @include mixin{
          }
        CSS

        it { should report_lint line: 1 }
      end

      context 'when brace is preceded by a new line' do
        let(:css) { <<-CSS }
          @include mixin
          {
          }
        CSS

        it { should report_lint line: 2 }

        context 'and the `style` option is `new_line`' do
          let(:linter_config) { { 'style' => 'new_line' } }

          it { should_not report_lint }
        end
      end
    end
  end

  context 'with a mixin include with no braces' do
    context 'with arguments' do
      let(:css) { <<-CSS }
        @include mixin(arg, arg2);
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end

    context 'without arguments' do
      let(:css) { <<-CSS }
        @include mixin;
      CSS

      it { should_not report_lint }

      context 'and the `style` option is set to `new_line`' do
        let(:linter_config) { { 'style' => 'new_line' } }

        it { should_not report_lint }
      end
    end
  end

  context 'when curly brace appears in a string' do
    context 'and the `style` option is `space`' do
      let(:css) { <<-CSS }
        a {
          content: "{";
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the `style` option is `new_line`' do
      let(:linter_config) { { 'style' => 'new_line' } }

      let(:css) { <<-CSS }
        a
        {
          content: "{";
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when using #{} interpolation' do
    context 'and the `style` option is `space`' do
      let(:css) { <<-CSS }
        @mixin test-mixin($class, $prop, $pixels) {
          .\#{$class} {
            \#{$prop}: \#{$pixels}px;
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the `style` option is `new_line`' do
      let(:linter_config) { { 'style' => 'new_line' } }

      let(:css) { <<-CSS }
        @mixin test-mixin($class, $prop, $pixels)
        {
          .\#{$class}
          {
            \#{$prop}: \#{$pixels}px;
          }
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when using braces in comments' do
    let(:css) { '// ({x})' }

    it { should_not report_lint }

    context 'and the `style` option is set to `new_line`' do
      let(:linter_config) { { 'style' => 'new_line' } }

      it { should_not report_lint }
    end
  end

  context 'when blocks occupy a single line' do
    let(:linter_config) do
      {
        'allow_single_line_padding' => allow_single_line_padding,
        'style' => style
      }
    end

    let(:css) { <<-CSS }
      p{ }
      p { }
      p           { &:before { } }
      p           { &:before{ } }
    CSS

    context 'and the `allow_single_line_padding` option is true' do
      let(:allow_single_line_padding) { true }
      let(:style) { 'space' }

      it { should report_lint line: 1 }
      it { should_not report_lint line: 2 }
      it { should_not report_lint line: 3 }
      it { should report_lint line: 4 }

      context 'and the `style` option is `new_line`' do
        let(:style) { 'new_line' }

        it { should report_lint line: 1 }
        it { should_not report_lint line: 2 }
        it { should_not report_lint line: 3 }
        it { should report_lint line: 4 }
      end
    end

    context 'and the `allow_single_line_padding` option is false' do
      let(:allow_single_line_padding) { false }
      let(:style) { 'space' }

      it { should report_lint line: 1 }
      it { should_not report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }

      context 'and the `style` option is `new_line`' do
        let(:style) { 'new_line' }

        it { should report_lint line: 1 }
        it { should report_lint line: 2 }
        it { should report_lint line: 3 }
        it { should report_lint line: 4 }
      end
    end
  end

  context 'when curly brace is in single quotes' do
    let(:css) { <<-CSS }
      @if $token == '{' {
      }
    CSS

    it { should_not report_lint }

    context 'and the `style` option is `new_line`' do
      let(:linter_config) { { 'style' => 'new_line' } }

      let(:css) { <<-CSS }
        @if $token == '{'
        {
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when curly brace is on own line' do
    let(:css) { <<-CSS }
      .class
      {
      }
    CSS

    it { should report_lint line: 2 }

    context 'and the `style` option is `new_line`' do
      let(:linter_config) { { 'style' => 'new_line' } }

      it { should_not report_lint }
    end
  end

  context 'when the `style` option is `new_line`' do
    let(:linter_config) { { 'style' => 'new_line' } }

    context 'and the curly brace is preceded by a space' do
      let(:css) { <<-CSS }
        .class {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'and the curly brace is preceded by multiple spaces' do
      let(:css) { <<-CSS }
        .class    {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'and there are multiple levels of nesting' do
      let(:css) { <<-CSS }
        ul
        {
          li
          {
            span
            {
              a
              {
              }
            }
          }
        }
      CSS

      it { should_not report_lint }
    end
  end
end
