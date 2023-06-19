import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';

void main() async {

  const values = {
    'key1': ['a', 'b', 'c'],
    'key2': ['a', 'b', 'c'],
    'key3': ['some_value'],
  };

 test('test if constructor COALESCE works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test if constructor CONCAT works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'abc',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input', 'd'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'abcd',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'abc',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test if constructor JOIN works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a;b;c',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input', 'd'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a;b;c;d',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a;b;c',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test if constructor COUPLE works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COUPLE', 'x'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a;b;c',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a', 'b'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'ab',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a', r'$input', 'b'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key1': 'ab',
        })
      );
    }
  });


  test('test if constructor INSERT works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '0', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'Xsome_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '1', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'sXome_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '-1', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_valuXe',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['INSERT', 'X', '0', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'Xa',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['INSERT', 'X', '20', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', '0', 'X', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '1.2', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', '0', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }
  });


  test('test if constructor PAD works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '5', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '10', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '12', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'XXsome_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-5', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-10', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-12', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'some_valueXX',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'XXX', '11', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key3': 'XXXsome_value',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['PAD', 'XXX', '-11', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'aXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', '3', 'X', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '1.2', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', '14', r'$input'],
      });

      expect(
        testConstructor.construct(values),
        equals({})
      );
    }
  });


  test('test expression nesting in constructor works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN',
          ['CONCAT', r'$input'],
          r'$input'
        ],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'aabcbabcc',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN',
          ['COALESCE', r'$input'],
          r'$input'
        ],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'aabac',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT',
          ['COALESCE', r'$input'],
          '-',
          r'$input'
        ],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a-abc',
        })
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT',
          ['JOIN', ';', r'$input'],
          '-',
          r'$input'
        ],
      });

      expect(
        testConstructor.construct(values),
        equals({
          'key1': 'a;b;c-abc',
        })
      );
    }
  });
}
