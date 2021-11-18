import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/models/question.dart';
import '/widgets/animated_dual_switcher.dart';
import '/widgets/question_inputs/question_input_view.dart';
import 'question_input_bubble.dart';
import 'question_navigation_bubble.dart';
import 'question_text_bubble.dart';

class QuestionDialog extends StatefulWidget {
  final ValueNotifier<Question?> question;

  QuestionDialog({
    required this.question
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  Question? question;

  @override
  void initState() {
    super.initState();

    question = widget.question.value;

    widget.question.addListener(_handleQuestionChange);
  }


  @override
  Widget build(BuildContext context) {
    return widget.question.value == null
      ? SizedBox.shrink()
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
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10 + MediaQuery.of(context).padding.top),
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: BouncingScrollPhysics(),
                    child: AnimatedDualSwitcher(
                      layoutBuilder: customLayoutBuilder,
                      animateInBuilder: _animateInBuilder,
                      animateOutBuilder: _animateOutBuilder,
                      animateInDuration: const Duration(milliseconds: 800),
                      animateOutDuration: const Duration(milliseconds: 400),
                      animateInCurve: Curves.fastOutSlowIn,
                      animateOutCurve: Curves.easeIn,
                      child: Column(
                        key: ValueKey(question),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          QuestionTextBubble(
                            question: question!.question,
                            details: question!.description,
                          ),
                          QuestionInputBubble(
                            child: QuestionInputView.fromQuestionInput(
                              question!.input,
                              onChange: null
                            )
                          ),
                        ],
                      )
                    )
                  )
                )
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10 + MediaQuery.of(context).padding.bottom),
            child: QuestionNavigationBubble(
              onConfirm: () {},
              onBack: () {},
              onSkip: () {},
            )
          )
        ],
    );
  }


  Widget _animateInBuilder(BuildContext context, Animation<double> animation, Widget? child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * 100),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: animation,
        child: child
      ),
    );
  }


  Widget _animateOutBuilder(BuildContext context, Animation<double> animation, Widget? child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * -100),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: animation,
        child: child
      ),
    );
  }


  Widget customLayoutBuilder(Iterable<Widget> animatingInChildren, Iterable<Widget> animatingOutChildren) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ...animatingOutChildren,
        ...animatingInChildren
      ],
    );
  }


  void _handleQuestionChange() {
    if (widget.question.value != null) {
      setState(() {
        question = widget.question.value;
      });
    }
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