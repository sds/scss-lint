require 'spec_helper'

describe SCSSLint::Linter::SpaceAfterComma do
  context 'in a mixin declaration' do
    context 'where spaces do not follow commas' do
      let(:css) { <<-CSS }
        @mixin mixin($arg1,$arg2,$kwarg1: 'default',$kwarg2: 'default') {
        }
      CSS

      it { should report_lint count: 3 }
    end

    context 'where spaces follow commas' do
      let(:css) { <<-CSS }
        @mixin mixin($arg1, $arg2, $kwarg1: 'default', $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'where spaces surround commas' do
      let(:css) { <<-CSS }
        @mixin mixin($arg1 , $arg2 , $kwarg1: 'default' , $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'where commas are followed by a newline' do
      let(:css) { <<-CSS }
        @mixin mixin($arg1,
                     $arg2,
                     $kwarg1: 'default',
                     $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'definining a variable argument' do
      context 'where spaces do not follow commas' do
        let(:css) { <<-CSS }
          @mixin mixin($arg,$args...) {
          }
        CSS

        it { should report_lint count: 1 }
      end

      context 'where spaces follow commas' do
        let(:css) { <<-CSS }
          @mixin mixin($arg, $args...) {
          }
        CSS

        it { should_not report_lint }
      end

      context 'where spaces surround commas' do
        let(:css) { <<-CSS }
          @mixin mixin($arg , $args...) {
          }
        CSS

        it { should_not report_lint }
      end

      context 'where commas are followed by a newline' do
        let(:css) { <<-CSS }
          @mixin mixin($arg,
                       $args...) {
          }
        CSS

        it { should_not report_lint }
      end
    end
  end

  context 'in a mixin inclusion' do
    context 'where spaces do not follow commas' do
      let(:css) { <<-CSS }
        p {
          @include mixin(1,2,3,$args...,$kwarg1: 4,$kwarg2: 5,$kwargs...);
        }
      CSS

      it { should report_lint count: 6 }
    end

    context 'where spaces follow commas' do
      let(:css) { <<-CSS }
        p {
          @include mixin(1, 2, 3, $args..., $kwarg1: 4, $kwarg2: 5, $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end

    context 'where spaces surround commas' do
      let(:css) { <<-CSS }
        p {
          @include mixin(1 , 2 , 3 , $args... , $kwarg1: 4 , $kwarg2: 5 , $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end

    context 'where commas are followed by a newline' do
      let(:css) { <<-CSS }
        p {
          @include mixin(1,
                         2,
                         3,
                         $args...,
                         $kwarg1: 4,
                         $kwarg2: 5,
                         $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'in a function declaration' do
    context 'where spaces do not follow commas' do
      let(:css) { <<-CSS }
        @function func($arg1,$arg2,$kwarg1: 'default',$kwarg2: 'default') {
        }
      CSS

      it { should report_lint count: 3 }
    end

    context 'where spaces follow commas' do
      let(:css) { <<-CSS }
        @function func($arg1, $arg2, $kwarg1: 'default', $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'where spaces surround commas' do
      let(:css) { <<-CSS }
        @function func($arg1 , $arg2 , $kwarg1: 'default' , $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'where commas are followed by a newline' do
      let(:css) { <<-CSS }
        @function func($arg1,
                       $arg2,
                       $kwarg1: 'default',
                       $kwarg2: 'default') {
        }
      CSS

      it { should_not report_lint }
    end

    context 'definining a variable argument' do
      context 'where spaces do not follow commas' do
        let(:css) { <<-CSS }
          @function func($arg,$args...) {
          }
        CSS

        it { should report_lint count: 1 }
      end

      context 'where spaces follow commas' do
        let(:css) { <<-CSS }
          @function func($arg, $args...) {
          }
        CSS

        it { should_not report_lint }
      end

      context 'where spaces surround commas' do
        let(:css) { <<-CSS }
          @function func($arg , $args...) {
          }
        CSS

        it { should_not report_lint }
      end

      context 'where commas are followed by a newline' do
        let(:css) { <<-CSS }
          @function func($arg,
                         $args...) {
          }
        CSS

        it { should_not report_lint }
      end
    end
  end

  context 'in a function invocation' do
    context 'where spaces do not follow commas' do
      let(:css) { <<-CSS }
        p {
          margin: func(1,2,3,$args...,$kwarg1: 4,$kwarg2: 5,$kwargs...);
        }
      CSS

      it { should report_lint count: 6 }
    end

    context 'where spaces follow commas' do
      let(:css) { <<-CSS }
        p {
          margin: func(1, 2, 3, $args..., $kwarg1: 4, $kwarg2: 5, $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end

    context 'where spaces surround commas' do
      let(:css) { <<-CSS }
        p {
          margin: func(1 , 2 , 3 , $args... , $kwarg1: 4 , $kwarg2: 5 , $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end

    context 'where commas are followed by a newline' do
      let(:css) { <<-CSS }
        p {
          margin: func(1,
                       2,
                       3,
                       $args...,
                       $kwarg1: 4,
                       $kwarg2: 5,
                       $kwargs...);
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'in a comma-separated literal list' do
    context 'where spaces do not follow commas' do
      let(:css) { <<-CSS }
        p {
          property: $a,$b,$c,$d;
        }
      CSS

      it { should report_lint count: 3 }
    end

    context 'where spaces follow commas' do
      let(:css) { <<-CSS }
        p {
          property: $a, $b, $c, $d;
        }
      CSS

      it { should_not report_lint }
    end

    context 'where spaces surround commas' do
      let(:css) { <<-CSS }
        p {
          property: $a , $b , $c , $d;
        }
      CSS

      it { should_not report_lint }
    end

    context 'where commas are followed by a newline' do
      let(:css) { <<-CSS }
        p {
          property: $a,
                    $b,
                    $c,
                    $d;
        }
      CSS

      it { should_not report_lint }
    end
  end
end
