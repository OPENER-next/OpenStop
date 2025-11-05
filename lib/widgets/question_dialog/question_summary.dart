import 'package:flutter/material.dart';

import '/l10n/app_localizations.g.dart';
import '/widgets/edge_feather.dart';
import 'question_sheet.dart';

class QuestionSummary extends StatelessWidget {
  final List<String> questions;

  final List<String> answers;

  final void Function(int index)? onJump;

  final String? userName;

  final bool elevate;

  const QuestionSummary({
    required this.questions,
    required this.answers,
    this.onJump,
    this.userName,
    this.elevate = true,
    super.key,
  }) : assert(
         questions.length == answers.length,
         'Every question should have a corresponding answer.',
       );

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    const horizontalPadding = 20.0;

    return QuestionSheet(
      active: elevate,
      header: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 10,
        ),
        child: Text(
          userName != null
              ? appLocale.questionnaireSummaryDedicatedMessage(userName!)
              : appLocale.questionnaireSummaryUndedicatedMessage,
          style: const TextStyle(
            height: 1.3,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: EdgeFeather(
        edges: const EdgeInsets.only(top: 10),
        child: Semantics(
          container: true,
          label: appLocale.semanticsSummary,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: questions.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemBuilder: _buildEntry,
            padding: const EdgeInsets.only(
              bottom: 25,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, int index) {
    final question = questions[index];
    final answer = answers[index];

    return Semantics(
      hint: AppLocalizations.of(context)!.semanticsReviewQuestion,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onJump?.call(index),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
              right: 10,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text('$question:'),
                  ),
                ),
                Expanded(
                  child: Text(
                    answer,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
