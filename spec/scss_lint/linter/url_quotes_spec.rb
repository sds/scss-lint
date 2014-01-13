require 'spec_helper'

describe SCSSLint::Linter::UrlQuotes do
  context 'when property has a literal URL' do
    let(:css) { <<-CSS }
      p {
        background: url(example.png);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when property has a URL enclosed in single quotes' do
    let(:css) { <<-CSS }
      p {
        background: url('example.png');
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property has a URL enclosed in double quotes' do
    let(:css) { <<-CSS }
      p {
        background: url("example.png");
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property has a literal URL in a list' do
    let(:css) { <<-CSS }
      p {
        background: transparent url(example.png);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when property has a single-quoted URL in a list' do
    let(:css) { <<-CSS }
      p {
        background: transparent url('example.png');
      }
    CSS

    it { should_not report_lint }
  end

  context 'when property has a double-quoted URL in a list' do
    let(:css) { <<-CSS }
      p {
        background: transparent url("example.png");
      }
    CSS

    it { should_not report_lint }
  end
end
