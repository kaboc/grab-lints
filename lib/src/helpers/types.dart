import 'package:custom_lint_builder/custom_lint_builder.dart';

const buildContextType = TypeChecker.fromName(
  'BuildContext',
  packageName: 'flutter',
);

const widgetType = TypeChecker.fromName(
  'Widget',
  packageName: 'flutter',
);

const listenableType = TypeChecker.fromName(
  'Listenable',
  packageName: 'flutter',
);
