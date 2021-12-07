import 'package:flutter/foundation.dart';

class MapViewModel extends ChangeNotifier {
  String _urlTemplate;
  double _minZoom;
  double _maxZoom;

  MapViewModel({
    required String urlTemplate,
    double minZoom = 0,
    double maxZoom = 18,
  }) : _urlTemplate = urlTemplate, _minZoom = minZoom, _maxZoom = maxZoom;

  String get urlTemplate => _urlTemplate;

  set urlTemplate(String value){
    if (value != _urlTemplate) {
      _urlTemplate = value;
      notifyListeners();
    }
  }

  double get minZoom => _minZoom;

  set minZoom(double value){
    if (value != _minZoom) {
      _minZoom = value;
      notifyListeners();
    }
  }

  double get maxZoom => _maxZoom;

  set maxZoom(double value){
    if (value != _maxZoom) {
      _maxZoom = value;
      notifyListeners();
    }
  }
}
