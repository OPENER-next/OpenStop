import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:postgres/postgres.dart';
import '/commons/globals.dart';
import '/models/stop.dart';


/// A class that automatically queries [Stop]s from the database based on a given map camera position.
/// The retrieved [Stop]s will be broadcasted by a [Stream] that can be accessed via the [stops] property.

class StopQueryHandler {

  /// A cache of points that contains all points that have been used to send a query to the database.

  final _queriedDatabaseByPoints = Set<LatLng>();


  /// The radius that will be used when querying points.

  final int queryRadius;

  PostgreSQLConnection? _connection;

  final _results = StreamController<Iterable<Stop>>();

  StopQueryHandler({
    this.queryRadius = 3000
  });


  /// This should be called on camera position changes and will trigger a database query if necessary.
  /// The query results can be accessed via the [stops] property.

  update(CameraPosition cameraPosition) async {
    final cameraCenter = cameraPosition.target;
    if (_isNewQueryRequired(cameraCenter)) {
      // get stops and add them to the stream
      final result = await _queryStopsNearPoint(cameraCenter, this.queryRadius);
      _results.add(_resultToMap(result));
      // cache queried camera point
      _queriedDatabaseByPoints.add(cameraCenter);
    }
  }


  /// A stream that returns a list of newly queried stops.

  Stream<Iterable<Stop>> get stops => _results.stream;


  /// Method to convert the database results to a lazy [Iterable] of [Stop]s.

  Iterable<Stop> _resultToMap(PostgreSQLResult result) sync* {
    for (final row in result) {
      yield Stop.fromQueryResult(row);
    }
  }


  /// Method to check whether a new database query is required for the given camera location.
  /// This currently only checks if the given point is inside an already queried area.

  _isNewQueryRequired(LatLng point) {
    return !_queriedDatabaseByPoints.any((circleCenter) {
      final distance = Geolocator.distanceBetween(
        point.latitude, point.longitude,
        circleCenter.latitude, circleCenter.longitude
      );
      // if distance between point and circle center is shorter than the circle radius the point is inside the circle
      // else the point is outside
      return distance <= this.queryRadius;
    });
  }


  /// Method to query all stops from a specific circular area.

  Future<PostgreSQLResult> _queryStopsNearPoint(LatLng point, int radius) async {
    // create connection if none exists or it was closed
    // otherwise reuse existing connection
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        DB_HOST, DB_PORT, DB_NAME,
        username: DB_USER,
        password: DB_PASSWORD
      );
      await _connection!.open();
    }

    return await _connection!.query(
      "SELECT dhid, name, ST_X(location::geometry) latitude, ST_Y(location::geometry) longitude "
      "FROM zhv WHERE ST_DWithin(zhv.location, ST_Point(@lat, @lon)::geography, @r) AND zhv.type = 'S';",
      substitutionValues: {
        'lat': point.latitude,
        'lon': point.longitude,
        'r': radius
    });
  }


  /// A method to cleanup the database connection and stream.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _connection?.close();
    _results.close();
  }
}