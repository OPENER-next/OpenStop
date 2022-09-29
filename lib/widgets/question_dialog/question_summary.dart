import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/osm_authenticated_user_provider.dart';

class QuestionSummary extends StatelessWidget {
  final List<String> questions;

  final List<String?> answers;

  final void Function(int index)? onJump;

  const QuestionSummary({
    required this.questions,
    required this.answers,
    this.onJump,
    Key? key
  })  :
    assert(questions.length == answers.length, 'Every question should have a corresponding answer.'),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      height: 1.3,
      fontSize: 20,
      fontWeight: FontWeight.bold
    );

    final userProvider = context.watch<OSMAuthenticatedUserProvider>();
    final userName = userProvider.isLoggedIn
      ? '${userProvider.authenticatedUser!.name} '
      : '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 20
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10
            ),
            child: Text(
              'Danke ${userName}für deine Antworten. \nBitte prüfe sie vor dem Hochladen nochmal.',
              style: textStyle
            )
          ),
          ..._buildEntries(),
        ],
      ),
    );
  }


  Iterable<Widget> _buildEntries() sync* {
    for (int i = 0, j = 0; i < questions.length; i++) {
      // filter unanswered questions
      // use this extra method instead of .where and .map to get access to the correct index
      if (answers[i] != null) {
        if (j > 0) {
          yield const Divider(
            height: 1,
            thickness: 1,
          );
        }
        j++;
        yield _buildEntry(i);
      }
    }
  }


  Widget _buildEntry(int index) {
    final question = questions[index];
    final answer = answers[index];

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => onJump?.call(index),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 15,
            right: 10
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chevron_left_rounded
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('$question:')
                ),
              ),
              Expanded(
                child: Text(
                  answer!,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ),
            ],
          )
        ),
      ),
    );
  }
}
