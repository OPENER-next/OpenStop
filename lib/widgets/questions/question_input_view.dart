import 'package:flutter/material.dart';
import '/models/question_input.dart';
import '/widgets/questions/string_input_view.dart';
import '/widgets/questions/bool_input_view.dart';
import '/widgets/questions/bool_number_input_view.dart';
import '/widgets/questions/duration_input_view.dart';
import '/widgets/questions/list_input_view.dart';
import '/widgets/questions/number_input_view.dart';
import '/widgets/questions/opening_hours_input_view.dart';


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
      case 'Bool': return BoolInputView(questionInput, onChange: onChange);
      case 'Number': return NumberInputView(questionInput, onChange: onChange);
      case 'String': return StringInputView(questionInput, onChange: onChange);
      case 'List': return ListInputView(questionInput, onChange: onChange);
      case 'Duration': return DurationInputView(questionInput, onChange: onChange);
      case 'OpeningHours': return OpeningHoursInputView(questionInput, onChange: onChange);
      case 'BoolNumber': return BoolNumberInputView(questionInput, onChange: onChange);
      default: throw TypeError();
    }
  }
}