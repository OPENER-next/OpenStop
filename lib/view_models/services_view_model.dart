import 'package:dio/dio.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/authentication/panoramax_authentication_api.dart';
import '/api/preferences_service.dart';
import '/api/user_account_service.dart';
import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';

class ServicesViewModel extends ViewModel {
  PreferencesService get _preferencesService => getService<PreferencesService>();

  PanoramaxAccountService get _photoAccountService => getService<PanoramaxAccountService>();

  Uri get panoramaxInstance => Uri.parse(_preferencesService.panoramaxInstance);

  bool get panoramaxUserIsLoggedIn => _photoAccountService.isLoggedIn;

  String? get panoramaxUserName => _photoAccountService.authenticatedUser?.name;

  void loginPanoramax() => _photoAccountService.login();

  void logoutPanoramax() => _photoAccountService.logout();

  void openPanoramaxUserProfile() => _photoAccountService.authenticatedUser?.openUserProfile();

  void openPanoramaxWebsite() => launchUrl(panoramaxInstance, mode: LaunchMode.externalApplication);

  /// Switches to the given Panoramax instance and logs out of the current one.
  /// An empty value restores the default instance.
  /// Returns false if the URL is not a secure Panoramax instance that can be reached.

  Future<bool> changePanoramaxInstance(String value) async {
    final input = value.trim().replaceFirst(RegExp(r'/+$'), '');
    final instance = Uri.tryParse(input.isEmpty ? kPanoramaxUrl : input);
    if (instance == null || instance.scheme != 'https' || instance.host.isEmpty) return false;
    if (instance == panoramaxInstance) return true;

    final dio = Dio();
    try {
      await dio.get<Map<String, dynamic>>(
        '$instance/api',
        options: Options(
          headers: {
            'User-Agent': kAppUserAgent,
          },
        ),
      );
    } on DioException {
      return false;
    } finally {
      dio.close();
    }

    final previousService = _photoAccountService;
    await previousService.logout();
    if (previousService.isLoggedIn) return false;
    // The authentication API is bound to one instance, so replace the whole account service.
    // Update the preference afterwards, so views observing it rebuild with the new service.
    GetIt.I.unregister<PanoramaxAccountService>(instance: previousService);
    GetIt.I.registerSingleton<PanoramaxAccountService>(
      PanoramaxAccountService(PanoramaxAuthenticationAPI(endPoint: instance.toString())),
    );
    _preferencesService.panoramaxInstance = instance.toString();
    return true;
  }
}
