require 'spec_helper'

describe SCSSLint::Linter::SpaceAfterPropertyColon do
  let(:linter_config) { { 'style' => style } }

  context 'when one space is preferred' do
    let(:style) { 'one_space' }

    context 'when the colon after a property is not followed by space' do
      let(:scss) { <<-SCSS }
        p {
          margin:0;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when colon after property is not followed by space and the semicolon is missing' do
      let(:scss) { <<-SCSS }
        p {
          color:#eee
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the colon after a property is followed by a space' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is surrounded by spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin : bold;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is followed by multiple spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin:  bold;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when interpolation within single quotes is followed by inline property' do
      context 'and property name is followed by a space' do
        let(:scss) { "[class~='\#{$test}'] { width: 100%; }" }

        it { should_not report_lint }
      end

      context 'and property name is not followed by a space' do
        let(:scss) { "[class~='\#{$test}'] { width:100%; }" }

        it { should report_lint }
      end
    end
  end

  context 'when no spaces are allowed' do
    let(:style) { 'no_space' }

    context 'when the colon after a property is not followed by space' do
      let(:scss) { <<-SCSS }
        p {
          margin:0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when colon after property is not followed by space and the semicolon is missing' do
      let(:scss) { <<-SCSS }
        p {
          color:#eee
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is followed by a space' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the colon after a property is surrounded by spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin : bold;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the colon after a property is followed by multiple spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin:  bold;
        }
      SCSS

      it { should report_lint line: 2 }
    end
  end

  context 'when at least one space is preferred' do
    let(:style) { 'at_least_one_space' }

    context 'when the colon after a property is not followed by space' do
      let(:scss) { <<-SCSS }
        p {
          margin:0;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when colon after property is not followed by space and the semicolon is missing' do
      let(:scss) { <<-SCSS }
        p {
          color:#eee
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when the colon after a property is followed by a space' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is surrounded by spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin : bold;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a property is followed by multiple spaces' do
      let(:scss) { <<-SCSS }
        p {
          margin:  bold;
        }
      SCSS

      it { should_not report_lint }
    end
  end

  context 'when aligned property values are preferred' do
    let(:style) { 'aligned' }

    context 'when the colon after a single property is not followed by space' do
      let(:scss) { <<-SCSS }
        p {
          margin:0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when the colon after a single property is followed by a space' do
      let(:scss) { <<-SCSS }
        p {
          margin: 0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when properties are not aligned' do
      let(:scss) { <<-SCSS }
        p {
          content: 'hello';
          margin: 0;
          padding: 0;
        }
      SCSS

      it { should report_lint line: 2 }
    end

    context 'when properties aligned but the names are not' do
      let(:scss) { <<-SCSS }
        p {
          content:  'hello';
           margin:  0;
          padding:  0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when properties aligned but the names with spaces are not' do
      let(:scss) { <<-SCSS }
        p {
          content :  'hello';
           margin :  0;
          padding :  0;
        }
      SCSS

      it { should_not report_lint }
    end

    context 'when properties are aligned' do
      let(:scss) { <<-SCSS }
        p {
          margin:  0;
          padding: 0;
        }
      SCSS

      it { should_not report_lint }
    end
  end
end
