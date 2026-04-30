import "package:wcas_frontend/core/utils/date_time_utils.dart";

class AppendixComment {
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
  final String appRefNo;
  final String commentType;
  final String comments;
  final String? name;
  final String? note;
  final String createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

  final int? appendixRemarkId;
}
