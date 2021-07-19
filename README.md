# OPENER next

The successor of the famous OPENER App.


## Before Compiling

**Rename** `globals.example.dart` to `globals.dart` in the `lib/commons` directory and **add** your public Mapbox API key and style URL.

```dart
const MAPBOX_API_TOKEN = 'YOUR TOKEN';
const MAPBOX_STYLE_URL = 'YOUR STYLE URL';
```

Also **add** your secret Mapbox SDK key to the system variables. For example add the following line to `.zshrc` file:

```
export SDK_REGISTRY_TOKEN="YOUR SECRET KEY"
```
