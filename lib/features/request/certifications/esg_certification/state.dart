import "package:wcas_frontend/core/utils/utils.dart";

class EsgCertificationState {
  const EsgCertificationState({
    required this.loaderStatus,
    this.additionalChecklist = "",
    this.fieldVersion = 0,
  });
  final LoadingStatus loaderStatus;
  final String additionalChecklist;
  final int fieldVersion;

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
