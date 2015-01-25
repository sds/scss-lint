require 'spec_helper'

describe SCSSLint::Linter::VariableForProperty do
  context 'when properties are specified' do
    let(:linter_config) { { 'properties' => %w[color font] } }

    context 'when configured property value is a variable' do
      let(:css) { <<-CSS }
        p {
          color: $black;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when configured property value is a hex string' do
      let(:css) { <<-CSS }
        p {
          color: #000;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when configured property value is a color keyword' do
      let(:css) { <<-CSS }
        p {
          color: red;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'when an unspecified property value is a variable' do
      let(:css) { <<-CSS }
        p {
          background-color: $black;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when an unspecified property value is not a variable' do
      let(:css) { <<-CSS }
        p {
          background-color: #000;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when multiple configured property values are variables' do
      let(:css) { <<-CSS }
        p {
          color: $black;
          font: $small;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when multiple configured property values are not variables' do
      let(:css) { <<-CSS }
        p {
          color: #000;
          font: 8px;
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
    end

    context 'when configured property values are mixed' do
      let(:css) { <<-CSS }
        p {
          color: $black;
          font: 8px;
        }
      CSS

      it { should report_lint line: 3 }
    end
  end

  context 'when properties are not specified' do
    let(:linter_config) { { 'properties' => [] } }

    context 'when property value is a variable' do
      let(:css) { <<-CSS }
        p {
          color: $black;
        }
      CSS

      it { should_not report_lint }
    end

    context 'when property value is not a variable' do
      let(:css) { <<-CSS }
        p {
          color: #000;
        }
      CSS

      it { should_not report_lint }
    end
  end
end
