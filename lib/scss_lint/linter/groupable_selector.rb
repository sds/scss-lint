# add missing comparison for literals
module Sass::Script::Tree
  class Literal

    def == other
      self.class == other.class and self.value == other.value
    end
  end
end

module SCSSLint
  class Linter::GroupableSelector < Linter
    include LinterRegistry

    def check_node(node)
      visits = Set.new
      node.children.each do |child_node|
        groupable_node = find_groupable_node child_node, node.children
        next unless groupable_node
        next if visits.include? [child_node, groupable_node] or
                visits.include? [groupable_node, child_node]
        visits << [child_node, groupable_node]

        add_lint child_node.line, "Group identical rule `#{node_rule child_node}` on line #{child_node.line} " \
        "with rule `#{node_rule groupable_node}` on line #{groupable_node.line}" do
          node.children.delete groupable_node
          child_node.parsed_rules = nil
          child_node.rule.first << ", #{groupable_node.rule.join}"
        end
      end

      yield # Continue linting children
    end

    alias_method :visit_root, :check_node
    alias_method :visit_rule, :check_node

  protected

    # TODO: currently find only nodes on the same level, as node.rule
    # does not know about its parent rules
    def find_groupable_node(node, level_rule_nodes)
      return unless node.is_a? Sass::Tree::RuleNode

      level_rule_nodes.find do |sibling_node|
        next unless sibling_node.is_a? Sass::Tree::RuleNode
        groupable?(node, sibling_node)
      end
    end

    def groupable?(node1, node2)
      node1 != node2 and node1.children.all? do |c1|
        node2.children.find do |c2|
          c1 == c2
        end
      end
    end

    def node_rule(node)
      node.rule.join
    end

  end
end
