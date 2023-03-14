import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../fixes/add_grab_mixin.dart';
import '../helpers/ast.dart';

class MissingGrabMixin extends DartLintRule {
  const MissingGrabMixin() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_grab_mixin',
    problemMessage: 'Grab mixin is necessary to use Grab extension methods.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!node.isGrabCall || !node.isInBuild || node.isInCallback) {
        return;
      }

      final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
      final classType = classDeclaration?.classType;
      if (classType == null || classType.isUnknown || classType.isStateful) {
        return;
      }

      final widgetDeclaration = classType.isStateless
          ? classDeclaration
          : classDeclaration?.findStatelessWidget();
      final mixinNames = widgetDeclaration?.mixinNames ?? [];

      if (classType.isStateless && !mixinNames.contains('StatelessGrabMixin') ||
          classType.isState && !mixinNames.contains('StatefulGrabMixin')) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  @override
  List<Fix> getFixes() => [AddGrabMixin()];
}
