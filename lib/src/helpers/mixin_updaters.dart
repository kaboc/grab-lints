import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'ast.dart';

const _kAllGrabMixinNames = [
  'Grab',
  'Grabful',
  'StatelessGrabMixin',
  'StatefulGrabMixin',
];

extension ChangeBuilderExtension on ChangeBuilder {
  void updateMixin({
    required ClassDeclaration widgetDeclaration,
    required WithClause? withClause,
    required String mixinName,
  }) {
    if (withClause == null) {
      addDartFileEdit((builder) {
        builder.addSimpleInsertion(
          widgetDeclaration.extendsClause!.end,
          ' with $mixinName',
        );
      });
    } else {
      _replaceAllMixins(
        withClause: withClause,
        newMixinNames: withClause.mixinNames
          ..removeWhere((v) => _kAllGrabMixinNames.contains(v))
          ..add(mixinName)
          ..sort((a, b) => a.compareTo(b)),
      );
    }
  }

  void removeMixins({
    required ClassDeclaration widgetDeclaration,
    required WithClause withClause,
    required List<String> targetMixinNames,
  }) {
    final newMixinNames = withClause.mixinNames
      ..removeWhere((v) => targetMixinNames.contains(v));

    if (newMixinNames.isEmpty) {
      _removeWithClause(
        widgetDeclaration: widgetDeclaration,
        withClause: withClause,
      );
    } else {
      _replaceAllMixins(
        withClause: withClause,
        newMixinNames: newMixinNames,
      );
    }
  }

  void _replaceAllMixins({
    required WithClause withClause,
    required List<String> newMixinNames,
  }) {
    addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        withClause.sourceRange,
        'with ${newMixinNames.join(', ')}',
      );
    });
  }

  void _removeWithClause({
    required ClassDeclaration widgetDeclaration,
    required WithClause withClause,
  }) {
    final nextOffset = widgetDeclaration.implementsClause?.offset ??
        widgetDeclaration.leftBracket.offset;
    final targetRange =
        SourceRange(withClause.offset, nextOffset - withClause.offset);

    addDartFileEdit((builder) {
      builder.addDeletion(targetRange);
    });
  }
}
