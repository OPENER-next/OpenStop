import 'package:flutter/foundation.dart';

import 'app_config.dart';

const oAuth2ClientId = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'Y82_lwoOuvAiSVBGOwFehyYUkm-l9AEsh4BB-2ivL8U'
  : 'dCjr74PY2yc2Ntk302zv0ENMTO9lnGFIR4o6nLnN3nE';

const oAuth2RedirectUri = kIsWeb
  ? bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? '$appCallbackUrlScheme://try.openstop.app/oauth2.html'
    : '$appCallbackUrlScheme://127.0.0.1:8080/oauth2.html'
  : '$appCallbackUrlScheme:/oauth2';

const osmServer = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'www.openstreetmap.org'
  : 'master.apis.dev.openstreetmap.org';

const osmCreditsURL= 'https://www.openstreetmap.org/copyright';
