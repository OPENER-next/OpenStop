import 'app_config.dart';

const oAuth2ClientId = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'Y82_lwoOuvAiSVBGOwFehyYUkm-l9AEsh4BB-2ivL8U'
  : 'dCjr74PY2yc2Ntk302zv0ENMTO9lnGFIR4o6nLnN3nE';

const oAuth2RedirectUri = '$appCallbackUrlScheme:/oauth2';

const osmServerUri = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'https://www.openstreetmap.org'
  : 'https://master.apis.dev.openstreetmap.org';

const osmCreditsText = 'Data © OpenStreetMap-Mitwirkende';

const osmCreditsURL= 'https://www.openstreetmap.org/copyright';
