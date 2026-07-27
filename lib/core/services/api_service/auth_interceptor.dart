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

/// Authentication Interceptor
///
/// Adds authentication headers to outgoing requests, refreshes expired
/// tokens, and handles authentication-related API errors.
class AuthInterceptor extends Interceptor {
  /// Creates an authentication interceptor.
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
        logger.i("Auth: token expired, refreshing before ${options.path}");
        token = await _authRepo.refreshToken();
      }
      options.headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "sessionID": Globals.sessionID,
      };
    } else {
      logger.i(
        "Auth: no stored token, sending ${options.path} unauthenticated",
      );
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
      logger.w("Auth: 401 on ${err.requestOptions.path}, logging out");
      _authRepo.logout();
    }

    if (err.response?.statusCode == HttpStatus.conflict) {
      if (_isConflictDialogOpen) {
        logger.i(
          "Auth: 409 on ${err.requestOptions.path}, conflict dialog "
          "already open, ignoring",
        );
        return; // Swallowing error to prevent alerts as per viewModel logic
      }

      logger.w("Auth: 409 session conflict on ${err.requestOptions.path}");
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
