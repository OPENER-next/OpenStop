import '/models/expression_handler.dart';

typedef TagValuesResolver = Iterable<String> Function(String key);

/// This class handles the OSM tags construction.
///
/// It contains an OSM tag to expression mapping. The final OSM tags can be retrieved by calling the [construct] method.

class AnswerConstructor with ExpressionHandler {
  final Map<String, List<dynamic>> tagConstructorDef;

  const AnswerConstructor(this.tagConstructorDef);

  /// Generate a constructor based on a list of possible tags.
  /// This is useful when no constructor is given, but a list of tags.
  ///
  /// This will coalesce input values per tag.

  AnswerConstructor.fromTags(Iterable<Map<String, String>> tagList)
    : tagConstructorDef = <String, List<String>>{
        for (var key in tagList.expand((tags) => tags.keys)) key: [r'$input'],
      };

  /// Create the final OSM tags.
  /// Substitutes the `$input` variable with the respective values from the given [tagVariables] mapping.
  ///
  /// Tags with an expression that evaluates to `null` will **not** be written.

  Map<String, String> construct(
    TagValuesResolver resolver, {
    Map<String, String> existingTags = const {},
  }) {
    final map = <String, String>{};

    for (final entry in tagConstructorDef.entries) {
      final numbered = entry.key.endsWith(':*');
      final key = numbered ? entry.key.substring(0, entry.key.length - 2) : entry.key;
      Iterable<String> evaluate(Iterable<String> values) => evaluateExpression(
        entry.value,
        (name) => name == 'input' ? values : const <String>[],
      );
      if (numbered) {
        for (final value in resolver(key)) {
          for (final result in evaluate([value])) {
            final occupied = {...existingTags, ...map};
            final family = RegExp(
              '^${RegExp.escape(key)}(?::[0-9]+)?'
              r'$',
            );
            if (occupied.entries.any(
              (tag) =>
                  family.hasMatch(tag.key) &&
                  tag.value.split(';').map((value) => value.trim()).contains(result),
            )) {
              continue;
            }
            var target = key;
            var suffix = 1;
            while (occupied.containsKey(target)) {
              target = '$key:${suffix++}';
            }
            map[target] = result;
          }
        }
      } else {
        final result = evaluate(resolver(key));
        if (result.isNotEmpty) map[key] = result.first;
      }
    }
    return map;
  }
}
