import 'package:mapbox_gl/mapbox_gl.dart';


/// A basic representation of a public transport stop/halt

class Stop {
  final String dhid;

  final String name;

  final LatLng location;

  Stop({
    required this.dhid,
    required this.name,
    required this.location
  });


  /// Method to construct a stop from an Overpass API JSON response

  static Stop fromOverpassJSON(Map<String, dynamic> element) {
    return Stop(
      dhid: "",
      name: element['tags']?['name'] ?? 'Unknown Name',
      location: LatLng(element['center']['lat'], element['center']['lon'])
    );
  }


  @override
  String toString() => '$runtimeType - dhid: $dhid; user: $name; text: $name; location: $location';


  @override
  int get hashCode =>
    dhid.hashCode ^
    name.hashCode ^
    location.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is Stop &&
    runtimeType == o.runtimeType &&
    dhid == o.dhid &&
    name == o.name &&
    location == o.location;
}