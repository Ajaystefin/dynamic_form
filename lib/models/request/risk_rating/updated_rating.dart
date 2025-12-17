class UpdatedRating {
  final int? entityId;
  final int? rimNo;
  final String? existingFinalGrade;
  final String? existingMmodelId;
  final String? existingFinacialYearDate;
  final String? existingCascadeGrade;
  final String? existingCascadeReason;
  final String? existingCascadeNote;
  final String? existinOverrideReason;
  final String? existinOverrideGrade;
  final String? existinOverrideComment;
  final String? proposedFinalGrade;
  final String? proposedModelId;
  final String? proposedFinacialYearDate;
  final String? sourceLongName;
  final String? proposedCascadeGrade;
  final String? proposedCascadeReason;
  final String? proposedCascadeNote;
  final String? proposedOverrideReason;
  final String? proposedOverrideGrade;
  final String? proposedOverrideComment;
  final bool? isLatestVersion;
  final int? latestStatementId;
  final String? businessStatus;
  final bool? isClDown;

  UpdatedRating({
    this.entityId,
    this.rimNo,
    this.existingFinalGrade,
    this.existingMmodelId,
    this.existingFinacialYearDate,
    this.existingCascadeGrade,
    this.existingCascadeReason,
    this.existingCascadeNote,
    this.existinOverrideReason,
    this.existinOverrideGrade,
    this.existinOverrideComment,
    this.proposedFinalGrade,
    this.proposedModelId,
    this.proposedFinacialYearDate,
    this.sourceLongName,
    this.proposedCascadeGrade,
    this.proposedCascadeReason,
    this.proposedCascadeNote,
    this.proposedOverrideReason,
    this.proposedOverrideGrade,
    this.proposedOverrideComment,
    this.isLatestVersion,
    this.latestStatementId,
    this.businessStatus,
    this.isClDown,
  });

  factory UpdatedRating.fromJson(Map<String, dynamic> json) {
    return UpdatedRating(
      entityId: json['entityId'],
      rimNo: json['rimNo'],
      existingFinalGrade: json['existingFinalGrade'],
      existingMmodelId: json['existingMmodelId'],
      existingFinacialYearDate: json['existingFinacialYearDate'],
      existingCascadeGrade: json['existingCascadeGrade'],
      existingCascadeReason: json['existingCascadeReason'],
      existingCascadeNote: json['existingCascadeNote'],
      existinOverrideReason: json['existinOverrideReason'],
      existinOverrideGrade: json['existinOverrideGrade'],
      existinOverrideComment: json['existinOverrideComment'],
      proposedFinalGrade: json['proposedFinalGrade'],
      proposedModelId: json['proposedModelId'],
      proposedFinacialYearDate: json['proposedFinacialYearDate'],
      sourceLongName: json['sourceLongName'],
      proposedCascadeGrade: json['proposedCascadeGrade'],
      proposedCascadeReason: json['proposedCascadeReason'],
      proposedCascadeNote: json['proposedCascadeNote'],
      proposedOverrideReason: json['proposedOverrideReason'],
      proposedOverrideGrade: json['proposedOverrideGrade'],
      proposedOverrideComment: json['proposedOverrideComment'],
      isLatestVersion: json['isLatestVersion'],
      latestStatementId: json['latestStatementId'],
      businessStatus: json['businessStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'rimNo': rimNo,
      'existingFinalGrade': existingFinalGrade,
      'existingMmodelId': existingMmodelId,
      'existingFinacialYearDate': existingFinacialYearDate,
      'existingCascadeGrade': existingCascadeGrade,
      'existingCascadeReason': existingCascadeReason,
      'existingCascadeNote': existingCascadeNote,
      'existinOverrideReason': existinOverrideReason,
      'existinOverrideGrade': existinOverrideGrade,
      'existinOverrideComment': existinOverrideComment,
      'proposedFinalGrade': proposedFinalGrade,
      'proposedModelId': proposedModelId,
      'proposedFinacialYearDate': proposedFinacialYearDate,
      'sourceLongName': sourceLongName,
      'proposedCascadeGrade': proposedCascadeGrade,
      'proposedCascadeReason': proposedCascadeReason,
      'proposedCascadeNote': proposedCascadeNote,
      'proposedOverrideReason': proposedOverrideReason,
      'proposedOverrideGrade': proposedOverrideGrade,
      'proposedOverrideComment': proposedOverrideComment,
      'isLatestVersion': isLatestVersion,
      'latestStatementId': latestStatementId,
      'businessStatus': businessStatus,
    };
  }
}
