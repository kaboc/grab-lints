import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'types.dart';
import 'utils.dart';

part 'visitors.dart';

extension NullableClassDeclarationExtension on ClassDeclaration? {
  bool get hasStatelessGrabMixin => mixinNames.contains('StatelessGrabMixin');
  bool get hasStatefulGrabMixin => mixinNames.contains('StatefulGrabMixin');
  bool get hasGrabMixin => hasStatelessGrabMixin || hasStatefulGrabMixin;
}

extension ClassDeclarationExtension on ClassDeclaration? {
  String get _className => this?.extendsClause?.superclass.name2.lexeme ?? '';

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
    final mixins = this?.declaredElement?.mixins ?? [];

    return [
      for (final mixin in mixins)
        mixin.getDisplayString(withNullability: false),
    ];
  }

  bool get hasGrabCall {
    return findMethodInvocations().any((v) => v.isGrabCall);
  }

  // This needs to be called on a declaration of a state class.
  ClassDeclaration? findStatelessWidget() {
    final superclass = this?.extendsClause?.superclass;
    final typeArgs = superclass?.typeArguments?.arguments;
    if (typeArgs == null) {
      return null;
    }

    final widgetName =
        typeArgs.first.type?.getDisplayString(withNullability: false);

    final visitor = _ClassDeclarationVisitor();
    this?.parent?.visitChildren(visitor);

    return visitor.declarations
        .firstWhereOrNull((v) => v.name.lexeme == widgetName);
  }

  // This needs to be called on a declaration of a StatefulWidget class.
  ClassDeclaration? findStateClass() {
    final members = this?.members ?? <ClassMember>[];
    for (final member in members) {
      if (member.declaredElement?.name == 'createState') {
        final visitor1 = _InstanceCreationExpressionVisitor();
        member.visitChildren(visitor1);

        final expressions = visitor1.expressions;
        if (expressions.isEmpty) {
          return null;
        }

        final visitor2 = _ClassDeclarationVisitor();
        this?.parent?.visitChildren(visitor2);

        return visitor2.declarations.firstWhereOrNull(
          (v) =>
              v.name.lexeme ==
              expressions.first.constructorName.type.name2.lexeme,
        );
      }
    }
    return null;
  }

  List<WithClause> findWithClauses() {
    final visitor = _WithClauseVisitor();
    this?.visitChildren(visitor);
    return visitor.clauses;
  }

  List<MethodInvocation> findMethodInvocations() {
    final visitor = _MethodInvocationVisitor();
    this?.visitChildren(visitor);
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

    final receiverElm = realTarget?.staticType?.element;

    return ['grab', 'grabAt'].contains(methodName.name) &&
        receiverElm != null &&
        receiverElm is ClassElement &&
        receiverElm.allSupertypes.any((t) => listenableType.isExactlyType(t));
  }

  // TODO: For grab <0.4.0. Will be removed.
  bool get _isGrabCallOld {
    final targetName =
        realTarget?.staticType?.getDisplayString(withNullability: false);
    final name = methodName.name;

    return targetName == 'BuildContext' && ['grab', 'grabAt'].contains(name);
  }

  bool get isInBuild {
    return thisOrAncestorOfType<MethodDeclaration>().isBuildMethod;
  }
}

extension MethodDeclarationExtension on MethodDeclaration? {
  bool get isBuildMethod {
    final classDecl = this?.thisOrAncestorOfType<ClassDeclaration>();
    final elm = this?.declaredElement;

    final isClassWithBuild =
        classDecl != null && classDecl.classType.hasBuildMethod;

    return isClassWithBuild &&
        elm != null &&
        widgetType.isExactlyType(elm.returnType) &&
        elm.name == 'build' &&
        elm.parameters.length == 1 &&
        buildContextType.isExactlyType(elm.parameters.first.type);
  }
}

extension FunctionExpressionExtension on FunctionExpression {
  VariableDeclaration? findVariableDeclaration({
    required String name,
    required int offsetBefore,
  }) {
    final visitor = _VariableDeclarationVisitor();
    visitChildren(visitor);

    for (final decl in visitor.declarations) {
      if (decl.offset > offsetBefore) {
        return null;
      }

      final elm = decl.declaredElement;
      final elmType = elm?.type;
      if (elmType.isBuildContext && elm?.name == name) {
        return decl;
      }
    }
    return null;
  }
}
