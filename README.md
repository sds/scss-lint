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

    scss-lint app/assets/stylesheets/

You can also specify a list of files explicitly:

    scss-lint app/assets/stylesheets/**/*.css.scss

`scss-lint` will output any problems with your SCSS, including the offending
filename and line number (if available).

Command Line Flag         | Description
--------------------------|----------------------------------------------------
`-c`/`--config`           | Specify a configuration file to use
`-e`/`--exclude`          | Exclude one or more files from being linted
`-f`/`--format`           | Specify the output format (`Default` or `XML`)
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
additional exclusions specified via the `--exclude` flag are also combined.

You can also configure `scss-lint` by specifying a file via the `--config`
flag, but note that this will override any configuration files that `scss-lint`
would normally find on its own (this can be useful for testing a particular
configuration setting, however). Configurations loaded this way will still be
merged with the default configuration specified by `config/default.yml`.

## What Gets Linted

`scss-lint` is an opinionated tool that helps you enforce a consistent style in
your SCSS. As an opinionated tool, we've had to make calls about what we think
are the "best" style conventions, even when there are often reasonable arguments
for more than one possible style. While all of our choices have a rational
basis, we think that the opinions themselves are less important than the fact
that `scss-lint` provides us with an automated and low-cost means of enforcing
consistency.

Any lint can be disabled by using the `--exclude_linter` flag.

* Prefer `border: 0` over `border: none`.

* IDs, classes, types, placeholders, and pseudo-selectors should be all lowercase.

    ```scss
    // Incorrect - capitalized class name
    .Button {
      ...
    }

    // Correct
    .button {
      ...
    }
    ```

* Prefer hexadecimal colors over their human-friendly form.

    ```scss
    // Incorrect
    color: green;

    // Correct
    color: #0f0;
    ```

    Defining colors directly in properties is usually a smell. When you color
    your body text in a number of places, if you ever want to change the color
    of the text you'll have to update the explicitly defined color in a number
    of places, and finding all those places can be difficult if you use the
    same color for other elements (i.e. a simple find/replace may not always
    work).

    A better approach is to use global variables like `$color-text-body` and
    refer to this variable everywhere you want to use it. This makes it easy
    to update the color, as you only need change it in one place. It is also
    more intention-revealing, as seeing the name `$color-text-body` is more
    descriptive than `#333` or `black`. Using color keywords can obfuscate
    this, as they look like variables.

* Prefer `//` comments over `/* ... */`.

    ```scss
    // Incorrect
    /* This is a comment that gets rendered */

    // Correct
    // This comment never gets rendered
    ```

    `//` comments should be preferred as they don't get rendered in the final
    generated CSS, whereas `/* ... */` comments do.

    Furthermore, comments should be concise, and using `/* ... */`
    encourages multi-line comments can tend to not be concise.

* Write `@extend` statements first in rule sets, followed by property
  declarations and then other nested rule sets.

    ```scss
    // Incorrect
    .fatal-error {
      color: #f00;
      @extend %error;

      p {
        ...
      }
    }

    // Correct
    .fatal-error {
      @extend %error;
      color: #f00;

      p {
        ...
      }
    }
    ```

* Functions, mixins, and variables should be declared with all lowercase letters.

    ```scss
    // Incorrect - uppercase letters
    $myVar: 10px;

    @mixin myMixin() {
      ...
    }

    // Correct
    $my-var: 10px;

    @mixin my-mixin() {
      ...
    }
    ```

* Prefer hyphens over underscores in function, mixin, and variable names.

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

    The Sass parser automatically treats underscores and hyphens the same, so
    even if you're using a library that declares a function with an underscore,
    you can refer to it using the hyphenated form instead.

* Prefer the shortest possible form for hex colors.

    ```scss
    // Incorrect
    color: #ff22ee;

    // Correct
    color: #f2e;
    ```

* Don't combine additional selectors with an ID selector.

    ```scss
    // Incorrect - `.button` class is unnecessary
    #submit-button.button {
      ...
    }

    // Correct
    #submit-button {
      ...
    }
    ```

    While the CSS specification allows for multiple elements with the same
    ID to appear in a single document, in practice this is usually a smell.
    When reasoning about IDs (including selector specificity), it should
    suffice to style an element with a particular ID based solely on the ID.

    Even better would be to never use IDs in the first place.

* Use two **spaces** per indentation level. No hard tabs.

    ```scss
    // Incorrect - four spaces
    p {
        color: #f00;
    }

    // Correct
    p {
      color: #f00;
    }
    ```

* Don't write leading zeros for numeric values with a decimal point.

    ```scss
    // Incorrect
    margin: 0.5em;

    // Correct
    margin: .5em;
    ```

* Always use placeholder selectors in `@extend`.

    ```scss
    // Incorrect
    .fatal {
      @extend .error;
    }

    // Correct
    .fatal {
      @extend %error;
    }
    ```

    Using a class selector with the `@extend` statement statement usually
    results in more generated CSS than when using a placeholder selector.
    Furthermore, Sass specifically introduced placeholder selectors in
    order to be used with `@extend`.

    See [Mastering Sass extends and placeholders](http://8gramgorilla.com/mastering-sass-extends-and-placeholders/).

* Don't write selectors with a depth of applicability greater than 3

    ```scss
    // Incorrect - resulting CSS will have a selctor with depth of 4
    .one .two .three > .four {
      ...
    }

    .one .two {
      .three > .four {
        ...
      }
    }

    // Correct
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
    lead to CSS tightly-coupled to your HTML structure, making it brittle to
    change.

    Deep selectors also come with a performance penalty, which can affect
    rendering times, especially on mobile devices. While the default limit is
    3, ideally it is better to use less than 3 whenever possible.

* Prefer the shortest shorthand form possible for properties that support it.

    ```scss
    // Incorrect - all 4 sides specified with same value
    margin: 1px 1px 1px 1px;

    // Correct - equivalent to specifying 1px for all sides
    margin: 1px;
    ```

* Split selectors onto separate lines after each comma.

    ```scss
    // Incorrect
    .error p, p.explanation {
      ...
    }

    // Correct - each selector sequence is on its own line
    .error p,
    p.explanation {
      ...
    }
    ```

* Sort properties in alphabetical order.

    It's brain-dead simple (highlight lines and execute `:sort` in `vim`), and it can
    [benefit gzip compression](http://www.barryvan.com.au/2009/08/css-minifier-and-alphabetiser/).

    Sorting alphabetically also makes properties easier to find. Ordering based
    on the semantics of the properties can be more problematic depending on
    which other properties are present.

    Note that there are legitimate cases where one needs to explicitly break
    alphabetical sort order in order to use vendor-specific properties. In
    this case, this is usually avoided by using mixins from a framework like
    [Compass](http://compass-style.org/) or [Bourbon](http://bourbon.io/) so
    vendor-specific properties rarely need to be manually written.

* Commas in lists should be followed by a space.

    ```scss
    // Incorrect
    @include box-shadow(0 2px 2px rgba(0,0,0,.2));
    color: rgba(0,0,0,.1);

    // Correct
    @include box-shadow(0 2px 2px rgba(0, 0, 0, .2));
    color: rgba(0, 0, 0, .1);
    ```

* Parentheses should not (or should) be padded with spaces.

    ```scss
    // Incorrect
    @include box-shadow( 0 2px 2px rgba( 0, 0, 0, .2 ) );
    color: rgba( 0, 0, 0, .1 );

    // Correct
    @include box-shadow(0 2px 2px rgba(0, 0, 0, .2));
    color: rgba(0, 0, 0, .1);
    ```

* Properties should be formatted with no space between the name and the colon,
  and a single space separating the colon from the property's value.

    ```scss
    // Incorrect - space before colon
    margin : 0;

    // Incorrect - more than one space after colon
    margin:  0;

    // Incorrect - no space after colon
    margin:0;

    // Correct
    margin: 0;
    ```

* Opening braces should be preceded by a single space.

    ```scss
    // Incorrect - no space before brace
    p{
    }

    // Incorrect - more than one space before brace
    p  {
    }

    // Correct - exactly one space before brace
    p {
    }
    ```

* Property values should always end with a semicolon.

    ```scss
    // Incorrect - no semicolon
    p {
      color: #fff
    }

    // Incorrect - space between value and semicolon
    p {
      color: #fff ;
    }

    // Correct
    p {
      color: #fff;
    }
    ```

* Omit units on zero values.

    ```scss
    // Incorrect - unnecessary units can be omitted
    margin: 0px;

    // Correct
    margin: 0;
    ```


### Other Lints

* Reports `@debug` statements (which you probably left behind accidentally)
* Reports when you define the same property twice in a single rule set
* Reports when you have an empty rule set

## Contributing

We love getting feedback with or without pull requests. If you do add a new
feature, please add tests so that we can avoid breaking it in the future.

Speaking of tests, we use `rspec`, which can be run like so:

    bundle exec rspec

## Changelog

If you're interested in seeing the changes and bug fixes between each version
of `scss-lint`, read the [SCSS-Lint Changelog](CHANGELOG.md).

## See Also

If you'd like to integrate `scss-lint` with Git, check out our Git hook gem,
[overcommit](https://github.com/causes/overcommit).

## License

This project is released under the MIT license.
