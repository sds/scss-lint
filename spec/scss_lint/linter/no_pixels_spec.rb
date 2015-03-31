require 'spec_helper'

describe SCSSLint::Linter::NoPixels do

  context 'when pixel value is used' do
    let(:scss) { <<-SCSS }
      p {
        font-size: 16px;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when non-pixel value is used' do
    let(:scss) { <<-SCSS }
      p {
        font-size: 1.6rem;
      }
    SCSS

    it { should_not report_lint}
  end

  context 'when non-pixel and pixel value are used in the same prop' do
    let(:scss) { <<-SCSS }
      p {
        margin: 1.6px 1rem;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when non-pixel and pixel value are used on same selector' do
    let(:scss) { <<-SCSS }
      p {
        margin: 1.6px;
        border: .1rem solid blue;
      }
    SCSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
  end

  context 'when properties are ignored' do
    let(:linter_config) { { 'ignored_properties' => ['font-size'] } }

    context 'when property is ignored and using pixels' do
      let(:scss) { <<-SCSS }
        p {
          font-size: 16px;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when property is not ignored and using pixels' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1px;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when mixing ignored and not ignored properties using pixels' do
      let(:scss) { <<-SCSS }
        p {
          font-size: 16px;
          margin: 1px;
        }
      SCSS

      it { should_not report_lint line: 2 }
      it { should report_lint line: 3 }
    end

  end
end