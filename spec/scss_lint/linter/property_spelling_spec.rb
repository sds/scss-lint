require 'spec_helper'

describe SCSSLint::Linter::PropertySpelling do
  context 'with a regular property' do
    let(:css) { <<-CSS }
      p {
        margin: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'with a property containing interpolation' do
    let(:css) { <<-CSS }
      p {
        \#{$property-name}: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'with a non-existent property' do
    let(:css) { <<-CSS }
      p {
        peanut-butter: jelly-time;
      }
    CSS

    it { should report_lint }
  end

  context 'when extra properties are specified' do
    let(:linter_config) { { 'extra_properties' => ['made-up-property'] } }

    context 'with a non-existent property' do
      let(:css) { <<-CSS }
        p {
          peanut-butter: jelly-time;
        }
      CSS

      it { should report_lint }
    end

    context 'with a property listed as an extra property' do
      let(:css) { <<-CSS }
        p {
          made-up-property: value;
        }
      CSS

      it { should_not report_lint }
    end
  end
end
