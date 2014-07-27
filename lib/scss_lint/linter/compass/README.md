# Compass Linters

These linters are designed specifically for codebases which utilize the
[Compass](http://compass-style.org/) framework. They are disabled by default,
but can be enabled by adding the following to your configuration:

```yaml
linters:
  Compass::*:
    enabled: true
```

You can of course enable/disable specific linters by referring to them by full
name, e.g. `Compass::PropertyWithMixin`.

## Compass::PropertyWithMixin

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

In the event you don't want to be warned about certain properties, you can opt
to ignore them by listing them in the `ignore` option.

Configuration Option  | Description
----------------------|--------------------------------------------------------
`ignore`              | Array of properties that should not be switched for Compass mixins.
