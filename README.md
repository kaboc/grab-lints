Lint rules to help avoid common misuse of [Grab].

## Available lint rules

A quick fix is available in some rules.

### With fix

- **missing_grab_mixin**
    - Warned when a Grab mixin is missing where it is necessary.
- **unnecessary_grab_mixin**
    - Warned when a Grab mixin is used where it is unnecessary.
- **wrong_grab_mixin**
    - Warned when a wrong Grab mixin is used.

### Without fix

- **avoid_grab_in_callback**
    - Warned when an extension method of Grab is used in a callback function.
        - Such usage is possible as long as the correct BuildContext is used,
          but it is not recommended as it easily leads to misuse or confusion.
- **avoid_grab_outside_build**
    - Warned when an extension method of Grab is used outside the build method
      of a widget.
        - Ditto.

## Setup

This plugin uses [custom_lint](https://pub.dev/packages/custom_lint).

### pubspec.yaml

Put the latest version in place of `x.x.x` below.

```yaml
dev_dependencies:
  custom_lint: ^x.x.x
  grab_lints: ^x.x.x
```

### analysis_options.yaml

```yaml
analyzer:
  plugins:
    - custom_lint
```

<!-- Links -->

[Grab]: https://pub.dev/packages/grab
