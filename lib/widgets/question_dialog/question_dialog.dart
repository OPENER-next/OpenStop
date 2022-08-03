import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_api/osm_api.dart';

import '/models/questionnaire.dart';
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

  final Map<QuestionnaireEntry, AnswerController> _answerControllerMapping = {};

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  @override
  void didUpdateWidget(covariant QuestionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateControllers();
  }

  /// Maps all QuestionnaireEntries to typed AnswerControllers

  void _updateControllers() {
    // remove obsolete text controllers
    _answerControllerMapping.removeWhere((key, value) => !widget.questionEntries.contains(key));
    // add new text controllers for each entry if none already exists
    for (final questionEntry in widget.questionEntries) {
      _answerControllerMapping.putIfAbsent(
        questionEntry,
        () => AnswerController.fromType(
          type: questionEntry.question.input.type,
          initialAnswer: questionEntry.answer
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final activeQuestionnaireEntry = widget.questionEntries[widget.activeQuestionIndex];
    final questionCount = widget.questionEntries.length;
    final activeIndex = widget.activeQuestionIndex + (_isFinished ? 1 : 0);
    final hasPrevious = activeIndex > 0;
    final hasAnyAnswer = widget.questionEntries.any((entry) => entry.answer != null);

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
                            elevate: _isFinished,
                            child: QuestionSummary(
                              questionEntries: widget.questionEntries,
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
                                    animation: _answerControllerMapping[activeQuestionnaireEntry]!,
                                    builder: (context, child) {
                                      final answer = _answerControllerMapping[activeQuestionnaireEntry]?.answer;
                                      return QuestionNavigationBar(
                                        nextText: _isFinished ? null : answer != null ? 'Weiter' : 'Überspringen',
                                        backText: hasPrevious ? 'Zurück' : null,
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
                    child: _isFinished && hasAnyAnswer
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
    final questionnaireEntry = widget.questionEntries[index];
    final isActive = widget.activeQuestionIndex == index;

    return QuestionSheet(
      elevate: isActive,
      key: ValueKey(questionnaireEntry.question),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionTextHeader(
            question: questionnaireEntry.question.question,
            details: questionnaireEntry.question.description,
            images: questionnaireEntry.question.images,
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              bottom: 30
            ),
            child: QuestionInputWidget.fromQuestionInput(
              definition: questionnaireEntry.question.input,
              controller: _answerControllerMapping[questionnaireEntry]!,
            )
          )
        ],
      ),
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
        scaffold.showSnackBar(
          CustomSnackBar('Änderungen erfolgreich übertragen.')
        );
      }
      on OSMConnectionException {
        scaffold.showSnackBar(
          CustomSnackBar('Fehler: Kein Verbindung zum OSM-Server.')
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

  void _update() {
    final questionnaire = context.read<QuestionnaireProvider>();

    final activeQuestionEntry = widget.questionEntries[widget.activeQuestionIndex];
    final answerController = _answerControllerMapping[activeQuestionEntry]!;

    if (answerController.answer?.isValid == false) {
      questionnaire.update(null);
    }
    else {
      questionnaire.update(answerController.answer);
    }
    debugPrint('Previous Answer: ${answerController.answer}');
    // always unfocus the current node to close all onscreen keyboards
    FocusManager.instance.primaryFocus?.unfocus();
  }


  @override
  void dispose() {
    _answerControllerMapping.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
