import "package:wcas_frontend/models/admin/reference.dart";

/// Represents certification data captured for an application,
/// including certificate information, selected options, and remarks.
class CertificationData {
  /// Creates a [CertificationData] instance.
  CertificationData({
    required this.certificateInformation,
    this.appCertificationId,
    this.selectedOption,
    this.remarks,
    this.certificationCategory,
    this.isUpdated = false,
  });

  /// Creates a [CertificationData] instance from a JSON map.
  factory CertificationData.fromJson(Map<String, dynamic> json) {
    return CertificationData(
      appCertificationId: json["appCertificationId"],
      certificateInformation:
          Reference.fromJson(json["certificateInformation"] ?? {}),
      selectedOption:
          json["option"] != null ? Reference.fromJson(json["option"]) : null,
      remarks: json["remarks"],
      certificationCategory: json["certificationCategory"],
    );
  }

  /// Unique identifier of the application certification record.
  int? appCertificationId;

  /// Certificate information associated with the certification.
  Reference certificateInformation;

  /// Selected certification option.
  Reference? selectedOption;

  /// Remarks provided for the certification.
  String? remarks;

  /// Category of the certification.
  int? certificationCategory;

  /// Indicates whether the certification data has been modified.
  bool isUpdated;

  /// Converts this [CertificationData] instance to a JSON map.
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
