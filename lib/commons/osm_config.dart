import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import 'app_config.dart';

const kOAuth2ClientId = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? 'jkUcoZ_7SbO3zLsxtOubJeDe1_lUw-leKH5_mhRXDAE'
    : 'F0hAZhRoqdSyQJyAGTRCeXVqwAw6RbSCS-2uAE0Fu8c';

const kOAuth2RedirectUri = kIsWeb
    ? bool.fromEnvironment('IS_RELEASE', defaultValue: false)
          ? '$kAppCallbackUrlScheme://try.openstop.app/oauth2.html'
          : '$kAppCallbackUrlScheme://127.0.0.1:8080/oauth2.html'
    : '$kAppCallbackUrlScheme://$kAppCallbackUrlHost$kAppCallbackUrlPath';

const kOSMServer = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? 'www.openstreetmap.org'
    : 'master.apis.dev.openstreetmap.org';

const kOSMAttributionURL = 'https://www.openstreetmap.org/copyright';

/// OSMAPI with app specific default parameters.

class DefaultOSMAPI extends OSMAPI {
  static const endPoint = 'https://$kOSMServer/api/0.6';

  DefaultOSMAPI({
    super.authentication,
    super.userAgent = kAppUserAgent,
    super.baseUrl = endPoint,
    super.connectTimeout = const Duration(seconds: 15),
    //  the duration during data transfer of each byte event (not the total duration of the receiving)
    super.receiveTimeout = const Duration(seconds: 30),
  });
}
