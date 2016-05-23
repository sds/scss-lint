[![Gem Version](https://badge.fury.io/rb/scss_lint.svg)](http://badge.fury.io/rb/scss_lint)
[![Build Status](https://travis-ci.org/brigade/scss-lint.svg?branch=master)](https://travis-ci.org/brigade/scss-lint)
[![Code Climate](https://codeclimate.com/github/brigade/scss-lint.svg)](https://codeclimate.com/github/brigade/scss-lint)
[![Coverage Status](https://coveralls.io/repos/brigade/scss-lint/badge.svg)](https://coveralls.io/r/brigade/scss-lint)
[![Inline docs](http://inch-ci.org/github/brigade/scss-lint.svg?branch=master)](http://inch-ci.org/github/brigade/scss-lint)
[![Dependency Status](https://gemnasium.com/brigade/scss-lint.svg)](https://gemnasium.com/brigade/scss-lint)

<p align="center">
  <img src="https://raw.githubusercontent.com/brigade/scss-lint/master/logo/horizontal.png" width="40%" alt="SCSS-Lint Logo"/>
</p>

`scss-lint` is a tool to help keep your [SCSS](http://sass-lang.com) files
clean and readable by running it against a collection of
[linter rules](lib/scss_lint/linter/README.md). You can run it manually from
the command line, or integrate it into your
[SCM hooks](https://github.com/brigade/overcommit).

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Formatters](#formatters)
* [Exit Status Codes](#exit-status-codes)
* [Linters](#linters)
* [Custom Linters](#custom-linters)
* [Preprocessing](#preprocessing)
* [Editor Integration](#editor-integration)
* [Git Integration](#git-integration)
* [Rake Integration](#rake-integration)
* [Maven Integration](#maven-integration)
* [Documentation](#documentation)
* [Contributing](#contributing)
* [Community](#community)
* [Changelog](#changelog)
* [License](#license)

## Requirements

* Ruby 1.9.3+
* Sass 3.4.20+ (`scss-lint` 0.27.0 was the last version to support Sass 3.3)
* Files you wish to lint must be written in SCSS (not Sass) syntax

## Installation

```bash
gem install scss_lint
```

...or add the following to your `Gemfile` and run `bundle install`:

```ruby
gem 'scss_lint', require: false
```

The `require: false` is necessary because `scss-lint` monkey patches Sass in
order to properly traverse the parse tree created by the Sass parser. This can
interfere with other applications that invoke the Sass parser after `scss-lint`
libraries have been loaded at runtime, so you should only require it in the
context in which you are linting, nowhere else.

## Usage

Run `scss-lint` from the command line by passing in a directory (or multiple
directories) to recursively scan:

```bash
scss-lint app/assets/stylesheets/
```

You can also specify a list of files explicitly:

```bash
scss-lint app/assets/stylesheets/**/*.css.scss
```

...or you can lint a file passed via standard input (**note** the
`--stdin-file-path` flag is required when passing via standard input):

```bash
cat some-file | scss-lint --stdin-file-path=path/to/treat/stdin/as/having.scss
```

`scss-lint` will output any problems with your SCSS, including the offending
filename and line number (if available).

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify a configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-f`/`--format`           | Output format (see [Formatters](#formatters))
`-o`/`--out`              | Write output to a file instead of STDOUT
`-r`/`--require`          | Require file/library (mind `$LOAD_PATH`, uses `Kernel.require`)
`-i`/`--include-linter`   | Specify which linters you specifically want to run
`-x`/`--exclude-linter`   | Specify which linters you _don't_ want to run
`--stdin-file-path`       | When linting a file passed via standard input, treat it as having the specified path to apply the appropriate configuration
`--[no-]color`            | Whether to output in color
`-h`/`--help`             | Show command line flag documentation
`--show-formatters`       | Show all available formatters
`--show-linters`          | Show all available linters
`-v`/`--version`          | Show version

When running `scss-lint` with JRuby, using JRuby's
[`--dev` flag](https://github.com/jruby/jruby/wiki/Improving-startup-time)
will probably improve performance.

## Configuration

`scss-lint` loads configuration in the following order of precedence:

1. Configuration file specified via the `--config` flag
2. Configuration from `.scss-lint.yml` in the current working directory,
   if it exists
3. Configuration from `.scss-lint.yml` in the user's home directory,
   if it exists

All configurations extend the [default configuration](config/default.yml).

**Note**: The first configuration file found is the one that is loaded, e.g.
the `.scss-lint.yml` file in the current working directory is loaded _instead_
of the one in the user's home directory&mdash;they are not merged with each
other.

Here's an example configuration file:

```yaml
scss_files: 'app/assets/stylesheets/**/*.css.scss'

exclude: 'app/assets/stylesheets/plugins/**'

linters:
  BorderZero:
    enabled: false

  Indentation:
    exclude:
      - 'path/to/file.scss'
      - 'path/to/directory/**'
    severity: warning
    width: 2
```

All linters have an `enabled` option which can be `true` or `false`, which
controls whether the linter is run, along with linter-specific options. The
defaults are defined in `config/default.yml`.

### Severities

The `severity` linter option allows you to specify whether the lint should be
treated as a `warning` or an `error`. Warnings cause `scss-lint` to exit with a
different error code than errors (unless both warnings _and_ errors are
present, in which case the `error` exit code is returned). This is useful when
integrating `scss-lint` with build systems or other executables, as you can
rely on its exit status code to indicate whether a lint actually requires
attention.

You can also define the default severity for all linters by setting the global
`severity` option.

### Excluding Files

The `exclude` directive allows you to specify a glob pattern of files that
should not be linted by `scss-lint`. Paths are relative to the location of the
config file itself if they are not absolute paths. If an inherited file
specifies the `exclude` directive, the two exclusion lists are combined. Any
additional exclusions specified via the `--exclude` flag are also combined. If
you need to exclude files for a single linter you can specify the list of files
using the linter's `exclude` configuration option.

### Generating a Configuration

To start using `scss-lint` you can use the [`Config` Formatter](#config),
which will generate an `.scss-lint.yml` configuration file with all linters
which caused a lint disabled. Starting with this as your configuration
you can slowly enable each linter and fix any lints one by one.

### Disabling Linters via Source

For special cases where a particular lint doesn't make sense in a specific
area of a file, special inline comments can be used to enable/disable linters.
Some examples are provided below:

**Disable for the entire file**
```scss
// scss-lint:disable BorderZero
p {
  border: none; // No lint reported
}
```

**Disable a few linters**
```scss
// scss-lint:disable BorderZero, StringQuotes
p {
  border: none; // No lint reported
  content: "hello"; // No lint reported
}
```

**Disable all lints within a block (and all contained blocks)**
```scss
p {
  // scss-lint:disable BorderZero
  border: none; // No lint reported
}

a {
  border: none; // Lint reported
}
```

**Disable and enable again**
```scss
// scss-lint:disable BorderZero
p {
  border: none; // No lint reported
}
// scss-lint:enable BorderZero

a {
  border: none; // Lint reported
}
```

**Disable/enable all linters**
```scss
// scss-lint:disable all
p {
  border: none; // No lint reported
}
// scss-lint:enable all

a {
  border: none; // Lint reported
}
```

## Formatters

### Default

The default formatter is intended to be easy to consume by both humans and
external tools.

```bash
scss-lint [scss-files...]
```

```
test.scss:2 [W] StringQuotes: Prefer single quoted strings
test.scss:2 [W] Indentation: Line should be indented 0 spaces, but was indented 1 space
test.scss:5 [W] StringQuotes: Prefer single quoted strings
test.scss:6 [W] UrlQuotes: URLs should be enclosed in quotes
```

### CleanFiles

Displays a list of all files that were free of lints.

### Config

Returns a valid `.scss-lint.yml` configuration where all linters which caused
a lint are disabled. Starting with this as your configuration, you can slowly
enable each linter and fix any lints one by one.

```bash
scss-lint --format=Config [scss-files...]
```

```yaml
linters:
  Indentation:
    enabled: false
  StringQuotes:
    enabled: false
  UrlQuotes:
    enabled: false
```

### Files

Useful when you just want to open all offending files in an editor. This will
just output the names of the files so that you can execute the following to
open them all:

```bash
scss-lint --format=Files [scss-files...] | xargs vim
```

### JSON

Outputs JSON with filenames and an array of issue objects.

```json
{
  "test.css": [
    {"line": 2, "severity": "warning", "reason": "Prefer single quoted strings"},
    {"line": 2, "severity": "warning", "reason": "Line should be indented 0 spaces, but was indented 1 spaces"},
    {"line": 5, "severity": "warning", "reason": "Prefer single quoted strings"},
    {"line": 6, "severity": "warning", "reason": "URLs should be enclosed in quotes"}
  ]
}
```

### TAP

Outputs [TAP version 13](https://testanything.org) format.

```
TAP version 13
1..5
ok 1 - ok1.scss
not ok 2 - not-ok1.scss:123:10 SCSSLint::Linter::PrivateNamingConvention
  ---
  message: Description of lint 1
  severity: warning
  data:
    file: not-ok1.scss
    line: 123
    column: 10
  ---
not ok 3 - not-ok2.scss:20:2 SCSSLint::Linter::PrivateNamingConvention
  ---
  message: Description of lint 2
  severity: error
  data:
    file: not-ok2.scss
    line: 20
    column: 2
  ---
not ok 4 - not-ok2.scss:21:3 SCSSLint::Linter::PrivateNamingConvention
  ---
  message: Description of lint 3
  severity: warning
  data:
    file: not-ok2.scss
    line: 21
    column: 3
  ---
ok 5 - ok2.scss
```

### Stats

Outputs statistics about how many lints of each type were found, and across how many files. This
reporter can help in cleaning up a large codebase, allowing you to fix and then enable one lint
type at a time.

```
15  ColorKeyword                  (across  1 files)
15  ColorVariable                 (across  1 files)
11  StringQuotes                  (across 11 files)
11  EmptyLineBetweenBlocks        (across 11 files)
 5  Indentation                   (across  1 files)
 5  QualifyingElement             (across  2 files)
 4  MergeableSelector             (across  1 files)
--  ----------------------        -----------------
66  total                         (across 12 files)
```

### Plugins

There are also formatters that integrate with third-party tools which are available as plugins.

#### Checkstyle

Outputs an XML document with `<checkstyle>`, `<file>`, and `<error>` tags.
Suitable for consumption by tools like
[Jenkins](http://jenkins-ci.org/) with the
[Checkstyle plugin](https://wiki.jenkins-ci.org/display/JENKINS/Checkstyle+Plugin).

```bash
gem install scss_lint_reporter_checkstyle
scss-lint --require=scss_lint_reporter_checkstyle --format=Checkstyle [scss-files...]
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<checkstyle version="1.5.6">
  <file name="test.css">
    <error line="2" severity="warning" message="Prefer single quoted strings" />
    <error line="2" severity="warning" message="Line should be indented 0 spaces, but was indented 1 spaces" />
    <error line="5" severity="warning" message="Prefer single quoted strings" />
    <error line="6" severity="warning" message="URLs should be enclosed in quotes" />
  </file>
</checkstyle>
```

## Exit Status Codes

`scss-lint` tries to use
[semantic exit statuses](http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits)
wherever possible, but the full list of codes and the conditions under which they are
returned is listed here for completeness.

Exit Status | Description
------------|-------------------------------------------------------------
`0`         | No lints were found
`1`         | Lints with a severity of `warning` were reported (no errors)
`2`         | One or more errors were reported (and any number of warnings)
`64`        | Command line usage error (invalid flag, etc.)
`66`        | One or more files specified were not found
`69`        | Required library specified via `-r`/`--require` flag was not found
`70`        | Unexpected error (i.e. a bug); please [report it](https://github.com/brigade/scss-lint/issues)
`78`        | Invalid configuration file; your [YAML](http://www.yaml.org/) is likely incorrect
`80`        | Files glob patterns specified did not match any files.

## Linters

`scss-lint` is a customizable tool with opinionated defaults that helps you
enforce a consistent style in your SCSS. For these opinionated defaults, we've
had to make calls about what we think are the "best" style conventions, even
when there are often reasonable arguments for more than one possible style.

Should you want to customize the checks run against your code, you can do so by
editing your [configuration file](#configuration) to match your
preferred style.

###[» Linters Documentation](lib/scss_lint/linter/README.md)

## Custom Linters

`scss-lint` allows you to create custom linters specific to your project. By
default, it will load linters from the `.scss-linters` in the root of your
repository. You can customize which directories to load from via the
`plugin_directories` option in your `.scss-lint.yml` configuration file. See
the [linters directory](lib/scss_lint/linter) for examples of how to write
linters. All linters loaded from directories in `plugin_directories` are
enabled by default, and you can set their configuration in your
`.scss-lint.yml`.

```ruby
# .scss-linters/another_linter.rb

module SCSSLint
  class Linter::AnotherLinter < Linter
    include LinterRegistry

    ...
  end
end
```

```yaml
# .scss-lint.yml
plugin_directories: ['.scss-linters', '.another_directory']

linters:
  AnotherLinter:
    enabled: true
    some_option: [1, 2, 3]
```

You can also load linters packaged as gems by specifying the gems via the
`plugin_gems` configuration option. See the
[`scss_lint_plugin_example`](https://github.com/cih/scss_lint_plugin_example)
for an example of how to structure these plugins.

If the gem is packaged with an `.scss-lint.yml` file in its root directory then
this will be merged with your configuration. This provides a convenient way for
organizations to define a single repo with their `scss-lint` configuration and
custom linters and use them across multiple projects. You can always override
plugin configuration with your repo's `.scss-lint.yml` file.

```yaml
# .scss-lint.yml
plugin_gems: ['scss_lint_plugin_example']
```

Note that you don't need to publish a gem to Rubygems to take advantage of
this feature. Using Bundler, you can specify your plugin gem in your project's
`Gemfile` and reference its git repository instead:

```ruby
# Gemfile
gem 'scss_lint_plugin_example', git: 'git://github.com/cih/scss_lint_plugin_example'
```

As long as you execute `scss-lint` via `bundle exec scss-lint`, it should be
able to load the gem.

## Preprocessing

Sometimes SCSS files need to be preprocessed before being linted. This is made
possible with two options that can be specified in your configuration file.

The `preprocess_command` option specifies the command to run once per SCSS
file. The command can be specified with arguments. The contents of a SCSS
file will be written to STDIN, and the processed SCSS contents must be written
to STDOUT. If the process exits with a code other than 0, scss-lint will
immediately exit with an error.

For example, `preprocess_command: "cat"` specifies a simple no-op preprocessor
(on Unix-like systems). `cat` simply writes the contents of STDIN back out to
STDOUT. To preprocess SCSS files with
[Jekyll front matter](http://jekyllrb.com/docs/assets/), you can use
`preprocess_command: "sed '1,2s/---//'"`. This will strip out any Jekyll front
matter, but preserve line numbers.

If only some SCSS files need to be preprocessed, you may use the
`preprocess_files` option to specify a list of file globs that need
preprocessing. Preprocessing only a subset of files should make scss-lint more
performant.

## Editor Integration

### Vim

You can have `scss-lint` automatically run against your SCSS files after saving
by using the [Syntastic](https://github.com/scrooloose/syntastic) plugin. If
you already have the plugin, just add
`let g:syntastic_scss_checkers = ['scss_lint']` to your `.vimrc`.

### IntelliJ

Install the [SCSS Lint plugin for IntelliJ](https://github.com/idok/scss-lint-plugin)

### Sublime Text

Install the
[Sublime scss-lint plugin](https://sublime.wbond.net/packages/SublimeLinter-contrib-scss-lint).

### Atom

Install the [Atom scss-lint plugin](https://atom.io/packages/linter-scss-lint). It is a part of the [`atomlinter`](https://atom.io/users/atomlinter) project, so if you are already using other linter plugins, you can keep them in one place.

### Emacs

Install and enable both [scss-mode](https://github.com/antonj/scss-mode) and [flycheck-mode](https://github.com/flycheck/flycheck). You can enable automatic linting for scss-mode buffers with `(add-hook 'scss-mode-hook 'flycheck-mode)` in your `init.el`.

## Git Integration

If you'd like to integrate `scss-lint` into your Git workflow, check out our
Git hook manager, [overcommit](https://github.com/brigade/overcommit).

## Rake Integration

To execute `scss-lint` via a [Rake](https://github.com/ruby/rake) task, add the
following to your `Rakefile`:

```ruby
require 'scss_lint/rake_task'

SCSSLint::RakeTask.new
```

When you execute `rake scss_lint`, the above configuration is equivalent to
just running `scss-lint`, which will lint all `.scss` files in the current
working directory and its descendants.

You can customize the task by writing:

```ruby
require 'scss_lint/rake_task'

SCSSLint::RakeTask.new do |t|
  t.config = 'custom/config.yml'
  t.args = ['--formatter', 'JSON', '--out', 'results.txt']
  t.files = ['app/assets', 'custom/*.scss']
end
```

You can specify any command line arguments in the `args` attribute that are
allowed by the `scss-lint` Ruby binary script. Each argument must be passed as
an Array element, rather than one String with spaces.

You can also use this custom configuration with a set of files specified via
the command line:

```bash
# Single quotes prevent shell glob expansion
rake 'scss_lint[app/assets, custom/*.scss]'
```

Files specified in this manner take precedence over the `files` attribute
initialized in the configuration above.

## Maven Integration

[Maven] integration is available as part of the [Sass maven
plugin][maven-plugin] `scss-lint` since [version 2.3][maven-plugin-2.3] Check
out the [plugin documentation][maven-plugin-info].

The Maven plugin comes with the necessary libraries included, a separate
installation of `ruby` or `scss-lint` is not required.

[maven]: https://maven.apache.org/
[maven-plugin]: https://github.com/GeoDienstenCentrum/sass-maven-plugin
[maven-plugin-2.3]: http://www.geodienstencentrum.nl/sass-maven-plugin/releasenotes.html#a2.3_Release_Notes
[maven-plugin-info]: https://GeoDienstenCentrum.github.io/sass-maven-plugin/plugin-info.html

## Documentation

[Code documentation] is generated with [YARD] and hosted by [RubyDoc.info].

[Code documentation]: http://rdoc.info/github/brigade/scss-lint/master/frames
[YARD]: http://yardoc.org/
[RubyDoc.info]: http://rdoc.info/

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run like so:

```bash
bundle exec rspec
```

After you get the unit tests passing, you probably want to see your version of
`scss-lint` in action. You can use Bundler to execute your binary locally from
within your project's directory:

```bash
bundle exec bin/scss-lint
```

## Community

All major discussion surrounding SCSS-Lint happens on the
[GitHub issues page](https://github.com/brigade/scss-lint/issues).

You can also follow [@scss_lint on Twitter](https://twitter.com/scss_lint).

## Changelog

If you're interested in seeing the changes and bug fixes between each version
of `scss-lint`, read the [SCSS-Lint Changelog](CHANGELOG.md).

## Code of conduct

This project adheres to the [Open Code of Conduct][code-of-conduct]. By
participating, you are expected to honor this code.

[code-of-conduct]: https://github.com/brigade/code-of-conduct

## License

This project is released under the [MIT license](MIT-LICENSE).
