import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/answer.dart';
import 'package:open_stop/models/question_input.dart';

void main() async {

  test('test if NumberAnswer.isValid with restrictions works correctly', () {
    const testInputValues = { 'single': QuestionInputValue(
      osmTags: {},
      decimals: 4,
      min: -10,
      max: 10
    )};

    expect(
      const NumberAnswer(questionValues: testInputValues, value: '0').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-0').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-10.1').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '10.1').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1.12345').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1.12345').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '.').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: 'abc').isValid,
      isFalse
    );
  });


  test('test if NumberAnswer.isValid without restrictions works correctly', () {
    const testInputValues = { 'single': QuestionInputValue(
      osmTags: {},
    )};

    expect(
      const NumberAnswer(questionValues: testInputValues, value: '0').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-0').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-10.1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '10.1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-1.12345').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '1.12345').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '-').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: '.').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(questionValues: testInputValues, value: 'abc').isValid,
      isFalse
    );
  });
}
