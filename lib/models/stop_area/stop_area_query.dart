import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/api/overpass_query_api.dart';
import '/utils/geo_utils.dart';
import 'stop_area.dart';


class StopAreaQuery extends OverpassQuery<Iterable<StopArea>> {

  @override
  final String query;

  /// Padding in meters that will be applied afterwards to the stop area bounding boxes.

  final double padding;

  StopAreaQuery({
    this.padding = 50,
    int mergeRadius = 100,
  }) : query = _buildQuery(mergeRadius);

  static String _buildQuery (int mergeRadius) =>
    // get all platforms
    'nwr[public_transport=platform]->.remaining_platforms;'
    // loop over every single platform element
    'foreach.remaining_platforms {'
      // make intersection of current platform (default set ._) and .remaining_platforms
      // therefore only if the current platform is in remaining_platforms count will be 1
      // otherwise it has already been merged and therefore removed from remaining_platforms
      'nwr._.remaining_platforms;'
      'if (count(nwr) > 0) {'
        // find any nearby platforms
        // this loops for every newly found platform until no new platforms are found
        // 10 is the max number of iterations
        'complete(10) -> .grouped {'
          'nwr.remaining_platforms(around:$mergeRadius);'
        '}'
        // delete .grouped platforms from .remaining_platforms set
        '(.remaining_platforms; - .grouped;) -> .remaining_platforms;'
        // write to default set because make always reads from default set
        '.grouped -> ._;'
        // build the target areas
        'make zone '
          // we could also use `u` instead of `min` here to only get the name if all
          // grouped platforms have the same name
          // benefit of min is that we will always get a name if one exists
          'name=min(t["name"]),'
          // uncomment the following line to get the source elements
          // 'source=set("{"+type()+" "+id()+"}"),'
          // group geometries into one
          '::geom=gcat(geom());'
        // output bbox only
        'out bb;'
      '}'
    '}';

  @override
  Iterable<StopArea> responseTransformer(Map<String, dynamic>? response) sync* {
    final List<dynamic>? elements = response?['elements'];
    if (elements != null) {
      for (final element in elements) {
        final points = (element['geometry']['coordinates'] as List<dynamic>)
          .map<LatLng>(
            (p) => LatLng(p[1].toDouble(), p[0].toDouble()),
          )
          .toList(growable: false);
        // inflate bbox by 50 meters in each direction
        final bbox = LatLngBounds.fromPoints(points).pad(padding);
        String? name = element['tags']?['name'];
        if (name?.isEmpty == true) name = null;
        yield StopArea(bbox.southWest, bbox.northEast, name: name);
      }
    }
  }
}
