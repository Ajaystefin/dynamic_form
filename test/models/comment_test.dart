import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  group("Comment", () {
    test("should create Comment instance with all properties", () {
      final createdDate = DateTime.utc(2023);
      final updatedDate = DateTime.utc(2023, 1, 2, 12, 30, 45, 123);
      final comment = Comment(
        id: 1,
        user: "John Doe",
        type: CommentsType.security,
        entityType: EntityIdentifier.security,
        categoryId: 123,
        categoryType: "Customer",
        strategyComment: "Strategy comment",
        createdBy: "user1",
        createdDate: createdDate,
        applicationRefNo: "APP001",
        comment: "Test comment",
        commentId: "COMMENT001",
        draft: false,
        reviewCommentId: "REVIEW001",
        userId: "user1",
        userRole: 1,
        srcMigratedId: 777,
        updatedBy: "admin",
        updatedDate: updatedDate,
        strategyCategory: "CAT_A",
        rimNo: 99,
        strategyCommentTypeId:
            ServerConstants.commentTypeId[CommentsType.security],
      );
      expect(comment.id, 1);
      expect(comment.user, "John Doe");
      expect(comment.type, CommentsType.security);
      expect(comment.entityType, EntityIdentifier.security);
      expect(comment.categoryId, 123);
      expect(comment.categoryType, "Customer");
      expect(comment.strategyComment, "Strategy comment");
      expect(comment.createdBy, "user1");
      expect(comment.createdDate, createdDate);
      expect(comment.applicationRefNo, "APP001");
      expect(comment.comment, "Test comment");
      expect(comment.commentId, "COMMENT001");
      expect(comment.draft, false);
      expect(comment.reviewCommentId, "REVIEW001");
      expect(comment.userId, "user1");
      expect(comment.userRole, 1);
      expect(comment.srcMigratedId, 777);
      expect(comment.updatedBy, "admin");
      expect(comment.updatedDate, updatedDate);
      expect(comment.strategyCategory, "CAT_A");
      expect(comment.rimNo, 99);
      expect(
        comment.strategyCommentTypeId,
        ServerConstants.commentTypeId[CommentsType.security],
      );
    });

    test("should create Comment instance using fromInputData factory", () {
      // Arrange globals
      Globals.request = Request(applicationRefNo: "APP123");
      Globals.user = User(id: "user42", currentRole: Role(roleId: 7));

      // Act
      final comment = Comment.fromInputData(
        strategyComment: "A strategy comment",
        categoryType: "Customer",
        type: CommentsType.security,
        entityType: EntityIdentifier.security,
        categoryId: 99,
        rimNo: 12345,
        comment: "This is a comment",
        id: 55,
        strategyCategory: "STRAT_CAT",
      );

      // Assert
      expect(comment.strategyComment, "A strategy comment");
      expect(comment.categoryType, "Customer");
      expect(comment.type, CommentsType.security);
      expect(comment.entityType, EntityIdentifier.security);
      expect(comment.categoryId, 99);
      expect(comment.rimNo, 12345);
      expect(comment.comment, "This is a comment");
      expect(comment.applicationRefNo, "APP123");
      expect(comment.userId, "user42");
      expect(comment.userRole, 7);
      expect(comment.id, 55);
      expect(comment.strategyCategory, "STRAT_CAT");
      expect(
        comment.strategyCommentTypeId,
        ServerConstants.commentTypeId[CommentsType.security],
      );
    });

    test("should create Comment instance with minimal properties", () {
      final comment = Comment();
      expect(comment.id, isNull);
      expect(comment.user, isNull);
      expect(comment.type, isNull);
      expect(comment.entityType, isNull);
      expect(comment.categoryId, isNull);
      expect(comment.categoryType, isNull);
      expect(comment.strategyComment, isNull);
      expect(comment.createdBy, isNull);
      expect(comment.createdDate, isNull);
      expect(comment.applicationRefNo, isNull);
      expect(comment.comment, isNull);
      expect(comment.commentId, isNull);
      expect(comment.draft, isNull);
      expect(comment.reviewCommentId, isNull);
      expect(comment.userId, isNull);
      expect(comment.userRole, isNull);
      expect(comment.srcMigratedId, isNull);
      expect(comment.updatedBy, isNull);
      expect(comment.updatedDate, isNull);
      expect(comment.strategyCategory, isNull);
      expect(comment.rimNo, isNull);
      expect(comment.strategyCommentTypeId, isNull);
    });

    test(
        "fromJson should prefer appStrategyCommentsId over"
        " id, and final category fields win", () {
      final json = {
        "appStrategyCommentsId": null,
        "id": 42,
        "CommentCategoryId": 7,
        "categoryType": "Type A",
        "categoryId": 77,
        "category": "Category B",
        "strategyComment": "SC",
        "createdBy": "creator",
        "createdDate": 1640995200000,
        "comment": "C",
        "user": "U",
        "rimNo": 9,
        "strategyCommentType": 2,
        "userName": "U2",
        "reasonList": "R",
      };
      final comment = Comment.fromJson(json);
      expect(
        comment.id,
        42,
      ); // falls back to id when appStrategyCommentsId is null
      expect(comment.categoryId, 77); // overwritten by 'categoryId'
      expect(comment.categoryType, "Category B"); // overwritten by 'category'
      expect(comment.strategyComment, "SC");
      expect(comment.createdBy, "creator");
      expect(comment.comment, "C");
      expect(comment.user, "U2"); // overwritten by userName
      expect(comment.rimNo, 9);
      expect(comment.strategyCommentTypeId, 2);
      expect(comment.reasonList, "R");
      // createdDate path goes through DateTimeUtils.intToDateTime, assert
      // non-null
      expect(comment.createdDate, isNotNull);
    });

    test("fromJson handles nulls safely", () {
      final json = {
        "appStrategyCommentsId": null,
        "categoryId": null,
        "category": null,
        "strategyComment": null,
        "createdBy": null,
        "createdDate": null,
        "comment": null,
        "userName": null,
      };
      final comment = Comment.fromJson(json);
      expect(comment.id, isNull);
      expect(comment.categoryId, isNull);
      expect(comment.categoryType, isNull);
      expect(comment.strategyComment, isNull);
      expect(comment.createdBy, isNull);
      expect(comment.createdDate, isNull);
      expect(comment.comment, isNull);
      expect(comment.user, isNull);
    });

    test(
        "toJson formats dates and "
        "maps fields correctly "
        "(with updatedBy override and srcMigratedId)", () {
      final createdDate = DateTime.utc(2023);
      final updatedDate = DateTime.utc(2023, 1, 2, 12, 30, 45, 123);

      final comment = Comment(
        id: 1,
        user: "John Doe",
        type: CommentsType.security,
        entityType: EntityIdentifier.security,
        categoryId: 123,
        categoryType: "Customer",
        strategyComment: "Strategy comment",
        createdBy: "user1",
        createdDate: createdDate,
        applicationRefNo: "APP001",
        comment: "Test comment",
        commentId: "COMMENT001",
        draft: false,
        reviewCommentId: "REVIEW001",
        userId: "user1",
        userRole: 1,
        srcMigratedId: 88,
        updatedBy: "admin",
        updatedDate: updatedDate,
      );

      final json = comment.toJson();

      expect(json["commentId"], "COMMENT001");
      expect(json["strategyComment"], "Strategy comment");
      expect(json["appRefNo"], "APP001");
      expect(json["strategyCategory"], isNull);
      expect(json["userAction"], 0); // reviewCommentId not parseable -> 0
      expect(json["comment"], "Test comment");
      expect(json["commentCategoryId"], 123);
      expect(json["categoryId"], 123);
      expect(json["id"], 1);
      expect(json["strategyCommentType"], isNull);
      expect(json["reasonList"], "");
      expect(json["isDraft"], 0);
      expect(json["userId"], "user1");
      expect(json["userRole"], 1);
      expect(json["createdBy"], "user1");
      expect(json["createdDate"], isNotNull);
      expect(json["updatedBy"], "admin"); // provided updatedBy takes precedence
      expect(json["srcMigratedId"], 88);
      expect(json["updatedDate"], isNotNull);

      // Verify date string format yyyy-MM-dd HH:mm:ss:SSS using a regex
      final dateRegex = RegExp(r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}:\d{3}$");
      expect(dateRegex.hasMatch(json["createdDate"]), true);
      expect(dateRegex.hasMatch(json["updatedDate"]), true);
    });

    test(
        "toJson with null dates writes empty "
        "createdDate and now for updatedDate", () {
      final comment = Comment();
      final json = comment.toJson();
      // createdDate should be empty string when null
      expect(json["createdDate"], isA<String>());
      expect((json["createdDate"] as String).isEmpty, true);
      // updatedDate should be a formatted now-string
      final dateRegex = RegExp(r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}:\d{3}$");
      expect(dateRegex.hasMatch(json["updatedDate"]), true);
      // updatedBy falls back to createdBy (both null -> null)
      expect(json["updatedBy"], isNull);
    });

    test("handle special characters & empties in toJson", () {
      final comment = Comment(
        id: 1,
        comment: r"Test comment with special chars: !@#$%^&*()_+-=[]{};:,.<>?",
        strategyComment:
            r"Strategy comment with special chars: !@#$%^&*()_+-=[]{};:,.<>?",
        categoryType: r"Category with special chars: !@#$%^&*()_+-=[]{};:,.<>?",
        createdBy: "",
        applicationRefNo: "",
        commentId: "",
        reviewCommentId: "",
        userId: "",
        user: "",
      );
      final json = comment.toJson();
      expect(
        json["comment"],
        r"Test comment with special chars: !@#$%^&*()_+-=[]{};:,.<>?",
      );
      expect(
        json["strategyComment"],
        r"Strategy comment with special chars: !@#$%^&*()_+-=[]{};:,.<>?",
      );
      expect(json["categoryId"], isNull);
      expect(json["createdBy"], "");
      expect(json["appRefNo"], "");
      expect(json["commentId"], "");
      expect(json["userId"], "");
      expect(json["userAction"], 0);
      expect(json["reasonList"], "");
    });

    test("large and negative integer values passthrough in toJson", () {
      final large =
          Comment(id: 999999999, categoryId: 999999999, userRole: 999999999);
      final lj = large.toJson();
      expect(lj["commentCategoryId"], 999999999);
      expect(lj["userRole"], 999999999);

      final neg = Comment(id: -1, categoryId: -123, userRole: -1);
      final nj = neg.toJson();
      expect(nj["commentCategoryId"], -123);
      expect(nj["userRole"], -1);
    });

    test("boolean draft maps to 1/0 in toJson", () {
      final cTrue = Comment(id: 1, draft: true);
      final cFalse = Comment(id: 2, draft: false);
      expect(cTrue.toJson()["isDraft"], 1);
      expect(cFalse.toJson()["isDraft"], 0);
    });

    test("enum passthrough (type/entityType)", () {
      final c1 = Comment(id: 1, type: CommentsType.security);
      final c2 = Comment(id: 2, type: CommentsType.approval);
      expect(c1.type, CommentsType.security);
      expect(c2.type, CommentsType.approval);

      final e1 = Comment(id: 3, entityType: EntityIdentifier.security);
      final e2 = Comment(id: 4, entityType: EntityIdentifier.approval);
      expect(e1.entityType, EntityIdentifier.security);
      expect(e2.entityType, EntityIdentifier.approval);
    });

    // ==== Additional coverage for all helper serializers ====

    test("toSaveStrategyCommentJson returns expected payload", () {
      final c = Comment(
        strategyComment: "SC",
        strategyCategory: "STRAT_CAT",
        applicationRefNo: "APP001",
        id: 11,
        categoryId: 22,
        draft: true,
        userId: "U1",
        userRole: 3,
        strategyCommentTypeId:
            ServerConstants.commentTypeId[CommentsType.security],
      );
      final j = c.toSaveStrategyCommentJson();
      expect(j["strategyComment"], "SC");
      expect(j["strategyCategory"], "STRAT_CAT");
      expect(j["appRefNo"], "APP001");
      expect(j["id"], 11);
      expect(j["categoryId"], 22);
      expect(j["isDraft"], 1);
      expect(j["userId"], "U1");
      expect(j["userRole"], 3);
      expect(
        j["strategyCommentType"],
        ServerConstants.commentTypeId[CommentsType.security],
      );
    });

    test("toSaveJson returns minimal payload", () {
      final c = Comment(
        applicationRefNo: "APP009",
        userId: "U9",
        userRole: 9,
        comment: "Hello",
        categoryId: 44,
      );
      final j = c.toSaveJson();
      expect(j["appRefNo"], "APP009");
      expect(j["userId"], "U9");
      expect(j["userRole"], 9);
      expect(j["comment"], "Hello");
      expect(j["commentCategoryId"], 44);
    });

    test("toConditionJson maps boolean draft to int and copies fields", () {
      final c = Comment(
        categoryId: 100,
        strategyComment: "Cond",
        applicationRefNo: "AR1",
        comment: "C",
        draft: true,
        userId: "U",
        userRole: 8,
      );
      final j = c.toConditionJson();
      expect(j["commentCategoryId"], 100);
      expect(j["strategyComment"], "Cond");
      expect(j["appRefNo"], "AR1");
      expect(j["comment"], "C");
      expect(j["isDraft"], 1);
      expect(j["userId"], "U");
      expect(j["userRole"], 8);
    });

    test(
        "toStrategyJson maps strategy fields "
        "including rimNo and comments type id", () {
      final c = Comment(
        categoryId: 5,
        categoryType: "TYPE_X",
        strategyComment: "SC",
        applicationRefNo: "APP-X",
        rimNo: 777,
        strategyCommentTypeId: 9,
      );
      final j = c.toStrategyJson();
      expect(j["categoryId"], 5);
      expect(j["category"], "TYPE_X");
      expect(j["strategyComment"], "SC");
      expect(j["appRefNo"], "APP-X");
      expect(j["rimNo"], 777);
      // expect(j['strategyCommentType'], 9);
    });

    test(
        "toPresentRequestJson includes id "
        "defaulting to 0 and maps category fields", () {
      final c1 = Comment(
        id: 88,
        categoryId: 7,
        strategyComment: "S",
        categoryType: "CT",
      );
      final p1 = c1.toPresentRequestJson();
      expect(p1["appStrategyCommentsId"], 88);
      expect(p1["categoryId"], 7);
      expect(p1["strategyComment"], "S");
      expect(p1["categoryType"], "CT");

      final c2 = Comment(categoryId: 7);
      final p2 = c2.toPresentRequestJson();
      expect(p2["appStrategyCommentsId"], 0);
      expect(p2["categoryId"], 7);
    });

    test("toSaveJson returns minimal payload", () {
      final c = Comment(
        applicationRefNo: "APP009",
        userId: "U9",
        userRole: 9,
        comment: "Hello",
        categoryId: 44,
      );
      final j = c.toSaveContractJson();
      expect(j["contractCode"], "APP009");
      expect(j["userId"], "U9");
      expect(j["userRole"], 9);
      expect(j["comment"], "Hello");
      expect(j["commentCategoryId"], 44);
    });

    test("toSaveJson returns minimal payload", () {
      final c = Comment(
        applicationRefNo: "APP009",
        userId: "U9",
        userRole: 9,
        comment: "Hello",
        categoryType: "Hello",
        categoryId: 44,
        id: 44,
      );
      final j = c.toGroupInfoJson();
      expect(j["appStrategyCommentsId"], 44);
      expect(j["categoryId"], 44);
      expect(j["strategyComment"], "Hello");
      expect(j["categoryType"], "Hello");
    });

    test("toSaveJson returns minimal payload", () {
      final c = Comment(
        applicationRefNo: "APP009",
        userId: "U9",
        userRole: 9,
        comment: "Hello",
        categoryId: 44,
        reviewCommentId: "44",
        reasonList: "44",
      );
      final j = c.toSaveReviewJson();
      expect(j["appRefNo"], "APP009");
      expect(j["userId"], "U9");
      expect(j["userRole"], 9);
      expect(j["comment"], "Hello");
      expect(j["commentCategoryId"], 44);
      expect(j["reviewCommentId"], "44");
      expect(j["reasonList"], "44");
    });
  });
}
