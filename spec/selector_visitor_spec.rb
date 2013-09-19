require 'spec_helper'

describe SCSSLint::SelectorVisitor do
  describe '#visit' do
    let(:engine) { SCSSLint::Engine.new(css) }
    before { RuleVisitor.new(visitor).run(engine) }

    # Visits every rule in the given parse tree and passes the parsed selector
    # to the given `selector_visitor`.
    class RuleVisitor < Sass::Tree::Visitors::Base
      def initialize(selector_visitor)
        @selector_visitor = selector_visitor
      end

      def run(engine)
        visit(engine.tree)
      end

      def visit_rule(node)
        @selector_visitor.visit_selector(node.parsed_rules)
        yield # Continue linting children
      end
    end

    # Superclass for all the test selector visitors
    class TrackingSelectorVisitor
      include SCSSLint::SelectorVisitor

      attr_reader :node_order

      def initialize
        @node_order = []
      end
    end

    context 'when visitor defines visit_attribute' do
      class TestAttributeVisitor < TrackingSelectorVisitor
        def visit_attribute(attribute)
          @node_order << attribute.name.join
        end
      end

      let(:visitor) { TestAttributeVisitor.new }

      let(:css) { <<-CSS }
        [rel="nofollow"] {}
        a[href="http"] {}
        .class [data-count] {}
      CSS

      it 'visits all attribute nodes' do
        visitor.node_order.should == %w[rel href data-count]
      end
    end

    context 'when visitor defines visit_class' do
      class TestClassVisitor < TrackingSelectorVisitor
        def visit_class(klass)
          @node_order << klass.name.join
        end
      end

      let(:visitor) { TestClassVisitor.new }

      let(:css) { <<-CSS }
        a.link {}
        .menu .menu-item {}
        .button[data-source], .overlay {}
      CSS

      it 'visits all class nodes' do
        visitor.node_order.should == %w[link menu menu-item button overlay]
      end
    end

    context 'when visitor defines visit_element' do
      class TestElementVisitor < TrackingSelectorVisitor
        def visit_element(element)
          @node_order << element.name.join
        end
      end

      let(:visitor) { TestElementVisitor.new }

      let(:css) { <<-CSS }
        a, b {}
        .class {}
        i + p {}
      CSS

      it 'visits all element nodes' do
        visitor.node_order.should == %w[a b i p]
      end
    end

    context 'when visitor defines visit_id' do
      class TestIdVisitor < TrackingSelectorVisitor
        def visit_id(id)
          @node_order << id.name.join
        end
      end

      let(:visitor) { TestIdVisitor.new }

      let(:css) { <<-CSS }
        #something, #thing {}
        #object + #entity {}
      CSS

      it 'visits all id nodes' do
        visitor.node_order.should == %w[something thing object entity]
      end
    end

    context 'when visitor defines visit_parent' do
      class TestParentVisitor < TrackingSelectorVisitor
        def visit_parent(parent)
          @node_order << parent.line
        end
      end

      let(:visitor) { TestParentVisitor.new }

      let(:css) { <<-CSS }
        p {
          &.class {}
          .container & {}
          .nothing {}
        }
      CSS

      it 'visits all parent nodes' do
        visitor.node_order.should == [2, 3]
      end
    end

    context 'when visitor defines visit_placeholder' do
      class TestPlaceholderVisitor < TrackingSelectorVisitor
        def visit_placeholder(placeholder)
          @node_order << placeholder.name.join
        end
      end

      let(:visitor) { TestPlaceholderVisitor.new }

      let(:css) { <<-CSS }
        %placeholder, %other-placeholder {}
        .button, %button {}
      CSS

      it 'visits all placeholder nodes' do
        visitor.node_order.should == %w[placeholder other-placeholder button]
      end
    end

    context 'when visitor defines visit_pseudo' do
      class TestPseudoVisitor < TrackingSelectorVisitor
        def visit_pseudo(pseudo)
          @node_order << pseudo.name.join
        end
      end

      let(:visitor) { TestPseudoVisitor.new }

      let(:css) { <<-CSS }
        li:first-child, li:last-child {}
        p {
          &:first-letter {}
        }
      CSS

      it 'visits all pseudo-selector nodes' do
        visitor.node_order.should == %w[first-child last-child first-letter]
      end
    end

    context 'when visitor defines visit_universal' do
      class TestUniversalVisitor < TrackingSelectorVisitor
        def visit_universal(universal)
          @node_order << universal.line
        end
      end

      let(:visitor) { TestUniversalVisitor.new }

      let(:css) { <<-CSS }
        p > * {}
        * {}
        li {}
        *:first-child {}
      CSS

      it 'visits all universal-selector nodes' do
        visitor.node_order.should == [1, 2, 4]
      end
    end

    context 'when visitor defines visit_simple_sequence' do
      class TestSimpleSequenceVisitor < TrackingSelectorVisitor
        def visit_simple_sequence(seq)
          @node_order << seq
        end
      end

      let(:visitor) { TestSimpleSequenceVisitor.new }

      let(:css) { <<-CSS }
        a, b, p[lang] {}
        a.link + b.word {}
        li {}
        ul > li {}
        p span {}
      CSS

      it 'visits all simple sequences' do
        visitor.node_order.count.should == 10
      end
    end

    context 'when visitor defines visit_sequence' do
      class TestSequenceVisitor < TrackingSelectorVisitor
        def visit_sequence(seq)
          @node_order << seq
        end
      end

      let(:visitor) { TestSequenceVisitor.new }

      let(:css) { <<-CSS }
        a, b, p[lang] {}
        a.link + b.word {}
        li {}
        ul > li {}
        p span {}
      CSS

      it 'visits all sequences' do
        visitor.node_order.count.should == 7
      end
    end

    context 'when visitor defines visit_comma_sequence' do
      class TestCommaSequenceVisitor < TrackingSelectorVisitor
        def visit_comma_sequence(seq)
          @node_order << seq
        end
      end

      let(:visitor) { TestCommaSequenceVisitor.new }

      let(:css) { <<-CSS }
        a, b, p[lang] {}
        a.link + b.word {}
        li {}
        ul > li {}
        p span {}
      CSS

      it 'visits all comma (i.e. selector) sequences' do
        visitor.node_order.count.should == 5
      end
    end
  end
end
