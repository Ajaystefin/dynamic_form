/// Constants for autosave moduleKey values.
/// These represent the top-level categories for drafts.
/// Screen keys (formKey) will use the existing route strings from `Routes`.
part of "constants.dart";

/// Constants for autosave module key values.
///
/// These keys represent the top-level categories used for draft storage.
/// Screen keys (`formKey`) should continue using the existing route strings
/// defined in `Routes`.
class DraftModuleKeys {
  /// Administration module.
  static const String admin = "ADMIN";

  /// Approval module.
  static const String approval = "APPROVAL";

  /// CCSYS module.
  static const String ccsys = "CCSYS";

  /// Certifications module.
  static const String certifications = "CERTIFICATIONS";

  /// Covenants and Conditions module.
  static const String covenantsAndConditions = "COVENANTS_AND_CONDITIONS";

  /// Customer Information module.
  static const String customerInformation = "CUSTOMER_INFORMATION";

  /// Facilities and Securities module.
  static const String facilitiesAndSecurities = "FACILITIES_AND_SECURITIES";

  /// File Attachment and Digital eFiling module.
  static const String fileAttachmentAndDigitalEFiling =
      "FILE_ATTACHMENT_AND_DIGITAL_E_FILING";

  /// Group Information module.
  static const String groupInformation = "GROUP_INFORMATION";

  /// Profitability and Account Conduct module.
  static const String profitabilityAndAccountConduct =
      "PROFITABILITY_AND_ACCOUNT_CONDUCT";

  /// Projects module.
  static const String projects = "PROJECTS";

  /// Remarks module.
  static const String remarks = "REMARKS";

  /// Request Information module.
  static const String requestInformation = "REQUEST_INFORMATION";

  /// Risk Rating module.
  static const String riskRating = "RISK_RATING";
}
