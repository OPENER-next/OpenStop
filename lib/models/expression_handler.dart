/// Function to substitute variables found in an expression.
/// Returns zero to multiple values for a given variable.

typedef SubstitutionCallback = Iterable<String> Function(String variableName);

/// Expressions must not throw an error.
/// Instead they return a meaningful result if possible or null.

typedef Expression = String? Function(Iterable<String>);


/// A utility class that can be mixed in to get expression support wherever needed.
///
/// Expressions are defined as an array where the first item is the expression identifier/name,
/// while the other items are strings or nested expressions (nested array) which will be passed
/// as arguments/parameters to the specific expression function.
///
/// Expressions can also contain variables which are marked with a `$` symbol at the start.
/// Variables may resolve into multiple values, but an expression has exactly one result.
///
/// Example:
/// ```
/// expression = ["JOIN", "; ",
///   "Foo",
///   ["CONCAT", "$var", " unit"],
///   "Bar"
/// ]
/// ```
///
/// For `$var = "5"` this will evaluate to `Foo; 5 unit; Bar`

mixin ExpressionHandler {

  /// A name to function mapping for expressions.

  static const _expressionMapping = <String, Expression>{
    'JOIN': _join,
    'CONCAT': _concat,
    'COALESCE': _coalesce,
    'COUPLE': _couple,
    'PAD': _pad,
    'INSERT': _insert,
    'REPLACE': _replace,
  };

  /// Substitutes any variables (marked by $) and then executes the given expression array.

  String? evaluateExpression(Iterable<dynamic> rawExpression, SubstitutionCallback substitutionCallback) {
    if (rawExpression.isEmpty) {
      throw const InvalidExpression('An expression list must not be empty.');
    }

    final expressionIdentifier = rawExpression.first;
    final Expression? expression;
    final Iterable parameters;

    if (expressionIdentifier is! String || expressionIdentifier.isEmpty) {
      throw const InvalidExpression('The first expression parameter must be an expression identifier.');
    }
    // interpret start with variable as shorthand for coalesce
    if (expressionIdentifier[0] == r'$') {
      expression = _coalesce;
      parameters = rawExpression;
    }
    else {
      expression = _expressionMapping[expressionIdentifier];
      parameters = rawExpression.skip(1);
    }

    if (expression != null) {
      final substitutedParameters = _substituteVariables(parameters, substitutionCallback);
      return expression(substitutedParameters);
    }
    throw UnsupportedError('The expression "$expressionIdentifier" is not supported.');
  }


  Iterable<String> _substituteVariables(Iterable<dynamic> expressionParameters, SubstitutionCallback substitutionCallback) sync* {
    for (final arg in expressionParameters) {
      if (arg is String) {
        if (arg.isNotEmpty && arg[0] == r'$') {
          yield* substitutionCallback(arg.substring(1));
        }
        else {
          yield arg;
        }
      }
      else if (arg is Iterable) {
        // evaluate nested expressions recursively
        final result = evaluateExpression(arg, substitutionCallback);
        if (result != null) {
          yield result;
        }
      }
    }
  }
}

// expression functions

String? _join(Iterable<String> args) {
  if (args.isEmpty) {
    return null;
  }
  final delimiter = args.first;
  final values = args.skip(1);
  return values.isEmpty ? null : values.join(delimiter);
}

String? _concat(Iterable<String> args) {
  return args.isEmpty ? null : args.join();
}

String? _coalesce(Iterable<String> args) {
  return args.isEmpty ? null : args.first;
}

/// Concatenates exactly two values. If less or more values are given this returns null.

String? _couple(Iterable<String> args) {
  // manually iterate and count, since using length property is more expensive on the given iterable
  var i = 0;
  final buffer = StringBuffer();
  for (final arg in args) {
    buffer.write(arg);
    i++;
  }
  return (i != 2) ? null : buffer.toString();
}

/// Adds a given String to a target String for each time the target String length is less than a given width.
/// First arg is the padding String.
/// Second arg is the desired width. Positive values will prepend, negative values will append to the target String.
/// Third arg is the target String.

String? _pad(Iterable<String> args) {
  final iter = args.iterator;
  if (!iter.moveNext()) return null;

  final paddingString = iter.current;
  if (!iter.moveNext()) return null;

  final width = int.tryParse(iter.current);
  if (!iter.moveNext() || width == null) return null;

  final mainString = iter.current;

  return width.isNegative
    ? mainString.padRight(width.abs(), paddingString)
    : mainString.padLeft(width, paddingString);
}

/// Inserts a given String into a target String.
/// First arg is the insertion String.
/// Second arg is the position/index where the String should be inserted into the target String.
/// Negative positions are treated as insertions starting at the end of the String.
/// So -1 means insert before the last character of the target String.
/// If the index exceeds the length of the target String, it will be returned without any modifications.
/// Third arg is the target String.

String? _insert(Iterable<String> args) {
  final iter = args.iterator;
  if (!iter.moveNext()) return null;

  final insertionString = iter.current;
  if (!iter.moveNext()) return null;

  final position = int.tryParse(iter.current);
  if (!iter.moveNext() || position == null) return null;

  final mainString = iter.current;
  if (mainString.length < position.abs()) return mainString;

  final index = position.isNegative
    ? mainString.length + position
    : position;

  return mainString.replaceRange(index, index, insertionString);
}

/// Replaces a given Pattern (either String or RegExp) in a target String by a given replacement String.
/// First arg is the Pattern the target String should be matched against.
/// Second arg is the replacement String.
/// Third arg is the target String.

String? _replace(Iterable<String> args) {
  final iter = args.iterator;
  if (!iter.moveNext()) {
    return null;
  }
  final Pattern pattern;

  // parse RegExp from String
  if (iter.current.startsWith('/') && iter.current.endsWith('/')) {
    try {
      pattern = RegExp(iter.current.substring(1, iter.current.length - 1));
    }
    on FormatException {
      return null;
    }
  }
  else {
    pattern = iter.current;
  }
  if (!iter.moveNext()) return null;

  final replacementString = iter.current;
  if (!iter.moveNext()) return null;

  final mainString = iter.current;

  return mainString.replaceAll(pattern, replacementString);
}

/// Indicates that an expression is malformed.

class InvalidExpression implements Exception {
  final String message;
  const InvalidExpression(this.message);
}
