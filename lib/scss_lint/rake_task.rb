require 'rake'
require 'rake/tasklib'

module SCSSLint
  # Provide task for invoking scss-lint via Rake.
  #
  # @example
  #   require 'scss_lint/rake_task'
  #   SCSSLint::RakeTask.new
  class RakeTask < Rake::TaskLib
    # The name of the task (default 'scss-lint')
    attr_accessor :name

    def initialize(*args, &task_block)
      @name = args.shift || :scss_lint

      desc 'Run scss-lint' unless ::Rake.application.last_comment

      task(name, *args) do |_, task_args|
        if task_block
          task_block.call(*[self, task_args].slice(0, task_block.arity))
        end
        run_task
      end
    end

    def run_task
      # Lazy load so task doesn't impact load time of Rakefile
      require 'scss_lint'
      require 'scss_lint/cli'

      puts 'Running SCSSLint...'

      CLI.new([]).tap do |cli|
        cli.parse_arguments
        cli.run
      end
    rescue SystemExit => ex
      if ex.status == CLI::EXIT_CODES[:data]
        abort('scss-lint found lints')
      elsif ex.status != 0
        abort('scss-lint failed with an error')
      end
    end
  end
end
