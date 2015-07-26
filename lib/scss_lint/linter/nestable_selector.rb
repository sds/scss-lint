module SCSSLint
  class Linter::NestableSelector < Linter
    include LinterRegistry

    def check_node(node)
      visits = Set.new

      node.children.each do |child_node|
        nestable_node = find_nestable_node child_node, node.children
        next unless nestable_node
        next if visits.include? [child_node, nestable_node] or
                visits.include? [nestable_node, child_node]
        visits << [child_node, nestable_node]

        add_lint child_node.line, "Nest rule `#{node_rule child_node}` on line #{child_node.line} " \
          "with rule `#{node_rule nestable_node}` on line #{nestable_node.line}" do
          node.children.delete child_node
          nestable_node.children << child_node

          # use #rule instead of #parsed_rules
          child_node.parsed_rules = nil
          child_node.rule.each do |rule|
            rule.gsub! nestable_node.rule.first, ''
          end
        end
      end

      yield # Continue linting children
    end

    alias_method :visit_root, :check_node
    alias_method :visit_rule, :check_node

  protected

    # TODO: currently find only nodes on the same level, as node.rule
    # does not know about its parent rules
    def find_nestable_node(node, level_rule_nodes)
      return unless node.is_a? Sass::Tree::RuleNode

      level_rule_nodes.find do |sibling_node|
        next unless sibling_node.is_a? Sass::Tree::RuleNode
        nested?(node, sibling_node)
      end
    end

    def node_rule(node)
      node.rule.join
    end

    def single_rule?(node)
      return unless node.parsed_rules
      node.parsed_rules.members.count == 1
    end

    def nested?(node1, node2)
      return false if node1 == node2
      return false unless single_rule?(node1) && single_rule?(node2)

      rule1 = node_rule(node1)
      rule2 = node_rule(node2)
      subrule?(rule1, rule2) || parentrule?(rule1, rule2)
    end

    def subrule?(rule1, rule2)
      rule1.start_with? "#{rule2} "
    end

    def parentrule?(rule1, rule2)
      rule1.start_with? "#{rule2}."
    end

  end
end
