import "package:wcas_frontend/core/utils/date_time_utils.dart";

/// Represents an appendix comment associated with an application.
class AppendixComment {
  /// Creates an [AppendixComment] instance.
  AppendixComment({
    required this.appRefNo,
    required this.commentType,
    required this.comments,
    required this.createdBy,
    this.name,
    this.note,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.appendixRemarkId,
  });

  /// Creates an [AppendixComment] instance from a JSON map.
  factory AppendixComment.fromJson(Map<String, dynamic> json) {
    return AppendixComment(
      appRefNo: (json["appRefNo"] ?? "").toString(),
      commentType: (json["commentType"] ?? "").toString().trim(),
      comments: (json["comments"] ?? "").toString(),
      name: json["name"] as String?,
      note: json["note"] as String?,
      createdBy: (json["createdBy"] ?? "").toString(),
      createdDate: json["createdDate"] != null
          ? DateTimeUtils.parseDateTime(json["createdDate"])
          : null,
      updatedBy: json["updatedBy"] as String?,
      updatedDate: json["updatedDate"] != null
          ? DateTimeUtils.parseDateTime(json["updatedDate"])
          : null,
      appendixRemarkId: json["appendixRemarkId"],
    );
  }

  /// Application reference number.
  final String appRefNo;

  /// Comment type.
  final String commentType;

  /// Comment text.
  final String comments;

  /// Name associated with the comment.
  final String? name;

  /// Additional note.
  final String? note;

  /// User who created the comment.
  final String createdBy;

  /// Comment creation date.
  final DateTime? createdDate;

  /// User who last updated the comment.
  final String? updatedBy;

  /// Comment last update date.
  final DateTime? updatedDate;

  /// Appendix remark identifier.
  final int? appendixRemarkId;
}
