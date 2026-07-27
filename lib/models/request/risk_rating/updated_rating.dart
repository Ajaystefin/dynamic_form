/// Represents updated rating information used for
/// internal risk rating evaluation and comparison.
class UpdatedRating {
  /// Creates an [UpdatedRating] instance.
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

  /// Creates an [UpdatedRating] instance from a JSON map.
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

  /// Entity identifier.
  final int? entityId;

  /// Customer RIM number.
  final int? rimNo;

  /// Existing final grade.
  final String? existingFinalGrade;

  /// Existing model name.
  final String? existingModelName;

  /// Existing financial year date.
  final String? existingFinacialYearDate;

  /// Existing cascade grade.
  final String? existingCascadeGrade;

  /// Existing cascade reason.
  final String? existingCascadeReason;

  /// Existing cascade note.
  final String? existingCascadeNote;

  /// Existing override reason.
  final String? existingOverrideReason;

  /// Existing override grade.
  final String? existingOverrideGrade;

  /// Existing override comment.
  final String? existingOverrideComment;

  /// Proposed final grade.
  final String? proposedFinalGrade;

  /// Proposed model name.
  final String? proposedModelName;

  /// Proposed financial year date.
  final String? proposedFinacialYearDate;

  /// Source long name.
  final String? sourceLongName;

  /// Proposed cascade grade.
  final String? proposedCascadeGrade;

  /// Proposed cascade reason.
  final String? proposedCascadeReason;

  /// Proposed cascade note.
  final String? proposedCascadeNote;

  /// Proposed override reason.
  final String? proposedOverrideReason;

  /// Proposed override grade.
  final String? proposedOverrideGrade;

  /// Proposed override comment.
  final String? proposedOverrideComment;

  /// Indicates whether this is the latest version.
  final bool? isLatestVersion;

  /// Latest statement identifier.
  final int? latestStatementId;

  /// Business status.
  final String? businessStatus;

  /// Indicates whether CL Down is applicable.
  final bool? isClDown;
}
