import "package:wcas_frontend/models/admin/reference.dart";

class CertificationData {
  CertificationData({
    required this.certificateInformation,
    this.appCertificationId,
    this.selectedOption,
    this.remarks,
    this.certificationCategory,
    this.isUpdated = false,
  });

  factory CertificationData.fromJson(Map<String, dynamic> json) {
    return CertificationData(
      appCertificationId: json["appCertificationId"],
      certificateInformation:
          Reference.fromJson(json["certificateInformation"] ?? {}),
      selectedOption:
          json["option"] != null ? Reference.fromJson(json["option"]) : null,
      remarks: json["remarks"],
      certificationCategory: json["certificationCategory"],
      isUpdated: false, // Always false when loading from API
    );
  }
  int? appCertificationId;
  Reference certificateInformation;
  Reference? selectedOption;
  String? remarks;
  int? certificationCategory;
  bool isUpdated;

  Map<String, dynamic> toJson() {
    return {
      "appCertificationId": appCertificationId,
      "certificateInformation": certificateInformation.toJson(),
      "option": selectedOption?.toJson(),
      "remarks": remarks,
      "certificationCategory": certificationCategory,
    };
  }
}
