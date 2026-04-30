// lib/models/request/appendix/group_corporate_structure_comment_payload.dart
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";

class GroupCorporateStructureCommentPayload {
  const GroupCorporateStructureCommentPayload({
    required this.appRefNo,
    required this.createdBy,
    required this.updatedBy,
    this.commentType = ServerConstants.groupCorporateStucture,
    this.comments,
    this.name,
    this.notes,
    this.createdDate,
    this.updatedDate,
    this.commentId, // new
    this.appendixRemarkId,
  });

  factory GroupCorporateStructureCommentPayload.fromContext({
    required String appRefNo,
    String commentType = ServerConstants.groupCorporateStucture,
    String? comments,
    String? name,
    String? notes,
    String? commentId, // new
    int? appendixRemarkId,
  }) {
    final String userName = (Globals.user?.name?.trim().isNotEmpty == true
        ? Globals.user!.name!
        : "system");
    final DateTime nowUtc = DateTime.now().toUtc();
    return GroupCorporateStructureCommentPayload(
      appRefNo: appRefNo,
      commentType: commentType,
      comments: comments,
      name: name,
      notes: notes,
      createdBy: userName,
      createdDate: nowUtc,
      updatedBy: userName,
      updatedDate: nowUtc,
      commentId: commentId,
      appendixRemarkId: appendixRemarkId,
    );
  }
  final String appRefNo;
  final String commentType;
  final String? comments;
  final String? name;
  final String? notes;

  final String? commentId;

  // audit
  final String createdBy;
  final DateTime? createdDate;
  final String updatedBy;
  final DateTime? updatedDate;
  final int? appendixRemarkId;

  Map<String, dynamic> toJson() {
    return {
      "appRefNo": appRefNo,
      "commentType": commentType,
      if (comments != null) "comments": comments,
      if (name != null) "name": name,
      if (notes != null) "note": notes,
      "createdBy": createdBy,
      "createdDate": createdDate?.toUtc().toIso8601String(),
      "updatedBy": updatedBy,
      "updatedDate": updatedDate?.toUtc().toIso8601String(),
      if (commentId != null) "commentId": commentId,
      "appendixRemarkId": appendixRemarkId,
    };
  }
}
