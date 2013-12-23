require 'spec_helper'

describe SCSSLint::Linter::IdWithExtraneousSelector do
  context 'when rule is just a type' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule is just an ID' do
    let(:css) { <<-CSS }
      #identifier {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule is just a class' do
    let(:css) { <<-CSS }
      .class {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule is a type with a class' do
    let(:css) { <<-CSS }
      a.class {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule is a type with an ID' do
    let(:css) { <<-CSS }
      a#identifier {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when rule is an ID with a pseudo' do
    let(:css) { <<-CSS }
      #identifier:active {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule is a type with an ID with a pseudo' do
    let(:css) { <<-CSS }
      a#identifier:active {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when rule contains multiple selectors' do
    context 'when all of the selectors are just IDs, classes, or types' do
      let(:css) { <<-CSS }
        #identifier,
        .class,
        a {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when one of the rules is an ID with a pseudo' do
      let(:css) { <<-CSS }
        #identifier:active,
        .class {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when one of the rules is a type with an ID with a pseudo' do
      let(:css) { <<-CSS }
        a#identifier:active,
        .class {
        }
      CSS

      it { should report_lint line: 1 }
    end

    context 'when one of the selectors is a type and class' do
      let(:css) { <<-CSS }
        #identifier,
        a.class {
        }
      CSS

      it { should_not report_lint }
    end

    context 'when one of the selectors is a type and ID' do
      let(:css) { <<-CSS }
        #identifier,
        a#my-id {
        }
      CSS

      it { should report_lint line: 1 }
    end
  end

  context 'when rule contains a nested rule with type and ID' do
    let(:css) { <<-CSS }
      p {
        a#identifier {
        }
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when selector contains a class and ID' do
    let(:css) { <<-CSS }
      #id.class {
      }
    CSS

    it { should report_lint line: 1 }
  end
end
