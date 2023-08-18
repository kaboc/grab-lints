import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'utils.dart';

part 'visitors.dart';

extension NullableClassDeclarationExtension on ClassDeclaration? {
  bool get hasStatelessMixin {
    return this?.mixinNames.contains('StatelessGrabMixin') ?? false;
  }

  bool get hasStatefulMixin {
    return this?.mixinNames.contains('StatefulGrabMixin') ?? false;
  }
}

extension ClassDeclarationExtension on ClassDeclaration {
  String get _className => extendsClause?.superclass.name2.lexeme ?? '';

  ClassType get classType {
    return switch (_className) {
      'StatelessWidget' => ClassType.stateless,
      'StatefulWidget' => ClassType.stateful,
      'State' => ClassType.state,
      _ => ClassType.unknown,
    };
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

        final visitor2 = _ClassDeclarationVisitor();
        parent?.visitChildren(visitor2);

        return visitor2.declarations.firstWhereOrNull(
          (v) => v.name == expressions.first.constructorName.type.name2,
        );
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
    return [for (final type in mixinTypes) type.name2.lexeme];
  }
}

extension MethodInvocationExtension on MethodInvocation {
  bool get isGrabCall {
    // TODO: Will be removed after most users start using grab >=0.4.0.
    if (_isGrabCallOld) {
      return true;
    }

    final receiverElement = realTarget?.staticType?.element;

    return ['grab', 'grabAt'].contains(methodName.name) &&
        receiverElement != null &&
        receiverElement is ClassElement &&
        receiverElement.allSupertypes.any(
          (t) => t.getDisplayString(withNullability: false) == 'Listenable',
        );
  }

  // TODO: For grab <0.4.0. Will be removed.
  bool get _isGrabCallOld {
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
    return thisOrAncestorOfType<FunctionExpression>() != null;
  }
}
