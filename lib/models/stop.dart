import 'package:latlong2/latlong.dart';

/// A basic representation of a public transport stop/halt.

class Stop {
  final LatLng location;

  final String name;

  Stop({
    required this.location,
    this.name = '',
  });


  /// Method to construct a stop from an Overpass API JSON response.

  factory Stop.fromOverpassJSON(Map<String, dynamic> element) {
    return Stop(
      name: element['tags']?['name'] ?? '',
      location: element.containsKey('center')
        ? LatLng(element['center']['lat'], element['center']['lon'])
        : LatLng(element['lat'], element['lon'])
    );
  }


  @override
  String toString() => 'Stop(name: $name, location: $location)';


  @override
  int get hashCode =>
    name.hashCode ^
    location.hashCode;


  @override
  bool operator == (other) =>
    identical(this, other) ||
    other is Stop &&
    runtimeType == other.runtimeType &&
    name == other.name &&
    location == other.location;
}
