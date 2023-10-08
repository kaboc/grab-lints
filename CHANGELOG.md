## 0.3.2

- First release on pub.dev.

## 0.3.1

- Fix `unnecessary_grab_mixin` not working for StatefulWidget.
- Improve tests.

## 0.3.0

- Update dependencies.
- Raise minimum Dart SDK version to 3.0.0.

## 0.2.0

- Support grab 0.4.0.
    - Support for older grab versions will be removed in the future.
- Update dependencies.
- Small refactorings.

## 0.1.1

- Fix `avoid_grab_in_callback` to not warn about use of grab outside a callback.
- Improve example and README.

## 0.1.0

- Raise minimum Dart SDK version to 2.19.0.
- Create almost all from scratch again due to breaking changes in custom_lint.
    - Improved rules:
        - avoid_grab_in_callback (previously grab_used_too_deep)
        - avoid_grab_outside_build (previously grab_used_in_function)
        - missing_grab_mixin (previously no_grab_mixin)
    - Newly added rules:
        - unnecessary_grab_mixin
        - wrong_grab_mixin

## 0.0.1

- Initial version.
