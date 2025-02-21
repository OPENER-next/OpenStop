import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/l10n/app_localizations.g.dart';
import '/models/question_catalog/question_definition.dart';
import '/utils/ui_utils.dart';
import '/view_models/home_view_model.dart';
import '/widgets/edge_feather.dart';
import '/widgets/question_dialog/question_summary.dart';
import '/widgets/question_inputs/question_input_widget.dart';
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
    super.key
  }) :
    assert(questions.length == answers.length, 'Every question should have a corresponding answer controller.');

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
    String? nextText;
    String? nextTextSemantics;

    if (!showSummary) {
      if (!hasNextQuestion) {
        nextTextSemantics = appLocale.semanticsFinishQuestionnaireButton;
        nextText = appLocale.finish;
      } else if (currentIsValidAnswer) {
        nextTextSemantics = appLocale.semanticsNextQuestionButton;
        nextText = appLocale.next;
      } else {
        nextTextSemantics = appLocale.semanticsSkipQuestionButton;
        nextText = appLocale.skip;
      }
    }

    // Use WillPopScope with "false" to prevent that back button closes app instead of Question Dialog
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => viewModel.closeQuestionnaire(),
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
                          QuestionSummary(
                            elevate: showSummary,
                            questions: questions
                              .whereIndexed((index, _) => answers[index].hasValidAnswer)
                              .map((question) => question.name)
                              .toList(growable: false),
                            answers: answers
                              .where((controller) => controller.hasValidAnswer)
                              .map((controller) => controller.answer!.toLocaleString(appLocale))
                              .toList(growable: false),
                            onJump: (index) {
                              // we get the filtered index so we need to convert it to the original index
                              // otherwise we jump to the wrong question/answer
                              final originalIndex = answers
                                .mapIndexed((i, controller) => controller.hasValidAnswer ? i : -1)
                                .where((i) => i != -1)
                                .elementAt(index);
                              viewModel.jumpToQuestion(originalIndex);
                            },
                            userName: viewModel.userName,
                          ),
                        ],
                      ),
                    ),
                    // Clip widget shadow vertically to prevent overlapping
                    ClipRect(
                      clipper: ClipSymmetric(
                        mediaQuery: MediaQuery.of(context)
                      ),
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
                              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            CompositedTransformTarget(
                              link: layerLink,
                              child: QuestionNavigationBar(
                                nextTextSemantics: nextTextSemantics,
                                nextText: nextText,
                                backText: hasPreviousQuestion
                                  ? appLocale.back
                                  : null,
                                backTextSemantics: appLocale.semanticsBackQuestionButton,
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
                          Icons.cloud_upload_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          semanticLabel: appLocale.semanticsUploadQuestionsButton,
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
    final isActive = !showSummary && activeQuestionIndex == index;

    return QuestionSheet(
      active: isActive,
      // important otherwise animation will fail
      key: ValueKey(question),
      header: QuestionTextHeader(
        question: question.question,
        details: question.description,
        images: question.images,
      ),
      body: EdgeFeather(
        edges: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 10,
            right: 20,
            left: 20,
            bottom: 25,
          ),
          child: QuestionInputWidget.fromAnswerDefinition(
            definition: question.answer,
            controller: answers[index],
          ),
        ),
      ),
    );
  }
}
