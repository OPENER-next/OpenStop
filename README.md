# OPENER next

The successor of the famous OPENER App.


## Before Compiling

**Rename** `globals.example.dart` to `globals.dart` in the `lib/commons` directory.

### Database Setup

To setup the OPENER next database please follow the instructions from [this repository](https://github.com/OPENER-next/Database-Setup).

**Add** your database host and credentials to the `globals.dart` file.

```dart
const DB_HOST = 'DATABASE HOST HERE';
const DB_PORT = 0;
const DB_USER = 'DATABASE USER NAME HERE';
const DB_PASSWORD = 'DATABASE PASSWORD HERE';
const DB_NAME = 'DATABASE NAME HERE';
```
