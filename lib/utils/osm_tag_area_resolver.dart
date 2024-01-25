// Derived from https://github.com/ideditor/id-area-keys/blob/57544340ffec7e3dc0028ae9f2e0b5ea59eb2c63/areaKeys.json
//
// Copyright (c) 2019, iD Contributors
//
// SPDX-License-Identifier: ISC

/// This map contains all tags that describe an area as long as none of the specified exceptions matches.
/// Tags with these values describe a linear feature instead.

const _areaTags = <String, Set<String>>{
  'addr:*': {},
  'advertising': {
    'billboard'
  },
  'aerialway': {
    'cable_car',
    'chair_lift',
    'drag_lift',
    'gondola',
    'goods',
    'j-bar',
    'magic_carpet',
    'mixed_lift',
    'platter',
    'rope_tow',
    't-bar',
    'zip_line'
  },
  'aeroway': {
    'jet_bridge',
    'parking_position',
    'runway',
    'taxiway'
  },
  'allotments': {},
  'amenity': {
    'bench'
  },
  'area:highway': {},
  'attraction': {
    'dark_ride',
    'river_rafting',
    'summer_toboggan',
    'train',
    'water_slide'
  },
  'bridge:support': {},
  'building': {},
  'building:part': {},
  'club': {},
  'craft': {},
  'demolished:building': {},
  'disused:amenity': {},
  'disused:railway': {},
  'disused:shop': {},
  'emergency': {
    'designated',
    'destination',
    'no',
    'official',
    'private',
    'yes'
  },
  'golf': {
    'cartpath',
    'hole',
    'path'
  },
  'healthcare': {},
  'historic': {},
  'indoor': {
    'corridor',
    'wall'
  },
  'industrial': {},
  'internet_access': {},
  'junction': {},
  'landuse': {},
  'leisure': {
    'slipway',
    'track'
  },
  'man_made': {
    'breakwater',
    'crane',
    'cutline',
    'dyke',
    'embankment',
    'goods_conveyor',
    'groyne',
    'pier',
    'pipeline',
    'torii'
  },
  'military': {
    'trench'
  },
  'natural': {
    'bay',
    'cliff',
    'coastline',
    'ridge',
    'tree_row',
    'valley'
  },
  'office': {},
  'piste:type': {
    'downhill',
    'hike',
    'ice_skate',
    'nordic',
    'skitour',
    'sled',
    'sleigh'
  },
  'place': {},
  'playground': {
    'balancebeam',
    'slide',
    'zipwire'
  },
  'polling_station': {},
  'power': {
    'cable',
    'line',
    'minor_line'
  },
  'public_transport': {},
  'residential': {},
  'seamark:type': {},
  'shop': {},
  'telecom': {},
  'tourism': {
    'artwork',
    'attraction'
  },
  'traffic_calming': {
    'bump',
    'chicane',
    'choker',
    'cushion',
    'dip',
    'hump',
    'island',
    'rumble_strip'
  },
  'waterway': {
    'canal',
    'dam',
    'ditch',
    'drain',
    'fish_pass',
    'lock_gate',
    'river',
    'stream',
    'tidal_channel',
    'weir'
  }
};


/// Returns true when the given tags describe an area.
/// More info here: https://github.com/ideditor/id-area-keys/blob/57544340ffec7e3dc0028ae9f2e0b5ea59eb2c63/README.md

bool isArea(Map<String, String> tags) {
  final area = tags['area'];
  if (area == 'yes') return true;
  if (area == 'no') return false;

  for (final entry in tags.entries) {
    final values = _areaTags[entry.key];
    if (values != null && !values.contains(entry.value)) {
      return true;
    }
  }

  return false;
}
