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

      exit CLI.new.run([])
    rescue SystemExit => ex
      if (ex.status == CLI::EXIT_CODES[:error] ||
          ex.status == CLI::EXIT_CODES[:warning])
        puts 'scss-lint found lints'
        exit ex.status
      elsif ex.status != 0
        puts 'scss-lint failed with an error'
        exit ex.status
      end
    end
  end
end
