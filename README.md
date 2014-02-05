# SCSS-Lint

[![Gem Version](https://badge.fury.io/rb/scss-lint.png)](http://badge.fury.io/rb/scss-lint)
[![Build Status](https://travis-ci.org/causes/scss-lint.png)](https://travis-ci.org/causes/scss-lint)
[![Code Climate](https://codeclimate.com/github/causes/scss-lint.png)](https://codeclimate.com/github/causes/scss-lint)
[![Dependency Status](https://gemnasium.com/causes/scss-lint.png)](https://gemnasium.com/causes/scss-lint)

`scss-lint` is a tool to help keep your [SCSS](http://sass-lang.com) files
clean and readable. You can run it manually from the command-line, or integrate
it into your [SCM hooks](https://github.com/causes/overcommit). It uses rules
established by the team at [Causes.com](https://causes.com).

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Formatters](#formatters)
* [Linters](#linters)
* [Editor Integration](#editor-integration)
* [Git Integration](#git-integration)
* [Contributing](#contributing)
* [Changelog](#changelog)
* [License](#license)

## Requirements

* Ruby 1.9.3+
* Files you wish to lint must be written in SCSS (not Sass) syntax

## Installation

```bash
gem install scss-lint
```

## Usage

Run `scss-lint` from the command-line by passing in a directory (or multiple
directories) to recursively scan:

```bash
scss-lint app/assets/stylesheets/
```

You can also specify a list of files explicitly:

```bash
scss-lint app/assets/stylesheets/**/*.css.scss
```

`scss-lint` will output any problems with your SCSS, including the offending
filename and line number (if available).

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify a configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-f`/`--format`           | Output format (see [Formatters](#formatters))
`-i`/`--include-linter`   | Specify which linters you specifically want to run
`-x`/`--exclude-linter`   | Specify which linters you _don't_ want to run
`-h`/`--help`             | Show command line flag documentation
`--show-linters`          | Show all registered linters
`-v`/`--version`          | Show version

## Configuration

`scss-lint` will automatically recognize and load any file with the name
`.scss-lint.yml` as a configuration file. It loads the configuration based on
the location of the file being linted, starting from that file's directory and
ascending until a configuration file is found. Any configuration loaded is
automatically merged with the default configuration (see `config/default.yml`).

Here's an example configuration file:

```yaml
inherit_from: '../../inherited-config.yml'

exclude: 'app/assets/stylesheets/plugins/**'

linters:
  BorderZero:
    enabled: false
    exclude:
      - 'path/to/file.scss'

  Indentation:
    enabled: true
    width: 2
```

All linters have an `enabled` option which can be `true` or `false`, which
controls whether the linter is run, along with linter-specific options.  The
defaults are defined in `config/default.yml`.

The `inherit_from` directive allows a configuration file to inherit settings
from another configuration file. The file specified by `inherit_from` is loaded
and then merged with the settings in the current file (settings in the current
file overrule those in the inherited file).

The `exclude` directive allows you to specify a glob pattern of files that
should not be linted by `scss-lint`. Paths are relative to the location of the
config file itself if they are not absolute paths. If an inherited file
specifies the `exclude` directive, the two exclusion lists are combined. Any
additional exclusions specified via the `--exclude` flag are also combined. If
you need to exclude files for a single linter you can specify the list of files
using the linter's `exclude` configuration option.

You can also configure `scss-lint` by specifying a file via the `--config`
flag, but note that this will override any configuration files that `scss-lint`
would normally find on its own (this can be useful for testing a particular
configuration setting, however). Configurations loaded this way will still be
merged with the default configuration specified by `config/default.yml`.

## Formatters

### Default

The default formatter is intended to be easy to consume by both humans and
external tools.

```
test.scss:2 [W] Prefer single quoted strings
test.scss:2 [W] Line should be indented 0 spaces, but was indented 1 space
test.scss:5 [W] Prefer single quoted strings
test.scss:6 [W] URLs should be enclosed in quotes
```

### Files

Useful when you just want to open all offending files in an editor. This will
just output the names of the files so that you can execute the following to
open them all:

```bash
scss-lint --format Files | xargs vim
```

### XML

Outputs XML with `<lint>`, `<file>`, and `<issue>` tags. Suitable for
consumption by tools like [Jenkins](http://jenkins-ci.org/).

```
<?xml version="1.0" encoding="utf-8"?>
<lint>
  <file name='test.css'>
    <issue line='2' severity='warning' reason='Prefer single quoted strings' />
    <issue line='2' severity='warning' reason='Line should be indented 0 spaces, but was indented 1 spaces' />
    <issue line='5' severity='warning' reason='Prefer single quoted strings' />
    <issue line='6' severity='warning' reason='URLs should be enclosed in quotes' />
  </file>
</lint>
```

## Linters

`scss-lint` is a customizable tool with opinionated defaults that helps you
enforce a consistent style in your SCSS. For these opinionated defaults, we've
had to make calls about what we think are the "best" style conventions, even
when there are often reasonable arguments for more than one possible style.

Should you want to customize the checks run against your code, you can do so by
editing your [configuration file](#configuration) to match your
preferred style.

###[» Linters Documentation](lib/scss_lint/linter/README.md)

## Editor Integration

### Vim

You can have `scss-lint` automatically run against your SCSS files after saving
by using the [Syntastic](https://github.com/scrooloose/syntastic) plugin. If
you already have the plugin, just add
`let g:syntastic_scss_checkers = ['scss_lint']` to your `.vimrc`.

### Sublime Text

Install the
[Sublime scss-lint plugin](https://sublime.wbond.net/packages/SublimeLinter-contrib-scss-lint).

## Git Integration

If you'd like to integrate `scss-lint` into your Git workflow, check out our
Git hook manager, [overcommit](https://github.com/causes/overcommit).

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run like so:

```bash
bundle exec rspec
```

## Changelog

If you're interested in seeing the changes and bug fixes between each version
of `scss-lint`, read the [SCSS-Lint Changelog](CHANGELOG.md).

## License

This project is released under the [MIT license](MIT-LICENSE).
