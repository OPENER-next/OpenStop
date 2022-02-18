import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/questionnaire.dart';
import '/models/answer.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/animated_progress_bar.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/widgets/question_dialog/question_summary.dart';
import 'question_list.dart';
import 'question_navigation_bar.dart';
import 'question_text_header.dart';


class QuestionDialog extends StatefulWidget {
  final int activeQuestionIndex;

  final List<QuestionnaireEntry> questionEntries;

  final double maxHeightFactor;

  const QuestionDialog({
    required this.activeQuestionIndex,
    required this.questionEntries,
    required this.maxHeightFactor,
    Key? key
  }) : super(key: key);

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}


class _QuestionDialogState extends State<QuestionDialog> {
  Answer? _answer;

  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.questionEntries.length;
    final activeIndex = widget.activeQuestionIndex + (_isFinished ? 1 : 0);
    final hasPrevious = activeIndex > 0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: widget.maxHeightFactor,
        child: Column(
          children: [
            Flexible(
              child: QuestionList(
                index: activeIndex,
                children: [
                  ...List<Widget>.generate(
                    questionCount,
                    _buildQuestion,
                    growable: false
                  ),
                  const QuestionSummary()
                ]
              )
            ),
            AnimatedProgressBar(
              minHeight: 1,
              color: Theme.of(context).colorScheme.primary,
              value: activeIndex / questionCount,
              // cannot use transparent color here otherwise the map widget behind will become slightly visible
              backgroundColor: const Color(0xFFEEEEEE)
            ),
            QuestionNavigationBar(
              nextText: _isFinished ? null : _answer != null ? 'Weiter' : 'Überspringen',
              backText: hasPrevious ? 'Zurück' : null,
              onNext: _handleNext,
              onBack: _handleBack,
            )
          ],
        )
      )
    );
  }


  Widget _buildQuestion(int index) {
    final questionnaireEntry = widget.questionEntries[index];

    return ColoredBox(
      key: ValueKey(questionnaireEntry.question),
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestionTextHeader(
              question: questionnaireEntry.question.question,
              details: questionnaireEntry.question.description,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
                bottom: 30
              ),
              child: QuestionInputView.fromQuestionInput(
                questionnaireEntry.question.input,
                onChange: _handleChange
              )
            )
          ],
        )
      )
    );
  }


  void _handleChange(Answer? answer) {
    if (answer != _answer) {
      setState(() {
        _answer = answer;
      });
    }
  }


  void _handleBack() {
    _update(goBack: true);
  }


  void _handleNext() {
    _update();
  }


  void _update({bool goBack = false}) {
    final questionnaire = context.read<QuestionnaireProvider>();
    debugPrint('Previous Answer: ${_answer?.answer}');
    questionnaire.update(_answer);
    // first update the questionnaire then check the new values
    final isLast = questionnaire.activeIndex! == questionnaire.length! - 1;

    if (!goBack && isLast) {
      if (!_isFinished) {
        setState(() {
          _isFinished = isLast;
        });
      }
    }
    else if (_isFinished) {
      setState(() {
        _isFinished = false;
      });
    }
    else {
      goBack ? questionnaire.previous() : questionnaire.next();
    }

    _answer = questionnaire.activeEntry?.answer;
    debugPrint('Current Answer: ${_answer?.answer}');
    // always unfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
