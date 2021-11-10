import 'package:flutter/material.dart';
import '/models/question_input.dart';
import '/widgets/question_inputs/string_input.dart';
import '/widgets/question_inputs/bool_input.dart';
import '/widgets/question_inputs/bool_number_input.dart';
import '/widgets/question_inputs/duration_input.dart';
import '/widgets/question_inputs/list_input.dart';
import '/widgets/question_inputs/number_input.dart';
import '/widgets/question_inputs/opening_hours_input.dart';


abstract class QuestionInputView extends StatefulWidget {

  /// The [QuestionInput] from which the view is constructed.

  final QuestionInput questionInput;


  /// A callback function with the applicable OSM tags constructed by the currently entered/selected value.

  final void Function(Map<String, String>)? onChange;


  const QuestionInputView(
    this.questionInput,
    { this.onChange, Key? key }
  ) : super(key: key);


  factory QuestionInputView.fromQuestionInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange }
  ) {
    switch (questionInput.type) {
      case 'Bool': return BoolInput(questionInput, onChange: onChange);
      case 'Number': return NumberInput(questionInput, onChange: onChange);
      case 'String': return StringInput(questionInput, onChange: onChange);
      case 'List': return ListInput(questionInput, onChange: onChange);
      case 'Duration': return DurationInput(questionInput, onChange: onChange);
      case 'OpeningHours': return OpeningHoursInput(questionInput, onChange: onChange);
      case 'BoolNumber': return BoolNumberInput(questionInput, onChange: onChange);
      default: throw TypeError();
    }
  }
}