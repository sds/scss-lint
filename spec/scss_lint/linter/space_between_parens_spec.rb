require 'spec_helper'

describe SCSSLint::Linter::SpaceBetweenParens do
  context 'when the opening parens is followed by a space' do
    let(:scss) { <<-SCSS }
      p {
        property: ( value);
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when the closing parens is preceded by a space' do
    let(:scss) { <<-SCSS }
      p {
        property: (value );
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when both parens are space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: ( value );
      }
    SCSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when neither parens are space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: (value);
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when parens are multi-line' do
    let(:scss) { <<-SCSS }
      p {
        property: (
          value
        );
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when parens are multi-line with tabs' do
    let(:scss) { <<-SCSS }
\t\t\tp {
\t\t\t\tproperty: (
\t\t\t\t\tvalue
\t\t\t\t);
\t\t\t}
    SCSS

    it { should_not report_lint }
  end

  context 'when outer parens are space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: fn( fn2(val1, val2) );
      }
    SCSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when inner parens are space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: fn(fn2( val1, val2 ));
      }
    SCSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when both parens are not space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: fn(fn2(val1, val2));
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when both parens are space padded' do
    let(:scss) { <<-SCSS }
      p {
        property: fn( fn2( val1, val2 ) );
      }
    SCSS

    it { should report_lint line: 2, count: 4 }
  end

  context 'when multi level parens are multi-line' do
    let(:scss) { <<-SCSS }
      p {
        property: fn(
          fn2(
            val1, val2
          )
        );
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when parens exist in a silent comment' do
    let(:scss) { <<-SCSS }
      p {
        margin: 0; // Some comment ( with parens )
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when parens exist in an outputted comment' do
    let(:scss) { <<-SCSS }
      p {
        margin: 0; /* Some comment ( with parens ) */
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when the number of spaces has been explicitly set' do
    let(:linter_config) { { 'spaces' => 1 } }

    context 'when the opening parens is followed by a space' do
      let(:scss) { <<-SCSS }
        p {
          property: ( value);
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the closing parens is preceded by a space' do
      let(:scss) { <<-SCSS }
        p {
          property: (value );
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when neither parens are space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: (value);
        }
      SCSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when both parens are space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: ( value );
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when parens are multi-line' do
      let(:scss) { <<-SCSS }
        p {
          property: (
            value
          );
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when parens are multi-line with tabs' do
      let(:scss) { <<-SCSS }
\t\t\t\tp {
\t\t\t\t\tproperty: (
\t\t\t\t\t\tvalue
\t\t\t\t\t);
\t\t\t\t}
      SCSS

      it { should_not report_lint }
    end

    context 'when outer parens are space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: fn( fn2(val1, val2) );
        }
      SCSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when inner parens are space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: fn(fn2( val1, val2 ));
        }
      SCSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when both parens are not space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: fn(fn2(val1, val2));
        }
      SCSS

      it { should report_lint line: 2, count: 4 }
    end

    context 'when both parens are space padded' do
      let(:scss) { <<-SCSS }
        p {
          property: fn( fn2( val1, val2 ) );
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when multi level parens are multi-line' do
      let(:scss) { <<-SCSS }
        p {
          property: fn(
            fn2(
              val1, val2
            )
          );
        }
      SCSS

      it { should_not report_lint }
    end
  end
end
