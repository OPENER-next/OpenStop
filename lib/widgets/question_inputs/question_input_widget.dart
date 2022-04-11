import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_input.dart';
import '/widgets/question_inputs/string_input.dart';
import '/widgets/question_inputs/bool_input.dart';
import '/widgets/question_inputs/duration_input.dart';
import '/widgets/question_inputs/list_input.dart';
import '/widgets/question_inputs/number_input.dart';
import '/widgets/question_inputs/opening_hours_input.dart';


/// The base widget for all question input fields.
/// It automatically rebuilds whenever its controller changes.
/// The controller should be used as the single source of truth when it comes to maintain the state.

abstract class QuestionInputWidget<T extends Answer> extends AnimatedWidget {

  /// The [QuestionInput] from which the view is constructed.

  final QuestionInput definition;


  /// A controller holding the currently selected/entered [Answer].

  AnswerController<T> get controller => listenable as AnswerController<T>;


  const QuestionInputWidget({
    required this.definition,
    required AnswerController<T> controller,
    Key? key
  }) : super(listenable: controller, key: key);


  static QuestionInputWidget fromQuestionInput<A extends Answer>({
    required QuestionInput definition,
    required AnswerController<A> controller,
    Key? key
  }) {
    switch (definition.type) {
      case 'Bool':
        return BoolInput(definition: definition, controller: controller as AnswerController<BoolAnswer>, key: key);
      case 'Number':
        return NumberInput(definition: definition, controller: controller as AnswerController<NumberAnswer>, key: key);
      case 'String':
        return StringInput(definition: definition, controller: controller as AnswerController<StringAnswer>, key: key);
      case 'List':
        return ListInput(definition: definition, controller: controller as AnswerController<ListAnswer>, key: key);
      case 'Duration':
        return DurationInput(definition: definition, controller: controller as AnswerController<DurationAnswer>, key: key);
      case 'OpeningHours':
        return OpeningHoursInput(definition: definition, controller: controller, key: key);
      default:
        return throw TypeError();
    }
  }
}


/// A controller for question input widgets that holds their currently selected answer.
/// The controller can also be used to alter the input values from outside

class AnswerController<T extends Answer> extends ChangeNotifier {
  T? _answer;

  AnswerController({
    T? initialAnswer
  }) : _answer = initialAnswer;


  T? get answer => _answer;

  set answer(T? value) {
    if (value != _answer) {
      _answer = value;
      notifyListeners();
    }
  }

  void clear() {
    if (_answer != null) {
      _answer = null;
      notifyListeners();
    }
  }

  get isEmpty => _answer == null;

  get isNotEmpty => !isEmpty;


  static AnswerController fromType<T extends Answer>({
    required String type,
    T? initialAnswer
  }) {
    switch (type) {
      case 'Bool':
        return AnswerController<BoolAnswer>(initialAnswer: initialAnswer as BoolAnswer?);
      case 'Number':
        return AnswerController<NumberAnswer>(initialAnswer: initialAnswer as NumberAnswer?);
      case 'String':
        return AnswerController<StringAnswer>(initialAnswer: initialAnswer as StringAnswer?);
      case 'List':
        return AnswerController<ListAnswer>(initialAnswer: initialAnswer as ListAnswer?);
      case 'Duration':
        return AnswerController<DurationAnswer>(initialAnswer: initialAnswer as DurationAnswer?);
      case 'OpeningHours':
        return AnswerController(initialAnswer: initialAnswer);
      default: throw TypeError();
    }
  }
}
