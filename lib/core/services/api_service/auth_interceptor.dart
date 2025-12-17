import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorageService _localStorageService;
  AuthRepository? _authRepository;

  AuthInterceptor({
    LocalStorageService? localStorageService,
    AuthRepository? authRepository,
  })  : _localStorageService = localStorageService ?? LocalStorageService(),
        _authRepository = authRepository;

  AuthRepository get _authRepo {
    _authRepository ??= AuthRepository.instance;
    return _authRepository!;
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await _localStorageService.get<String>(
        LocalStorageBoxes.user, LocalStorageKeys.authToken);
    if (token != null) {
      bool isRefreshTokenCall =
          options.path.contains(APIEndpoints.refreshToken);
      int? tokenExpiryTime = await _localStorageService.get<int>(
          LocalStorageBoxes.user, LocalStorageKeys.tokenExpiryTime);
      logger.i(
          "current time: ${DateTime.now().millisecondsSinceEpoch}token expiry:$tokenExpiryTime");
      if (tokenExpiryTime != null &&
          DateTime.now().millisecondsSinceEpoch >= tokenExpiryTime &&
          !isRefreshTokenCall) {
        // regenerate the token if it is expired and not refresh token call itself, to avoid looping itself.
        token = await _authRepo.refreshToken();
      }
      options.headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      };
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == HttpStatus.unauthorized &&
        Globals.currentRoute != Routes.login) {
      // if any api except login throws 401, logout.
      _authRepo.logout();
    }

    super.onError(err, handler);
  }
}
