# SCSS-Lint

`scss-lint` is a tool to help keep your [SCSS](http://sass-lang.com) files
clean and readable. You can run it manually from the command-line, or integrate
it into your SCM hooks. It uses rules established by the team at
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

## What gets linted

`scss-lint` is an opinionated tool that helps you enforce a consistent style in
your SCSS. As an opinionated tool, we've had to make calls about what we think
are the "best" style conventions, even when there are often reasonable arguments
for more than one possible style. While all of our choices have a rational
basis, we think that the opinions themselves are less important than the fact
that `scss-lint` provides us with an automated and low-cost means of enforcing
consistency.

To get a sense of what lints exist, check out
[the spec suite](https://github.com/causes/scss-lint/tree/master/spec/linter).

The lints include:

* use `border: 0` not `border: none`
* use unit-less dimensions for 0-length quantities; ie. `margin: 0`, not
  `margin: 0px`
* use `$foo-bar`, not `$FooBar` or `$foo_bar`
* use `#foo`, not `a#foo`
* keep your rules in order, with mix-ins at the top
* use one selector per line
* use the shortest shorthand possible; ie. `padding: 0`, not `padding: 0 0`
* use consistent spacing between property names and property values
* use short-form lowercase hex codes when possible; ie. `#fc0`, not `#FFCC00`
* exclude empty rules

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run like so:

    bundle exec rspec

## See also

If you'd like to integrate `scss-lint` with Git, check out our Git hook gem,
[overcommit](https://github.com/causes/overcommit).
