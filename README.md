# SCSS-Lint

`scss-lint` is a tool to help keep your SCSS files clean and readable. It uses
rules established by the team at [Causes.com](http://causes.com).

## Installation

`gem install scss-lint`

## Usage

Run `scss-lint` from the command line by passing it files you want to lint:

    scss-lint app/assets/stylesheets/**/*.css.scss

`scss-lint` will output any problems with your SCSS, including the offending
filename and line number (if available).
