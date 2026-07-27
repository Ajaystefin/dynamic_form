import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for facility security linkage.
///
/// Holds information related to the loading status of the linkage process.
class FacilitySecurityLinkageState {
  /// Creates an instance of [FacilitySecurityLinkageState].
  ///
  /// Requires the current [loaderStatus].
  const FacilitySecurityLinkageState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of facility security linkage.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  FacilitySecurityLinkageState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitySecurityLinkageState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
