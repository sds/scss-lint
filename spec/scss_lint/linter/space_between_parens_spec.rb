require 'spec_helper'

describe SCSSLint::Linter::SpaceBetweenParens do
  context 'when the opening parens is followed by a space' do
    let(:css) { <<-CSS }
      p {
        property: ( value);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when the closing parens is preceded by a space' do
    let(:css) { <<-CSS }
      p {
        property: (value );
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when both parens are space padded' do
    let(:css) { <<-CSS }
      p {
        property: ( value );
      }
    CSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when neither parens are space padded' do
    let(:css) { <<-CSS }
      p {
        property: (value);
      }
    CSS

    it { should_not report_lint }
  end

  context 'when parens are multi-line' do
    let(:css) { <<-CSS }
      p {
        property: (
          value
        );
      }
    CSS

    it { should_not report_lint }
  end

  context 'when parens are multi-line with tabs' do
    let(:css) { <<-CSS }
			p {
				property: (
					value
				);
			}
    CSS

    it { should_not report_lint }
  end

  context 'when outer parens are space padded' do
    let(:css) { <<-CSS }
      p {
        property: fn( fn2(val1, val2) );
      }
    CSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when inner parens are space padded' do
    let(:css) { <<-CSS }
      p {
        property: fn(fn2( val1, val2 ));
      }
    CSS

    it { should report_lint line: 2, count: 2 }
  end

  context 'when both parens are not space padded' do
    let(:css) { <<-CSS }
      p {
        property: fn(fn2(val1, val2));
      }
    CSS

    it { should_not report_lint }
  end

  context 'when both parens are space padded' do
    let(:css) { <<-CSS }
      p {
        property: fn( fn2( val1, val2 ) );
      }
    CSS

    it { should report_lint line: 2, count: 4 }
  end

  context 'when multi level parens are multi-line' do
    let(:css) { <<-CSS }
      p {
        property: fn(
          fn2(
            val1, val2
          )
        );
      }
    CSS

    it { should_not report_lint }
  end

  context 'when the number of spaces has been explicitly set' do
    let(:linter_config) { { 'spaces' => 1 } }

    context 'when the opening parens is followed by a space' do
      let(:css) { <<-CSS }
        p {
          property: ( value);
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when the closing parens is preceded by a space' do
      let(:css) { <<-CSS }
        p {
          property: (value );
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when neither parens are space padded' do
      let(:css) { <<-CSS }
        p {
          property: (value);
        }
      CSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when both parens are space padded' do
      let(:css) { <<-CSS }
        p {
          property: ( value );
        }
      CSS

      it { should_not report_lint }
    end

    context 'when parens are multi-line' do
      let(:css) { <<-CSS }
        p {
          property: (
            value
          );
        }
      CSS

      it { should_not report_lint }
    end

    context 'when parens are multi-line with tabs' do
      let(:css) { <<-CSS }
				p {
					property: (
						value
					);
				}
      CSS

      it { should_not report_lint }
    end

    context 'when outer parens are space padded' do
      let(:css) { <<-CSS }
        p {
          property: fn( fn2(val1, val2) );
        }
      CSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when inner parens are space padded' do
      let(:css) { <<-CSS }
        p {
          property: fn(fn2( val1, val2 ));
        }
      CSS

      it { should report_lint line: 2, count: 2 }
    end

    context 'when both parens are not space padded' do
      let(:css) { <<-CSS }
        p {
          property: fn(fn2(val1, val2));
        }
      CSS

      it { should report_lint line: 2, count: 4 }
    end

    context 'when both parens are space padded' do
      let(:css) { <<-CSS }
        p {
          property: fn( fn2( val1, val2 ) );
        }
      CSS

      it { should_not report_lint }
    end

    context 'when multi level parens are multi-line' do
      let(:css) { <<-CSS }
        p {
          property: fn(
            fn2(
              val1, val2
            )
          );
        }
      CSS

      it { should_not report_lint }
    end
  end
end
