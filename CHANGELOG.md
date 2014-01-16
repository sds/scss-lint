# SCSS-Lint Changelog

## master (unreleased)

* Fix bug where `SingleLinePerSelector` would incorrectly report lint for
  selectors where interpolation contained commas
* Gracefully handle files with invalid byte sequences
* Add `FilesReporter` which prints out just the files that had lints
* Add `exclude` option to individual linter configurations, which disables
  that linter for files matching any of the specified set of globs
* Fix bug where scss-lint would crash if a `.scss-lint.yml` file contained
  only comments
* Teach scss-lint to report a lint when double quotes are used when single
  quotes will suffice (can be configured to prefer double quotes instead)
* Teach scss-lint to prefer quoted URLs
* Upgrade `colorize` dependency from `0.5.8` to `0.6.0`

## 0.16.1

* Fix bug where `data` directory was not included in gemspec

## 0.16.0

* Add `extra_properties` option to `PropertySpelling` linter so additional
  CSS properties can be added to the whitelist
* Teach scss-lint to report a lint when rule sets, functions, or mixins are
  not separated from each other with an empty line

## 0.15.0

* Fix bug where `SelectorDepth` could incorrectly report a lint for selectors
  with sequences chained onto a parent selector
* Teach scss-lint to detect non-existent/misspelled properties
* Teach `IdWithExtraneousSelector` linter to not report lints for IDs with
  just pseudo-selectors
* Teach scss-lint to detect spaces in parentheses
* Fix bug where `DuplicateProperty` linter would incorrectly report lints for
  properties with vendor-prefix values

## 0.14.0

* Fix bug where `ColorKeyword` would incorrectly report a lint for identifiers
  containing color keywords as substrings
* Teach scss-lint to detect selectors with large depths of applicability
* Add `-f`/`--format` flags to allow different output format type
* Remove `--xml` flag in favor of `-f XML`/`--format XML`

## 0.13.0

* Teach scss-lint to load configuration via the `--config` flag
* Teach scss-lint to load configuration based on location of file being linted
* Allow `Indentation` linter to have configurable indent width
* Add `exclude` directive to configuration system, allowing you to specify glob
  patterns of files to not lint
* Allow use of wildcards when configuring linters so you can enable/disable
  entire namespaces
* Use [semantic exit codes](http://tldp.org/LDP/abs/html/exitcodes.html#FTN.AEN23462)
  for common error conditions

## 0.12.1

* Teach scss-lint to prefer Compass mixins over some CSS properties
* Fix bug where `Shorthand` linter would crash on a numeric property value with
  no trailing semicolon

## 0.12.0

* Split `PropertyFormat` linter into `SpaceAfterPropertyColon`,
  `SpaceAfterPropertyName`, and `TrailingSemicolonAfterPropertyValue` linters
* Teach scss-lint to prefer spaces after commas in argument lists
* Display better error message for unexpected linter errors, including the
  name of the linter, the file that the linter failed on, and a link to
  the issue tracker

## 0.11.1

* Update Sass dependency from `3.2.10` -> `3.3.0.rc.1` for better source mapping
* Fix bug in `ColorKeyword` where an incorrect lint would be reported for the
  "transparent" color keyword

## 0.11.0

* Fix bug in `Shorthand` linter where a property with interpolation that
  started with a shorthandable property name could report false positives
* Improve message reported by `Shorthand` linter to display the shortest
  possible form
* Syntax errors are now differentiated from lint warnings in `scss-lint`'s
  output by using `E` and `W` respectively.
* `NoZeroBeforeDecimal` linter has been renamed to `LeadingZero`
* Fix bug where `LeadingZero` linter would not report lints for numeric
  values appearing in Sass script (e.g. function arguments)
* Teach scss-lint to detect duplicate properties in a rule set
* Teach scss-lint to detect incorrect indentation

## 0.10.1

* Fix bug where `HexFormat` linter would crash on color keywords
* Fix bug where `ColorKeyword` linter would not detect color keywords in
  shorthand properties and function/mixin calls

## 0.10.0
* Teach scss-lint to prefer hexadecimal colors over color names
* Linters can now define `visit_*` methods for visiting selectors
* Linters can now report lints with context-specific descriptions
* Fix bug where `CapitalizationInSelector` would report lint for attribute
  selectors with values containing capital letters
* `DeclaredName` and `UsageName` linters now report context-specific lint
  descriptions (i.e. they mention whether the offending item is a function,
  variable, etc.)
* `TypeInIdSelector` was renamed to `IdWithExtraneousSelector` and now reports
  a lint for the use of an ID with any other selector
* Upgrade Sass gem dependency to 3.2.10
* Fix bug where `ZeroUnit` linter would not report lints for properties with
  lists of values or Sass script
* Fix bug where `HexFormat` linter would report lints for ID selectors with
  names that could be hexadecimal color values

## 0.9.0
* Add `--show-linters` flag for listing all linters available to scss-lint
* Change `--ignore-linter` flag to use `CamelCase` linter names instead of
  `snake_case`
* Removed `-x` alias for `--xml` flag
* Change `-i`/`--ignore-linter` flags to `-x`/`--exclude-linter`
* Add `-i`/`--include-linters` flag to specify a subset of linters
* Fix bug where using transform-related functions were reported as lints
* Teach scss-lint that `.5em` is preferred over `0.5em`
* Teach scss-lint to prefer lowercase characters in selectors
* Linters names no longer have a `Linter` suffix
* Teach scss-lint that `@extend` should use placeholder selectors
* Fix bug where a lint would be reported for hyphened keyword arguments
* Teach scss-lint to recognize vendor-prefixed properties when enforcing sort
  order

## 0.8.0
* Handle non-existent files/directories gracefully
* Teach scss-lint that opening curly braces should be preceded by one space
* Teach scss-lint that placeholder names should be lowercase and use hyphens

## 0.7.1
* Upgrade Sass gem dependency from 3.2.8 -> 3.2.9
* Fixed crash that occurred for directive nodes (`@media`, etc.)

## 0.7.0
* Teach scss-lint that `border: 0;` is preferred over `border: none;`
* Teach scss-lint that variable names should not contain underscores or capital
  letters
* Teach scss-lint that function and mixin names follow same rules as variables
* Fix shorthand linter to work with Sass script expressions
* Fix property format linter to work with interpolated expressions
* Teach scss-lint to check names of functions/mixins/variables in scripts
* Fix hex color linter to work with Sass script expressions
* Teach scss-lint that // comments should be preferred over /**/ comments
* Upgrade Sass gem dependency from 3.2.7 -> 3.2.8

## 0.6.7
* Fixed `--ignore-linters` flag

## 0.6.6
* Fixed `--version` flag to not error due to not autoloading `VERSION`
* Trailing newlines are no longer output by default in linter output

## 0.6.5
* Major refactor of the Linter class to use Visitor pattern
* Fix shorthand linter for lists containing function calls

## 0.6
* Only lint files with `css` or `scss` extensions
* Fix recursive directory scanning
* Fix specs on Sass gem >= 3.2.6 (`ShorthandLinter` was failing)
* Add changelog (the thing you're reading)
* Add command-line flags (e.g. --version, --help)
* Add --xml flag for outputting XML
* Add --exclude flag for excluding SCSS files from being linted
* Add --ignore-linters flag to skip lints produced by certain linters

## 0.5.2
* Version bump to remove erroneously added untracked files from gem

## 0.5
* Improve clarity of shorthand linter through naming
* Teach scss-lint `property: 10px 10px` can be shorter
* Clarify ShorthandLinter spec structure

## 0.4
* Add linter for unnecessary types in selectors

## 0.3
* Teach scss-lint that selectors each get their own line

## 0.2
* Teach scss-lint about nested property syntax
* Teach scss-lint to detect too-long shorthand values
* Make scss-lint detect space before semicolon
* Add linter for order of declarations

## 0.1
* Initial public release
