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
}