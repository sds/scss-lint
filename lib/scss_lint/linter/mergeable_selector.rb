module SCSSLint
  # Checks for redundant selector rules.
  class Linter::MergeableSelector < Linter
    include LinterRegistry

    def check_node(node)
      node.children.each_with_object([]) do |child_node, seen_nodes|
        next unless child_node.is_a? Sass::Tree::RuleNode

        mergeable_node = find_mergeable_node(child_node, seen_nodes)
        seen_nodes << child_node
        next unless mergeable_node

        type = equal?(child_node, mergeable_node) ? 'identical' : 'nested'
        add_lint child_node.line,
                 "Merge rule `#{node_rule(child_node)}` with #{type} rule at " \
                 "same level on line #{mergeable_node.line}"
      end
      yield # Continue linting children
    end
    alias_method :visit_root, :check_node
    alias_method :visit_rule, :check_node

  private

    def find_mergeable_node(node, seen_nodes)
      seen_nodes.find do |seen_node|
        equal?(node, seen_node) ||
          (config['force_nesting'] && nested?(node, seen_node))
      end
    end

    def equal?(node1, node2)
      node_rule(node1) == node_rule(node2)
    end

    def nested?(node1, node2)
      return false unless single_rule?(node1) && single_rule?(node2)

      rule1 = node_rule(node1)
      rule2 = node_rule(node2)
      subrule?(rule1, rule2) || subrule?(rule2, rule1)
    end

    def node_rule(node)
      node.rule.join
    end

    def single_rule?(node)
      node.parsed_rules.members.count == 1
    end

    def subrule?(rule1, rule2)
      "#{rule1}".start_with?("#{rule2} ") ||
        "#{rule1}".start_with?("#{rule2}.")
    end
  end
end
