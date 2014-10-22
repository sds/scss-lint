require 'spec_helper'

describe SCSSLint::Linter::QualifyingElement do
  context 'when selector does not include an element' do
    let(:css) { <<-CSS }
      .foo {}
      #bar {}
      [foobar] {}
      .foo .bar {}
      #bar > .foo {}
      [foobar] #bar .foo {}
    CSS

    it { should_not report_lint }
  end

  context 'when selector includes an element' do
    context 'and element does not qualify' do
      let(:css) { <<-CSS }
        ul {}
      CSS

      it { should_not report_lint }
    end

    context 'and element qualifies class' do
      let(:css) { <<-CSS }
        ul.list {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and element qualifies attribute' do
      let(:css) { <<-CSS }
        a[href] {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and element qualifies id' do
      let(:css) { <<-CSS }
        ul#list {}
      CSS

      it { should report_lint line: 1 }
    end

    context 'and selector is in a group' do
      context 'and element does not qualify' do
        let(:css) { <<-CSS }
          .list li,
          .item > span {}
        CSS

        it { should_not report_lint }
      end

      context 'and element qualifies class' do
        let(:css) { <<-CSS }
          .item span,
          ul > li.item {}
        CSS

        it { should report_lint line: 1 }
      end

      context 'and element qualifies attribute' do
        let(:css) { <<-CSS }
          .item + span,
          li a[href] {}
        CSS

        it { should report_lint line: 1 }
      end

      context 'and element qualifies id' do
        let(:css) { <<-CSS }
          #foo,
          li#item + li {}
        CSS

        it { should report_lint line: 1 }
      end
    end

    context 'and selector involves a combinator' do
      context 'and element does not qualify' do
        let(:css) { <<-CSS }
          .list li {}
          .list > li {}
          .item + li {}
          .item ~ li {}
        CSS

        it { should_not report_lint }
      end

      context 'and element qualifies class' do
        let(:css) { <<-CSS }
          ul > li.item {}
        CSS

        it { should report_lint line: 1 }
      end

      context 'and element qualifies attribute' do
        let(:css) { <<-CSS }
          li a[href] {}
        CSS

        it { should report_lint line: 1 }
      end

      context 'and element qualifies id' do
        let(:css) { <<-CSS }
          li#item + li {}
        CSS

        it { should report_lint line: 1 }
      end
    end
  end
end
