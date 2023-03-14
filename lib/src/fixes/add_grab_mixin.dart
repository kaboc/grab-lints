import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../helpers/ast.dart';
import '../helpers/mixin_updaters.dart';
import '../helpers/utils.dart';

class AddGrabMixin extends DartFix {
  AddGrabMixin();

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) {
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
      if (widgetDeclaration == null) {
        return;
      }

      final withClauses = widgetDeclaration.findWithClauses();
      final withClause = withClauses.firstWhereOrNull(
        (v) => v.sourceRange.intersects(widgetDeclaration.sourceRange),
      );

      final newMixinNames = classType.isStateless
          ? ['Grab', 'StatelessGrabMixin']
          : ['Grabful', 'StatefulGrabMixin'];

      for (final name in newMixinNames) {
        reporter
            .createChangeBuilder(
              message: 'Add $name mixin',
              priority: 90,
            )
            .updateMixin(
              widgetDeclaration: widgetDeclaration,
              withClause: withClause,
              mixinName: name,
            );
      }
    });
  }
}
