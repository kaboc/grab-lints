import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../helpers/ast.dart';

class AvoidGrabOutsideBuild extends DartLintRule {
  const AvoidGrabOutsideBuild() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_grab_outside_build',
    problemMessage:
        'Extension method of Grab should only be used in the build method.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.isGrabCall && !node.isInBuild) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
