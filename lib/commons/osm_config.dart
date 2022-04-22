import 'app_config.dart';

const oAuth2ClientId = 'XWjiQpZ8E8eOq1i50M8UW68Z4HW_bwaeC3qj1nNLxNo';
const oAuth2RedirectUri = '$appCallbackUrlScheme:/oauth2';

const osmServerUri = bool.fromEnvironment('IS_RELEASE', defaultValue: false)
  ? 'https://www.openstreetmap.org'
  : 'https://master.apis.dev.openstreetmap.org';

const osmCreditsText = 'Data © OpenStreetMap-Mitwirkende';

const osmCreditsURL= 'https://www.openstreetmap.org/copyright';