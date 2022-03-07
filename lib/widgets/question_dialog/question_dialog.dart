import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/questionnaire.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/animated_progress_bar.dart';
import '/widgets/question_inputs/question_input_widget.dart';
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
  var _isFinished = false;

  final _layerLink = LayerLink();

  final _answerController = AnswerController();

  @override
  void initState() {
    super.initState();
    _answerController.answer = widget.questionEntries[widget.activeQuestionIndex].answer;
  }

  @override
  void didUpdateWidget(covariant QuestionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _answerController.answer = widget.questionEntries[widget.activeQuestionIndex].answer;
  }

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.questionEntries.length;
    final activeIndex = widget.activeQuestionIndex + (_isFinished ? 1 : 0);
    final hasPrevious = activeIndex > 0;
    final hasAnyAnswer = widget.questionEntries.any((entry) => entry.answer != null);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: widget.maxHeightFactor,
          child: Stack(
            children: [
              Column(
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
                        QuestionSummary(
                          questionEntries: widget.questionEntries,
                          onJump: _handleJump
                        )
                      ]
                    )
                  ),
                  AnimatedProgressBar(
                    minHeight: 1,
                    color: Theme.of(context).colorScheme.primary,
                    value: activeIndex / questionCount,
                    // cannot use transparent color here otherwise the map widget behind will become slightly visible
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: AnimatedBuilder(
                      animation: _answerController,
                      builder: (context, child) {
                        return QuestionNavigationBar(
                          nextText: _isFinished ? null : _answerController.answer != null ? 'Weiter' : 'Überspringen',
                          backText: hasPrevious ? 'Zurück' : null,
                          onNext: _handleNext,
                          onBack: _handleBack,
                        );
                      }
                    )
                  ),
                ],
              ),
              // extra stack is necessary because the CompositedTransformFollower widget
              // will take up the space where it was originally placed
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: _isFinished && hasAnyAnswer
                    ? FloatingActionButton.large(
                      elevation: 0,
                      highlightElevation: 2,
                      shape: const CircleBorder(),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        CommunityMaterialIcons.check_bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {},
                    )
                    : null
                )
              )
            ],
          )
        )
      )
    );
  }


  Widget _buildQuestion(int index) {
    final questionnaireEntry = widget.questionEntries[index];

    return ColoredBox(
      key: ValueKey(questionnaireEntry.question),
      color: Theme.of(context).colorScheme.surface,
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
              child: QuestionInputWidget.fromQuestionInput(
                questionnaireEntry.question.input,
                controller: _answerController,
              )
            )
          ],
        )
      )
    );
  }


  void _handleBack() {
    final questionnaire = context.read<QuestionnaireProvider>();

    _update();

    if (_isFinished) {
      setState(() {
        _isFinished = false;
      });
    }
    else {
      questionnaire.previous();
    }
  }


  void _handleNext() {
    final questionnaire = context.read<QuestionnaireProvider>();
    // first update the questionnaire then check the new values
    _update();

    final isLast = questionnaire.activeIndex! == questionnaire.length! - 1;

    if (isLast) {
      if (!_isFinished) {
        setState(() {
          _isFinished = true;
        });
      }
    }
    else {
      questionnaire.next();
    }
  }


  void _handleJump(int index) {
    final questionnaire = context.read<QuestionnaireProvider>();

    if (_isFinished) {
      setState(() {
        _isFinished = false;
      });
    }

    questionnaire.jumpTo(index);
  }


  void _update() {
    final questionnaire = context.read<QuestionnaireProvider>();
    questionnaire.update(_answerController.answer);
    debugPrint('Previous Answer: ${_answerController.answer}');
    // always unfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
