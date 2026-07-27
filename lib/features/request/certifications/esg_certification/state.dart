import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the ESG Certification feature.
///
/// Manages loading status, additional checklist information,
/// and field versioning for the certification process.
class EsgCertificationState {
  /// Creates an instance of [EsgCertificationState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [additionalChecklist] holds any extra checklist data,
  /// and [fieldVersion] tracks field updates or changes.
  const EsgCertificationState({
    required this.loaderStatus,
    this.additionalChecklist = "",
    this.fieldVersion = 0,
  });

  /// Defines the overall loading status of the ESG certification process.
  final LoadingStatus loaderStatus;

  /// Stores additional checklist details for certification.
  final String additionalChecklist;

  /// Tracks the version of fields for update handling.
  final int fieldVersion;

  /// Creates a new instance of [EsgCertificationState] with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  EsgCertificationState copyWith({
    LoadingStatus? loaderStatus,
    String? additionalChecklist,
    int? fieldVersion,
  }) {
    return EsgCertificationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      additionalChecklist: additionalChecklist ?? this.additionalChecklist,
      fieldVersion: fieldVersion ?? this.fieldVersion,
    );
  }
}
