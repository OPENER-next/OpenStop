import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';

void main() async {

  const values = {
    'key1': ['a', 'b', 'c'],
    'key2': ['a', 'b', 'c'],
  };

 test('test if constructor coalesce works correctly', () {
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
        'key2': ['coalesce', 'x'],
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
        'key2': ['coalesce', 'x'],
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
        'key2': ['coalesce', 'x'],
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
        'key1': ['coalesce', r'$input'],
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
        'key1': ['coalesce', r'$input'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['coalesce', r'$input', 'fallback'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['coalesce', r'$input'],
        'key2': ['coalesce', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test if constructor concat works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['concat', r'$input'],
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
        'key1': ['concat', r'$input', 'd'],
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
        'key1': ['concat', r'$input'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['concat', r'$input', 'fallback'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['concat', r'$input'],
        'key2': ['coalesce', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test if constructor join works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['join', ';', r'$input'],
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
        'key1': ['join', ';', r'$input', 'd'],
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
        'key1': ['join', ';', r'$input'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['join', ';', r'$input', 'fallback'],
        'key2': ['coalesce', 'x'],
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
        'key1': ['join', ';', r'$input'],
        'key2': ['coalesce', 'x'],
      });

      expect(
        testConstructor.construct({}),
        equals({
          'key2': 'x',
        })
      );
    }
  });


  test('test expression nesting in constructor works correctly', () {
    {
      const testConstructor = AnswerConstructor({
        'key1': ['join',
          ['concat', r'$input'],
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
        'key1': ['join',
          ['coalesce', r'$input'],
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
        'key1': ['concat',
          ['coalesce', r'$input'],
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
        'key1': ['concat',
          ['join', ';', r'$input'],
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
