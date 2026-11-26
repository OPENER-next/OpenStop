import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'osm_config.dart';

const kPanoramaxUrl = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? 'https://osm-lens.vee.network'
    : 'https://osm-lens-sandbox.vee.network';

/// The scheme the token claim page uses to return to the app.
///
/// Unlike the OSM login this is a custom scheme instead of the verified https app link.
/// When the user is still logged in on the Panoramax website, the claim page redirects
/// immediately without any user interaction, and browsers do not hand such redirects
/// to a verified https app link. The redirect carries no secret, so a custom scheme is safe here.
const kPanoramaxCallbackUrlScheme = kIsWeb
    ? kAppCallbackUrlScheme
    : 'de.tu-chemnitz.etit.sse.openstop';

const kPanoramaxCallbackUri = kIsWeb
    ? kOAuth2RedirectUri
    : '$kPanoramaxCallbackUrlScheme://panoramax';
