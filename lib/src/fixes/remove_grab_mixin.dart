import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../helpers/ast.dart';
import '../helpers/mixin_updaters.dart';
import '../helpers/utils.dart';

class RemoveGrabMixin extends DartFix {
  RemoveGrabMixin();

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

      final widgetDeclaration = node.parent as ClassDeclaration?;
      final classType = widgetDeclaration?.classType;
      if (classType == null || classType.isUnknown || classType.isState) {
        return;
      }

      final targetNames = node.mixinNames.intersects(
        classType.isStateless
            ? ['StatelessGrabMixin', 'Grab']
            : ['StatefulGrabMixin', 'Grabful'],
      );

      if (targetNames.isNotEmpty) {
        reporter
            .createChangeBuilder(
              message: 'Remove unused ${targetNames.join(' and ')}',
              priority: 90,
            )
            .removeMixins(
              widgetDeclaration: widgetDeclaration!,
              withClause: node,
              targetMixinNames: targetNames.toList(),
            );
      }
    });
  }
}
