import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/lints/avoid_grab_outside_build.dart';
import 'src/lints/maybe_wrong_build_context_for_grab.dart';
import 'src/lints/missing_grab_mixin.dart';
import 'src/lints/unnecessary_grab_mixin.dart';
import 'src/lints/wrong_grab_mixin.dart';

/// The entrypoint of this plugin.
PluginBase createPlugin() => _GrabLints();

class _GrabLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
        AvoidGrabOutsideBuild(),
        MaybeWrongBuildContextForGrab(),
        MissingGrabMixin(),
        UnnecessaryGrabMixin(),
        WrongGrabMixin(),
      ];
}
