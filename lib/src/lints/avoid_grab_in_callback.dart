import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../helpers/ast.dart';

class AvoidGrabInCallback extends DartLintRule {
  const AvoidGrabInCallback() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_grab_in_callback',
    problemMessage:
        'Extension method of Grab should not be used in a callback function.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.isGrabCall && node.isInBuild && node.isInCallback) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
