Lint rules to help avoid common misuse of [Grab].

## Available lint rules

A quick fix is available in some rules.

### Errors

<table>
<tr>
<th>Rule</th><th>Fix</th><th>Details</th>
</tr>
<tr>
<th style="text-align: left">missing_grab_mixin</th>
<td style="text-align: center">✅</td>
<td>
A necessary Grab mixin is missing in the <code>with</code> clause.
</td>
</tr>
<tr>
<th style="text-align: left">wrong_grab_mixin</th>
<td style="text-align: center">✅</td>
<td>
The widget class has a mismatching Grab mixin in the <code>with</code> clause.
</td>
</tr>
</table>

### Warnings

<table>
<tr>
<th>Rule</th><th>Fix</th><th>Details</th>
</tr>
<tr>
<th style="text-align: left">unnecessary_grab_mixin</th>
<td style="text-align: center">✅</td>
<td>
An unnecessary Grab mixin is in the <code>with</code> clause.
</td>
</tr>
<tr>
<th style="text-align: left">maybe_wrong_build_context_for_grab</th>
<td style="text-align: center">(✅)</td>
<td>
The <code>BuildContext</code> passed to the grab method has either of the following issues:
<ul>
<li>Not the one from the <code>build</code> method</li>
<li>Passed via a variable</li>
</ul>
The <code>BuildContext</code> parameter itself of the <code>build</code> method should be
directly used to avoid misuse or confusion.<br>
<br>
Quick fix is available only when an automatic fix is possible.
</td>
</tr>
<tr>
<th style="text-align: left">avoid_grab_outside_build</th>
<td style="text-align: center"></td>
<td>
A grab method has been used outside the <code>build</code> method of a widget.<br>
<br>
It is discouraged although using the method outside the <code>build</code> method is
possible as long as the correct <code>BuildContext</code> is used. Such usage easily
leads to misuse or confusion. 
</td>
</tr>
</table>

## Setup

This plugin uses [custom_lint](https://pub.dev/packages/custom_lint).

### pubspec.yaml

Put the latest version in place of `x.x.x` below.

```yaml
dev_dependencies:
  custom_lint:
  grab_lints:
```

### analysis_options.yaml

```yaml
analyzer:
  plugins:
    - custom_lint
```

<!-- Links -->

[Grab]: https://pub.dev/packages/grab
