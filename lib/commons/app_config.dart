import 'package:flutter/foundation.dart';

import 'version.g.dart';

const appName = 'OpenStop';

const appVersion = packageVersion;

const appUserAgent = '$appName $appVersion';

const appCallbackUrlScheme = kIsWeb
  ? bool.fromEnvironment('IS_RELEASE', defaultValue: false) ? 'https' : 'http'
  : 'openstop.app';

const appProjectUrl = 'https://github.com/OPENER-next/OpenStop';
