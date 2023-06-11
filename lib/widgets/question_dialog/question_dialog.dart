import 'package:flutter_mvvm_architecture/base.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/view_models/home_view_model.dart';
import '/models/question_catalog/question_definition.dart';
import '/widgets/question_inputs/question_input_widget.dart';
import '/widgets/question_dialog/question_summary.dart';
import '/utils/ui_utils.dart';
import 'question_list.dart';
import 'question_navigation_bar.dart';
import 'question_progress_bar.dart';
import 'question_sheet.dart';
import 'question_text_header.dart';


class QuestionDialog extends ViewFragment<HomeViewModel> {
  final int activeQuestionIndex;

  final List<QuestionDefinition> questions;
  final List<AnswerController> answers;

  final bool showSummary;

  const QuestionDialog({
    required this.activeQuestionIndex,
    required this.questions,
    required this.answers,
    this.showSummary = false,
    Key? key
  }) :
    assert(questions.length == answers.length, 'Every question should have a corresponding answer controller.'),
    super(key: key);

  @override
  Widget build(BuildContext context, viewModel) {
    final layerLink = LayerLink();

    final questionCount = questions.length;
    final activeIndex = showSummary ? questionCount : activeQuestionIndex;
    final hasPreviousQuestion = activeIndex > 0;
    final hasNextQuestion = activeQuestionIndex < questionCount - 1;

    final currentIsValidAnswer = answers[activeQuestionIndex].hasValidAnswer;
    final hasAnyValidAnswer = answers.any((controller) => controller.hasValidAnswer);

    final appLocale = AppLocalizations.of(context)!;

    // Use WillPopScope with "false" to prevent that back button closes app instead of Question Dialog
    return WillPopScope(
      onWillPop: () async {
        viewModel.closeQuestionnaire();
        return false;
      },
      child: SafeArea(
        minimum: MediaQuery.of(context).viewInsets,
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * viewModel.questionDialogMaxHeightFactor,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Flexible(
                      child: QuestionList(
                        index: activeIndex,
                        children: [
                          ...Iterable<Widget>.generate(
                            questionCount, _buildQuestion,
                          ),
                          QuestionSheet(
                            elevate: showSummary,
                            child: QuestionSummary(
                              questions: questions.map(
                                (question) => question.name
                              ).toList(),
                              answers: answers.map((controller) => controller.hasValidAnswer
                                ? controller.answer.toString()
                                : null
                              ).toList(),
                              onJump: viewModel.jumpToQuestion,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Clip widget shadow vertically to prevent overlapping
                  ClipRect(
                    clipper: const ClipSymmetric(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: kElevationToShadow[4],
                      ),
                        child: Column(
                          children: [
                            QuestionProgressBar(
                              minHeight: 1,
                              color: Theme.of(context).colorScheme.primary,
                              value: activeIndex / questionCount,
                              backgroundColor: Theme.of(context).colorScheme.onBackground,
                            ),
                            CompositedTransformTarget(
                              link: layerLink,
                              child: QuestionNavigationBar(
                                nextText: showSummary
                                  ? null
                                  : !hasNextQuestion
                                    ? appLocale.finish
                                    : currentIsValidAnswer
                                      ? appLocale.next
                                      : appLocale.skip,
                                backText: hasPreviousQuestion
                                  ? appLocale.back
                                  : null,
                                onNext: hasNextQuestion || hasAnyValidAnswer
                                  ? viewModel.goToNextQuestion
                                  : null,
                                onBack: viewModel.goToPreviousQuestion,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // extra stack is necessary because the CompositedTransformFollower widget
                // will take up the space where it was originally placed
                CompositedTransformFollower(
                  link: layerLink,
                  targetAnchor: Alignment.topCenter,
                  followerAnchor: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: showSummary && hasAnyValidAnswer
                      ? FloatingActionButton.large(
                        elevation: 0,
                        highlightElevation: 2,
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: viewModel.submitQuestionnaire,
                        child: Icon(
                          MdiIcons.cloudUpload,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                      : null
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuestion(int index) {
    final question = questions[index];
    final isActive = activeQuestionIndex == index;

    return QuestionSheet(
      elevate: isActive,
      // important otherwise animation will fail
      key: ValueKey(question),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionTextHeader(
            question: question.question,
            details: question.description,
            images: question.images,
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              bottom: 30,
            ),
            child: QuestionInputWidget.fromAnswerDefinition(
              definition: question.answer,
              controller: answers[index],
            ),
          ),
        ],
      ),
    );
  }
}
