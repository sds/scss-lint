require 'spec_helper'

describe SCSSLint::Linter::IdSelector do
  context 'when rule is a type' do
    let(:css) { 'p {}' }

    it { should_not report_lint }
  end

  context 'when rule is an ID' do
    let(:css) { '#identifier {}' }

    it { should report_lint line: 1 }
  end

  context 'when rule is a class' do
    let(:css) { '.class {}' }

    it { should_not report_lint }
  end

  context 'when rule is a type with a class' do
    let(:css) { 'a.class {}' }

    it { should_not report_lint }
  end

  context 'when rule is a type with an ID' do
    let(:css) { 'a#identifier {}' }

    it { should report_lint line: 1 }
  end

  context 'when rule is an ID with a pseudo-selector' do
    let(:css) { '#identifier:active {}' }

    it { should report_lint line: 1 }
  end

  context 'when rule contains a nested rule with type and ID' do
    let(:css) { <<-CSS }
      p {
        a#identifier {}
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when rule contains multiple selectors' do
    context 'when all of the selectors are just IDs, classes, or types' do
      let(:css) { <<-CSS }
        #identifier,
        .class,
        a {
        }
      CSS

      it { should report_lint line: 1 }
    end
  end
end
