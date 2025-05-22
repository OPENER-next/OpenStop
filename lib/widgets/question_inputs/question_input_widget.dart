import 'dart:collection';

import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import '/widgets/question_inputs/bool_input.dart';
import '/widgets/question_inputs/duration_input.dart';
import '/widgets/question_inputs/list_input.dart';
import '/widgets/question_inputs/multi_list_input.dart';
import '/widgets/question_inputs/number_input.dart';
import '/widgets/question_inputs/string_input.dart';

/// The base widget for all question input fields.
/// It automatically rebuilds whenever its controller changes.
/// The controller should be used as the single source of truth when it comes to maintain the state.

abstract class QuestionInputWidget<D extends AnswerDefinition, T extends Answer>
    extends AnimatedWidget {
  /// The [QuestionInput] from which the view is constructed.

  final D definition;

  /// A controller holding the currently selected/entered [Answer].

  AnswerController<T> get controller => listenable as AnswerController<T>;

  const QuestionInputWidget({
    required this.definition,
    required AnswerController<T> controller,
    super.key,
  }) : super(listenable: controller);

  static QuestionInputWidget fromAnswerDefinition<A extends Answer>({
    required AnswerDefinition definition,
    required AnswerController<A> controller,
    Key? key,
  }) {
    switch (definition.runtimeType) {
      case const (StringAnswerDefinition):
        return StringInput(
          definition: definition as StringAnswerDefinition,
          controller: controller as AnswerController<StringAnswer>,
          key: key,
        );
      case const (NumberAnswerDefinition):
        return NumberInput(
          definition: definition as NumberAnswerDefinition,
          controller: controller as AnswerController<NumberAnswer>,
          key: key,
        );
      case const (DurationAnswerDefinition):
        return DurationInput(
          definition: definition as DurationAnswerDefinition,
          controller: controller as AnswerController<DurationAnswer>,
          key: key,
        );
      case const (BoolAnswerDefinition):
        return BoolInput(
          definition: definition as BoolAnswerDefinition,
          controller: controller as AnswerController<BoolAnswer>,
          key: key,
        );
      case const (ListAnswerDefinition):
        return ListInput(
          definition: definition as ListAnswerDefinition,
          controller: controller as AnswerController<ListAnswer>,
          key: key,
        );
      case const (MultiListAnswerDefinition):
        return MultiListInput(
          definition: definition as MultiListAnswerDefinition,
          controller: controller as AnswerController<MultiListAnswer>,
          key: key,
        );
      default:
        throw TypeError();
    }
  }
}

/// A controller for question input widgets that holds their currently selected answer.
/// The controller can also be used to alter the input values from outside

class AnswerController<T extends Answer> extends ChangeNotifier {
  T? _answer;

  AnswerController({
    T? initialAnswer,
  }) : _answer = initialAnswer;

  T? get answer => _answer;

  set answer(T? value) {
    if (value != _answer && !isDisposed) {
      final previousState = state;
      _answer = value;
      final newState = state;

      if (previousState != newState) {
        _notifyStatusListeners(newState);
      }
      notifyListeners();
    }
  }

  void clear() {
    answer = null;
  }

  bool get isEmpty => _answer == null;

  bool get isNotEmpty => !isEmpty;

  bool get hasValidAnswer => _answer?.isValid == true;

  AnswerStatus get state {
    if (isEmpty) {
      return AnswerStatus.empty;
    } else if (hasValidAnswer) {
      return AnswerStatus.valid;
    }
    return AnswerStatus.invalid;
  }

  final _statusListeners = HashSet<AnswerStatusListener>();

  /// Calls listener every time the answer status changes.
  ///
  /// The same listener can only be added once.
  ///
  /// Returns true if the listener was not already registered.
  bool addStatusListener(AnswerStatusListener listener) {
    return _statusListeners.add(listener);
  }

  /// Stops calling the listener every time the answer status changes.
  ///
  /// Returns true if the listener was not already unregistered.
  bool removeStatusListener(AnswerStatusListener listener) {
    return _statusListeners.remove(listener);
  }

  void _notifyStatusListeners(AnswerStatus newState) {
    for (final listener in _statusListeners) {
      listener(newState);
    }
  }

  static AnswerController fromType<T extends Answer>({
    required Type type,
    T? initialAnswer,
  }) {
    switch (type) {
      case const (BoolAnswerDefinition):
        return AnswerController<BoolAnswer>(initialAnswer: initialAnswer as BoolAnswer?);
      case const (NumberAnswerDefinition):
        return AnswerController<NumberAnswer>(initialAnswer: initialAnswer as NumberAnswer?);
      case const (StringAnswerDefinition):
        return AnswerController<StringAnswer>(initialAnswer: initialAnswer as StringAnswer?);
      case const (ListAnswerDefinition):
        return AnswerController<ListAnswer>(initialAnswer: initialAnswer as ListAnswer?);
      case const (DurationAnswerDefinition):
        return AnswerController<DurationAnswer>(initialAnswer: initialAnswer as DurationAnswer?);
      case const (MultiListAnswerDefinition):
        return AnswerController<MultiListAnswer>(initialAnswer: initialAnswer as MultiListAnswer?);
      default:
        throw TypeError();
    }
  }

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _statusListeners.clear();
    super.dispose();
    _isDisposed = true;
  }
}

typedef AnswerStatusListener = void Function(AnswerStatus status);

enum AnswerStatus {
  invalid,
  empty,
  valid,
}
