import "package:flutter/material.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Splash screen.
///
/// Holds information about the current loading status
/// during app initialization.
@immutable
class SplashState {
  /// Creates an instance of [SplashState].
  ///
  /// Requires the current [loaderStatus].
  const SplashState({required this.loaderStatus});

  /// Indicates the current loading status of the splash screen.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  SplashState copyWith({LoadingStatus? loaderStatus}) {
    return SplashState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplashState &&
          runtimeType == other.runtimeType &&
          loaderStatus == other.loaderStatus;

  @override
  int get hashCode => loaderStatus.hashCode;
}
