module SCSSLint
  class Linter::MergeEqualSelector < Linter
    include LinterRegistry

    def check_node(node)
      visits = Set.new
      node.children.each do |child_node|

        equal_node = find_equal_node child_node, node.children
        next unless equal_node
        next if visits.include? [child_node, equal_node] or
                visits.include? [equal_node, child_node]
        visits << [child_node, equal_node]

        add_lint child_node.line,
        "Merge rule `#{node_rule(child_node)}` on line #{child_node.line} with rule " \
        "on line #{equal_node.line}" do
          node.children.delete equal_node

          equal_node.children.each do |ec_node|
            if ec_node.is_a? Sass::Tree::PropNode
              index = child_node.children.rindex{ |n| n.is_a? Sass::Tree::PropNode } + 1
              index ||= child_node.children.index{ |n| n.is_a? Sass::Tree::RuleNode }
            else
              index = -1
            end
            child_node.children.insert index, ec_node
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
    def find_equal_node(node, level_rule_nodes)
      return unless node.is_a? Sass::Tree::RuleNode

      level_rule_nodes.find do |sibling_node|
        next unless sibling_node.is_a? Sass::Tree::RuleNode
        equal?(node, sibling_node)
      end
    end

    def equal?(node1, node2)
      node1 != node2 and node_rule(node1) == node_rule(node2)
    end

    def node_rule(node)
      node.rule.join
    end

  end
end
