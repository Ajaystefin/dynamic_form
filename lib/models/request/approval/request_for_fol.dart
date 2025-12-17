class LegalAndLimitDetails {
  final bool isFOLApproved;
  final int userAction;
  final int roleId;

  LegalAndLimitDetails({
    required this.isFOLApproved,
    required this.userAction,
    required this.roleId,
  });

  factory LegalAndLimitDetails.fromJson(Map<String, dynamic> json) {
    return LegalAndLimitDetails(
      isFOLApproved: json['isFOLApproved'] as bool,
      userAction: json['userAction'] as int,
      roleId: json['roleId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'isFOLApproved': isFOLApproved,
        'userAction': userAction,
        'roleId': roleId,
      };
}
