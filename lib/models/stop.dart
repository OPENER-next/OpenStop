import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:postgres/postgres.dart';


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


  /// Method to construct a stop from a database query result

  static Stop fromQueryResult(PostgreSQLResultRow row) {
    final entry = row.toColumnMap();
    return Stop(
      dhid: entry['dhid'],
      name: entry['name'],
      location: LatLng(entry['latitude'], entry['longitude']),
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