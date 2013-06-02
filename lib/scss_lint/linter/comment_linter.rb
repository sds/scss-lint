require 'sass'

module SCSSLint
  class Linter::CommentLinter < Linter
    include LinterRegistry

    def visit_comment(node)
      add_lint(node) unless node.invisible?
    end

    def description
      'Use // comments everywhere'
    end
  end
end
