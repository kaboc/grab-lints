// ignore_for_file: avoid_single_cascade_in_expression_statements, invalid_override, mixin_application_not_implemented_interface, non_abstract_class_inherits_abstract_member

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

// expect_lint: unnecessary_grab_mixin
class App extends StatelessWidget with Grab {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MyStatelessWidget1(),
            _MyStatelessWidget2(),
            _MyStatelessWidget3(),
            _MyStatefulWidget1(),
            _MyStatefulWidget2(),
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

class _MyStatelessWidget1 extends StatelessWidget with Grab {
  const _MyStatelessWidget1();

  @override
  Widget build(BuildContext context) {
    // Using grab in an if expression or a block is fine.
    if (valueNotifier.grab(context).isEven) {
      valueNotifier.grab(context);
    }

    return Center(
      child: SizedBox.square(
        dimension: 500.0,
        child: Column(
          children: [
            Padding(
              // Using grab in a deeply nested location is fine
              // as long as it is not in a callback.
              padding: EdgeInsets.all(valueNotifier.grab(context).toDouble()),
              child: Text('${valueNotifier.grab(context)}'),
            ),
            ...[
              Text('${valueNotifier.grab(context)}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyStatelessWidget2 extends StatelessWidget {
  const _MyStatelessWidget2();

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

    // Works for grabAt() too.
    // expect_lint: missing_grab_mixin
    valueNotifier.grabAt(context, (v) => v);
    // expect_lint: missing_grab_mixin
    changeNotifier1.grabAt(context, (MyChangeNotifier1 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier2.grabAt(context, (MyChangeNotifier2 n) => n.value);
    // expect_lint: missing_grab_mixin
    changeNotifier3.grabAt(context, (MyChangeNotifier3 n) => n.value);

    // Works for a call with cascade notation.
    // expect_lint: missing_grab_mixin
    valueNotifier..grab(context);

    final ctx = context;

    // Works for a call using a name other than context.
    // expect_lint: missing_grab_mixin
    valueNotifier.grab(ctx);

    return Center(
      child: Text('$count'),
    );
  }
}

// expect_lint: wrong_grab_mixin
class _MyStatelessWidget3 extends StatelessWidget with Grabful {
  const _MyStatelessWidget3();

  @override
  Widget build(BuildContext context) {
    // expect_lint: missing_grab_mixin
    final count = valueNotifier.grab(context);

    return Center(
      child: Text('$count'),
    );
  }
}

class _MyStatefulWidget1 extends StatefulWidget {
  const _MyStatefulWidget1();

  @override
  State<_MyStatefulWidget1> createState() => _MyStatefulWidget1State();
}

class _MyStatefulWidget1State extends State<_MyStatefulWidget1> {
  @override
  Widget build(BuildContext context) {
    // expect_lint: missing_grab_mixin
    final count = valueNotifier.grab(context);

    return Center(
      child: Text('$count'),
    );
  }
}

// expect_lint: wrong_grab_mixin
class _MyStatefulWidget2 extends StatefulWidget with Grab {
  const _MyStatefulWidget2();

  @override
  State<_MyStatefulWidget2> createState() => _MyStatefulWidget2State();
}

class _MyStatefulWidget2State extends State<_MyStatefulWidget2> {
  @override
  Widget build(BuildContext context) {
    // expect_lint: missing_grab_mixin
    final count = valueNotifier.grab(context);
    _func(context);

    return Center(
      child: Column(
        children: [
          Text('$count'),
          Builder(
            builder: (context) {
              // expect_lint: avoid_grab_in_callback
              valueNotifier.grab(context);

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _func(BuildContext context) {
    // expect_lint: avoid_grab_outside_build
    valueNotifier.grab(context);
  }
}
