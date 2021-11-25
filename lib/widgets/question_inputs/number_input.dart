import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

class NumberInput extends QuestionInputView {
  NumberInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key) ;

  @override
  _NumberInputState createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  final _controller = TextEditingController();
  late final _focusNode = FocusNode();
  late final minValue = widget.questionInput.min?.toDouble() ?? double.negativeInfinity;
  late final maxValue = widget.questionInput.max?.toDouble() ?? double.infinity;
  void _clearTextfield (){
    _controller.clear();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(()  {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, TextEditingValue value, __) {
          return TextFormField(
            focusNode: _focusNode,
            controller: _controller,
            decoration: InputDecoration(
                hintText: 'Hier eintragen...',
                suffixText: widget.questionInput.unit,
                suffixIcon: IconButton(
                  onPressed: _focusNode.hasFocus ? () => _clearTextfield() : null,
                  disabledColor: Colors.transparent,
                  color: Colors.black54,
                  icon: Icon(Icons.clear_rounded),
                )
            ),
            autovalidateMode: AutovalidateMode.always,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return null;
              }
              else {
                text=text.replaceAll(",", ".");
                final value = double.parse(text);
                if (value < minValue || value > maxValue) {
                  return 'Wert muss zwischen $minValue und $maxValue liegen';
                }
              }
            },
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+(\,)?\d{0,''${widget.questionInput.decimals}}'))
            ],
          );
        }
        );
  }
}
