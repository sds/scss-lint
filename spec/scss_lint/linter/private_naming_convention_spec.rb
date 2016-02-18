require 'spec_helper'

describe SCSSLint::Linter::PrivateNamingConvention do
  context 'when a private variable' do
    context 'is not used in the same file it is defined' do
      let(:scss) { <<-SCSS }
        $_foo: red;
      SCSS

      it { should report_lint line: 1 }
    end

    context 'is used but not defined in the same file' do
      let(:scss) { <<-SCSS }
        p {
          color: $_foo;
          background: rgba($_foo, 0);
        }
      SCSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
    end

    context 'is used but has not been defined quite yet' do
      let(:scss) { <<-SCSS }
        p {
          color: $_foo;
          background: rgba($_foo, 0);
        }

        $_foo: red;
      SCSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
    end

    context 'is defined and used in the same file' do
      let(:scss) { <<-SCSS }
        $_foo: red;

        p {
          color: $_foo;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined and used in the same file in a function' do
      let(:scss) { <<-SCSS }
        $_foo: red;

        p {
          color: rgba($_foo, 0);
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined within a selector and not used' do
      let(:scss) { <<-SCSS }
        p {
          $_foo: red;
        }
      SCSS

      it { should_not report_lint }
    end
  end

  context 'when a public variable' do
    context 'is used but not defined' do
      let(:scss) { <<-SCSS }
        p {
          color: $foo;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined but not used' do
      let(:scss) { <<-SCSS }
        $foo: red;
      SCSS

      it { should_not report_lint }
    end
  end

  context 'when a private mixin' do
    context 'is not used in the same file it is defined' do
      let(:scss) { <<-SCSS }
        @mixin _foo {
          color: red;
        }
      SCSS

      it { should report_lint line: 1 }
    end

    context 'is used but not defined in the same file' do
      let(:scss) { <<-SCSS }
        p {
          @include _foo;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'is used but has not been defined quite yet' do
      let(:scss) { <<-SCSS }
        p {
          @include _foo;
        }

        @mixin _foo {
          color: red;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'is defined within a selector and not used' do
      let(:scss) { <<-SCSS }
        p {
          @mixin _foo {
            color: red;
          }
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined and used in the same file' do
      let(:scss) { <<-SCSS }
        @mixin _foo {
          color: red;
        }

        p {
          @include _foo;
        }
      SCSS

      it { should_not report_lint }
    end
  end

  context 'when a public mixin' do
    context 'is used but not defined' do
      let(:scss) { <<-SCSS }
        p {
          @include foo;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined but not used' do
      let(:scss) { <<-SCSS }
        @mixin foo {
          color: red;
        }
      SCSS

      it { should_not report_lint }
    end
  end

  describe 'when a private function' do
    context 'is not used in the same file it is defined' do
      let(:scss) { <<-SCSS }
        @function _foo() {
          @return red;
        }
      SCSS

      it { should report_lint line: 1 }
    end

    context 'is used but not defined in the same file' do
      let(:scss) { <<-SCSS }
        p {
          color: _foo();
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'is used but has not been defined quite yet' do
      let(:scss) { <<-SCSS }
        p {
          color: _foo();
        }

        @function _foo() {
          @return red;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'is defined within a selector and not used' do
      let(:scss) { <<-SCSS }
        p {
          @function _foo() {
            @return red;
          }
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined and used in the same file' do
      let(:scss) { <<-SCSS }
        @function _foo() {
          @return red;
        }

        p {
          color: _foo();
        }
      SCSS

      it { should_not report_lint }
    end
  end

  context 'when a public function' do
    context 'is used but not defined' do
      let(:scss) { <<-SCSS }
        p {
          color: foo();
        }
      SCSS

      it { should_not report_lint }
    end

    context 'is defined but not used' do
      let(:scss) { <<-SCSS }
        @function foo() {
          @return red;
        }
      SCSS

      it { should_not report_lint }
    end
  end
end
