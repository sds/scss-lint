# SCSS-Lint

`scss-lint` is a tool to help keep your [SCSS](http://sass-lang.com) files
clean and readable. It uses rules established by the team at
[Causes.com](http://causes.com).

## Installation

`gem install scss-lint`

## Usage

Run `scss-lint` from the command-line by passing in a directory (or multiple
directories) to recursively scan:

    scss-lint app/assets/stylesheets/

You can also specify a list of files explicitly:

    scss-lint app/assets/stylesheets/**/*.css.scss

`scss-lint` will output any problems with your SCSS, including the offending
filename and line number (if available).

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run like so:

    bundle exec rspec
