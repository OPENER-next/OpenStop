# How to add new questions

The question catalog contains all questions the app may ask. Each question item consists of three main parts: **question**, **answer** and **conditions**.

```jsonc
{
  "question": {
    ...
  },
  "answer": {
    ...
  },
  "conditions": [
    ...
  ]
}
```

## The `question` part

This contains any fields that describe the actual question displayed to the user. The main question must be provided via the `text` property and a short string that describes the modified value via `name`.
Further details and information can be added using the `description` and `image` (expects an array of image paths) fields.

```jsonc
{
  "question": {
      "name": "",
      "text": "",
      "description": "...",
      "image": [
        "assets/question_catalog/images/..."
      ]
  },
  ...
}
```

## The `answer` part

This defines the input element the user interacts with as well as which tags are written. It consists of three sub-properties:
- `type` defines the UI input element that will be displayed to the user. Possible types are: `String`, `Number`, `Duration`, `Bool`, `List` and `MultiList`
- `input` defines additional settings for the input element, which varies across different input types.
- `constructor` defines the transformation from input value(s) to tags that are ultimately written to the OSM element.


### Input types

#### `String` input

Displays a small text input to the user.

```jsonc
"answer": {
    "type": "String",
    "input": {
        // [optional] Placeholder string for the text input.
        "placeholder": "Operator",
        // [optional] Minimum string length.
        // Defaults to 0 which is also the smallest value allowed.
        "min": 0,
        // [optional] Maximum string length.
        // Defaults to 255 which is also the biggest value allowed.
        "max": 255,
    },
    // Mandatory since the tags/keys cannot be derived.
    // $input will contain the entered string.
    "constructor": {}
}
```

#### `Number` input

Displays a small text input to the user which allows entering numbers only.

```jsonc
"answer": {
    "type": "Number",
    "input": {
        // [optional] Placeholder string for the number input.
        "placeholder": "Length",
        // [optional] Unit displayed in the the number input.
        "unit": "Meter",
        // [optional] Lower inclusive limit for the inserted number.
        "min": 0,
        // [optional] Upper inclusive limit for the inserted number.
        "max": 100,
        // [optional] Limit the amount of allowed decimal places.
        "decimals": 0
    },
    // Mandatory since the tags/keys cannot be derived.
    // $input will contain the entered number.
    "constructor": { }
}
```

#### `Duration` input

Displays a number wheel for each specified time unit. Possible time units are `days`, `hours`, `minutes` and `seconds`.

The duration is always completely returned to the constructor, meaning no duration inputs are lost.
If for example the input is in hours, minutes and seconds, but only hours is marked as a return value, the hours value will include the minutes and seconds in its representation (potentially in the fractional part). Make sure that the `constructor` only generates the permitted values of the corresponding tag.

The `$input` variable will contain all duration values marked with `return: true` in the following order: `days`, `hours`, `minutes` and `seconds`. Therefore at least one duration value should have `return": true`.

```jsonc
"answer": {
    "type": "Duration",
    "input": {
      // Maximum allowed input value for the biggest time unit with `display: true`.
      "max": 3,
      // Defines the usage of minutes
      "minutes": {
          // The time segment/step size of the minutes number wheel.
          "step": 1,
          // Whether a separate minutes input should be shown to the user.
          // Defaults to true when the unit is defined otherwise false.
          "display": true,
          // Defines whether minutes should be returned as a separate value in the answer constructor.
          // Defaults to true when the unit is defined otherwise false.
          "return": true,
      },
      // Defines the usage of seconds
      "seconds": {
          ...
      },
      ...
    },
    // Mandatory since the tags/keys cannot be derived.
    // The duration will be split into a separate value for each unit with "return" set to true.
    "constructor": { }
},
```


#### `Bool` input

Displays two options side by side and allows the selection of one of them.

```jsonc
"answer": {
    "type": "Bool",
    // Must be a list of exactly two items.
    "input": [
      {
          // Values that will be assigned to the constructor's $input variable.
          "osm_tags": {
            "crossing:bell": "yes"
          },
          // [optional] Short term representing this option. If omitted this will fallback to "Yes".
          "name": "Option 1",
      },
      {
          "osm_tags": {
            "crossing:bell": "no"
          },
          // [optional] Short term representing this option. If omitted this will fallback to "No".
          "name": "Option 2",
      }
    ],
    // Can be omitted. In this case the constructor will be generated/derived from the selected input item.
    // Generated constructor: "crossing:bell": ["COALESCE", "$input"]
    // $input will contain the value of the corresponding key from the selected option.
    // If no corresponding key exists $input will be empty.
    "constructor": { }
}
```

#### `List` and `MultiList` input

Displays a list of multiple options and allows the selection of one option (`List`) or multiple options (`MultiList`).

```jsonc
"answer": {
    "type": "List" | "MultiList",
    // Must be a list of at least two items.
    "input": [
      {
          // Values that will be assigned to the constructor's $input variable.
          "osm_tags": {
            "crossing": "unmarked"
          },
          // Short term representing this option.
          "name": "Option 1",
          // [optional] Path to an image that will be displayed in addition to the name.
          "image": "assets/path/to/image",
          // [optional] Additional text that will be displayed upon selecting the option.
          "description": "more details here",
      },
      ...
    ],
    // Can be omitted. In this case the constructor will be generated/derived from the selected input item(s).
    // $input will contain the value of the corresponding key from the selected option.
    // If no corresponding key exists $input will be empty.
    "constructor": { }
}
```

### Constructor

The constructor is defined as a mapping of OSM keys to expressions, while an expression is like a function which eventually computes the value of the tag.

```jsonc
constructor: {
  "my_tag": ["EXPRESSION"]
}
```

Expressions are structured like this: `["EXPRESSION", arg1, arg2, argN]`, while every argument hast to be a string.
The first item of the array is the expression identifier and must be written in caps. Expressions can freely be nested in other expressions.

There is a special `$input` variable which holds the **values** entered by the user via the input widget. Note that for some inputs like `MultiList` this might spread into multiple values.

For `Number`, `Duration` and `String` inputs the `$input` variable will return the same value regardless of the tag/key it is used on.
For `Bool`, `List` and `MultiList` the `$input` variable has a separate value for each tag/key which is defined in the `input` part.

If an expression doesn't return a value, for example because all arguments are empty or invalid, the corresponding tag won't be written.

#### `COALESCE` expression (default)

Takes the first value/argument and applies it to the tag/key.

This is the default expression, which means it will be used when no expression is defined. Example: `"operator": ["$input"]` is equal to `"operator": ["COALESCE", "$input"]`.

**Examples:**
- input: `[A,B,C]`
constructor: `"operator": ["COALESCE", "first", "$input", "last"]`
output: `operator=first`
- input: `[A,B,C]`
constructor: `"operator": ["COALESCE", "$input"]`
output: `operator=A`

#### `CONCAT` expression

Concatenates all values/arguments to a single one and applies it to the tag/key.

**Examples:**
- input: `[A,B,C]`
constructor: `"operator": ["CONCAT", "first", "$input", "last"]`
output: `operator=firstABClast`
- input: `[A,B,C]`
constructor: `"operator": ["CONCAT", "$input"]`
output: `operator=ABC`

#### `JOIN` expression

Concatenates all values/arguments to a single one with a given delimiter and applies it to the tag/key.

The first argument will be used as the delimiter string.

**Examples:**
- input: `[A,B,C]`
constructor: `"operator": ["JOIN", " | ", "first", "$input", "last"]`
output: `operator=first | A | B | C | last`
- input: `[A,B,C]`
constructor: `"operator": ["JOIN", ";", "$input"]`
output: `operator=A;B;C`

#### `COUPLE` expression

Concatenates exactly two values/arguments to a single value. In contrast to `CONCAT` this will return null if more or less arguments are given.

This is useful for prefix and suffix strings which on their own don't make any sense.

**Examples:**
- input: `[A]`
constructor: `"operator": ["COUPLE", "prefix_", "$input"]`
output: `operator=prefix_A`
- input: `[A]`
constructor: `"operator": ["COUPLE", "$input", "_suffix"]`
output: `operator=A_suffix`
- input: `[]`
constructor: `"operator": ["COUPLE", "$input", "_suffix"]`
output: `operator=NULL`

#### `INSERT` expression

Inserts one String into one or multiple other Strings at a certain position.
*This expression can have multiple return values.*

First argument represents the insertion String.
Second argument specifies the position/index where the String should be inserted into the target String. Negative positions are treated as insertions starting at the end of the String. So -1 means insert before the last character of the target String. If the index exceeds the length of the target String, it will be returned without any modifications.
All succeeding arguments resemble the target Strings. For each target string a respective result value will be returned.

**Examples:**
- input: `[tag_value]`
constructor: `"operator": ["INSERT", "X", "1", "$input"]`
output: `operator=tXag_value`
- input: `[tag_value]`
constructor: `"operator": ["INSERT", "X", "-5", "$input"]`
output: `operator=tag_Xvalue`
- input: `[tag_value]`
constructor: `"operator": ["INSERT", "X", "20", "$input"]`
output: `operator=tag_value`

#### `PAD` expression

Adds a given String to one or multiple other Strings for each time the target String length is less than the given width.
*This expression can have multiple return values.*

First argument represents the padding String.
Second argument specifies the desired width. Positive values will prepend, negative values will append to the target String. Remember that the final String length may be greater than the desired width when the padding String contains more than one character.
All succeeding arguments resemble the target Strings. For each target string a respective result value will be returned.

**Examples:**
- input: `[1]`
constructor: `"operator": ["PAD", "0", "3", "$input"]`
output: `operator=001`
- input: `[1]`
constructor: `"operator": ["PAD", "0", "-3", "$input"]`
output: `operator=100`
- input: `[value]`
constructor: `"operator": ["PAD", "XXX", "9", "$input"]`
output: `operator=XXXXXXvalue`

#### `REPLACE` expression

Replaces a given Pattern (either String or RegExp) in one or multiple target Strings with a given replacement String.
*This expression can have multiple return values.*

RegExp are denoted by a `/` at the start and end of the String.
First argument represents the Pattern the target String should be matched against.
Second argument defines the replacement String.
All succeeding arguments resemble the target Strings. For each target string a respective result value will be returned.

**Examples:**
- input: `[sometimes]`
constructor: `"operator": ["REPLACE", "times", "thing", "$input"]`
output: `operator=something`
- input: `[sometimes]`
constructor: `"operator": ["REPLACE", "e", "#", "$input"]`
output: `operator=som#tim#s`
- input: `[value]`
constructor: `"operator": ["REPLACE", "/^.|.$/", "_", "$input"]`
output: `operator=_alu_`

### Answer examples

#### Multiple values using the semi-colon value separator
The example will write all selected values to the *cuisine* tag separated by semi-colon.
**Explanation:** The `$input` variable will contain all selected values, which will be concatenated by the `JOIN` expression.

```jsonc
"answer": {
    "type": "MultiList",
    "input": [
      {
          "name": "African",
          "osm_tags": {
            "cuisine": "african"
          }
      },
      {
          "name": "Asian",
          "osm_tags": {
            "cuisine": "asian"
          }
      },
      {
          "name": "American",
          "osm_tags": {
            "cuisine": "american"
          }
      },
      {
          "name": "European",
          "osm_tags": {
            "cuisine": "european"
          }
      }
    ],
    "constructor": {
      "cuisine": ["JOIN", ";", "$input"]
    }
}
```

#### Multiple values using multiple tags
The example will write the three tags *bus*, *tram* & *train*. For unselected options the values will fallback to *no*.
**Explanation:** The `$input` variable will be empty for unselected options. Because `COALESCE` evaluates to the first value/argument it will output *no* in this case. If the fallback value is omitted then the expression will evaluate to `null` which means that the tag won't be written.
```jsonc
"answer": {
    "type": "MultiList",
    "input": [
      {
          "name": "Bus",
          "osm_tags": {
            "bus": "yes"
          }
      },
      {
          "name": "Tram",
          "osm_tags": {
            "tram": "yes"
          }
      },
      {
          "name": "Train",
          "osm_tags": {
            "train": "yes"
          }
      }
    ],
    "constructor": {
      "bus": ["COALESCE", "$input", "no"],
      "tram": ["COALESCE", "$input", "no"],
      "train": ["COALESCE", "$input", "no"]
    }
}
```

#### Using expressions to convert centimeters to meters
The example makes use of the 3 expressions PAD, INSERT and REPLACE to convert from centimeters to meters. The REPLACE expression is only used to remove any pending zeros (and potentially the decimal point). Note that this expression combination only works for positive integers (not for negative or decimal numbers) and does a conversion by exactly two decimal places to the left.

**Explanation:** The expressions evaluate from the inner most to the outer most as shown in the table below.

| $input | PAD   | INSERT | REPLACE |
| ------ | ----- | ------ | ------- |
| 1      | 001   | 0.01   | 0.01    |
| 1000   | 1000  | 10.00  | 10      |
| 12     | 012   | 0.12   | 0.12    |
| 0      | 000   | 0.00   | 0       |
| 102    | 102   | 1.02   | 1.02    |
| 120    | 120   | 1.20   | 1.2     |


```jsonc
"answer": {
    "type": "Number",
    "input": {
      "placeholder": "Step height",
      "decimals": 0,
      "min": 0,
      "max": 40,
      "unit": "Centimeter"
    },
    "constructor": {
      "height": [
          "REPLACE", "/\\.?0{1,2}$/", "", [
            "INSERT", ".", "-2", [
                "PAD", "0", "3", "$input"
            ]
          ]
      ]
    }
}
```

#### Using expressions to write duration value according to ISO 8601 (HH:MM)
The example will write the entered value in minutes to the *duration* tag in the format HH:MM, e.g. 72 minutes will become 01:12.
**Explanation:** The `$input` variable will contain all values with `return` set to `true`. Single digit values will be padded with a leading zero and finally concatenated by the `JOIN` expression.

```jsonc
"answer": {
    "type": "Duration",
    "input": {
      "max": 90,
      "hours": {
        "display": false
      },
      "minutes": {
        "step": 1
      }
    },
    "constructor": {
      "duration": [
        "JOIN", ":", [
          "PAD", "0", "2", "$input"
        ]
      ]
    }
}
```


## The `conditions` part

Conditions define when a question will be asked to a particular element.

When defining conditions it is important to ensure that **every answer invalidates its own conditions**. Below is an example for a question that writes the `speech_output` tag. The question is only asked for elevators (`highway=elevator`) and **when `speech_output` is not already defined**. This ensures that the condition won't match anymore once an answer is given (i.e.`speech_output` tag is set).

```jsonc
{
  "question": {
    ...
  },
  "answer": {
      "type": "Bool",
      "input": [
        {
            "osm_tags": {
              "speech_output": "yes"
            }
        },
        {
            "osm_tags": {
              "speech_output": "no"
            }
        }
      ]
  },
  "conditions": [
      {
        "osm_tags": {
            "highway": "elevator",
            "speech_output": false
        }
      }
  ]
}
```

Multiple conditions can be defined per questions, while at least one of them must be met in order to ask the question. A condition itself consists of 8 main properties: `osm_tags`, `osm_element`, `child`, `parent` and respective negated variants using the `!` prefix.

### `osm_tags` condition

In its simplest form this defines a set of tags (key value pairs) that must apply to an OSM element in order to evaluate the condition to true. The negated variant `!osm_tags` basically means "match any element that doesn't have these tags".

```jsonc
"osm_tags": {
  "key": "value",
  "bla": "blub",
  "highway": "elevator",
}
```
In order to match elements that have or don't have a certain key one can set the value to `true` or `false` respectively:
- `"some_osm_key": true` means that the element must have a tag with the key `some_osm_key` while its **value can be anything**.
- `"some_osm_key": false` means that the element **must not** have a tag with the key `some_osm_key`.

To match against multiple values of the same key one could write multiple conditions. However this will often result in a lot of repetitive code wherefore a shorthand array notation exists:
`highway": ["motorway ", "trunk", "primary"]` The previous example will match any elements that contain the key `highway` with a value of either `motorway`, `trunk` or `primary`. You can also use `true`, `false` and regular expressions in this notation.

For more complex tag matching scenarios **Regular expressions** can be used. They are written as normal strings enclosed by slashes (`/`) and use Dart's regular expression syntax and semantics, which is the same as for [JavaScript regular expressions](https://developer.mozilla.org/docs/Web/JavaScript/Guide/Regular_Expressions).
Example use cases are:
- matching a tag that **does not equal** a certain value `/^(?!EXCLUDED_VALUE$).*$/`.
- matching a tag that contains certain value `/INCLUDED_VALUE/`.
- matching a tag that contains a certain value between a separator string (e.g. semicolon) `/(^|^.+;)LIST_VALUE(;.+$|$)/`.

Currently setting regex flags is not supported. All of them are turned off except for the *match case sensitive* flag.

**Notation summary:**

```jsonc
"osm_tags": {
  // must have key "foo" with the value "bar"
  "foo": "bar",
  // must have key "foo" with any value
  "foo": true,
  // must not have key "bar"
  "bar": false,
  // must have key "foo" with the value "value1" or "value2" or "value3"
  "foo": ["value1", "value2", "value3"],
  // must have key "foo" with different value than "OTHER"
  "foo": "/^(?!OTHER$).*$/",
}
```

### `osm_element` condition

This defines the element type or types the element must have in order to evaluate the condition to true. The negated variant `!osm_element` basically means "match any element that is not one of the given types".

Possible types are: `Node`, `OpenWay`, `ClosedWay` and `Relation`

In contrast to the standard OSM element types, way is split into two sub-types to distinguish between area/boundary and path/segment elements.

### `child` condition

This defines an array of nested conditions. An element must have at least one child element which in turn matches at least one of the inner conditions in order to evaluate the outer condition to true. The negated variant `!child` basically means "match any element that doesn't have a child which matches the nested conditions".

Note that this condition field does not make sense for every OSM element:
- *Nodes* cannot have children.
- *Ways* can only have *Nodes* as children.
- *Relations* can have any element as children, including *Relations* themselves.

You can freely nest child and parent conditions in already nested conditions (recursion).

The example below matches all buildings (in this form only those defined as a way) that have at least one entrance.
```jsonc
{
  ...
  "conditions": [
      {
        "osm_tags": {
            "building": true
        },
        "child": [
            {
              "osm_tags": {
                  "entrance": true
              }
            }
        ]
      }
  ]
}
```

### `parent` condition

*This is the inverted functionality of the child property and basically works identical.*

Defines an array of nested conditions. An element must have at least one parent element which in turn matches at least one of the inner conditions in order to evaluate the outer condition to true. The negated variant `!parent` basically means "match any element that doesn't have a parent which matches the nested conditions".

While every element can have a parent element, not any element can serve as a parent element:
- *Nodes* cannot be a parent element.
- *Ways* can only be a parent element for *Nodes*.
- *Relations* can be a parent element for any element, including *Relations* themselves.

You can freely nest child and parent conditions in already nested conditions (recursion).

The example below matches all elements which are part of a public transport bus route.
```jsonc
{
  ...
  "conditions": [
      {
        "parent": [
            {
              "osm_tags": {
                  "type": "route",
                  "route": "bus",
              }
            }
        ]
      }
  ]
}
```
