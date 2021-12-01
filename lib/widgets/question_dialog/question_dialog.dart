import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/questionnaire_provider.dart';
import '/widgets/question_inputs/question_input_view.dart';
import 'question_list.dart';
import 'question_input_bubble.dart';
import 'question_navigation_bubble.dart';
import 'question_text_bubble.dart';

class QuestionDialog extends StatefulWidget {
  QuestionDialog();

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}


class _QuestionDialogState extends State<QuestionDialog> {
  @override
  Widget build(BuildContext context) {
    final questionnaire = context.watch<QuestionnaireProvider>();

    return AnimatedSwitcher(
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
            children: [
              Expanded(
                child: ClipRect(
                  // this is required to clip the scrollable bubbles behind the navigation bubbles
                  // this needs to be put outside of the paddings since these affect the clipper starting point
                  clipper: ViewClipper(
                    size: MediaQuery.of(context).size,
                    insets: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 55)
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10 + MediaQuery.of(context).padding.top
                      ),
                      child: QuestionList(
                        index: questionnaire.activeIndex!,
                        children: List.generate(
                          questionnaire.length!,
                          (index) {
                            final questionnaireEntry = questionnaire.entries![index];

                            return QuestionListEntry(
                              key: ValueKey(questionnaireEntry.question),
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    QuestionTextBubble(
                                      question: questionnaireEntry.question.question,
                                      details: questionnaireEntry.question.description,
                                    ),
                                    QuestionInputBubble(
                                      child: QuestionInputView.fromQuestionInput(
                                        questionnaireEntry.question.input,
                                        onChange: null
                                      )
                                    ),
                                  ],
                                )
                              )
                            );
                          },
                          growable: false
                        )
                      )
                    )
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 10 + MediaQuery.of(context).padding.bottom
                ),
                child: QuestionNavigationBubble(
                  onConfirm: _handleConfirm,
                  onBack: _handleBack,
                  onSkip: _handleSkip,
                )
              )
            ],
        )
    );
  }


  void _handleBack() {
    final questionnaire = context.read<QuestionnaireProvider>();
    questionnaire.previous();
  }


  void _handleSkip() {
    final questionnaire = context.read<QuestionnaireProvider>();
    questionnaire.next();
  }


  void _handleConfirm() {
    final questionnaire = context.read<QuestionnaireProvider>();
    questionnaire.next();
  }
}


/// Clips the given size minus any provided insets.

class ViewClipper extends CustomClipper<Rect> {
  final Size size;

  final EdgeInsets insets;

  ViewClipper({
    required this.size,
    this.insets = EdgeInsets.zero
  });

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0 + insets.left,
      0 + insets.top,
      this.size.width - insets.right,
      this.size.height - insets.bottom
    );
  }

  @override
  bool shouldReclip(ViewClipper oldClipper) {
    return (oldClipper.size != size || oldClipper.insets != insets);
  }
}