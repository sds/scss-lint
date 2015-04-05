require 'spec_helper'

describe SCSSLint::Linter::PropertyUnits do
  context 'when global units are set and local are not set' do
    let(:linter_config) { { 'global' => ['rem'], 'properties' => {} } }

    context 'when unit is allowed' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1rem;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when unit is not allowed' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1px;
        }
      SCSS

      it { should report_lint line: 2 }
    end
  end

  context 'when global and local units are set' do
    let(:linter_config) { { 'global' => ['rem'], 'properties' => { 'font-size' => ['px'] } } }

    context 'when unit is allowed locally not globally' do
      let(:scss) { <<-SCSS }
        p {
          font-size: 16px;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when unit is allowed globally not locally' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1rem;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when unit is not allowed globally nor locally' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1vh;
        }
      SCSS

      it { should report_lint line: 2 }
    end
  end

  context 'when local units are set and global are not set' do
    let(:linter_config) { { 'global' => [], 'properties' => { 'margin' => ['rem'] } } }

    context 'when unit is allowed locally not globally' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1rem;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when unit is not allowed locally nor globally' do
      let(:scss) { <<-SCSS }
        p {
          margin: 10px;
        }
      SCSS

      it { should report_lint line: 2 }
    end
  end

  context 'when multiple units are set on a property' do
    let(:linter_config) { { 'global' => [], 'properties' => { 'margin' => %w[rem em] } } }

    context 'when one of multiple units is used' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1rem;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when another of multiple units is used' do
      let(:scss) { <<-SCSS }
        p {
          margin: 1em;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when a not allowed unit is used' do
      let(:scss) { <<-SCSS }
        p {
          margin: 10px;
        }
      SCSS

      it { should report_lint line: 2 }
    end
  end

  context 'when no local units are allowed' do
    let(:linter_config) { { 'global' => ['px'], 'properties' => { 'line-height' => [] } } }

    context 'when a disallowed unit is used' do
      let(:scss) { <<-SCSS }
        p {
          line-height: 10px;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when no unit is used' do
      let(:scss) { <<-SCSS }
        p {
          line-height: 1;
        }
      SCSS

      it { should_not report_lint }
    end
  end
end
