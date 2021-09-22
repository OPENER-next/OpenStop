import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import '/models/question.dart';
import '/widgets/questions/question_input_view.dart';
import '/widgets/triangle_down.dart';

class QuestionSheet extends StatefulWidget {
  final double initialSheetSize;

  final ValueNotifier<Question?> question;

  QuestionSheet({
    required this.question,
    this.initialSheetSize = 0.4
  });

  @override
  State<QuestionSheet> createState() => _QuestionSheetState();
}

class _QuestionSheetState extends State<QuestionSheet> {
  final sheetController = SheetController();

  Question? question;

  @override
  void initState() {
    super.initState();

    question = widget.question.value;

    widget.question.addListener(_handleQuestionChange);
  }


  @override
  Widget build(BuildContext context) {
    return question == null ? const SizedBox.shrink() : SlidingSheet(
      controller: sheetController,
      addTopViewPaddingOnFullscreen: true,
      elevation: 8,
      // since the background color is overlaid by the individual builders/widgets background colors
      // this color is only visible as the top padding behind the navigation bar
      // thus it should match the header color
      color: Theme.of(context).colorScheme.surface,
      cornerRadius: 15,
      cornerRadiusOnFullscreen: 0,
      liftOnScrollHeaderElevation: 8,
      closeOnBackButtonPressed: true,
      duration: const Duration(milliseconds: 300),
      snapSpec: SnapSpec(
        snap: true,
        snappings: [0, widget.initialSheetSize, 1.0],
        positioning: SnapPositioning.relativeToAvailableSpace,
        onSnap: _handleSnap,
        initialSnap: widget.initialSheetSize
      ),
      headerBuilder: (context, state) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.background,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // TODO: remove or re-implement stop name
                            // "${widget.marker.value?.data?['name'] ?? 'Unknown'}"
                            " - ${question!.name}",
                            style: Theme.of(context).textTheme.overline
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            question!.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.12) ?? Colors.black12
                    )
                  ]
                )
              ),
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 5, bottom: -10,
                child:TriangleDown(
                  size: Size(10, 10),
                  color: Theme.of(context).colorScheme.surface
                )
              ),
            ]
          )
        );
      },
      builder: (context, state) {
        return Container(
          color: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.fromLTRB(25, 25, 25, 25 + MediaQuery.of(context).padding.bottom),
          child: QuestionInputView.fromQuestionInput(question!.input, onChange: null)
        );
      }
    );
  }


  void _handleQuestionChange() {
    if (widget.question.value == null && (sheetController.state?.extent != 0 || sheetController.state?.isHidden == false)) {
      sheetController.hide();
      return;
    }

    if (widget.question.value != null) {
      setState(() => question = widget.question.value);

      if ((sheetController.state?.extent == 0 || sheetController.state?.isHidden == true)) {
        sheetController.snapToExtent(widget.initialSheetSize);
      }
    }
  }


  void _handleSnap(SheetState state, double? extend) {
    if (state.isHidden == true) {
      widget.question.value = null;
    }
  }
}