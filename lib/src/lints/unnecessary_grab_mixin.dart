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
      final widgetDeclaration = node.parent;
      if (widgetDeclaration is! ClassDeclaration) {
        return;
      }

      if (!widgetDeclaration.hasStatelessMixin &&
          !widgetDeclaration.hasStatefulMixin) {
        return;
      }

      final hasGrabCall = widgetDeclaration.classType.isStateless
          ? widgetDeclaration.hasGrabCall
          : widgetDeclaration.findStateClass()?.hasGrabCall;

      if (hasGrabCall == false) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  @override
  List<Fix> getFixes() => [RemoveGrabMixin()];
}
