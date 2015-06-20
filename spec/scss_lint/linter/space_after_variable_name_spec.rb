require 'spec_helper'

describe SCSSLint::SpaceAfterVariableName do
  let(:scss) { <<-SCSS }
    $none: #fff;
    $one : #fff;
    $two  : #fff;
   SCSS

  it { should_not report_lint line: 1 }
  it { should report_lint line: 2 }
  it { should report_lint line: 3 }
end
