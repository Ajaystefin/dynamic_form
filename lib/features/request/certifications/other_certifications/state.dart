import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Other Certifications feature.
///
/// Manages loading status and the selected certification type.
class OtherCertificationsState {
  /// Creates an instance of [OtherCertificationsState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [type] represents the selected certification type.
  OtherCertificationsState({
    required this.loaderStatus,
    required this.type,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the selected certification type.
  CertificationType type = CertificationType.rm;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  OtherCertificationsState copyWith({
    LoadingStatus? loaderStatus,
    CertificationType? type,
  }) {
    return OtherCertificationsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      type: type ?? this.type,
    );
  }
}
