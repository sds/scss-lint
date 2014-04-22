module SCSSLint
  # Provides functionality for conveniently visiting a Selector sequence.
  module SelectorVisitor
    def visit_selector(node)
      visit_selector_node(node)
    end

  private

    def visit_selector_node(node)
      method = "visit_#{selector_node_name(node)}"
      send(method, node) if respond_to?(method, true)

      visit_members(node) if node.is_a?(Sass::Selector::AbstractSequence)
    end

    def visit_members(sequence)
      sequence.members.each do |member|
        visit_selector(member)
      end
    end

    def selector_node_name(node)
      # Converts the class name of a node into snake_case form, e.g.
      # `Sass::Selector::SimpleSequence` -> `simple_sequence`
      node.class.name.gsub(/.*::(.*?)$/, '\\1')
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                      .downcase
    end
  end
end
