import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../fixes/remove_grab_mixin.dart';
import '../helpers/ast.dart';

class UnnecessaryGrabMixin extends DartLintRule {
  const UnnecessaryGrabMixin() : super(code: _code);

  static const _code = LintCode(
    name: 'unnecessary_grab_mixin',
    problemMessage:
        'Grab mixin is unnecessary where Grab extension methods are not used.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addWithClause((node) {
      final widgetDecl = node.parent;
      if (widgetDecl is! ClassDeclaration) {
        return;
      }

      final classType = widgetDecl.classType;
      if (!widgetDecl.hasGrabMixin ||
          !classType.isStateless && !classType.isStateful) {
        return;
      }

      final hasGrabCall = classType.isStateless
          ? widgetDecl.hasGrabCall
          : widgetDecl.findStateClass().hasGrabCall;

      if (hasGrabCall == false) {
        reporter.reportErrorForNode(code, node, null, null, widgetDecl);
      }
    });
  }

  @override
  List<Fix> getFixes() => [RemoveGrabMixin()];
}
