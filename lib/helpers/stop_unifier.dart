import 'dart:collection';
import 'package:latlong2/latlong.dart';
import '/models/stop_area.dart';
import '/commons/geo_utils.dart';
import '/models/stop.dart';

const _distance = Distance();

/// Merge a list of [Stop]s to a bundle of [StopArea]s based on a given merge distance.

Iterable<StopArea> unifyStops(Iterable<Stop> stops, double mergeDistance) sync* {
  // pre sort stops by latitude for faster processing later
  // use latitude because distance basically never varies and can therefore be calculated cheaply
  final unassignedStops = stops.toList()
  ..sort(
    (Stop a, Stop b) => a.location.latitude.compareTo(b.location.latitude)
  );

  while (unassignedStops.isNotEmpty) {
    yield StopArea(
      _takeNearbyStops(
        unassignedStops.removeLast(),
        unassignedStops,
        mergeDistance
      )
    );
  }
}


/// Create an [Iterable] of [Stop]s where each [Stop] in the returned [Iterable]
/// has a distance that is shorter than the given [mergeDistance] to one ore more other [Stop]s in the [Iterable].
/// The [Iterable] includes the given [sampleStop].
///
/// This requires the given [Stop]s to be sorted by latitude in order to work correctly.

Iterable<Stop> _takeNearbyStops(Stop sampleStop, List<Stop>unassignedStops, double mergeDistance) sync* {
  yield sampleStop;

  final assignedStops = Queue<Stop>();

  // iterate list in reverse to circumvent the problem of deleting elements while iterating
  for (int i = unassignedStops.length - 1; i >= 0; i--) {
    final stop = unassignedStops[i];
    final latDelta = (sampleStop.location.latitude - stop.location.latitude).abs();
    final latDistance = metersPerLatitude * latDelta;
    if (latDistance > mergeDistance) {
      // leave iteration if lat difference is greater than the merge distance
      // since the stops are sorted by lat, all values after this will differ more in its distance
      break;
    }
    if (_distance(sampleStop.location, stop.location) <= mergeDistance) {
      // remove current stop from unassigned list and to assigned queue
      assignedStops.add(stop);
      unassignedStops.removeAt(i);
    }
  }

  // check for every assigned stop if there are any unassigned stops that are nearby
  while (assignedStops.isNotEmpty) {
    final assignedStop = assignedStops.removeFirst();
    yield* _takeNearbyStops(assignedStop, unassignedStops, mergeDistance);
  }
}
