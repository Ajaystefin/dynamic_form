import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';

class Comment {
  int? appStrategyCommentsId;
  int? id;
  int? categoryId;
  int? srcMigratedId;
  String? categoryType;
  String? strategyComment;
  int? strategyCommentTypeId;
  String? createdBy;
  String? strategyCategory;
  int? strategyCommentType;
  DateTime? createdDate;
  String? commentId;
  String? applicationRefNo;
  String? comment;
  bool? draft;
  String? userId;
  int? userRole;
  String? reviewCommentId;
  String? user;
  int? rimNo;
  CommentsType? type;
  EntityIdentifier? entityType;
  String? reasonList;
  String? updatedBy;
  DateTime? updatedDate;

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
  });

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
  }) {
    return Comment(
      comment: comment,
      id: id,
      strategyCommentTypeId: ServerConstants.commentTypeId[type],
      strategyComment: strategyComment,
      applicationRefNo: Globals.request?.applicationRefNo,
      userId: Globals.user?.id,
      userRole: Globals.user?.currentRole?.roleId,
      categoryId: categoryId,
      rimNo: rimNo,
      categoryType: categoryType,
      type: type,
      entityType: entityType,
      strategyCategory: strategyCategory,
    );
  }

  Comment.fromJson(Map<String, dynamic> json) {
    if (json['appStrategyCommentsId'] != null) {
      id = json['appStrategyCommentsId'];
    } else if (json['id'] != null) {
      id = json['id'];
    }

    categoryId = json['CommentCategoryId'];
    categoryType = json['categoryType'];
    categoryId = json['categoryId'];
    categoryType = json['category'];
    strategyComment = json['strategyComment'];
    createdBy = json['createdBy'];
    createdDate = DateTimeUtils.intToDateTime(json['createdDate']);
    comment = json['comment'];
    user = json['user'];
    rimNo = json['rimNo'];
    strategyCommentTypeId = json['strategyCommentsType'];
    user = json['userName'];
    reasonList = json["reasonList"];
    applicationRefNo = json['appRefNo'];
  }

  Map<String, dynamic> toJson() {
    {
      final df = DateFormat('yyyy-MM-dd HH:mm:ss:SSS');
      final Map<String, dynamic> data = <String, dynamic>{};
      data['commentId'] = commentId;
      data['strategyComment'] = strategyComment;
      data['appRefNo'] = applicationRefNo;
      data['strategyCategory'] = strategyCategory;
      data['userAction'] = int.tryParse(reviewCommentId ?? '') ?? 0;
      data['comment'] = comment;
      data['categoryId'] = categoryId;
      data['id'] = id;
      data['strategyCommentType'] = strategyCommentTypeId;
      data['commentCategoryId'] = categoryId;
      data['categoryId'] = categoryId;
      // data['strategyCategory'] = "SIC_CODE_REVIEW";
      data['reasonList'] = reasonList ?? '';
      data['isDraft'] = (draft == true ? 1 : 0);
      data['userId'] = userId;
      data['userRole'] = userRole;
      data['createdBy'] = createdBy;
      data['createdDate'] = createdDate != null ? df.format(createdDate!) : '';
      data['updatedBy'] = updatedBy ?? createdBy;
      data['srcMigratedId'] = srcMigratedId;
      data['updatedDate'] = updatedDate != null
          ? df.format(updatedDate!)
          : df.format(DateTime.now());
      return data;
    }
  }

  Map<String, dynamic> toSaveStrategyCommentJson() {
    {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['strategyComment'] = strategyComment;
      data['strategyCategory'] = strategyCategory;
      data['appRefNo'] = applicationRefNo;
      data['id'] = id;
      data['categoryId'] = categoryId;
      data['isDraft'] = (draft == true ? 1 : 0);
      data['userId'] = userId;
      data['userRole'] = userRole;
      data['strategyCommentType'] = strategyCommentTypeId;
      return data;
    }
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'appRefNo': applicationRefNo,
      'userId': userId,
      'userRole': userRole,
      'comment': comment,
      'commentCategoryId': categoryId,
    };
  }

  Map<String, dynamic> toConditionJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentCategoryId'] = categoryId;
    data['strategyComment'] = strategyComment;
    data['appRefNo'] = applicationRefNo;
    data['comment'] = comment;
    data['isDraft'] = (draft ?? false) ? 1 : 0;
    data['userId'] = userId;
    data['userRole'] = userRole;
    return data;
  }

  Map<String, dynamic> toStrategyJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['categoryId'] = categoryId;
    data['category'] = categoryType;
    data['strategyComment'] = strategyComment;
    data['appRefNo'] = applicationRefNo;
    data['rimNo'] = rimNo;
    data['strategyCommentsType'] = strategyCommentTypeId;
    return data;
  }

  Map<String, dynamic> toPresentRequestJson() {
    return {
      'appStrategyCommentsId': id ?? 0,
      'categoryId': categoryId,
      'strategyComment': strategyComment,
      'categoryType': categoryType
    };
  }
}
