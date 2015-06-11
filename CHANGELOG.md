# SCSS-Lint Changelog

## master (unreleased)

* Fix `ColorVariable` from crashing when variable interpolation occurs in
  multiline comments
* Add support for loading custom linters via the `plugin_directories` and
  `plugin_gems` configuration options (experimental)
* Add `ExtendDirective` linter which checks for any usage of the `@extend`
  directive.
* Fix `PropertySortOrder`'s `ignore_unspecified: false` behavior to not care
  about the relative order of unspecified properties at the end of a list of
  properties
* Change `NameFormat` to no longer check placeholder names, as this is handled
  by the `SelectorFormat` linter
* Add `TrailingWhitespace` linter which reports whitespace characters at the
  end of a line
* Change `NestingDepth` to allow parent selectors to be ignored in depth count
  by passing configuration option `ignore_parent_selectors: true`

## 0.39.0

### New Features

* Add `BemDepth` which checks the number of BEM elements is under a specified
  maximum

### Changes

* Load configuration file from user's home directory if one exists and no other
  configuration file is specified or in the current working directory
* Improve issue reporting instructions displayed when scss-lint crashes
* Remove `XML` formatter (see the
  [`Checkstyle` formatter](https://github.com/Sweetchuck/scss_lint_reporter_checkstyle)
  for an XML-based alternative)

### Bug Fixes

* Fix `Indentation` to not report `@import` directives spread across multiple
  lines
* Fix `Indentation` linter from crashing on `@else` statements with
  `allow_non_nested_indentation` set to `true`
* Update default configuration to work with projects using the
  [`syck`](https://github.com/indeyets/syck) YAML parser
* Fix `ColorKeyword` to not report lints for map keys with color keyword names

## 0.38.0

* Change configuration loading behavior so that defining lists in a custom
  configuration will completely override the old list instead of adding to it
* Fix `DeclarationOrder` linter to report lints for items within media queries
* Add `allowed_shorthands` option for `Shorthand` linter
* Add `allowed` option to `Comment` linter specifying regex of allowed
  multi-line comments, such as copyright notices
* Fix bug where control comments could filter out lints from other files
  depending on scan order
* Ignore `currentColor`, `inherit`, and `transparent` values in
  `VariableForProperty`
* Add `min_properties` option to `PropertySortOrder` to allow specifying a
  threshold number of properties that must be present before linting occurs
* Fix `PropertySortOrder` to lint sort order of nested properties
* Add `one_space_or_newline` `style` option to `SpaceAfterPropertyColon`
* Fix `ColorVariable` to ignore literal strings containing color keywords
* Rename `scss-lint` gem to `scss_lint` to follow RubyGems [best practices for
  naming gems](http://guides.rubygems.org/name-your-gem/). This only affects
  the name you use in `Gemfile`s or when you `gem install`; everything else
  remains the same.

## 0.37.0

* Rename `BEM` option on `SelectorFormat` to `strict_BEM` to emphasize that
  this is a particular dialect which may not be what developers expect
* Allow `SelectorFormat` convention explanations to be customized via the
  `#{type}_convention_explanation` and `convention_explanation` options
* Add `camel_case` and `snake_case` conventions to `NameFormat`
* Remove `BEM` convention from `NameFormat`, as it didn't make sense in this
  context since `NameFormat` does not deal with selectors
* Add support for function, mixin, or variable-specific conventions to
  `NameFormat`
* Add support for custom convention explanations to `NameFormat`

## 0.36.1

* Fix `PropertyUnits` to not error on properties with function call values
* Fix `DeclarationOrder` false positives on lines of the same type of node
* Fix `PropertyUnits` false positives on unicode escape sequences and string
  values that look like units
* Add additional units to default configuration for `PropertyUnits`, including
  durations, frequencies, angles, and resolutions

## 0.36.0

* Fix `SpaceAfterPropertyColon` to report nested properties
* Add `PropertyUnits` allowing customization of which units are allowed for
  specific properties
* Allow color literals in map declarations and the `rgba` helper function in
  `ColorVariable`
* Gracefully handle when a library specified via `-r`/`--require` is not found
  and return a semantic exit code `EX_UNAVAILABLE` (`69`)
* Improve message of `DeclarationOrder` to specify the line number of the
  out-of-order item and the line number of where it was expected to be
* Return helpful error message and unsuccessful exit code when all files
  matched by specified glob patterns are excluded by `--exclude` flags and
  `exclude` configuration settings
* Change exit code returned when file globs patterns did not match any files to
  be different from the exit code returned when a specified file does not exist

## 0.35.0

* Fix `ColorVariable` to not report occurrences of `transparent` when appearing
  in function calls or list literals
* Fix infinite loop in control comment processor when dealing with parse nodes
  with no children with line numbers
* Change `VendorPrefix` config options `include` and `exclude` to
  `additional_identifers` and `excluded_identifers`, respectively
* Rename `VendorPrefixes` to `VendorPrefix`
* Add `animation*` properties to concentric.txt
* Fix bug where attempting to lint a non-existent file would result in a crash

## 0.34.0

### New Features

* Add `ImportantRule` linter which reports uses of `!important` in properties
* Add `VariableForProperty` linter which enforces using variables for
  specified property values instead of literal values
* Add `convention` option to `BorderZero` allowing `none` to be preferred over
  zero
* Add `separate_groups` option to `PropertySortOrder` to specify that groups
  of properties should be visually separated
* Add `PropertyCount` linter which reports rule sets with a large number of
  properties
* Add `ColorVariable` linter which enforces the use of color literals in
  variable declarations only
* Add `break-after`, `break-before`, `break-inside`, and `text-size-adjust`
  to list of recognized properties
* Add `allow_non_nested_indentation` option to `Indentation` linter
* Allow files without `.scss`/`.css` extension to be linted if they are
  passed explicitly (i.e. you do not specify a directory, but the file itself)

### Changes

* Remove support for per-directory configuration and `inherit_from` from
  the configuration system

### Bug Fixes

* Fix bug in `StringQuotes` where Sass script in non-silent comments would
  cause a crash
* Fix control comments placed before `@include` blocks to apply within them
* Fix crash in `PropertySortOrder` when non-existent preset sort order or
  otherwise invalid sort order are specified in the configuration
* Fix recognition of control comments in selector comma sequences
* Fix crash in `BangFormat`, `ImportantRule`, and `VendorPrefixes` when linting
  properties with list literals containing empty lists

## 0.33.0

* Call `Kernel.exit` with status code returned by CLI in rake task (unless 0)
* Allow list of files and glob patterns to be passed as task arguments
  to rake task
* Allow custom configuration file to be specified in rake task
* Fix infinite loop in `SpaceAfterComma` for arguments spanning multiple
  lines

## 0.32.0

* Fix regression in rake task
* Fix grammar of lints reported by `SelectorFormat`
* Add .projections.json configuration file
* Fix regression in `--require` switch that caused custom formatters to
  not be `require`d before they were created
* Fix bug in `BangFormat` where lines without a semicolon would cause an
  infinite loop

## 0.31.0

### New Features

* Add support for disabling/enabling linters via inline comments
* Add `smacss` sort order option for `PropertySortOrder`
* Add `recess` sort order option for `PropertySortOrder`
* Add `allow_leading_underscore` option to `NameFormat` to allow the leading
  underscore convention to denote private functions

### Changes

* Change `IdWithExtraneousSelector` to `IdSelector` and modify behavior to
  always report a lint when an ID appears as part of a selector.

### Bug Fixes

* Fix regression in default configuration for `QualifyingElement` so that
  elements with attributes, classes, or ids are disallowed by default
* Fix error message for `TrailingSemicolon` where lines without a semicolon
  would incorrectly be reported as having a space before the semicolon
* Fix `BangFormat` linter to not report lints for exclamation points in
  strings
* Update minimum version of `sass` gem to 3.4.1 to fix a parser bug
* Fix `DuplicateProperty` not reporting duplicate properties in nested rule
  sets
* Fix `TrailingSemicolon` handling of comma-separated `@import`s
* Fix `SelectorFormat` to not allow format of pseudo-selectors to be defined,
  as they are always hyphenated lowercase
* Fix `Indentation` to not crash on `@at-root` directives with comments inside
* Fix `DuplicateProperty` to report correct name of duplicated property
* Fix `EmptyLineBetweenBlocks` to allow trailing comments after rule sets
  (e.g. control comments disabling linters)

## 0.30.0

### New Features

* Add `VendorPrefixes` linter which ensures only whitelisted vendor-prefixed
  properties are used
* Add `scss_files` configuration option allowing a default set of files to be
  linted if no files are explicitly specified
* Add `BangFormat` linter which enforces spacing around the `!` for
  `!important` and `!default`
* Add `new_line` option to `SpaceBeforeBrace` linter enforcing opening curly
  braces start on a new line
* Add `NestingDepth` linter which ensures selectors are nested only up to a
  specified maximum depth
* Add support to `SelectorFormat` for specifying different conventions for
  different types of selectors via the `<type>_convention` options
* Add `@import` check to `TrailingSemicolon`
* Add support for differentiating `@include`s with actual content versus
  no-content `@include`s in `DeclarationOrder`
* Add support for checking the ordering of content within `@include`s
* Add `ImportPath` linter which ensures paths for `@import` directives follow
  a certain format
* Add `QualifyingElement` linter which checks for unnecessarily-qualified
  element selectors
* Add `--out` flag which allows the output of the last formatter specified via
  the `--format` flag to be redirected to a file
* Add `--require` flag allowing arbitrary Ruby modules to be loaded (facilitating
  custom reporters)

### Changes

* Improve message reported by `PropertySortOrder` to specify the expected sort
  order
* Enforce UTF-8 encoding by default
* Change `BEM` convention of `SelectorFormat` `convention` option to
  `hyphenated_BEM`, and introduce `BEM` format as specified in
  https://bem.info/method/definitions/
* Prefix all syntax error messages with "Syntax Error:"

### Bug Fixes

* Fix bug in `SpaceAfterPropertyName`/`TrailingSemicolon` linters where lint
  would be reported for oneline properties following a selector with
  interpolation
* Fix bug in `SpaceAfterPropertyColon`/`SpaceAfterPropertyName`/`TrailingSemicolon`
  linters where lint would be reported for one-line properties following a
  selector with interpolation
* Fix `PropertySpelling` linter to check the names of nested properties

## 0.29.0

### New Features

* Add `TrailingZero` linter which checks for unnecessary zeros following a
  decimal point
* Add `SelectorFormat` linter which checks that the names of ids, classes, etc.
  in selectors match a desired convention
* Add JSON formatter

### Changes

* Update list of known properties (used by `PropertySpelling` lint)
* Enhance `TrailingSemicolon` to check for more than one semicolon at the end
  of a statement
* Remove `CapitalizationInSelector`, which has been superseded by the more
  powerful `SelectorFormat` linter

### Bug Fixes

* Fix bug where SassScript selectors referring to the current selector would
  result in a crash
* Fix bug in `EmptyLineBetweenBlocks` linter where lint would incorrectly be
  reported when comments immediately followed the closing brace of a rule set
* Fix bug in `PropertySortOrder` where properties within media queries were
  not checked for sort order
* Fix bug in `UrlQuotes` linter where lint would be reported for data URIs
* Fix bug in `UnnecessaryParentReference` where selectors with multiple `&`
  references where one `&` was concatenated would incorrectly report a lint

## 0.28.0

* Fix bug in `StringQuotes` where strings with interpolation were incorrectly
  being linted
* Upgrade minimum `sass` version dependency to 3.4.x series

## 0.27.0

* Fix broken `ignore_unspecified` option in `PropertySortOrder`
* Add linting of `@include` and `@if`/`@else` blocks in `PropertySortOrder`
* Fix `HexValidation` bug incorrectly reporting lints for 8 character hex
  codes in Microsoft `filter` property
* Fix `UnnecessaryParentReference` incorrectly reporting lints for nested
  selectors with more than one parent reference

## 0.26.2

* Fix `TrailingSemicolon` bug with `@include` blocks that didn't contain
  properties
* Add more properties to `concentric` preset order

## 0.26.1

* Fix `TrailingSemicolon` incorrectly reporting `@include`s with block contents
* Fix `UnnecessaryParentReference` incorrectly reporting using of `&` with
  concatenation
* Fix `SingleLinePerSelector` crashing for selectors that contained
  interpolated function calls
* Add additional properties to the `concentric` preset order
* Fix `LeadingZero` crashing on multi-line strings with interpolation

## 0.26.0

### New Features

* Add `severity` option allowing the severity level of a lint to be configured
* Include linter name in lint description
* Add `character` option to `Indentation` linter which allows specifying
  tabs or spaces as the indentation character of choice
* Add `SingleLinePerProperty` linter which checks that properties each reside
  on their own line
* Add support to `PropertySortOrder` to specify a preset sort order via the
  `order` property
* Add [`concentric`](http://rhodesmill.org/brandon/2011/concentric-css/) preset
  sort order to the `PropertySortOrder` linter
* Add `ignore_unspecified` option to `PropertySortOrder` to indicate that
  unspecified properties in custom sort orderings are to be ignored (i.e. they
  can appear anywhere)
* Add `ignore` option to `Compass::PropertyWithMixin` linter allowing you to
  not warn for certain properties
* Add `ignored_names` option to `CapitalizationInSelector`, allowing you to
  whitelist certain names as not needing to follow the convention
* Add `ignored_types` option to `CapitalizationInSelector`, allowing you to
  selectively ignore capitalization in certain types of selectors
* Add `UnnecessaryParentReference` linter which checks nested selectors for
  extraneous parent references
* Teach `TrailingSemicolon` to report lints for uses of `@extend`, `@include`,
  or variable declarations without semicolons

### Changes

* Change CLI to return exit code of `1` if only warnings are reported, or `2`
  if any errors are reported (was previously `65` for either)
* Update `sass` dependency to require 3.3.7 or later (fixes a parsing bug)
* Include test files in gem distribution
* Rename `TrailingSemicolonAfterPropertyValue` to `TrailingSemicolon`

### Bug Fixes

* Fix bug in `SpaceBeforeBrace` linter where an erroneous lint would
  be reported for a brace on its own line
* Fix bug in `SpaceAfterComma` where trailing spaces followed by a newline after
  a comma would incorrectly report a lint
* Fix `SingleLinePerSelector` to ignore any selectors that contain interpolation

## 0.25.1

* Fix bug in `Indentation` linter where it would crash when a comment
  preceded a line whose indentation was being checked

## 0.25.0

* Fix bug in `Indentation` linter where `@at-root` directives with inline
  selectors would erroneously report incorrect indentation levels
* Fix bug in `Indentation` linter where rule nodes with selectors spread
  over multiple lines and a single inline property would incorrectly report
  a lint
* Add `ElsePlacement` linter which checks the position of `@else` directives
  with respect to the previous curly brace
* Replace `allow_extra_spaces` option on `SpaceAfterPropertyColon` linter with
  `style` which accepts multiple different property spacing styles
* Fix bug in `PlaceholderInExtend` linter which erroneously report lints for
  selectors with interpolated strings

## 0.24.1

* Fix bug in `TrailingSemicolonAfterPropertyValue` to not crash on a one-line
  property without a semicolon
* Fix crash due to `DefaultReporter` not being loaded on Windows machines
* Fix bug in `MergeableSelector` where it would crash checking rules with
  interpolation

## 0.24.0

* Extend `DuplicateRoot` to `MergeableSelector` linter to check for nested
  rule sets that can be merged in addition to root-level ones
* Add `ConfigReporter` formatter which returns a valid `.scss-lint.yml`
  configuration file where all linters that caused a lint are disabled
* Fix bug in `Indentation` linter where `@at-root` directives were not
  treated as an increase in indentation level
* Fix `ZeroUnit` to only report lints for zero values in
  [lengths](https://developer.mozilla.org/en-US/docs/Web/CSS/length)
* Fix crash in `SingleLinePerSelector` for selectors containing only
  interpolation
* Add `--show-formatters` option to display all available formatters
* Add `HexValidation` to validate hex colors
* Split `HexFormat` into `HexLength` (checking length) and `HexNotation`
  (checking lowercase / uppercase)

## 0.23.1

* Fix bug in `SpaceAfterPropertyColon` linter for properties with no
  terminating semicolon
* Fix bug in `DuplicateRoot` linter where incorrect lints would be reported
  in `@keyframes` directives

## 0.23.0

* Fix character escaping in XML attributes output by `XMLReporter`
* Fix bug in `ZeroUnit` where hex color codes or real numbers with a zero
  decimal unit would report a false positive
* Fix bug in `Shorthand` linter where `!important` priority overrides would
  prevent lints from being reported
* Add `UnnecessaryMantissa` linter which checks for zero value decimals in
  numbers (i.e. prefers `4` over `4.0`)
* `XMLReporter` now includes `column` and `length` information for lints
* Fix class of bugs in `SpaceBeforeBrace` where a false positive could be
  reported for braces that aren't part of declarations
* Teach `Compass::PropertyWithMixin` to prefer `inline-block` mixin over
  `display: inline-block`
* Add `DuplicateRoot` linter which checks for identical rules used as root
  selectors in a document

## 0.22.0

* Add `allow_single_line_padding` option to `SpaceBeforeBrace` which allows
  you to visually align multiple single line blocks with extra padding spaces
* Add `FinalNewline` linter which checks for existence/lack of final newlines
  in files
* Fix bug in `ZeroUnit` linter where a string with a substring that looked
  like a zero followed by units would incorrectly report a lint
* Fix bug in `TrailingSemicolonAfterPropertyValue` where a lint would be
  incorrectly reported for properties split up over multiple lines
* Fix bug in `UrlFormat` where using a data URL would be incorrectly
  reported as a URL with protocol
* Add `allow_extra_spaces` option to `SpaceAfterPropertyColon` which
  allows you to use extra spaces to align values
* Fix bug in `SpaceBeforeBrace` linter when using `{` in single quotes

## 0.21.0

* Add support to `DuplicateProperty` linter to detect duplicate properties
  in placeholder and mixin declarations
* Add option `ignore_single_line_blocks` to the `EmptyLineBetweenBlocks`
  linter
* Add `UrlFormat` linter which reports uses of `url(...)` with URLs
  containing protocols or domains
* Replace `colorize` dependency with `rainbows`

## 0.20.3

* Fix bug in `NameFormat` linter where it would incorrectly report a
  lint for transform-related Compass mixins

## 0.20.2

* Fix bug in `SpaceBeforeBrace` where it would report a lint for #{...}
  interpolation erroneously

## 0.20.1

* Fix bug in `SpaceBeforeBrace` where it would not report a lint for
  one-line rule sets

## 0.20.0

* Add `convention` option to `NameFormat` allowing custom convention to
  be specified
* Fix bug in `SpaceBetweenParens` linter for majority of cases where a
  lint would be reported if parens existed inside a comment
* Add basic rake task

## 0.19.0

* Update Sass dependency to 3.3.0. All previous versions are not supported.
* Fix `StringQuotes` linter to not report lints for strings containing
  interpolation
* Fix configuration loading to gracefully report YAML errors

## 0.18.0

* Add `order` option to `SortedProperties` linter allowing an explicit
  ordering of properties to be specified
* Rename `SortedProperties` linter to `PropertySortOrder`

## 0.17.3

* Fix bug in XML output where `DuplicateProperty` linter message would
  result in invalid XML

## 0.17.2

* Merge `DeclaredName` and `UsageName` into `NameFormat` linter

## 0.17.1

* Downgrade `colorize` dependency from `0.6.0` back to `0.5.8`

## 0.17.0

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
* Fix bug where `SelectorDepth` would error when encountering percentages
  inside of `@keyframe` declarations.

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
