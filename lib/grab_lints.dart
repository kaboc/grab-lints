import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/lints/avoid_grab_in_callback.dart';
import 'src/lints/avoid_grab_outside_build.dart';
import 'src/lints/missing_grab_mixin.dart';
import 'src/lints/unnecessary_grab_mixin.dart';
import 'src/lints/wrong_grab_mixin.dart';

PluginBase createPlugin() => _GrabLints();

class _GrabLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
        AvoidGrabInCallback(),
        AvoidGrabOutsideBuild(),
        MissingGrabMixin(),
        UnnecessaryGrabMixin(),
        WrongGrabMixin(),
      ];
}
