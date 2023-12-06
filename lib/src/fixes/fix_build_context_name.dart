import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class FixBuildContextName extends DartFix {
  FixBuildContextName();

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

      final targetToken = analysisError.data as Token?;
      if (targetToken == null) {
        return;
      }

      reporter
          .createChangeBuilder(
            message: 'Convert "${targetToken.lexeme}" to "context"',
            priority: 90,
          )
          .addDartFileEdit(
            (builder) => builder.addSimpleReplacement(
              targetToken.sourceRange,
              'context',
            ),
          );
    });
  }
}
