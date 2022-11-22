import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_api/osm_api.dart';

import '/models/question.dart';
import '/view_models/osm_elements_provider.dart';
import '/view_models/osm_authenticated_user_provider.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/custom_snackbar.dart';
import '/widgets/question_inputs/question_input_widget.dart';
import '/widgets/question_dialog/question_summary.dart';
import '/utils/ui_utils.dart';
import 'question_list.dart';
import 'question_navigation_bar.dart';
import 'question_progress_bar.dart';
import 'question_sheet.dart';
import 'question_text_header.dart';


class QuestionDialog extends StatefulWidget {
  final int activeQuestionIndex;

  final List<Question> questions;
  final List<AnswerController> answers;

  final bool showSummary;

  final double maxHeightFactor;

  const QuestionDialog({
    required this.activeQuestionIndex,
    required this.questions,
    required this.answers,
    this.showSummary = false,
    this.maxHeightFactor = 0.75,
    Key? key
  }) :
    assert(questions.length == answers.length, 'Every question should have a corresponding answer controller.'),
    super(key: key);

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}


class _QuestionDialogState extends State<QuestionDialog> {
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final questionCount = widget.questions.length;
    final activeIndex = widget.showSummary ? questionCount : widget.activeQuestionIndex;
    final hasPrevious = activeIndex > 0;
    final hasAnyValidAnswer = widget.answers.any((controller) => controller.hasValidAnswer);

    // Use WillPopScope with "false" to prevent that back button closes app instead of Question Dialog
    return WillPopScope(
      onWillPop: () async {
        final questionnaire = context.read<QuestionnaireProvider>();
        questionnaire.close();
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
              maxHeight: MediaQuery.of(context).size.height * widget.maxHeightFactor,
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
                            questionCount,
                            _buildQuestion
                          ),
                          QuestionSheet(
                            elevate: widget.showSummary,
                            child: QuestionSummary(
                              questions: widget.questions.map(
                                (question) => question.name
                              ).toList(),
                              answers: widget.answers.map((controller) => controller.hasValidAnswer
                                ? controller.answer.toString()
                                : null
                              ).toList(),
                              onJump: _handleJump
                            )
                          )
                      ]
                    )
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
                              link: _layerLink,
                              child: AnimatedBuilder(
                                animation: widget.answers[widget.activeQuestionIndex],
                                builder: (context, child) {
                                  final answerController = widget.answers[widget.activeQuestionIndex];
                                  return QuestionNavigationBar(
                                    nextText: widget.showSummary
                                      ? null
                                      : answerController.hasValidAnswer ? 'Weiter' : 'Überspringen',
                                    backText: hasPrevious
                                      ? 'Zurück'
                                      : null,
                                    onNext: _handleNext,
                                    onBack: _handleBack,
                                  );
                                }
                              )
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
                    child: widget.showSummary && hasAnyValidAnswer
                      ? FloatingActionButton.large(
                        elevation: 0,
                        highlightElevation: 2,
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        onPressed: _handleSubmit,
                        child: Icon(
                          CommunityMaterialIcons.cloud_upload,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      )
                      : null
                  )
                )
              ],
            )
          )
        )
      ),
    );
  }


  Widget _buildQuestion(int index) {
    final question = widget.questions[index];
    final isActive = widget.activeQuestionIndex == index;

    return QuestionSheet(
      elevate: isActive,
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
              bottom: 30
            ),
            child: QuestionInputWidget.fromQuestionInput(
              definition: question.input,
              controller: widget.answers[index],
            )
          )
        ],
      ),
    );
  }


  void _handleBack() {
    // always unfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<QuestionnaireProvider>().previousQuestion();
  }


  void _handleNext() {
    // always unfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<QuestionnaireProvider>().nextQuestion();
  }


  void _handleJump(int index) {
    context.read<QuestionnaireProvider>().jumpToQuestion(index);
  }


  void _handleSubmit() async {
    final authenticationProvider = context.read<OSMAuthenticatedUserProvider>();

    if (authenticationProvider.isLoggedOut) {
      // wait till the user login process finishes
      await authenticationProvider.login();
    }

    // check if the user is successfully logged in
    // check if mounted to verify a context exists
    if (authenticationProvider.isLoggedIn && mounted) {
      final osmElementProvider = context.read<OSMElementProvider>();
      final questionnaire = context.read<QuestionnaireProvider>();

      // save state object for later use even if widget is unmounted
      final scaffold = ScaffoldMessenger.of(context);

      try {
        final osmElement = questionnaire.workingElement!;
        questionnaire.close();
        await osmElementProvider.upload(
          osmProxyElement: osmElement,
          authenticatedUser: authenticationProvider.authenticatedUser!,
          locale: Localizations.localeOf(context)
        );
        // on success remove stored questionnaire
        questionnaire.discard(osmElement);
        scaffold.showSnackBar(
          CustomSnackBar('Änderungen erfolgreich übertragen.')
        );
      }
      on OSMConnectionException {
        scaffold.showSnackBar(
          CustomSnackBar('Fehler: Keine Verbindung zum OSM-Server.')
        );
      }
      catch(e) {
        debugPrint(e.toString());
        scaffold.showSnackBar(
          CustomSnackBar('Unbekannter Fehler bei der Übertragung.')
        );
      }
    }
  }
}
