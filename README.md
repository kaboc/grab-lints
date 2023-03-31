A Dart analyzer plugin to add lint rules for [Grab](https://pub.dev/packages/grab).

Experimental for now.

## Available lint rules

### With fix

- missing_grab_mixin
- unnecessary_grab_mixin
- wrong_grab_mixin

### Without fix

- avoid_grab_in_callback
- avoid_grab_outside_build

## Setup

This plugin uses [custom_lint](https://pub.dev/packages/custom_lint).

### pubspec.yaml

```yaml
dev_dependencies:
  custom_lint: ^x.x.x
  grab_lints:
    git:
      url: https://github.com/kaboc/grab-lints
```

### analysis_options.yaml

```yaml
analyzer:
  plugins:
    - custom_lint
```
