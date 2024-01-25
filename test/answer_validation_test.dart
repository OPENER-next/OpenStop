// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/answer.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';
import 'package:open_stop/models/question_catalog/answer_definition.dart';

void main() async {

  test('test if NumberAnswer.isValid with restrictions works correctly', () {
    const testInputValues = NumberAnswerDefinition(
      input: NumberInputDefinition(
        decimals: 4,
        min: -10,
        max: 10,
      ),
      constructor: AnswerConstructor({}),
    );

    expect(
      const NumberAnswer(definition: testInputValues, value: '0').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-0').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-10.1').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '10.1').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1.12345').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1.12345').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '.').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: 'abc').isValid,
      isFalse
    );
  });


  test('test if NumberAnswer.isValid without restrictions works correctly', () {
    const testInputValues = NumberAnswerDefinition(
      input: NumberInputDefinition(),
      constructor: AnswerConstructor({}),
    );

    expect(
      const NumberAnswer(definition: testInputValues, value: '0').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-0').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-10').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-10.1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '10.1').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1,1234').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-1.12345').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '1.12345').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '0.5').isValid,
      isTrue
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-.5').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '-').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: '.').isValid,
      isFalse
    );
    expect(
      const NumberAnswer(definition: testInputValues, value: 'abc').isValid,
      isFalse
    );
  });
}
