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
