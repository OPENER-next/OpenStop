import 'package:flutter/foundation.dart';

import 'app_config.dart';

const oAuth2ClientId = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'jkUcoZ_7SbO3zLsxtOubJeDe1_lUw-leKH5_mhRXDAE'
  : 'F0hAZhRoqdSyQJyAGTRCeXVqwAw6RbSCS-2uAE0Fu8c';

const oAuth2RedirectUri = kIsWeb
  ? bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? '$appCallbackUrlScheme://try.openstop.app/oauth2.html'
    : '$appCallbackUrlScheme://127.0.0.1:8080/oauth2.html'
  : '$appCallbackUrlScheme://$appCallbackUrlHost$appCallbackUrlPath';

const osmServer = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'www.openstreetmap.org'
  : 'master.apis.dev.openstreetmap.org';

const osmCreditsURL= 'https://www.openstreetmap.org/copyright';
