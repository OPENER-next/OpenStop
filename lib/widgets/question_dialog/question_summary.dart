import 'package:flutter/material.dart';
import '/models/questionnaire.dart';

class QuestionSummary extends StatelessWidget {
  final List<QuestionnaireEntry> questionEntries;

  final void Function(int index)? onJump;

  const QuestionSummary({
    required this.questionEntries,
    this.onJump,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAnyAnswer = questionEntries.any((entry) => entry.answer != null);
    const textStyle = TextStyle(
      height: 1.3,
      fontSize: 20,
      fontWeight: FontWeight.bold
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 20
      ),
      child: !hasAnyAnswer
        ? const Padding(
          padding: EdgeInsets.only(
            bottom: 10
          ),
          child: Text(
            'Endstation. Weitere Fragen gibt es nicht.\nBisher hast du noch keine Frage beantwortet.',
            style: textStyle
          )
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                bottom: 10
              ),
              child: Text(
                'Vielen Dank für deine Antworten. Bitte überprüfe sie vor dem Hochladen noch einmal.',
                style: textStyle
              )
            ),
            Material(
              type: MaterialType.transparency,
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground
                  )
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const <int, TableColumnWidth>{
                  0: FractionColumnWidth(0.1),
                  1: FractionColumnWidth(0.65),
                  2: FractionColumnWidth(0.25)
                },
                children: _buildTableEntries()
              )
            ),
          ],
        ),
      );
  }


  List<TableRow>_buildTableEntries() {
    final rows = <TableRow>[];
    for (int i = 0; i < questionEntries.length; i++) {
      // filter unanswered questions
      // use this extra method instead of .where and .map to get access to the correct index
      if (questionEntries[i].answer != null) {
        rows.add(_buildTableEntry(i));
      }
    }
    return rows;
  }


  TableRow _buildTableEntry(int index) {
    final entry = questionEntries[index];
    void onTap() => onJump?.call(index);

    return TableRow(
      children: [
        TableRowInkWell(
          onTap: onTap,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.chevron_left_rounded
            )
          )
        ),
        TableRowInkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text('${entry.question.name}:'),
          )
        ),
        TableRowInkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10
            ),
            child: Text(
              entry.answer.toString(),
              textAlign: TextAlign.right,
            ),
          )
        ),
      ],
    );
  }
}
