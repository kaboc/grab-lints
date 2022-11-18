import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _GrabLint());
}

class _GrabLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final variableDeclarationVisitor = _VariableDeclarationVisitor();
    resolvedUnitResult.unit.visitChildren(variableDeclarationVisitor);

    for (final declaration in variableDeclarationVisitor.declarations) {
      final methodInvocationVisitor = _MethodInvocationVisitor();
      declaration.visitChildren(methodInvocationVisitor);

      for (final invocation in methodInvocationVisitor.invocations) {
        final identifierVisitor = _SimpleIdentifierVisitor();
        invocation.visitChildren(identifierVisitor);

        final identifiers = identifierVisitor.identifiers.toList();
        final grabIndex = identifiers.indexWhere(
          (e) => ['grab', 'grabAt'].contains((e as Identifier).name),
        );

        if (grabIndex > 0) {
          final contextIndex = grabIndex - 1;
          final identifier = identifiers[contextIndex];
          final context = _findBuildContextNode(identifier);

          if (context != null) {
            final parents = _parents(context);

            final lint1 =
                _usedInFunctionLint(resolvedUnitResult, invocation, parents);
            if (lint1 != null) {
              yield lint1;
              continue;
            }

            final lint2 = _tooDeepLint(resolvedUnitResult, invocation, parents);
            if (lint2 != null) {
              yield lint2;
              continue;
            }

            final lint3 = _noMixinLint(resolvedUnitResult, invocation, parents);
            if (lint3 != null) {
              yield lint3;
              continue;
            }
          }
        }
      }
    }
  }

  List<AstNode> _parents(AstNode node) {
    final parents = <AstNode>[];

    AstNode? current = node;
    while (true) {
      current = current?.parent;
      if (current == null) {
        break;
      }

      parents.add(current);

      if (current is ClassDeclaration) {
        break;
      }
    }

    // Nodes up to the closest MethodInvocation are unnecessary.
    final index = parents.indexWhere((e) => e is MethodInvocation);
    return index > -1 ? parents.skip(index + 1).toList() : parents;
  }

  AstNode? _findBuildContextNode(AstNode node) {
    if (node is Identifier && node.staticType?.dispName == 'BuildContext') {
      return node;
    }

    // When a BuildContext is returned from a function and a Grab
    // extension method is called with it like `contextHolder().grab()`,
    // it appears that we can check it by seeing the parent of the
    // function node that is a SimpleIdentifier.
    // No idea why the parent is FunctionExpressionInvocation and
    // its child (the BuildContext node) is not.
    final parent = node.parent;
    if (parent is FunctionExpressionInvocation &&
        parent.staticType?.dispName == 'BuildContext') {
      return parent;
    }

    return null;
  }

  ClassDeclaration? _findClass(ResolvedUnitResult result, String name) {
    final visitor = _ClassDeclarationVisitor();
    result.unit.visitChildren(visitor);
    final declarations = visitor.declarations.toList();

    final index = declarations.indexWhere(
      (e) => (e as ClassDeclaration).name.name == name,
    );

    return index < 0 ? null : declarations[index] as ClassDeclaration;
  }

  ClassDeclaration? _findWidgetNameIfStateClass(
    ResolvedUnitResult result,
    ClassDeclaration declaration,
  ) {
    final superclass = declaration.extendsClause?.superclass;
    final isState = superclass?.type?.dispName.startsWith('State<') ?? false;
    final args = superclass?.typeArguments?.arguments ?? <TypeAnnotation>[];

    return isState && args.isNotEmpty
        ? _findClass(result, args.first.type!.dispName) ?? declaration
        : declaration;
  }

  Lint? _usedInFunctionLint(
    ResolvedUnitResult result,
    AstNode invocation,
    List<AstNode> parents,
  ) {
    final index = parents.indexWhere(
      (e) =>
          e.toString().startsWith('@override Widget build(BuildContext ') ||
          e.toString().startsWith('Widget build(BuildContext '),
    );

    return index > -1
        ? null
        : Lint(
            code: 'grab_used_in_function',
            message: 'Extension methods of Grab are only available in '
                'the build method of either of the followings:\n'
                '* A StatelessWidget with the StatelessGrabMixin / Grab '
                'mixin\n'
                '* The State class associated with a StatefulWidget with '
                'the StatefulGrabMixin / Grabful mixin',
            location: result.lintLocationFromOffset(
              invocation.offset,
              length: invocation.length,
            ),
          );
  }

  Lint? _tooDeepLint(
    ResolvedUnitResult result,
    AstNode invocation,
    List<AstNode> parents,
  ) {
    final index = parents.indexWhere((e) => e is InstanceCreationExpression);

    return index < 0
        ? null
        : Lint(
            code: 'grab_used_too_deep',
            message: 'Extension methods of Grab are only available at '
                'the top level of the build method.',
            location: result.lintLocationFromOffset(
              invocation.offset,
              length: invocation.length,
            ),
          );
  }

  Lint? _noMixinLint(
    ResolvedUnitResult result,
    AstNode invocation,
    List<AstNode> parents,
  ) {
    var hasMixin = false;
    final index = parents.indexWhere((e) => e is ClassDeclaration);
    if (index > -1) {
      ClassDeclaration? declaration = parents[index] as ClassDeclaration;
      declaration = _findWidgetNameIfStateClass(result, declaration);

      final element = declaration?.declaredElement;
      final mixins = element?.mixins ?? [];
      final mixinIndex = mixins.indexWhere(
        (e) => ['StatelessGrabMixin', 'StatefulGrabMixin'].contains(e.dispName),
      );
      hasMixin = mixinIndex > -1;
    }

    return hasMixin
        ? null
        : Lint(
            code: 'no_grab_mixin',
            message: 'Extension methods of Grab are only available in '
                'the build method of either of the followings:\n'
                '* A StatelessWidget with the StatelessGrabMixin / Grab '
                'mixin\n'
                '* The State class associated with a StatefulWidget with '
                'the StatefulGrabMixin / Grabful mixin',
            location: result.lintLocationFromOffset(
              invocation.offset,
              length: invocation.length,
            ),
          );
  }
}

class _VariableDeclarationVisitor extends RecursiveAstVisitor<void> {
  final _declarations = <AstNode>[];

  Iterable<AstNode> get declarations => _declarations;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _declarations.add(node);
  }
}

class _MethodInvocationVisitor extends RecursiveAstVisitor<void> {
  final _invocations = <AstNode>[];

  Iterable<AstNode> get invocations => _invocations;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _invocations.add(node);
  }
}

class _SimpleIdentifierVisitor extends RecursiveAstVisitor<void> {
  final _identifiers = <AstNode>[];

  Iterable<AstNode> get identifiers => _identifiers;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _identifiers.add(node);
  }
}

class _ClassDeclarationVisitor extends RecursiveAstVisitor<void> {
  final _declarations = <AstNode>[];

  Iterable<AstNode> get declarations => _declarations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _declarations.add(node);
  }
}

extension on DartType {
  String get dispName => getDisplayString(withNullability: false);
}

extension on InterfaceType {
  String get dispName => getDisplayString(withNullability: false);
}
