import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/questionnaire_provider.dart';

class QuestionSummary extends StatefulWidget {
  const QuestionSummary({Key? key}) : super(key: key);

  @override
  State<QuestionSummary> createState() => _QuestionSummaryState();
}


class _QuestionSummaryState extends State<QuestionSummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: ElevatedButton(
          child: const Text('Hochladen'),
          onPressed: _triggerUpload,
        ),
      )
    );
  }


  void _triggerUpload() {
    final questionnaire = context.read<QuestionnaireProvider>();
    questionnaire.discard();
  }
}
