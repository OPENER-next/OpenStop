import 'element_conditions/element_condition.dart';
import 'element_conditions/sub_condition_matcher.dart';
import 'element_variants/base_element.dart';
import 'question_catalog/question_catalog.dart';

/// Used to efficiently get all elements that match or don't match any question
/// after a change to a specific element.
///
/// Usage:
/// ```dart
/// final differ = AffectedElementsDetector(...);
/// final preResults = differ.takeSnapshot(myElement); // important in order to fully detect changes
/// myElement.updateTags();
/// final changeResults = differ.takeSnapshot(myElement);
/// ```
class AffectedElementsDetector {
  final QuestionCatalog questionCatalog;

  Set<ProcessedElement>? _before;
  Set<ProcessedElement>? _after;

  AffectedElementsDetector({
    required this.questionCatalog,
  });

  /// Takes a snapshot of the currently affected elements and returns whether
  /// they match or don't match any question.
  ///
  /// This takes the previous snapshot into account (if any) in order to detect elements
  /// that matched before but stop matching after the element was updated.

  Iterable<AffectedElementsRecord> takeSnapshot(ProcessedElement element) {
    final elements = _collectAffectedElements(element);

    if (_before == null) {
      _before = elements;
    } else {
      if (_after != null) {
        _before = _after;
      }
      _after = elements;
    }
    return _diff();
  }

  Iterable<AffectedElementsRecord> _diff() {
    // ensure that takeSnapshot() has been called before once
    final elements = _after == null ? _before! : _before!.union(_after!);

    return elements.map((element) {
      final matches = questionCatalog.any(
        (questionDef) => questionDef.conditions.any(
          (condition) => condition.matches(element),
        ),
      );
      return AffectedElementsRecord(
        element: element,
        matches: matches,
      );
    });
  }

  /// All elements whose matching of questions **may** be affected (positively or negatively)
  /// by changes to the given target element.

  Set<ProcessedElement> _collectAffectedElements(ProcessedElement element) {
    return questionCatalog
        .expand(
          (questionDef) => _findAffected(element, questionDef.conditions),
        )
        .toSet();
  }

  /// Recursively walks through all the parent and child conditions and gathers
  /// any ancestors or descendants that may be affected by changes to the sample element.

  Iterable<ProcessedElement> _findAffected(
    ProcessedElement sample,
    List<ElementCondition> conditions,
  ) sync* {
    for (final cond in conditions) {
      for (final subCond in cond.characteristics) {
        final bool takeChildren;
        final List<ElementCondition> conditions;

        // access child/parent in reverse direction here
        if (subCond is ParentSubCondition) {
          takeChildren = true;
          conditions = subCond.characteristics;
        } else if (subCond is ChildSubCondition) {
          takeChildren = false;
          conditions = subCond.characteristics;
        } else if (subCond is NegatedSubCondition<ParentSubCondition>) {
          takeChildren = true;
          conditions = subCond.characteristics.characteristics;
        } else if (subCond is NegatedSubCondition<ChildSubCondition>) {
          takeChildren = false;
          conditions = subCond.characteristics.characteristics;
        } else {
          continue;
        }

        // recursively move into nested parent/child conditions
        // return potentially matching child/parent elements
        final candidates = _findAffected(sample, conditions);
        // return the respective children/parent of the potentially matching elements
        yield* (takeChildren
            ? candidates.expand((element) => element.children)
            : candidates.expand((element) => element.parents));
        // this gets first called for the deepest/most nested parent/child condition
        if (conditions.any((cond) => cond.matches(sample))) {
          yield* (takeChildren ? sample.children : sample.parents);
        }
      }
    }
  }
}

class AffectedElementsRecord {
  final ProcessedElement element;
  final bool matches;

  const AffectedElementsRecord({
    required this.element,
    required this.matches,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AffectedElementsRecord && other.element == element && other.matches == matches;
  }

  @override
  int get hashCode => element.hashCode ^ matches.hashCode;
}
