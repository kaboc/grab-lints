import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../fixes/fix_build_context_name.dart';
import '../helpers/ast.dart';
import '../helpers/utils.dart';

class MaybeWrongBuildContextForGrab extends DartLintRule {
  const MaybeWrongBuildContextForGrab() : super(code: _code);

  static const _code = LintCode(
    name: 'maybe_wrong_build_context_for_grab',
    problemMessage: 'The BuildContext passed to the grab method may be wrong.',
    correctionMessage: 'Use the BuildContext parameter of the build method. '
        'It should be used directly, not via another variable, because it '
        'easily leads to misuse.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.isGrabCall && node.isInBuild) {
        final arg = node.argumentList.arguments.firstOrNull;
        if (arg == null) {
          return;
        }

        final grabInvocationOffset = node.offset;
        final contextToken = arg.beginToken;
        final contextName = contextToken.lexeme;

        var hasError = false;
        var fixable = false;

        node.parent?.thisOrAncestorMatching((node) {
          if (node is FunctionExpression) {
            // Error if the callback function has a BuildContext param
            // with the same name as the one used for the grab method.
            if (node.parameters.hasBuildContext(name: contextName)) {
              hasError = true;
              return true;
            }

            // `thisOrAncestorMatching()` does not visit siblings,
            // so a separate search inside the callback is necessary.
            final varDecl = node.findVariableDeclaration(
              name: contextName,
              offsetBefore: grabInvocationOffset,
            );

            if (varDecl != null) {
              hasError = true;
              return true;
            }
          }

          if (node is MethodDeclaration) {
            if (node.isBuildMethod &&
                !node.parameters.hasBuildContext(name: contextName)) {
              hasError = true;
              fixable = true;
            }

            // Stops here as there is no need to search above
            // the current method.
            return true;
          }

          return false;
        });

        if (hasError) {
          final targetToken = fixable ? contextToken : null;
          reporter.reportErrorForNode(code, node, null, null, targetToken);
        }
      }
    });
  }

  @override
  List<Fix> getFixes() => [FixBuildContextName()];
}
