const kPanoramaxUrl = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? 'https://osm-lens.vee.network'
    : 'https://osm-lens-sandbox.vee.network';
