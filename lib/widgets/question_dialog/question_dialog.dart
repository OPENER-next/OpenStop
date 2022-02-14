import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/answer.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/animated_progress_bar.dart';
import '/widgets/question_inputs/question_input_view.dart';
import 'question_list.dart';
import 'question_navigation_bubble.dart';
import 'question_text_bubble.dart';


class QuestionDialog extends StatefulWidget {

  const QuestionDialog({Key? key}) : super(key: key);

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}


class _QuestionDialogState extends State<QuestionDialog> {

  final _answer = ValueNotifier<Answer?>(null);

  @override
  Widget build(BuildContext context) {
    final questionnaire = context.watch<QuestionnaireProvider>();

    return ValueListenableProvider<Answer?>.value(
      value: _answer,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.ease,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            )
          );
        },
        child: !questionnaire.hasEntries
          ? null
          : Column(
            // add key so changes of the underlying questionnaire will be animated
            key: questionnaire.key,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5
                ),
                child: QuestionList(
                  index: questionnaire.activeIndex!,
                  children: List.generate(
                    questionnaire.length!,
                    (index) {
                      final questionnaireEntry = questionnaire.entries![index];

                      return ColoredBox(
                        key: ValueKey(questionnaireEntry.question),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QuestionTextBubble(
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
                    },
                    growable: false
                  )
                )
              ),
              AnimatedProgressBar(
                minHeight: 1,
                color: Theme.of(context).colorScheme.primary,
                value: (questionnaire.activeIndex!) / questionnaire.length!,
                // cannot use transparent color here otherwise the map widget behind will become slightly visible
                backgroundColor: const Color(0xFFEEEEEE)
              ),
              QuestionNavigationBubble(
                onNext: _handleNext,
                onBack: _handleBack,
              )
            ],
          )
        )
    );
  }


  // ignore: use_setters_to_change_properties
  void _handleChange(Answer? answer) {
    _answer.value = answer;
  }


  void _handleBack() {
    _update(goBack: true);
  }


  void _handleNext() {
    _update();
  }


  void _update({bool goBack = false}) {
    final questionnaire = context.read<QuestionnaireProvider>();
    debugPrint('Previous Answer: ${_answer.value?.answer}');
    questionnaire.update(_answer.value);
    goBack ? questionnaire.previous() : questionnaire.next();
    _answer.value = questionnaire.activeEntry?.answer;
    debugPrint('Current Answer: ${_answer.value?.answer}');
    // always onfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
