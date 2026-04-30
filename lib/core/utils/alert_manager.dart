import "package:flutter/material.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class AlertManager {
  factory AlertManager() => _instance;

  AlertManager._internal() : _toastification = ToastificationImpl();

  AlertManager._withDependency(this._toastification);

  factory AlertManager.withToastification(
    ToastificationInterface toastification,
  ) {
    return AlertManager._withDependency(toastification);
  }
  static AlertManager _instance = AlertManager._internal();
  static set instance(AlertManager newInstance) => _instance = newInstance;

  final ToastificationInterface _toastification;

  static void overrideInstance(AlertManager mock) {
    _instance = mock;
  }

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
      description: Text(
        message,
        style: const TextStyle(color: AppColors.white),
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

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
      description: Text(
        message,
        style: const TextStyle(color: AppColors.white),
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

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
      description: Text(
        message,
        style: const TextStyle(color: AppColors.black),
      ),
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: false,
    );
  }

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

/// Abstract interface for toastification to allow dependency injection and
/// mocking
abstract class ToastificationInterface {
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
        showType: CloseButtonShowType.always,
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
