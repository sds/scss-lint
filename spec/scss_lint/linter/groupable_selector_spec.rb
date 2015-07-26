require 'spec_helper'

describe SCSSLint::Linter::GroupableSelector do

  context 'when different elements' do
    let(:scss) { <<-SCSS }
      p {
        background: #000;
        margin: 5px;
      }
      a {
        background: #000;
        margin: 5px;
      }
    SCSS

    it { should report_lint }
  end

end
