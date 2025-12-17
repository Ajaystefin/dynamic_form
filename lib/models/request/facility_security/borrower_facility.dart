class Borrower {
  final int applicationBorrowerId;
  final int customerRimNo;
  final String? appRefNo;
  final int? groupId;
  final int? groupOwner;
  final String? groupName;
  final String? groupStatus;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? preferredName;
  final String? customerStatus;
  final String? createdBy;
  final String? createdDate;
  final String? updatedBy;
  final String? updatedDate;

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

  factory Borrower.fromJson(Map<String, dynamic> json) {
    return Borrower(
      applicationBorrowerId: (json['applicationBorrowerId'] ?? 0) as int,
      customerRimNo: (json['customerRimNo'] ?? 0) as int,
      appRefNo: json['appRefNo'] as String?,
      groupId: json['groupId'] as int?,
      groupOwner: json['groupOwner'] as int?,
      groupName: json['groupName'] as String?,
      groupStatus: json['groupStatus'] as String?,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      preferredName: json['preferredName'] as String?,
      customerStatus: json['customerStatus'] as String?,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] as String?,
      updatedBy: json['updatedBy'] as String?,
      updatedDate: json['updatedDate'] as String?,
    );
  }

  /// Display label: preferredName -> lastName -> "RIM NO <rim>"
  String get displayName {
    if ((preferredName ?? '').trim().isNotEmpty) return preferredName!;
    if ((lastName ?? '').trim().isNotEmpty) return lastName!;
    return 'RIM NO $customerRimNo';
  }
}
