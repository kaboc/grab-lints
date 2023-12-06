// ignore_for_file: avoid_single_cascade_in_expression_statements, invalid_override, mixin_application_not_implemented_interface, non_abstract_class_inherits_abstract_member, unused_element

//=========================================================
// This file works as both a demonstration and tests.
// Your editor shows no error if lint warnings are being
// successfully suppressed by the `expect_lint` comments.
//=========================================================

import 'package:flutter/material.dart';
import 'package:grab/grab.dart';

final valueNotifier = ValueNotifier(0);
final changeNotifier1 = MyChangeNotifier1(0);
final changeNotifier2 = MyChangeNotifier2(0);
final changeNotifier3 = MyChangeNotifier3(0);
final textController = TextEditingController();

class MyChangeNotifier1 extends ChangeNotifier {
  MyChangeNotifier1(this.value);

  final int value;
}

class MyChangeNotifier2 extends MyChangeNotifier1 {
  MyChangeNotifier2(super.value);
}

class MyChangeNotifier3 with ChangeNotifier {
  MyChangeNotifier3(this.value);

  final int value;
}

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatelessWidget1(),
            _StatelessWidget2(),
            _StatelessWidget3(),
            _StatelessWidget4(),
            _StatefulWidget1(),
            _StatefulWidget2(),
            _StatefulWidget3(),
            _StatefulWidget4(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => valueNotifier.value++,
        ),
      ),
    );
  }
}

// expect_lint: unnecessary_grab_mixin
class _StatelessWidget1 extends StatelessWidget with Grab {
  const _StatelessWidget1();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _StatelessWidget2 extends StatelessWidget with Grab {
  const _StatelessWidget2();

  @override
  Widget build(BuildContext context) {
    // Using grab in an if condition or a block is fine.
    if (valueNotifier.grab(context).isEven) {
      valueNotifier.grab(context);
    }

    int localFunc1() {
      // expect_lint: avoid_grab_in_callback
      return valueNotifier.grab(context);
    }

    int localFunc2(BuildContext context) {
      // expect_lint: avoid_grab_in_callback
      return valueNotifier.grab(context);
    }

    final ctx = context;
    valueNotifier.grab(ctx);

    return Center(
      child: SizedBox.square(
        dimension: 500.0,
        child: Column(
          children: [
            Padding(
              // Using grab in a deeply nested location is fine.
              padding: EdgeInsets.all(valueNotifier.grab(context).toDouble()),
              child: Text('${valueNotifier.grab(context)}'),
            ),
            ...[
              Text('${valueNotifier.grab(context)}'),
            ],
            Builder(
              builder: (_) {
                // expect_lint: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
            Builder(
              builder: (context) {
                // ignore: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
            Builder(
              builder: (context2) {
                final context = context2;

                // ignore: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// expect_lint: wrong_grab_mixin
class _StatelessWidget3 extends StatelessWidget with Grabful {
  const _StatelessWidget3();

  @override
  Widget build(BuildContext context) {
    _func(context);

    // expect_lint: missing_grab_mixin
    return Text('${valueNotifier.grab(context)}');
  }

  void _func(BuildContext context) {
    // expect_lint: avoid_grab_outside_build
    valueNotifier.grab(context);
  }
}

class _StatelessWidget4 extends StatelessWidget {
  const _StatelessWidget4();

  @override
  Widget build(BuildContext context) {
    // Either Grab or StatelessGrabMixin is necessary.
    // expect_lint: missing_grab_mixin
    final count = valueNotifier.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier1.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier2.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier3.grab(context);
    // expect_lint: missing_grab_mixin
    textController.grab(context);

    // expect_lint: missing_grab_mixin
    valueNotifier.grabAt(context, (v) => v);
    // expect_lint: missing_grab_mixin
    changeNotifier1.grabAt(context, (MyChangeNotifier1 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier2.grabAt(context, (MyChangeNotifier2 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier3.grabAt(context, (MyChangeNotifier3 n) => n.value);

    // expect_lint: missing_grab_mixin
    valueNotifier..grab(context);

    return Center(
      child: Text('$count'),
    );
  }
}

// expect_lint: unnecessary_grab_mixin
class _StatefulWidget1 extends StatefulWidget with Grabful {
  const _StatefulWidget1();

  @override
  State<_StatefulWidget1> createState() => _StatefulWidget1State();
}

class _StatefulWidget1State extends State<_StatefulWidget1> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _StatefulWidget2 extends StatefulWidget with Grabful {
  const _StatefulWidget2();

  @override
  State<_StatefulWidget2> createState() => _StatefulWidget2State();
}

class _StatefulWidget2State extends State<_StatefulWidget2> {
  @override
  Widget build(BuildContext context) {
    // Using grab in an if condition or a block is fine.
    if (valueNotifier.grab(context).isEven) {
      valueNotifier.grab(context);
    }

    int localFunc1() {
      // expect_lint: avoid_grab_in_callback
      return valueNotifier.grab(context);
    }

    int localFunc2(BuildContext context) {
      // expect_lint: avoid_grab_in_callback
      return valueNotifier.grab(context);
    }

    final ctx = context;
    valueNotifier.grab(ctx);

    return Center(
      child: SizedBox.square(
        dimension: 500.0,
        child: Column(
          children: [
            Padding(
              // Using grab in a deeply nested location is fine.
              padding: EdgeInsets.all(
                valueNotifier.grab(context).toDouble(),
              ),
              child: Text('${valueNotifier.grab(context)}'),
            ),
            ...[
              Text('${valueNotifier.grab(context)}'),
            ],
            Builder(
              builder: (_) {
                // expect_lint: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
            Builder(
              builder: (context) {
                // expect_lint: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
            Builder(
              builder: (context2) {
                final context = context2;

                /// expect_lint: avoid_grab_in_callback
                return Text('${valueNotifier.grab(context)}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// expect_lint: wrong_grab_mixin
class _StatefulWidget3 extends StatefulWidget with Grab {
  const _StatefulWidget3();

  @override
  State<_StatefulWidget3> createState() => _StatefulWidget3State();
}

class _StatefulWidget3State extends State<_StatefulWidget3> {
  @override
  Widget build(BuildContext context) {
    _func(context);

    // expect_lint: missing_grab_mixin
    return Text('${valueNotifier.grab(context)}');
  }

  void _func(BuildContext context) {
    // expect_lint: avoid_grab_outside_build
    valueNotifier.grab(context);
  }
}

class _StatefulWidget4 extends StatefulWidget {
  const _StatefulWidget4();

  @override
  State<_StatefulWidget4> createState() => _StatefulWidget4State();
}

class _StatefulWidget4State extends State<_StatefulWidget4> {
  @override
  Widget build(BuildContext context) {
    // Either Grabful or StatefulGrabMixin is necessary.
    // expect_lint: missing_grab_mixin
    final count = valueNotifier.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier1.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier2.grab(context);
    // expect_lint: missing_grab_mixin
    changeNotifier3.grab(context);
    // expect_lint: missing_grab_mixin
    textController.grab(context);

    // expect_lint: missing_grab_mixin
    valueNotifier.grabAt(context, (v) => v);
    // expect_lint: missing_grab_mixin
    changeNotifier1.grabAt(context, (MyChangeNotifier1 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier2.grabAt(context, (MyChangeNotifier2 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier3.grabAt(context, (MyChangeNotifier3 n) => n.value);

    // expect_lint: missing_grab_mixin
    valueNotifier..grab(context);

    return Center(
      child: Text('$count'),
    );
  }
}
