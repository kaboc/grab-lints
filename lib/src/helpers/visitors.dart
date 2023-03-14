part of 'ast.dart';

class _ClassDeclarationVisitor extends RecursiveAstVisitor<void> {
  final _declarations = <ClassDeclaration>[];

  List<ClassDeclaration> get declarations => _declarations;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _declarations.add(node);
  }
}

class _WithClauseVisitor extends RecursiveAstVisitor<void> {
  final _clauses = <WithClause>[];

  List<WithClause> get clauses => _clauses;

  @override
  void visitWithClause(WithClause node) {
    _clauses.add(node);
  }
}

class _MethodInvocationVisitor extends RecursiveAstVisitor<void> {
  final _invocations = <MethodInvocation>[];

  List<MethodInvocation> get invocations => _invocations;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _invocations.add(node);
  }
}

class _InstanceCreationExpressionVisitor extends RecursiveAstVisitor<void> {
  final _expressions = <InstanceCreationExpression>[];

  List<InstanceCreationExpression> get expressions => _expressions;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _expressions.add(node);
  }
}
