require 'spec_helper'

describe SCSSLint::Linter::TrailingCommaInMap do
  let(:linter_config) { { 'present' => present } }

  context 'when trailing comma is preferred' do
    let(:present) { true }

    context 'when the file is empty' do
      let(:scss) { '' }

      it { should_not report_lint }
    end

    context 'when the map is a single line' do
      let(:scss) do
        <<-SCSS
          $map: (key_one: value_one);
        SCSS
      end

      it { should_not report_lint }
    end

    context 'when the last line in a multi-line map ends with a comma' do
      let(:scss) do
        <<-SCSS
          $map: (
            key_one: value_one,
            key_two: value_two,
          );
        SCSS
      end

      it { should_not report_lint }
    end

    context 'when the last line in a multi-line map does not end with a comma' do
      let(:scss) do
        <<-SCSS
          $map: (
            key_one: value_one,
            key_two: value_two,
          );
        SCSS
      end

      it { should report_lint }
    end
  end

  context 'when no trailing newline is preferred' do
    let(:present) { false }

    context 'when the file is empty' do
      let(:scss) { '' }

      it { should_not report_lint }
    end

    context 'when the map is a single line' do
      let(:scss) do
        <<-SCSS
          $map: (key_one: value_one);
        SCSS
      end

      it { should_not report_lint }
    end

    context 'when the last line in a multi-line map ends with a comma' do
      let(:scss) do
        <<-SCSS
          $map: (
            key_one: value_one,
            key_two: value_two,
          );
        SCSS
      end

      it { should report_lint }
    end

    context 'when the last line in a multi-line map does not end with a comma' do
      let(:scss) do
        <<-SCSS
          $map: (
            key_one: value_one,
            key_two: value_two
          );
        SCSS
      end

      it { should_not report_lint }
    end
  end
end
