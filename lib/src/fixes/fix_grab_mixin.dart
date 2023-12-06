import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../helpers/ast.dart';
import '../helpers/mixin_updaters.dart';
import '../helpers/utils.dart';

class FixGrabMixin extends DartFix {
  FixGrabMixin();

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addWithClause((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) {
        return;
      }

      final widgetDecl = analysisError.data! as ClassDeclaration;

      final fixes = widgetDecl.classType.isStateless
          ? {
              'Grabful': 'Grab',
              'StatefulGrabMixin': 'StatelessGrabMixin',
            }
          : {
              'Grab': 'Grabful',
              'StatelessGrabMixin': 'StatefulGrabMixin',
            };

      final wrongNames = fixes.keys.intersects(node.mixinNames);

      for (final name in wrongNames) {
        reporter
            .createChangeBuilder(
              message: 'Convert to ${fixes[name]}',
              priority: 90,
            )
            .updateMixin(
              widgetDeclaration: widgetDecl,
              withClause: node,
              mixinName: fixes[name]!,
            );
      }
    });
  }
}
