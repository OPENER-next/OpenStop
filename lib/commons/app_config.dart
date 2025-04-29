import 'package:flutter/foundation.dart';

import 'version.g.dart';

const kAppName = 'OpenStop';

const kAppVersion = packageVersion;

const kAppUserAgent = '$kAppName $kAppVersion';

const kAppCallbackUrlScheme = kIsWeb && !bool.fromEnvironment('IS_RELEASE', defaultValue: false)
    ? 'http'
    : 'https';

const kAppCallbackUrlHost = 'openstop.app';

const kAppCallbackUrlPath = '/oauth2';

const kAppProjectUrl = 'https://github.com/OPENER-next/OpenStop';
