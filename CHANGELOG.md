0.5.5 (unreleased)

* Only lint files with `css` or `scss` extensions
* Fix recursive directory scanning
* Fix specs on Sass gem >= 3.2.6 (shorthand_linter was failing)
* Add changelog (the thing you're reading)
* Add command-line flags (e.g. --version, --help)

0.5.2

* Version bump to remove erroneously added untracked files from gem

0.5

* Improve clarity of shorthand linter through naming
* Teach scss-lint `property: 10px 10px` can be shorter
* Clarify ShorthandLinter spec structure

0.4

* Add linter for unnecessary types in selectors

0.3

* Teach scss-lint that selectors each get their own line

0.2

* Teach scss-lint about nested property syntax
* Teach scss-lint to detect too-long shorthand values
* Make scss-lint detect space before semicolon
* Add linter for order of declarations

0.1

* Initial public release
