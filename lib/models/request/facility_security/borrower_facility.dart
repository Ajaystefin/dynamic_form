/// Represents a borrower associated with an application.
class Borrower {
  /// Creates a [Borrower] instance.
  Borrower({
    required this.applicationBorrowerId,
    required this.customerRimNo,
    this.appRefNo,
    this.groupId,
    this.groupOwner,
    this.groupName,
    this.groupStatus,
    this.firstName,
    this.middleName,
    this.lastName,
    this.preferredName,
    this.customerStatus,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  /// Creates a [Borrower] instance from a JSON map.
  factory Borrower.fromJson(Map<String, dynamic> json) {
    return Borrower(
      applicationBorrowerId: (json["applicationBorrowerId"] ?? 0) as int,
      customerRimNo: (json["customerRimNo"] ?? 0) as int,
      appRefNo: json["appRefNo"] as String?,
      groupId: json["groupId"] as int?,
      groupOwner: json["groupOwner"] as int?,
      groupName: json["groupName"] as String?,
      groupStatus: json["groupStatus"] as String?,
      firstName: json["firstName"] as String?,
      middleName: json["middleName"] as String?,
      lastName: json["lastName"] as String?,
      preferredName: json["preferredName"] as String?,
      customerStatus: json["customerStatus"] as String?,
      createdBy: json["createdBy"] as String?,
      createdDate: json["createdDate"] as String?,
      updatedBy: json["updatedBy"] as String?,
      updatedDate: json["updatedDate"] as String?,
    );
  }

  /// Application borrower identifier.
  final int applicationBorrowerId;

  /// Customer RIM number.
  final int customerRimNo;

  /// Application reference number.
  final String? appRefNo;

  /// Group identifier.
  final int? groupId;

  /// Group owner identifier.
  final int? groupOwner;

  /// Group name.
  final String? groupName;

  /// Group status.
  final String? groupStatus;

  /// First name.
  final String? firstName;

  /// Middle name.
  final String? middleName;

  /// Last name.
  final String? lastName;

  /// Preferred name.
  final String? preferredName;

  /// Customer status.
  final String? customerStatus;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  final String? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final String? updatedDate;

  /// Display label: preferredName -> lastName -> "RIM NO <>"
  String get displayName {
    if ((preferredName ?? "").trim().isNotEmpty) {
      return preferredName!;
    }
    if ((lastName ?? "").trim().isNotEmpty) {
      return lastName!;
    }
    return "RIM NO $customerRimNo";
  }
}
