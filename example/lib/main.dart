// ignore_for_file: invalid_override, mixin_application_not_implemented_interface, non_abstract_class_inherits_abstract_member

//==================================================================
// Lint warnings are being suppressed with `expect_lint` comments.
// Try commenting out them to see that misuse is actually warned.
//==================================================================

import 'package:flutter/material.dart';
import 'package:grab/grab.dart';

final notifier = ValueNotifier(0);

void main() => runApp(const App());

// expect_lint: unnecessary_grab_mixin
class App extends StatelessWidget with Grab {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _MyStatelessWidget1(),
            _MyStatelessWidget2(),
            _MyStatefulWidget1(),
            _MyStatefulWidget2(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => notifier.value++,
        ),
      ),
    );
  }
}

class _MyStatelessWidget1 extends StatelessWidget {
  const _MyStatelessWidget1();

  @override
  Widget build(BuildContext context) {
    // Either Grab or StatelessGrabMixin is necessary.
    // expect_lint: missing_grab_mixin
    final count = context.grab(notifier);

    return Center(
      child: Text('$count'),
    );
  }
}

// expect_lint: wrong_grab_mixin
class _MyStatelessWidget2 extends StatelessWidget with Grabful {
  const _MyStatelessWidget2();

  @override
  Widget build(BuildContext context) {
    // expect_lint: missing_grab_mixin
    final count = context.grab(notifier);

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
    final count = context.grab(notifier);

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
    final count = context.grab(notifier);
    _func(context);

    return Center(
      child: Column(
        children: [
          Text('$count'),
          Builder(
            builder: (context) {
              // expect_lint: avoid_grab_in_callback
              context.grab(notifier);

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _func(BuildContext context) {
    // expect_lint: avoid_grab_outside_build
    context.grab(notifier);
  }
}
