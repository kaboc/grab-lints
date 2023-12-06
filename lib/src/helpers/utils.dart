import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'types.dart';

enum ClassType {
  stateless,
  stateful,
  state,
  unknown;

  bool get isStateless => this == ClassType.stateless;
  bool get isStateful => this == ClassType.stateful;
  bool get isState => this == ClassType.state;
  bool get isUnknown => this == ClassType.unknown;

  bool get hasBuildMethod => isStateless || isState;
}

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final v in this) {
      if (test(v)) {
        return v;
      }
    }
    return null;
  }

  Iterable<T> intersects(List<T> other) {
    return [
      for (final v in other)
        if (contains(v)) v,
    ];
  }
}

extension ElementIsType on DartType? {
  bool get isBuildContext {
    final type = this;
    return type != null && buildContextType.isExactlyType(type);
  }
}

extension FormalParameterListExtension on FormalParameterList? {
  ParameterElement? _findParameter({required String name}) {
    return this?.parameterElements.firstWhereOrNull((elm) => elm?.name == name);
  }

  bool hasBuildContext({required String name}) {
    final elm = _findParameter(name: name);
    return elm != null && elm.type.isBuildContext;
  }
}
