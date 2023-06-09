import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/element_processing/element_processor.dart';
import 'package:open_stop/models/affected_elements_detector.dart';
import 'package:open_stop/models/question_catalog/question_catalog.dart';
import 'package:osm_api/osm_api.dart';

void main() async {

  late OSMNode n1, n2;
  late OSMWay w1;
  late OSMRelation r1;
  late OSMElementProcessor elementProcessor;

  // create clean set of elements for every test function
  setUp(() {
    n1 = OSMNode(0, 0, id: 0, tags: {
      'foo': 'bar',
    });
    n2 = OSMNode(0, 0, id: 1, tags: {
      'bla': 'blub',
    });
    w1 = OSMWay([0, 1], id: 0, tags: {
      'way': 'yes',
    });
    r1 = OSMRelation([
      OSMMember(type: OSMElementType.way, ref: 0),
      OSMMember(type: OSMElementType.node, ref: 1),
    ], id: 0, tags: {
      'relation': 'yes',
    });

    elementProcessor = OSMElementProcessor(OSMElementBundle(
      nodes: [n1, n2],
      ways: [w1],
      relations: [r1]
    ));
  });


  test('test affected element detection 01', () {
    final qc = QuestionCatalog.fromJson([
      {
        'question': {
          'name': '',
          'text': '',
        },
        'answer': {
          'type': 'String',
          'input': {},
          'constructor': {
            'some_key': [r'$input']
          }
        },
        'conditions': [
          {
            'osm_tags': {
              'bla': 'blub',
            },
            'parent': [
              {
                'osm_tags': {
                  'relation': 'yes'
                },
                'child': [
                  {
                    'osm_tags': {
                      'way': 'yes'
                    },
                  }
                ]
              }
            ]
          }
        ]
      },
    ]);

    final target = elementProcessor.find(OSMElementType.way, 0)!;
    final detector = AffectedElementsDetector(questionCatalog: qc);

    final previouslyAffectedElements = detector.takeSnapshot(target);
    expect(previouslyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: true,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.way, 0)!,
        matches: false,
      ),
    }));

    // update the underlying way element (simulate publish)
    w1.tags['way'] = 'other';

    final newlyAffectedElements = detector.takeSnapshot(target);
    expect(newlyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: false,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.way, 0)!,
        matches: false,
      ),
    }));
  });


  test('test affected element detection 02', () {
    final qc = QuestionCatalog.fromJson([
      {
        'question': {
          'name': '',
          'text': '',
        },
        'answer': {
          'type': 'String',
          'input': {},
          'constructor': {
            'some_key': [r'$input']
          }
        },
        'conditions': [
          {
            'osm_tags': {
              'bla': 'blub',
            },
            'parent': [
              {
                'osm_tags': {
                  'relation': 'yes'
                },
                'child': [
                  {
                    'osm_tags': {
                      'way': 'other'
                    },
                  }
                ]
              }
            ]
          }
        ]
      },
    ]);

    final target = elementProcessor.find(OSMElementType.way, 0)!;
    final detector = AffectedElementsDetector(questionCatalog: qc);

    final previouslyAffectedElements = detector.takeSnapshot(target);
    expect(previouslyAffectedElements, unorderedEquals(<AffectedElementsRecord>{}));

    // update the underlying way element (simulate publish)
    w1.tags['way'] = 'other';

    final newlyAffectedElements = detector.takeSnapshot(target);
    expect(newlyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.way, 0)!,
        matches: false,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: true,
      ),
    }));
  });


  test('test affected element detection 03', () {
    final qc = QuestionCatalog.fromJson([
      {
        'question': {
          'name': '',
          'text': '',
        },
        'answer': {
          'type': 'String',
          'input': {},
          'constructor': {
            'some_key': [r'$input']
          }
        },
        'conditions': [
          {
            'osm_tags': {
              'bla': 'blub',
            },
            '!parent': [
              {
                'osm_tags': {
                  'relation': 'yes'
                },
                'child': [
                  {
                    'osm_tags': {
                      'way': 'other'
                    },
                  }
                ]
              }
            ]
          }
        ]
      },
    ]);

    final target = elementProcessor.find(OSMElementType.way, 0)!;
    final detector = AffectedElementsDetector(questionCatalog: qc);

    final previouslyAffectedElements = detector.takeSnapshot(target);
    expect(previouslyAffectedElements, unorderedEquals(<AffectedElementsRecord>{}));

    // update the underlying way element (simulate publish)
    w1.tags['way'] = 'other';

    final newlyAffectedElements = detector.takeSnapshot(target);
    expect(newlyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.way, 0)!,
        matches: false,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: false,
      ),
    }));
  });


  test('test affected element detection 04', () {
    final qc = QuestionCatalog.fromJson([
      {
        'question': {
          'name': '',
          'text': '',
        },
        'answer': {
          'type': 'String',
          'input': {},
          'constructor': {
            'some_key': [r'$input']
          }
        },
        'conditions': [
          {
            'osm_tags': {
              'bla': 'blub',
            },
            '!parent': [
              {
                'osm_tags': {
                  'way': 'other'
                },
              }
            ]
          }
        ]
      },
    ]);

    final target = elementProcessor.find(OSMElementType.way, 0)!;
    final detector = AffectedElementsDetector(questionCatalog: qc);

    final previouslyAffectedElements = detector.takeSnapshot(target);
    expect(previouslyAffectedElements, unorderedEquals(<AffectedElementsRecord>{}));

    // update the underlying way element (simulate publish)
    w1.tags['way'] = 'other';

    final newlyAffectedElements = detector.takeSnapshot(target);
    expect(newlyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 0)!,
        matches: false,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: false,
      ),
    }));
  });


  test('test affected element detection 05', () {
    final qc = QuestionCatalog.fromJson([
      {
        'question': {
          'name': '',
          'text': '',
        },
        'answer': {
          'type': 'String',
          'input': {},
          'constructor': {
            'some_key': [r'$input']
          }
        },
        'conditions': [
          {
            'osm_tags': {
              'foo': 'bar'
            }
          },
          {
            'osm_tags': {
              'bla': 'blub'
            },
            'parent': [
              {
                'osm_tags': {
                  'way': 'yes'
                },
                'parent': [
                  {
                    'osm_tags': {
                      'relation': 'yes'
                    },
                  }
                ]
              }
            ]
          },
        ]
      },
    ]);

    final target = elementProcessor.find(OSMElementType.way, 0)!;
    final detector = AffectedElementsDetector(questionCatalog: qc);

    final previouslyAffectedElements = detector.takeSnapshot(target);
    expect(previouslyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 0)!,
        matches: true,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: true,
      ),
    }));

    // update the underlying way element (simulate publish)
    w1.tags['way'] = 'other';

    final newlyAffectedElements = detector.takeSnapshot(target);
    expect(newlyAffectedElements, unorderedEquals({
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 0)!,
        matches: true,
      ),
      AffectedElementsRecord(
        element: elementProcessor.find(OSMElementType.node, 1)!,
        matches: false,
      ),
    }));
  });
}
