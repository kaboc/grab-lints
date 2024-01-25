Lint rules to warn you about common misuse of [Grab] and fix it quickly.

**This package is incompatible with grab 1.0.0-dev.1 and above.\
grab_lints is no longer necessary to avoid misuse related to the limitations
that existed in older versions of grab.**

## Setup

This plugin uses [custom_lint](https://pub.dev/packages/custom_lint).

### pubspec.yaml

Put the latest version in place of `x.x.x` below.

```yaml
dev_dependencies:
  custom_lint:
  grab_lints: x.x.x
```

### analysis_options.yaml

```yaml
analyzer:
  plugins:
    - custom_lint
```

## Available lints

### Errors

| Rule               | Fix | Details                                                                        |
|--------------------|:---:|--------------------------------------------------------------------------------|
| missing_grab_mixin |  ✅  | A necessary Grab mixin is missing in the <code>with</code> clause.             |
| wrong_grab_mixin   |  ✅  | The widget class has a mismatching Grab mixin in the <code>with</code> clause. |

### Warnings

| Rule                               | Fix | Details                                                                                                                                                                                                                                                                                                                                                                                              |
|------------------------------------|:---:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| unnecessary_grab_mixin             |  ✅  | An unnecessary Grab mixin is in the <code>with</code> clause.                                                                                                                                                                                                                                                                                                                                        |
| maybe_wrong_build_context_for_grab | (✅) | The <code>BuildContext</code> passed to the grab method has either of the following issues:<ul><li>Not the one from the <code>build</code> method</li><li>Passed via a variable</li></ul>The <code>BuildContext</code> parameter itself of the <code>build</code> method should be directly used to avoid misuse or confusion.<br><br>Quick fix is available only when an automatic fix is possible. |
| avoid_grab_outside_build           |     | A grab method has been used outside the <code>build</code> method of a widget.<br><br>It is discouraged although using the method outside the <code>build</code> method is possible as long as the correct <code>BuildContext</code> is used. Such usage easily leads to misuse or confusion.                                                                                                        |

<!-- Links -->

[Grab]: https://pub.dev/packages/grab
