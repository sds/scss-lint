require 'spec_helper'

describe SCSSLint::Linter::DeclarationOrderLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::DeclarationOrderLinter.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains only properties' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        margin: 5px;
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains only mixins' do
    let(:css) { <<-CSS }
      p {
        @include border-radius(5px);
        @include box-shadow(5px);
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains no mixins or properties' do
    let(:css) { <<-CSS }
      p {
        a {
          color: #f00;
        }
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains properties after nested rules' do
    let(:css) { <<-CSS }
      p {
        a {
          color: #f00;
        }
        color: #f00;
        margin: 5px;
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when @extend appears before any properties or rules' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .error {
        @extend .warn;
        color: #f00;
        a {
          color: #ccc;
        }
      }
    CSS

    it 'returns a lint' do
      subject.should be_empty
    end
  end

  context 'when @extend appears after a property' do
    let(:css) { <<-CSS }
      .warn {
        font-weight: bold;
      }
      .error {
        color: #f00;
        @extend .warn;
        a {
          color: #ccc;
        }
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end
end
