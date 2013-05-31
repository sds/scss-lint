require 'spec_helper'

describe SCSSLint::Linter::SingleLinePerSelector do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::SingleLinePerSelector.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when rule has one selector' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it 'returns no lints' do
      subject.count.should == 0
    end
  end

  context 'when rule has one selector on each line' do
    let(:css) { <<-CSS }
      p,
      a {
      }
    CSS

    it 'returns no lints' do
      subject.count.should == 0
    end
  end

  context 'when rule contains multiple selectors on the same line' do
    let(:css) { <<-CSS }
      .first,
      .second,
      .third, .fourth,
      .fifth {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the first line of the multi-selector declaration for the lint' do
      subject.first.line.should == 4
    end
  end

  context 'when commas are not at the end of the line' do
    let(:css) { <<-CSS }
      .foo
      , .bar {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when commas are on their own line' do
    let(:css) { <<-CSS }
      .foo
      ,
      .bar {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when nested rule contains multiple selectors on the same line' do
    let(:css) { <<-CSS }
      #foo {
        .first,
        .second,
        .third, .fourth,
        .fifth {
        }
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the last line of the multi-selector declaration for the lint' do
      subject.first.line.should == 5
    end
  end

  context 'when rule contains interpolated selectors' do
    let(:css) { <<-CSS }
      .first,
      \#{interpolated-selector}.thing,
      .third {
      }
    CSS

    it 'returns no lints' do
      subject.count.should == 0
    end
  end

  context 'when rule contains an interpolated selector not on its own line' do
    let(:css) { <<-CSS }
      .first,
      .second, \#{interpolated-selector}.thing,
      .fourth {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the last line of the multi-selector declaration for the lint' do
      subject.first.line.should == 3
    end
  end

  context 'when rule contains an inline comment' do
    let(:css) { <<-CSS }
      .first,  /* A comment */
      .second, // Another comment
      .third {
      }
    CSS

    it 'returns no lints' do
      subject.count.should == 0
    end
  end
end
