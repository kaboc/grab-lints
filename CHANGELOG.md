## 0.1.0

- Require Dart SDK 2.19.
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
