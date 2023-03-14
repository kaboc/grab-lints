import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'utils.dart';

part 'visitors.dart';

extension ClassDeclarationExtension on ClassDeclaration {
  String get _className => extendsClause?.superclass.name.name ?? '';

  ClassType get classType {
    switch (_className) {
      case 'StatelessWidget':
        return ClassType.stateless;
      case 'StatefulWidget':
        return ClassType.stateful;
      case 'State':
        return ClassType.state;
      default:
        return ClassType.unknown;
    }
  }

  // Unlike the getter with the same name in WithClause, this getter
  // returns original type names when the with clause has their aliases.
  List<String> get mixinNames {
    final mixins = declaredElement?.mixins ?? [];

    return [
      for (final mixin in mixins)
        mixin.getDisplayString(withNullability: false),
    ];
  }

  bool get hasGrabCall {
    final methodInvocations = findMethodInvocations();
    return methodInvocations.any((v) => v.isGrabCall);
  }

  // This needs to be called on a declaration of a state class.
  ClassDeclaration? findStatelessWidget() {
    final superclass = extendsClause?.superclass;
    final typeArgs = superclass?.typeArguments?.arguments;
    if (typeArgs == null) {
      return null;
    }

    final widgetName =
        typeArgs.first.type?.getDisplayString(withNullability: false);

    final visitor = _ClassDeclarationVisitor();
    parent?.visitChildren(visitor);

    return visitor.declarations
        .firstWhereOrNull((v) => v.name.lexeme == widgetName);
  }

  // This needs to be called on a declaration of a StatefulWidget class.
  ClassDeclaration? findStateClass() {
    for (final member in members) {
      final element = member.declaredElement;
      if (element?.name == 'createState') {
        final visitor1 = _InstanceCreationExpressionVisitor();
        member.visitChildren(visitor1);

        final expressions = visitor1.expressions;
        if (expressions.isEmpty) {
          return null;
        }

        final name = expressions.first.constructorName.type.name.name;

        final visitor2 = _ClassDeclarationVisitor();
        parent?.visitChildren(visitor2);

        return visitor2.declarations
            .firstWhereOrNull((v) => v.name.lexeme == name);
      }
    }
    return null;
  }

  List<WithClause> findWithClauses() {
    final visitor = _WithClauseVisitor();
    visitChildren(visitor);
    return visitor.clauses;
  }

  List<MethodInvocation> findMethodInvocations() {
    final visitor = _MethodInvocationVisitor();
    visitChildren(visitor);
    return visitor.invocations;
  }
}

extension WithClauseExtension on WithClause {
  List<String> get mixinNames {
    return [for (final type in mixinTypes) type.name.name];
  }
}

extension MethodInvocationExtension on MethodInvocation {
  bool get isGrabCall {
    final targetName =
        realTarget?.staticType?.getDisplayString(withNullability: false);
    final name = methodName.name;

    return targetName == 'BuildContext' && ['grab', 'grabAt'].contains(name);
  }

  bool get isInBuild {
    final signature = thisOrAncestorOfType<MethodDeclaration>()
        ?.declaredElement
        ?.getDisplayString(withNullability: false);

    return signature == 'Widget build(BuildContext context)';
  }

  bool get isInCallback {
    return thisOrAncestorOfType<InstanceCreationExpression>() != null ||
        thisOrAncestorOfType<FunctionExpression>() != null;
  }
}
