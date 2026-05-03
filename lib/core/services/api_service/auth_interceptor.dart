import "dart:io";

import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/session_conflict_dialog.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    LocalStorageService? localStorageService,
    AuthRepository? authRepository,
  })  : _localStorageService = localStorageService ?? LocalStorageService(),
        _authRepository = authRepository;
  final LocalStorageService _localStorageService;
  AuthRepository? _authRepository;
  static bool _isConflictDialogOpen = false;

  AuthRepository get _authRepo {
    _authRepository ??= AuthRepository.instance;
    return _authRepository!;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = await _localStorageService.get<String>(
      LocalStorageBoxes.user,
      LocalStorageKeys.authToken,
    );
    if (token != null) {
      final bool isRefreshTokenCall =
          options.path.contains(APIEndpoints.refreshToken);
      final int? tokenExpiryTime = await _localStorageService.get<int>(
        LocalStorageBoxes.user,
        LocalStorageKeys.tokenExpiryTime,
      );
      logger.i(
        "current time: ${DateTime.now().millisecondsSinceEpoch}token "
        "expiry:$tokenExpiryTime",
      );
      if (tokenExpiryTime != null &&
          DateTime.now().millisecondsSinceEpoch >= tokenExpiryTime &&
          !isRefreshTokenCall) {
        // regenerate the token if it is expired and not refresh token call
        // itself, to avoid looping itself.
        token = await _authRepo.refreshToken();
      }
      options.headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "sessionID": Globals.sessionID,
      };
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == HttpStatus.unauthorized &&
        Globals.currentRoute != Routes.login &&
        !err.requestOptions.path.contains(APIEndpoints.login) &&
        !err.requestOptions.path.contains(APIEndpoints.logout) &&
        !err.requestOptions.path.contains(APIEndpoints.validateRSAToken)) {
      // if any api except login throws 401, logout.
      _authRepo.logout();
    }

    if (err.response?.statusCode == HttpStatus.conflict) {
      if (_isConflictDialogOpen) {
        return; // Swallowing error to prevent alerts as per viewModel logic
      }

      _isConflictDialogOpen = true;
      final BuildContext? context = Globals.navigatorKey.currentContext;
      if (context != null) {
        DialogHelper.showCustomDialog(
          context: context,
          width: 300.w,
          title: "common.components.sessionConflict.title".tr(),
          content: const SessionConflictDialog(),
          barrierDismissible: false,
          showCloseButton: false,
        ).then((_) {
          _isConflictDialogOpen = false;
        });
      }
      return; // Swallowing error to prevent alerts as per viewModel logic
    }

    super.onError(err, handler);
  }
}
