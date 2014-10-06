module SCSSLint
  class Linter::VendorPrefixes < Linter
    include LinterRegistry

    def check_node(node)
      name = node.name.is_a?(Array) ? node.name.join : node.name
      # Remove '@' from @keyframes node name
      name = name.gsub('@', '')
      return unless name.start_with?('-', '_')
      add_lint(node, 'Vendor prefixes should not be used.')
    end

    alias_method :visit_prop, :check_node
    alias_method :visit_pseudo, :check_node
    alias_method :visit_directive, :check_node

  end
end
