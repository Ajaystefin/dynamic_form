// lib/models/request/appendix/group_corporate_structure_comment_payload.dart
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";

/// Represents a payload for group corporate structure comments.
class GroupCorporateStructureCommentPayload {
  /// Creates a [GroupCorporateStructureCommentPayload] instance.
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

  /// Creates a [GroupCorporateStructureCommentPayload] instance
  /// using application context and default audit information.
  factory GroupCorporateStructureCommentPayload.fromContext({
    required String appRefNo,
    String commentType = ServerConstants.groupCorporateStucture,
    String? comments,
    String? name,
    String? notes,
    String? commentId, // new
    int? appendixRemarkId,
  }) {
    final String userName = (Globals.user?.name?.trim().isNotEmpty ?? false
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

  /// Application reference number.
  final String appRefNo;

  /// Comment type.
  final String commentType;

  /// Comment text.
  final String? comments;

  /// Comment title or name.
  final String? name;

  /// Additional notes.
  final String? notes;

  /// Comment identifier.
  final String? commentId;

  /// User who created the record.
  final String createdBy;

  /// Record creation date.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  /// Appendix remark identifier.
  final int? appendixRemarkId;

  /// Converts this [GroupCorporateStructureCommentPayload]
  /// instance to a JSON map.
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
