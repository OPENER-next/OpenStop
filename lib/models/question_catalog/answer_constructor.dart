/// This class handles the OSM tags construction.
///
/// It contains an OSM tag to expression mapping. The final OSM tags can be retrieved by calling the [construct] method.

class AnswerConstructor {
  final Map<String, List<String>> tagConstructorDef;

  const AnswerConstructor(this.tagConstructorDef);

  /// Generate a constructor based on a list of possible tags.
  /// This is useful when no constructor is given, but a list of tags.
  ///
  /// This will coalesce input values per tag.

  AnswerConstructor.fromTags(Iterable<Map<String, String>> tagList) :
    tagConstructorDef = <String, List<String>>{
      for (var key in tagList.expand((tags) => tags.keys)) key: [r'$input'],
    };

  /// Create the final OSM tags.
  /// Input variables will be substituted with the values from the given [tagVariables] mapping.
  ///
  /// Tags with an expression that evaluates to `null` will **not** be written.

  Map<String, String> construct(Map<String, Iterable<String>> tagVariables) {
    final map = <String, String>{};

    for (final entry in tagConstructorDef.entries) {
      final result = _evaluateExpression(
        tagVariables[entry.key] ?? const Iterable.empty(),
        entry.value,
      );
      // write osm tag if the expression did not return null
      if (result != null) {
        map[entry.key] = result;
      }
    }
    return map;
  }

  /// Substitutes the "$input" variable with the given variables and then executes the given expression array.

  String? _evaluateExpression(Iterable<String> variables, List<String> rawExpression) {
    if (rawExpression.isEmpty) {
      throw const InvalidExpression('An expression list must not be empty.');
    }

    final mainParameter = rawExpression.first;
    final Expression? expression;
    final Iterable<String> parameters;

    if (mainParameter.isEmpty) {
      throw const InvalidExpression('The first expression parameter must not be empty.');
    }
    // shorthand for coalesce
    if (mainParameter == r'$input') {
      expression = coalesce;
      parameters = rawExpression;
    }
    else {
      expression = expressionMapping[mainParameter];
      parameters = rawExpression.skip(1);
    }

    if (expression != null) {
      final substitutedParameters = _insertVariables(variables, parameters);
      return expression(substitutedParameters);
    }
    throw UnsupportedError('The expression "$mainParameter" is not supported.');
  }


  Iterable<String> _insertVariables(Iterable<String> variables, Iterable<String> expressionParameters) {
    return expressionParameters.expand<String>((arg) sync* {
      if (arg == r'$input') {
        yield* variables;
      }
      else {
        yield arg;
      }
    });
  }
}


/// Expressions must not throw an error.
/// Instead they return a meaningfully result if possible or null.

typedef Expression = String? Function(Iterable<String>);

/// A name to function mapping for expressions.

const expressionMapping = <String, Expression>{
  'join': join,
  'concat': concat,
  'coalesce': coalesce,
};


String? join(Iterable<String> args) {
  if (args.isEmpty) {
    return null;
  }
  final delimiter = args.first;
  final values = args.skip(1);
  return values.isEmpty ? null : values.join(delimiter);
}

String? concat(Iterable<String> args) {
  return args.isEmpty ? null : args.join();
}

String? coalesce(Iterable<String> args) {
  return args.isEmpty ? null : args.first;
}


/// Indicates that an expression is malformed.

class InvalidExpression implements Exception {
  final String message;
  const InvalidExpression(this.message);
}
