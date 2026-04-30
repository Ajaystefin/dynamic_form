import "package:wcas_frontend/core/utils/utils.dart";

class OtherCertificationsState {
  OtherCertificationsState({
    required this.loaderStatus,
    required this.type,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  CertificationType type = CertificationType.rm;

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
