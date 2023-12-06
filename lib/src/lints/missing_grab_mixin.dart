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
      if (!node.isGrabCall || !node.isInBuild) {
        return;
      }

      final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
      final classType = classDecl.classType;

      final widgetDecl =
          classType.isStateless ? classDecl : classDecl.findStatelessWidget();

      if (classType.isStateless && !widgetDecl.hasStatelessGrabMixin ||
          classType.isState && !widgetDecl.hasStatefulGrabMixin) {
        reporter.reportErrorForNode(code, node, null, null, widgetDecl);
      }
    });
  }

  @override
  List<Fix> getFixes() => [AddGrabMixin()];
}
