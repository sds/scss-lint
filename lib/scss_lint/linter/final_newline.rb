module SCSSLint
  # Checks for final newlines at the end of a file.
  class Linter::FinalNewline < Linter
    include LinterRegistry

    def visit_root(_node)
      return if engine.lines.empty?

      ends_with_newline = engine.lines[-1][-1] == "\n"

      if config['present']
        add_lint(engine.lines.count,
                 'Files should end with a trailing newline') unless ends_with_newline
      else
        add_lint(engine.lines.count,
                 'Files should not end with a trailing newline') if ends_with_newline
      end
    end
  end
end
