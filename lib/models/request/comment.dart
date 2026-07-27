import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Represents a comment associated with an application,
/// review, strategy, contract, or workflow action.
class Comment {
  /// Creates a [Comment] instance.
  Comment({
    this.id,
    this.user,
    this.type,
    this.entityType,
    this.categoryId,
    this.categoryType,
    this.strategyComment,
    this.createdBy,
    this.createdDate,
    this.applicationRefNo,
    this.comment,
    this.commentId,
    this.draft,
    this.reviewCommentId,
    this.userId,
    this.userRole,
    this.strategyCommentTypeId,
    this.rimNo,
    this.reasonList,
    this.srcMigratedId,
    this.updatedBy,
    this.updatedDate,
    this.strategyCategory,
    this.name,
    this.notes,
  });

  /// Creates a [Comment] instance from user input data.
  factory Comment.fromInputData({
    String? strategyComment,
    String? categoryType,
    CommentsType? type,
    EntityIdentifier? entityType,
    int? categoryId,
    int? rimNo,
    String? comment,
    int? id,
    String? strategyCategory,
    String? name,
    String? notes,
    String? reviewCommentId,
    String? applicationRefNo,
  }) {
    return Comment(
      comment: comment,
      id: id,
      strategyCommentTypeId: ServerConstants.commentTypeId[type],
      strategyComment: strategyComment,
      applicationRefNo: Globals.request?.applicationRefNo ?? applicationRefNo,
      userId: Globals.user?.id,
      userRole: Globals.user?.currentRole?.roleId,
      categoryId: categoryId,
      rimNo: rimNo,
      categoryType: categoryType,
      type: type,
      entityType: entityType,
      strategyCategory: strategyCategory,
      name: name,
      notes: notes,
      reviewCommentId: reviewCommentId,
    );
  }

  /// Creates a [Comment] instance from a JSON map.
  Comment.fromJson(Map<String, dynamic> json) {
    if (json["appStrategyCommentsId"] != null) {
      id = json["appStrategyCommentsId"];
    } else if (json["id"] != null) {
      id = json["id"];
    }

    if (json["applicationRefNo"] != null) {
      applicationRefNo = json["applicationRefNo"];
    } else if (json["appRefNo"] != null) {
      applicationRefNo = json["appRefNo"];
    }

    if (json["contractCode"] != null) {
      contractCode = json["contractCode"];
    }

    if (json["CommentCategoryId"] != null) {
      categoryId = json["CommentCategoryId"];
    } else if (json["commentCategoryId"] != null) {
      categoryId = json["commentCategoryId"];
    }

    categoryType = json["categoryType"];

    if (json["categoryId"] != null) {
      categoryId = json["categoryId"];
    }

    categoryType = json["category"];
    strategyComment = json["strategyComment"];
    createdBy = json["createdBy"];
    createdDate = DateTimeUtils.intToDateTime(json["createdDate"]);
    comment = json["comment"];
    user = json["user"];
    rimNo = json["rimNo"];
    strategyCommentTypeId = json["strategyCommentType"];
    user = json["userName"];
    reasonList = json["reasonList"];
    name = json["name"];
    notes = json["note"];
    userId = json["userId"] ?? "";
    userRole = json["userRole"] ?? 0;

    if (json["RoleCode"] != null) {
      userRoleCode = json["RoleCode"] ?? "";
    }

    if (json["reviewCommentId"] != null) {
      reviewCommentId = '${json['reviewCommentId']}';
    }

    if (json["commentId"] != null) {
      commentId = json["commentId"];
    }
  }

  /// Identifier of the application strategy comment.
  int? appStrategyCommentsId;

  /// Unique identifier of the comment.
  int? id;

  /// Identifier of the comment category.
  int? categoryId;

  /// Identifier of the source migrated record.
  int? srcMigratedId;

  /// Type of comment category.
  String? categoryType;

  /// Strategy comment content.
  String? strategyComment;

  /// Identifier of the strategy comment type.
  int? strategyCommentTypeId;

  /// User who created the comment.
  String? createdBy;

  /// Strategy category associated with the comment.
  String? strategyCategory;

  /// Type of strategy comment.
  int? strategyCommentType;

  /// Date when the comment was created.
  DateTime? createdDate;

  /// Unique comment reference identifier.
  String? commentId;

  /// Application reference number.
  String? applicationRefNo;

  /// Comment text.
  String? comment;

  /// Indicates whether the comment is saved as a draft.
  bool? draft;

  /// Identifier of the user who submitted the comment.
  String? userId;

  /// Role identifier of the user.
  int? userRole;

  /// Role code of the user.
  String? userRoleCode;

  /// Review comment identifier.
  String? reviewCommentId;

  /// Display name of the user.
  String? user;

  /// Customer RIM number associated with the comment.
  int? rimNo;

  /// Comment type enumeration.
  CommentsType? type;

  /// Entity identifier associated with the comment.
  EntityIdentifier? entityType;

  /// List of reasons associated with the comment.
  String? reasonList;

  /// User who last updated the comment.
  String? updatedBy;

  /// Date when the comment was last updated.
  DateTime? updatedDate;

  /// Name associated with the comment.
  String? name;

  /// Notes associated with the comment.
  String? notes;

  /// Contract code associated with the comment.
  String? contractCode;

  /// Creates a copy of this [Comment] with updated ESG section values.
  Comment copyWithESGDynamicSection({
    int? id,
    String? strategyComment,
    int? categoryId,
    String? strategyCategory,
    DateTime? createdDate,
    // add other fields here as optional named params
  }) {
    return Comment(
      id: id ?? this.id,
      strategyComment: strategyComment ?? this.strategyComment,
      categoryId: categoryId ?? this.categoryId,
      strategyCategory: strategyCategory ?? this.strategyCategory,
      createdDate: createdDate ?? this.createdDate,
      // pass through other fields similarly
    );
  }

  /// Converts this [Comment] instance to a JSON map.
  Map<String, dynamic> toJson() {
    {
      final df = DateFormat("yyyy-MM-dd HH:mm:ss:SSS");
      final Map<String, dynamic> data = <String, dynamic>{};
      data["commentId"] = commentId;
      data["strategyComment"] = strategyComment;
      data["appRefNo"] = applicationRefNo;
      data["strategyCategory"] = strategyCategory;
      data["userAction"] = int.tryParse(reviewCommentId ?? "") ?? 0;
      data["comment"] = comment;
      data["categoryId"] = categoryId;
      data["id"] = id;
      data["strategyCommentType"] = strategyCommentTypeId;
      data["commentCategoryId"] = categoryId;
      data["categoryId"] = categoryId;
      data["name"] = name;
      data["notes"] = notes;
      // data['strategyCategory'] = "SIC_CODE_REVIEW";
      data["reasonList"] = reasonList ?? "";
      data["isDraft"] = (draft ?? false ? 1 : 0);
      data["userId"] = userId;
      data["userRole"] = userRole;
      data["createdBy"] = createdBy;
      data["createdDate"] = createdDate != null ? df.format(createdDate!) : "";
      data["updatedBy"] = updatedBy ?? createdBy;
      data["srcMigratedId"] = srcMigratedId;
      data["updatedDate"] = updatedDate != null
          ? df.format(updatedDate!)
          : df.format(DateTime.now());
      return data;
    }
  }

  /// Converts this [Comment] instance to a strategy comment JSON payload.
  Map<String, dynamic> toSaveStrategyCommentJson() {
    {
      final Map<String, dynamic> data = <String, dynamic>{};
      data["strategyComment"] = strategyComment;
      data["strategyCategory"] = strategyCategory;
      data["appRefNo"] = applicationRefNo;
      data["id"] = id;
      data["categoryId"] = categoryId;
      data["isDraft"] = (draft ?? false ? 1 : 0);
      data["userId"] = userId;
      data["userRole"] = userRole;
      data["strategyCommentType"] = strategyCommentTypeId;
      return data;
    }
  }

  /// Converts this [Comment] instance to a standard comment JSON payload.
  Map<String, dynamic> toSaveJson() {
    return {
      "appRefNo": applicationRefNo,
      "userId": userId,
      "userRole": userRole,
      "comment": comment,
      "commentCategoryId": categoryId,
    };
  }

  /// Converts this [Comment] instance to a contract comment JSON payload.
  Map<String, dynamic> toSaveContractJson() {
    return {
      "contractCode": applicationRefNo,
      "userId": userId,
      "userRole": userRole,
      "comment": comment,
      "commentCategoryId": categoryId,
      "isDraft": 0,
    };
  }

  /// Converts this [Comment] instance to a review comment JSON payload.
  Map<String, dynamic> toSaveReviewJson() {
    return {
      "appRefNo": applicationRefNo,
      "userId": userId,
      "userRole": userRole,
      "comment": comment,
      "commentCategoryId": categoryId,
      "reviewCommentId": reviewCommentId,
      "reasonList": reasonList,
    };
  }

  /// Converts this [Comment] instance to a condition comment JSON payload.
  Map<String, dynamic> toConditionJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["commentCategoryId"] = categoryId;
    data["strategyComment"] = strategyComment;
    data["appRefNo"] = applicationRefNo;
    data["comment"] = comment;
    data["isDraft"] = (draft ?? false) ? 1 : 0;
    data["userId"] = userId;
    data["userRole"] = userRole;
    return data;
  }

  /// Converts this [Comment] instance to a strategy JSON payload.
  Map<String, dynamic> toStrategyJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["categoryId"] = categoryId;
    data["category"] = categoryType;
    data["strategyComment"] = strategyComment;
    data["appRefNo"] = applicationRefNo;
    data["rimNo"] = rimNo ?? Globals.request?.customerRimNo;
    data["strategyCommentsType"] = strategyCommentTypeId;
    return data;
  }

  /// Converts this [Comment] instance to a present request JSON payload.
  Map<String, dynamic> toPresentRequestJson() {
    return {
      "appStrategyCommentsId": id ?? 0,
      "categoryId": categoryId,
      "strategyComment": strategyComment ?? comment,
      "categoryType": categoryType,
      "rimNo": rimNo ?? Globals.request?.customerRimNo,
    };
  }

  /// Converts this [Comment] instance to a group information JSON payload.
  Map<String, dynamic> toGroupInfoJson() {
    return {
      "appStrategyCommentsId": id ?? 0,
      "categoryId": categoryId,
      "strategyComment": comment,
      "categoryType": categoryType,
    };
  }
}
