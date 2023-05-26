import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../fixes/fix_grab_mixin.dart';
import '../helpers/ast.dart';

class WrongGrabMixin extends DartLintRule {
  const WrongGrabMixin() : super(code: _code);

  static const _code = LintCode(
    name: 'wrong_grab_mixin',
    problemMessage: 'This Grab mixin does not match the widget type.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addWithClause((node) {
      final widgetDeclaration = node.parent;
      if (widgetDeclaration is! ClassDeclaration) {
        return;
      }

      final classType = widgetDeclaration.classType;

      if (classType.isStateless && widgetDeclaration.hasStatefulMixin ||
          classType.isStateful && widgetDeclaration.hasStatelessMixin) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  @override
  List<Fix> getFixes() => [FixGrabMixin()];
}
