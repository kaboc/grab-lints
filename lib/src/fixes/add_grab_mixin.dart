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

      final widgetDecl = analysisError.data! as ClassDeclaration;

      final withClauses = widgetDecl.findWithClauses();
      final withClause = withClauses.firstWhereOrNull(
        (v) => v.sourceRange.intersects(widgetDecl.sourceRange),
      );

      final newMixinNames = widgetDecl.classType.isStateless
          ? ['Grab', 'StatelessGrabMixin']
          : ['Grabful', 'StatefulGrabMixin'];

      for (final name in newMixinNames) {
        reporter
            .createChangeBuilder(
              message: 'Add $name mixin',
              priority: 90,
            )
            .updateMixin(
              widgetDeclaration: widgetDecl,
              withClause: withClause,
              mixinName: name,
            );
      }
    });
  }
}
