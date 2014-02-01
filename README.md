# SCSS-Lint

[![Gem Version](https://badge.fury.io/rb/scss-lint.png)](http://badge.fury.io/rb/scss-lint)
[![Build Status](https://travis-ci.org/causes/scss-lint.png)](https://travis-ci.org/causes/scss-lint)
[![Code Climate](https://codeclimate.com/github/causes/scss-lint.png)](https://codeclimate.com/github/causes/scss-lint)

`scss-lint` is a tool to help keep your [SCSS](http://sass-lang.com) files
clean and readable. You can run it manually from the command-line, or integrate
it into your [SCM hooks](https://github.com/causes/overcommit). It uses rules
established by the team at [Causes.com](https://causes.com).

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
`-f`/`--format`           | Output format (`Default`, `XML`, `Files`)
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

## What Gets Linted

`scss-lint` is a customizable tool with opinionated defaults that helps you
enforce a consistent style in your SCSS. As an opinionated tool, we've had to
make calls about what we think are the "best" style conventions, even when
there are often reasonable arguments for more than one possible style. While
all of our choices have a rational basis, we think that the opinions themselves
are less important than the fact that `scss-lint` provides us with an automated
and low-cost means of enforcing consistency.

Should you want to customize the checks run against your code, you can do so by
editing your [`.scss-lint.yml` configuration file](#configuration) to match
your preferred style.

## Linters

Below is the list of linters supported by `scss-lint`, ordered alphabetically.

### BorderZero

Prefer `border: 0` over `border: none`.

### CapitalizationInSelector

IDs, classes, types, placeholders, and pseudo-selectors should be all lowercase.

**Bad: capitalized class name**
```scss
.Button {
  ...
}
```

**Good: all lowercase**
```scss
.button {
  ...
}
```

### ColorKeyword

Prefer hexadecimal color codes over color keywords.

**Bad: color keyword**
```scss
color: green;
```

**Good: hexadecimal color**
```scss
color: #0f0;
```

Defining colors directly in properties is usually a smell. When you color your
body text in a number of places, if you ever want to change the color of the
text you'll have to update the explicitly defined color in a number of places,
and finding all those places can be difficult if you use the same color for
other elements (i.e. a simple find/replace may not always work).

A better approach is to use global variables like `$color-text-body` and refer
to this variable everywhere you want to use it. This makes it easy to update
the color, as you only need change it in one place. It is also more
intention-revealing, as seeing the name `$color-text-body` is more descriptive
than `#333` or `black`. Using color keywords can obfuscate this, as they look
like variables.

### Comment

Prefer `//` comments over `/* ... */`.

**Bad**
```scss
/* This is a comment that gets rendered */
```

**Good**
```scss
// This comment never gets rendered
```

`//` comments should be preferred as they don't get rendered in the final
generated CSS, whereas `/* ... */` comments do.

Furthermore, comments should be concise, and using `/* ... */`
encourages multi-line comments which tend to not be concise.

### DebugStatement

Reports `@debug` statements (which you probably left behind accidentally).

### DuplicateProperty

Reports when you define the same property twice in a single rule set.

**Bad**
```scss
h1 {
  margin: 10px;
  text-transform: uppercase;
  margin: 0; // Second declaration
}
```

Having duplicate properties is usually just an error. However, they can be used
as a technique for dealing with varying levels of browser support for CSS
properties. In the example below, some browsers might not support the `rgba`
function, so the intention is to fall back to the color `#fff`.

```scss
.box {
  background: #fff;
  background: rgba(255, 255, 255, .5);
}
```

In this situation, using duplicate properties is acceptable.

### EmptyLineBetweenBlocks

Separate rule, function, and mixin declarations with empty lines.

**Bad: no lines separating blocks**
```scss
p {
  margin: 0;
  em {
    ...
  }
}
a {
  ...
}
```

**Good: lines separating blocks**
```scss
p {
  margin: 0;

  em {
    ...
  }
}

a {
  ...
}
```

### EmptyRule

Reports when you have an empty rule set.

```scss
.cat {
}
```

### DeclarationOrder

Write `@extend` statements first in rule sets, followed by property
declarations and then other nested rule sets.

**Bad: `@extend` not first**
```scss
.fatal-error {
  color: #f00;
  @extend %error;

  p {
    ...
  }
}
```

**Good: `@extend` appears first**
```scss
.fatal-error {
  @extend %error;
  color: #f00;

  p {
    ...
  }
}
```

The `@extend` statement functionally acts like an inheritance mechanism, which
means the properties defined by the placeholder being extended are rendered
before the rest of the properties in the rule set.

Thus, declaring the `@extend` at the top of the rule set reminds the developer
of this behavior.

### DeclaredName

Functions, mixins, and variables should be declared with all lowercase letters
and hyphens instead of underscores.

**Bad: uppercase characters**
```scss
$myVar: 10px;

@mixin myMixin() {
  ...
}
```

**Good: all lowercase with hyphens**
```scss
$my-var: 10px;

@mixin my-mixin() {
  ...
}
```

Using lowercase with hyphens in CSS has become the _de facto_ standard, and
brings with it a couple of benefits. First of all, hyphens are easier to type
than underscores, due to the additional `Shift` key required for underscores on
most popular keyboard layouts. Furthermore, using hyphens in class names in
particular allows you to take advantage of the
[`|=` attribute selector](http://www.w3.org/TR/CSS21/selector.html#attribute-selectors),
which allows you to write a selector like `[class|="inactive"]` to match both
`inactive-user` and `inactive-button` classes.

The Sass parser automatically treats underscores and hyphens the same, so even
if you're using a library that declares a function with an underscore, you can
refer to it using the hyphenated form instead.

### HexFormat

Prefer the shortest possible form for hexadecimal color codes.

**Bad: can be shortened**
```scss
color: #ff22ee;
```

**Good: color code in shortest possible form**
```scss
color: #f2e;
```

### IdWithExtraneousSelector

Don't combine additional selectors with an ID selector.

**Bad: `.button` class is unnecessary**
```scss
#submit-button.button {
  ...
}
```

**Good: standalone ID selector**
```scss
#submit-button {
  ...
}
```

While the CSS specification allows for multiple elements with the same ID to
appear in a single document, in practice this is a smell.  When
reasoning about IDs (including selector specificity), it should suffice to
style an element with a particular ID based solely on the ID.

Another possible pattern is to modify the style of an element with a given
ID based on the class it has. This is also a smell, as the purpose of a CSS
class is to be reusable and composable, and thus redefining it for a specific
ID is a violation of those principles.

Even better would be to
[never use IDs](http://screwlewse.com/2010/07/dont-use-id-selectors-in-css/)
in the first place.

### Indentation

Use two spaces per indentation level. No hard tabs.

**Bad: four spaces**
```scss
p {
    color: #f00;
}
```

**Good: two spaces**
```scss
p {
  color: #f00;
}
```

This is adjustable via the `width` configuration parameter.

### LeadingZero

Don't write leading zeros for numeric values with a decimal point.

**Bad: unnecessary leading zero**
```scss
margin: 0.5em;
```

**Good: no leading zero**
```scss
margin: .5em;
```

### PlaceholderInExtend

Always use placeholder selectors in `@extend`.

**Bad: extending a class**
```scss
.fatal {
  @extend .error;
}
```

**Good: extending a placeholder**
```scss
.fatal {
  @extend %error;
}
```

Using a class selector with the `@extend` statement statement usually results
in more generated CSS than when using a placeholder selector.  Furthermore,
Sass specifically introduced placeholder selectors in order to be used with
`@extend`.

See [Mastering Sass extends and placeholders](http://8gramgorilla.com/mastering-sass-extends-and-placeholders/).

### PropertySpelling

Reports when you use an unknown CSS property (ignoring vendor-prefixed
properties).

```scss
diplay: none; // "display" is spelled incorrectly
```

Since the list of available CSS properties is constantly changing, it's
possible that you might get some false positives here, especially if you're
using experimental CSS features. If that's the case, you can add additional
properties to the whitelist by adding the following to your `.scss-lint.yml`
configuration:

```yaml
linters:
  PropertySpelling:
    extra_properties:
      - some-experimental-property
      - another-experimental-property
```

If you're sure the property in question is valid,
[submit a request](https://github.com/causes/scss-lint/issues/new)
to add it to the
[default whitelist](data/properties.txt).

### PropertyWithMixin (Compass)

Prefer Compass mixins for properties when they exist.

**Bad: property possibly not fully supported in all browsers**
```scss
border-radius: 5px;
```

**Good: using Compass mixin ensures all vendor-prefixed extensions are rendered**
```scss
@include border-radius(5px);
```

These mixins include the necessary vendor-prefixed properties to increase the
number of browsers the CSS supports.

### SelectorDepth

Don't write selectors with a depth of applicability greater than 3.

**Bad: selectors with depths of 4**
```scss
.one .two .three > .four {
  ...
}

.one .two {
  .three > .four {
    ...
  }
}
```

**Good**
```scss
.one .two .three {
  ...
}

.one .two {
  .three {
    ...
  }
}
```

Selectors with a large [depth of applicability](http://smacss.com/book/applicability)
lead to CSS tightly-coupled to your HTML structure, making it brittle to change.

Deep selectors also come with a performance penalty, which can affect rendering
times, especially on mobile devices. While the default limit is 3, ideally it
is better to use less than 3 whenever possible.

### Shorthand

Prefer the shortest shorthand form possible for properties that support it.

**Bad: all 4 sides specified with same value**
```scss
margin: 1px 1px 1px 1px;
```

**Good: equivalent to specifying 1px for all sides**
```scss
margin: 1px;
```

### SingleLinePerSelector

Split selectors onto separate lines after each comma.

**Bad: comma-separated selectors not on their own lines**
```scss
.error p, p.explanation {
  ...
}
```

**Good: each selector sequence is on its own line**
```scss
.error p,
p.explanation {
  ...
}
```

### SortedProperties

Sort properties in alphabetical order.

It's brain-dead simple (highlight lines and execute `:sort` in `vim`), and it can
[benefit gzip compression](http://www.barryvan.com.au/2009/08/css-minifier-and-alphabetiser/).

Sorting alphabetically also makes properties easier to find. Ordering based on
the semantics of the properties can be more problematic depending on which
other properties are present.

If you need to write vendor-prefixed properties, the linter will allow you to
order the vendor-prefixed properties before the standard CSS property they
apply to. For example:

```scss
border: 0;
-moz-border-radius: 3px;
-o-border-radius: 3px;
-webkit-border-radius: 3px;
border-radius: 3px;
color: #ccc;
margin: 5px;
```

In this case, this is usually avoided by using mixins from a framework like
[Compass](http://compass-style.org/) or [Bourbon](http://bourbon.io/) so
vendor-specific properties rarely need to be explicitly written by hand.

### SpaceAfterComma

Commas in lists should be followed by a space.

**Bad: no space after commas**
```scss
@include box-shadow(0 2px 2px rgba(0,0,0,.2));
color: rgba(0,0,0,.1);
```

**Good: commas followed by a space**
```scss
@include box-shadow(0 2px 2px rgba(0, 0, 0, .2));
color: rgba(0, 0, 0, .1);
```

### SpaceAfterPropertyColon

Properties should be formatted with a single space separating the colon from
the property's value.

**Bad: no space after colon**
```scss
margin:0;
```

**Bad: more than one space after colon**
```scss
margin:  0;
```

**Good**
```scss
margin: 0;
```

### SpaceAfterPropertyName

Properties should be formatted with no space between the name and the colon.

**Bad: space before colon**
```scss
margin : 0;
```

**Good**
```scss
margin: 0;
```

### SpaceBeforeBrace

Opening braces should be preceded by a single space.

**Bad: no space before brace**
```scss
p{
  ...
}
```

**Bad: more than one space before brace**
```scss
p  {
  ...
}
```

**Good**
```scss
p {
  ...
}
```

### SpaceBetweenParens

Parentheses should not be padded with spaces.

**Bad**
```scss
@include box-shadow( 0 2px 2px rgba( 0, 0, 0, .2 ) );
color: rgba( 0, 0, 0, .1 );
```

**Good**
```scss
@include box-shadow(0 2px 2px rgba(0, 0, 0, .2));
color: rgba(0, 0, 0, .1);
```

### StringQuotes

String literals should be written with single quotes unless using double quotes
would save on escape characters.

**Bad: double quotes**
```scss
content: "hello";
```

**Good: single quotes**
```scss
content: 'hello';
```

**Good: double quotes prevent the need for escaping single quotes**
```scss
content: "'hello'";
```

Single quotes are easier to type by virtue of not requiring the `Shift` key on
most popular keyboard layouts.

### TrailingSemicolonAfterPropertyValue

Property values should always end with a semicolon.

**Bad: no semicolon**
```scss
p {
  color: #fff
}
```

**Bad: space between value and semicolon**
```scss
p {
  color: #fff ;
}
```

**Good**
```scss
p {
  color: #fff;
}
```

CSS allows you to omit the semicolon if the property is the last property in
the rule set. However, this introduces inconsistency and requires anyone adding
a property after that property to remember to append a semicolon.

### UrlQuotes

URLs should always be enclosed within quotes.

**Bad: no enclosing quotes**
```scss
background: url(example.png);
```

**Good**
```scss
background: url('example.png');
```

Using quoted URLs is consistent with using other Sass asset helpers, which also
expect quoted strings. It also works better with most syntax highlighters, and
makes it easier to escape characters, as the escape rules for strings apply,
rather than the different set of rules for literal URLs.

See the [URL type](http://dev.w3.org/csswg/css-values/#url-value) documentation
for more information.

### ZeroUnit

Omit units on zero values.

**Bad: unnecessary units**
```scss
margin: 0px;
```

**Good**
```
margin: 0;
```

Zero is zero regardless of units.

### UsageName

Prefer hyphens over underscores in function, mixin, and variable names.

```scss
// Incorrect - words separated by underscores
$my_var: 10px;

@mixin my_mixin() {
  ...
}

// Correct - words separated by hyphens
$my-var: 10px;

@mixin my-mixin() {
  ...
}
```

Hyphens are easier to type than underscores.

The Sass parser automatically treats underscores and hyphens the same, so even
if you're using a library that declares a function with an underscore, you can
refer to it using the hyphenated form instead.

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

## See Also

If you'd like to integrate `scss-lint` with Git, check out our Git hook gem,
[overcommit](https://github.com/causes/overcommit).

## License

This project is released under the MIT license.
