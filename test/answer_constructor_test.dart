import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';

void main() async {
  Iterable<String> withValues(String key) sync* {
    switch (key) {
      case 'key1':
        yield* ['a', 'b', 'c'];
      case 'key2':
        yield* ['a', 'b', 'c'];
      case 'key3':
        yield* ['some_value'];
    }
  }

  Iterable<String> noValues(String key) sync* {}

  test('test if constructor COALESCE works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COALESCE', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key2': 'x',
        }),
      );
    }
  });

  test('test if constructor CONCAT works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'abc',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input', 'd'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'abcd',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'abc',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['CONCAT', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key2': 'x',
        }),
      );
    }
  });

  test('test if constructor JOIN works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a;b;c',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input', 'd'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a;b;c;d',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a;b;c',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input', 'fallback'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key1': 'fallback',
          'key2': 'x',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COALESCE', 'x'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key2': 'x',
        }),
      );
    }
  });

  test('test if constructor COUPLE works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['JOIN', ';', r'$input'],
        'key2': ['COUPLE', 'x'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a;b;c',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a', 'b'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'ab',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['COUPLE', 'a', r'$input', 'b'],
      });

      expect(
        testConstructor.construct(noValues),
        equals({
          'key1': 'ab',
        }),
      );
    }
  });

  test('test if constructor INSERT works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '0', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'Xsome_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '1', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'sXome_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '-1', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_valuXe',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['INSERT', 'X', '0', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'Xa',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['INSERT', 'X', '20', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', '0', 'X', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', 'X', '1.2', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['INSERT', '0', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }
  });

  test('test if constructor PAD works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '5', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '10', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '12', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'XXsome_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-5', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-10', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '-12', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_valueXX',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'XXX', '11', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'XXXsome_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['PAD', 'XXX', '-11', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'aXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', '3', 'X', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', 'X', '1.2', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['PAD', '14', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }
  });

  test('test if constructor REPLACE works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key3': ['REPLACE', 'value', 'test', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_test',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['REPLACE', 'e', '#', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'som#_valu#',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['REPLACE', 'E', 'X', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        // match first and last character
        'key3': ['REPLACE', r'/^.|.$/', '_', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': '_ome_valu_',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        // missing / will not parse it as a regular expression and instead teat it as a string
        'key3': ['REPLACE', r'^.|.$', 'XX', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key3': 'some_value',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        // malformed regular expression
        'key3': ['REPLACE', r'/^.|.$)/', 'XX', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key3': ['REPLACE', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({}),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': ['REPLACE', r'$input'],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'c',
        }),
      );
    }
  });

  test('test expression nesting in constructor works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': [
          'JOIN',
          ['CONCAT', r'$input'],
          r'$input',
        ],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'aabcbabcc',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [
          'JOIN',
          ['COALESCE', r'$input'],
          r'$input',
        ],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'aabac',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [
          'CONCAT',
          ['COALESCE', r'$input'],
          '-',
          r'$input',
        ],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a-abc',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [
          'CONCAT',
          ['JOIN', ';', r'$input'],
          '-',
          r'$input',
        ],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': 'a;b;c-abc',
        }),
      );
    }

    {
      const testConstructor = AnswerConstructor({
        'key1': [
          'CONCAT',
          [
            'INSERT',
            '_',
            '-1',
            [
              'PAD',
              '#',
              '4',
              r'$input',
            ],
          ],
        ],
        'key2': [
          'JOIN',
          '.',
          ['REPLACE', 'a', 'x', r'$input'],
        ],
      });

      expect(
        testConstructor.construct(withValues),
        equals({
          'key1': '###_a###_b###_c',
          'key2': 'x.b.c',
        }),
      );
    }
  });
}
