class UpdatedRating {
  UpdatedRating({
    this.entityId,
    this.rimNo,
    this.existingFinalGrade,
    this.existingModelName,
    this.existingFinacialYearDate,
    this.existingCascadeGrade,
    this.existingCascadeReason,
    this.existingCascadeNote,
    this.existingOverrideReason,
    this.existingOverrideGrade,
    this.existingOverrideComment,
    this.proposedFinalGrade,
    this.proposedModelName,
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
      entityId: json["entityId"],
      rimNo: json["rimNo"],
      existingFinalGrade: json["existingFinalGrade"],
      existingModelName: json["existingModelName"],
      existingFinacialYearDate: json["existingFinacialYearDate"],
      existingCascadeGrade: json["existingCascadeGrade"],
      existingCascadeReason: json["existingCascadeReason"],
      existingCascadeNote: json["existingCascadeNote"],
      existingOverrideReason: json["existingOverrideReason"],
      existingOverrideGrade: json["existingOverrideGrade"],
      existingOverrideComment: json["existingOverrideComment"],
      proposedFinalGrade: json["proposedFinalGrade"],
      proposedModelName: json["proposedModelName"],
      proposedFinacialYearDate: json["proposedFinacialYearDate"],
      sourceLongName: json["sourceLongName"],
      proposedCascadeGrade: json["proposedCascadeGrade"],
      proposedCascadeReason: json["proposedCascadeReason"],
      proposedCascadeNote: json["proposedCascadeNote"],
      proposedOverrideReason: json["proposedOverrideReason"],
      proposedOverrideGrade: json["proposedOverrideGrade"],
      proposedOverrideComment: json["proposedOverrideComment"],
      isLatestVersion: json["isLatestVersion"],
      latestStatementId: json["latestStatementId"],
      businessStatus: json["businessStatus"],
    );
  }
  final int? entityId;
  final int? rimNo;
  final String? existingFinalGrade;
  final String? existingModelName;
  final String? existingFinacialYearDate;
  final String? existingCascadeGrade;
  final String? existingCascadeReason;
  final String? existingCascadeNote;
  final String? existingOverrideReason;
  final String? existingOverrideGrade;
  final String? existingOverrideComment;
  final String? proposedFinalGrade;
  final String? proposedModelName;
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
}
