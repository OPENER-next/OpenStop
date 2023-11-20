/// Function to substitute variables found in an expression.
/// Returns zero to multiple values for a given variable.

typedef SubstitutionCallback = Iterable<String> Function(String variableName);

/// Expressions must not throw an error.
/// Instead they return a meaningful result if possible or null.

typedef ExpressionCallback = Iterable<String> Function(Iterable<String>);


/// A utility class that can be mixed in to get expression support wherever needed.
///
/// Expressions are defined as an array where the first item is the expression identifier/name,
/// while the other items are strings or nested expressions (nested array) which will be passed
/// as arguments/parameters to the specific expression function.
///
/// Expressions can also contain variables which are marked with a `$` symbol at the start.
/// Variables and expressions may resolve into multiple values.
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

  static const _expressionMapping = <String, ExpressionCallback>{
    'JOIN': _join,
    'CONCAT': _concat,
    'COALESCE': _coalesce,
    'COUPLE': _couple,
    'PAD': _pad,
    'INSERT': _insert,
    'REPLACE': _replace,
  };

  /// Substitutes any variables (marked by $) and then executes the given expression array.

  Iterable<String> evaluateExpression(Iterable<dynamic> rawExpression, SubstitutionCallback substitutionCallback) {
    if (rawExpression.isEmpty) {
      throw const InvalidExpression('An expression list must not be empty.');
    }

    final expressionIdentifier = rawExpression.first;
    final ExpressionCallback? expression;
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
        yield* evaluateExpression(arg, substitutionCallback);
      }
    }
  }
}

// expression functions

Iterable<String> _join(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final delimiter = iter.current;

  if (!iter.moveNext()) return;
  final buffer = StringBuffer(iter.current);

  while (iter.moveNext()) {
    buffer
      ..write(delimiter)
      ..write(iter.current);
  }
  yield buffer.toString();
}

/// Returns the concatenation of all inputs.

Iterable<String> _concat(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final buffer = StringBuffer(iter.current);

  while (iter.moveNext()) {
    buffer.write(iter.current);
  }
  yield buffer.toString();
}

/// Returns the first input and discards the others.

Iterable<String> _coalesce(Iterable<String> args) sync* {
  final iter = args.iterator;
  if (iter.moveNext()) yield iter.current;
}

/// Concatenates exactly two values. If less or more values are given this returns empty.

Iterable<String> _couple(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final firstString = iter.current;

  if (!iter.moveNext()) return;
  final secondString = iter.current;

  // empty return when more then 2 values are provided
  if (iter.moveNext()) return;

  yield firstString + secondString;
}

/// Adds a given String to a target String for each time the target String length is less than a given width.
/// First arg is the padding String.
/// Second arg is the desired width. Positive values will prepend, negative values will append to the target String.
/// Any following args are the target Strings.

Iterable<String> _pad(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final paddingString = iter.current;

  if (!iter.moveNext()) return;
  final width = int.tryParse(iter.current);

  if (width == null) return;

  if (width.isNegative) {
    while (iter.moveNext()) {
      yield iter.current.padRight(width.abs(), paddingString);
    }
  }
  else {
    while (iter.moveNext()) {
      yield iter.current.padLeft(width, paddingString);
    }
  }
}

/// Inserts a given String into a target String.
/// First arg is the insertion String.
/// Second arg is the position/index where the String should be inserted into the target String.
/// Negative positions are treated as insertions starting at the end of the String.
/// So -1 means insert before the last character of the target String.
/// If the index exceeds the length of the target String, it will be returned without any modifications.
/// Any following args are the target Strings.

Iterable<String> _insert(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final insertionString = iter.current;

  if (!iter.moveNext()) return;
  final position = int.tryParse(iter.current);

  if (position == null) return;

  while (iter.moveNext()) {
    final mainString = iter.current;
    if (mainString.length < position.abs()) {
      yield mainString;
    }
    else {
      final index = position.isNegative
        ? mainString.length + position
        : position;
      yield mainString.replaceRange(index, index, insertionString);
    }
  }
}

/// Replaces a given Pattern (either String or RegExp) in a target String by a given replacement String.
/// First arg is the Pattern the target String should be matched against.
/// Second arg is the replacement String.
/// Any following args are the target Strings.

Iterable<String> _replace(Iterable<String> args) sync* {
  final iter = args.iterator;

  if (!iter.moveNext()) return;
  final Pattern pattern;

  // parse RegExp from String
  if (iter.current.startsWith('/') && iter.current.endsWith('/')) {
    try {
      pattern = RegExp(iter.current.substring(1, iter.current.length - 1));
    }
    on FormatException {
      return;
    }
  }
  else {
    pattern = iter.current;
  }

  if (!iter.moveNext()) return;
  final replacementString = iter.current;

  while (iter.moveNext()) {
    yield iter.current.replaceAll(pattern, replacementString);
  }
}


/// Indicates that an expression is malformed.

class InvalidExpression implements Exception {
  final String message;
  const InvalidExpression(this.message);
}
