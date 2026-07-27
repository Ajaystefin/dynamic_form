import "package:flutter/material.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Alert Manager
///
/// Displays application toast notifications.
class AlertManager {
  /// Returns the singleton instance.
  factory AlertManager() => _instance;

  AlertManager._internal() : _toastification = ToastificationImpl();

  AlertManager._withDependency(this._toastification);

  /// Creates an alert manager with a custom toastification implementation.
  factory AlertManager.withToastification(
    ToastificationInterface toastification,
  ) {
    return AlertManager._withDependency(toastification);
  }
  static AlertManager _instance = AlertManager._internal();

  /// Overrides the singleton instance.
  ///
  /// This setter is kept for tests and manual instance replacement.
  /// A getter is intentionally not exposed because normal access happens
  // ignore: avoid_setters_without_getters
  static set instance(AlertManager newInstance) => _instance = newInstance;

  final ToastificationInterface _toastification;

  /// Returns the singleton instance for testing.
  @visibleForTesting
  static AlertManager get overrideInstance => _instance;

  /// Overrides the singleton instance for testing.
  @visibleForTesting
  static set overrideInstance(AlertManager mock) {
    _instance = mock;
  }

  Widget _buildDescription(String message, Color color) {
    return Builder(
      builder: (context) {
        return RichText(
          text: TextSpan(
            text: message,
            style: DefaultTextStyle.of(context).style.copyWith(color: color),
          ),
        );
      },
    );
  }

  /// Displays a failure toast message.
  void showFailureToast(String message) {
    _toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      backgroundColor: AppColors.alertToastFailure,
      foregroundColor: AppColors.white,
      primaryColor: AppColors.alertToastFailure,
      icon: const Icon(
        Icons.cancel,
        color: AppColors.white,
      ),
      closeButtonColor: AppColors.white,
      description: _buildDescription(
        message,
        AppColors.white,
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

  /// Displays a success toast message.
  void showSuccessToast(String message) {
    _toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      backgroundColor: AppColors.alertToastSuccess,
      foregroundColor: AppColors.white,
      primaryColor: AppColors.alertToastSuccess,
      icon: const Icon(
        Icons.check_circle,
        color: AppColors.white,
      ),
      closeButtonColor: AppColors.white,
      description: _buildDescription(
        message,
        AppColors.white,
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

  /// Displays a warning toast message.
  void showWarningToast(String message) {
    _toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      backgroundColor: AppColors.alertToastWarning,
      foregroundColor: AppColors.white,
      icon: const Icon(
        Icons.warning,
        color: AppColors.black,
      ),
      closeButtonColor: AppColors.black,
      description: _buildDescription(
        message,
        AppColors.black,
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

  /// Displays an informational toast message.
  void showInfoToast(String message) {
    _toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }
}

/// Toastification Interface
///
/// Defines toast notification operations.
abstract class ToastificationInterface {
  /// Displays a toast notification.
  void show({
    required ToastificationType type,
    ToastificationStyle? style,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? primaryColor,
    Widget? icon,
    Widget? description,
    Widget? title,
    Duration? autoCloseDuration,
    bool? showProgressBar,
    Color? closeButtonColor,
  });
}

/// Production implementation of ToastificationInterface
class ToastificationImpl implements ToastificationInterface {
  @override
  void show({
    required ToastificationType type,
    ToastificationStyle? style,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? primaryColor,
    Widget? icon,
    Widget? description,
    Widget? title,
    Duration? autoCloseDuration,
    bool? showProgressBar,
    Color? closeButtonColor,
  }) {
    toastification.show(
      type: type,
      style: style,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      primaryColor: primaryColor,
      icon: icon,
      description: description,
      title: title,
      showIcon: true,
      autoCloseDuration: autoCloseDuration,
      showProgressBar: showProgressBar,
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) {
          return IconButton(
            icon: Icon(Icons.close, size: 20, color: closeButtonColor),
            onPressed: onClose,
            tooltip: "Close",
          );
        },
      ),
    );
  }
}
