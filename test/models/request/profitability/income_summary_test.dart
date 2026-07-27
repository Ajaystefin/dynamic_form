import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/income_summary.dart";

void main() {
  group("IncomeSummary", () {
    test("fromJson should parse all fields correctly", () {
      final json = <String, dynamic>{
        "relationshipIncomeId": 101,
        "rimNo": 202,
        "custName": "John Doe",
        "incomeNature": "Salary",
        "lastYearAmount": "10000",
        "nextYearAmount": "12000",
        "nextYear2Amount": "14000",
        "lastYearProfitability": "10%",
        "nextYearProfitability": "12%",
        "nextYear2Profitability": "14%",
        "createdBy": "creator",
        "createdDate": "2024-01-01T00:00:00.000Z",
        "updatedBy": "updater",
        "updatedDate": "2024-01-02T00:00:00.000Z",
      };

      final result = IncomeSummary.fromJson(json);

      expect(result.relationshipIncomeId, 101);
      expect(result.rimNo, 202);
      expect(result.custName, "John Doe");
      expect(result.incomeNature, "Salary");
      expect(result.lastYearAmount, "10000");
      expect(result.nextYearAmount, "12000");
      expect(result.nextYear2Amount, "14000");
      expect(result.lastYearProfitability, "10%");
      expect(result.nextYearProfitability, "12%");
      expect(result.nextYear2Profitability, "14%");
      expect(result.createdBy, "creator");
      expect(result.createdDate, DateTime.parse("2024-01-01T00:00:00.000Z"));
      expect(result.updatedBy, "updater");
      expect(result.updatedDate, DateTime.parse("2024-01-02T00:00:00.000Z"));
    });

    test("fromJson should handle null fields correctly", () {
      final json = <String, dynamic>{
        "relationshipIncomeId": null,
        "rimNo": null,
        "custName": null,
        "incomeNature": null,
        "lastYearAmount": null,
        "nextYearAmount": null,
        "nextYear2Amount": null,
        "lastYearProfitability": null,
        "nextYearProfitability": null,
        "nextYear2Profitability": null,
        "createdBy": null,
        "createdDate": null,
        "updatedBy": null,
        "updatedDate": null,
      };

      final result = IncomeSummary.fromJson(json);

      expect(result.relationshipIncomeId, isNull);
      expect(result.rimNo, isNull);
      expect(result.custName, isNull);
      expect(result.incomeNature, isNull);
      expect(result.lastYearAmount, isNull);
      expect(result.nextYearAmount, isNull);
      expect(result.nextYear2Amount, isNull);
      expect(result.lastYearProfitability, isNull);
      expect(result.nextYearProfitability, isNull);
      expect(result.nextYear2Profitability, isNull);
      expect(result.createdBy, isNull);
      expect(result.createdDate, isNull);
      expect(result.updatedBy, isNull);
      expect(result.updatedDate, isNull);
    });

    test("toJson should serialize all fields correctly", () {
      final model = IncomeSummary(
        relationshipIncomeId: 101,
        rimNo: 202,
        custName: "John Doe",
        incomeNature: "Salary",
        lastYearAmount: "10000",
        nextYearAmount: "12000",
        nextYear2Amount: "14000",
        lastYearProfitability: "10%",
        nextYearProfitability: "12%",
        nextYear2Profitability: "14%",
        createdBy: "creator",
        createdDate: DateTime.utc(2024),
        updatedBy: "updater",
        updatedDate: DateTime.utc(2024, 1, 2),
      );

      final json = model.toJson();

      expect(json["relationshipIncomeId"], 101);
      expect(json["rimNo"], 202);
      expect(json["custName"], "John Doe");
      expect(json["incomeNature"], "Salary");
      expect(json["lastYearAmount"], "10000");
      expect(json["nextYearAmount"], "12000");
      expect(json["nextYear2Amount"], "14000");
      expect(json["lastYearProfitability"], "10%");
      expect(json["nextYearProfitability"], "12%");
      expect(json["nextYear2Profitability"], "14%");
      expect(json["createdBy"], "creator");
      expect(json["createdDate"], "2024-01-01T00:00:00.000Z");
      expect(json["updatedBy"], "updater");
      expect(json["updatedDate"], "2024-01-02T00:00:00.000Z");
    });

    test("toJson should serialize null dates as null", () {
      final model = IncomeSummary();

      final json = model.toJson();

      expect(json["relationshipIncomeId"], isNull);
      expect(json["rimNo"], isNull);
      expect(json["custName"], isNull);
      expect(json["incomeNature"], isNull);
      expect(json["lastYearAmount"], isNull);
      expect(json["nextYearAmount"], isNull);
      expect(json["nextYear2Amount"], isNull);
      expect(json["lastYearProfitability"], isNull);
      expect(json["nextYearProfitability"], isNull);
      expect(json["nextYear2Profitability"], isNull);
      expect(json["createdBy"], isNull);
      expect(json["createdDate"], isNull);
      expect(json["updatedBy"], isNull);
      expect(json["updatedDate"], isNull);
    });
  });

  group("IncomeComment", () {
    test("fromJson should parse all fields correctly", () {
      final json = <String, dynamic>{
        "appRefNo": "APP123",
        "userId": "user_1",
        "userRole": 1,
        "commentCategoryId": 10,
        "comment": "Looks good",
        "reasonList": [
          "Reason1",
          2,
          {"key": "value"},
        ],
        "isDraft": 0,
        "userAction": 2,
        "updatedDate": "2024-02-01T00:00:00.000Z",
        "updatedBy": "updater",
        "createdDate": "2024-01-31T00:00:00.000Z",
        "createdBy": "creator",
      };

      final result = IncomeComment.fromJson(json);

      expect(result.appRefNo, "APP123");
      expect(result.userId, "user_1");
      expect(result.userRole, 1);
      expect(result.commentCategoryId, 10);
      expect(result.comment, "Looks good");
      expect(result.reasonList, [
        "Reason1",
        2,
        {"key": "value"},
      ]);
      expect(result.isDraft, 0);
      expect(result.userAction, 2);
      expect(result.updatedDate, DateTime.parse("2024-02-01T00:00:00.000Z"));
      expect(result.updatedBy, "updater");
      expect(result.createdDate, DateTime.parse("2024-01-31T00:00:00.000Z"));
      expect(result.createdBy, "creator");
    });

    test("fromJson should handle null fields correctly", () {
      final json = <String, dynamic>{
        "appRefNo": null,
        "userId": null,
        "userRole": null,
        "commentCategoryId": null,
        "comment": null,
        "reasonList": null,
        "isDraft": null,
        "userAction": null,
        "updatedDate": null,
        "updatedBy": null,
        "createdDate": null,
        "createdBy": null,
      };

      final result = IncomeComment.fromJson(json);

      expect(result.appRefNo, isNull);
      expect(result.userId, isNull);
      expect(result.userRole, isNull);
      expect(result.commentCategoryId, isNull);
      expect(result.comment, isNull);
      expect(result.reasonList, isNull);
      expect(result.isDraft, isNull);
      expect(result.userAction, isNull);
      expect(result.updatedDate, isNull);
      expect(result.updatedBy, isNull);
      expect(result.createdDate, isNull);
      expect(result.createdBy, isNull);
    });

    test("toJson should serialize all fields correctly", () {
      final model = IncomeComment(
        appRefNo: "APP123",
        userId: "user_1",
        userRole: 1,
        commentCategoryId: 10,
        comment: "Looks good",
        reasonList: [
          "Reason1",
          2,
          {"key": "value"},
        ],
        isDraft: 0,
        userAction: 2,
        updatedDate: DateTime.utc(2024, 2),
        updatedBy: "updater",
        createdDate: DateTime.utc(2024, 1, 31),
        createdBy: "creator",
      );

      final json = model.toJson();

      expect(json["appRefNo"], "APP123");
      expect(json["userId"], "user_1");
      expect(json["userRole"], 1);
      expect(json["commentCategoryId"], 10);
      expect(json["comment"], "Looks good");
      expect(json["reasonList"], [
        "Reason1",
        2,
        {"key": "value"},
      ]);
      expect(json["isDraft"], 0);
      expect(json["userAction"], 2);
      expect(json["updatedDate"], "2024-02-01T00:00:00.000Z");
      expect(json["updatedBy"], "updater");
      expect(json["createdDate"], "2024-01-31T00:00:00.000Z");
      expect(json["createdBy"], "creator");
    });

    test("toJson should serialize null fields correctly", () {
      final model = IncomeComment();

      final json = model.toJson();

      expect(json["appRefNo"], isNull);
      expect(json["userId"], isNull);
      expect(json["userRole"], isNull);
      expect(json["commentCategoryId"], isNull);
      expect(json["comment"], isNull);
      expect(json["reasonList"], isNull);
      expect(json["isDraft"], isNull);
      expect(json["userAction"], isNull);
      expect(json["updatedDate"], isNull);
      expect(json["updatedBy"], isNull);
      expect(json["createdDate"], isNull);
      expect(json["createdBy"], isNull);
    });
  });

  group("IncomeSummaryResponseData", () {
    test("fromJson should parse populated list and comment correctly", () {
      final json = <String, dynamic>{
        "appRefNo": "APP999",
        "incomeSummaryDataList": [
          {
            "relationshipIncomeId": 1,
            "rimNo": 123,
            "custName": "Alice",
            "incomeNature": "Business",
            "lastYearAmount": "5000",
            "nextYearAmount": "6000",
            "nextYear2Amount": "7000",
            "lastYearProfitability": "5%",
            "nextYearProfitability": "6%",
            "nextYear2Profitability": "7%",
            "createdBy": "creator1",
            "createdDate": "2024-03-01T00:00:00.000Z",
            "updatedBy": "updater1",
            "updatedDate": "2024-03-02T00:00:00.000Z",
          }
        ],
        "comment": {
          "appRefNo": "APP999",
          "userId": "reviewer",
          "userRole": 2,
          "commentCategoryId": 5,
          "comment": "Approved",
          "reasonList": ["All good"],
          "isDraft": 1,
          "userAction": 3,
          "updatedDate": "2024-03-03T00:00:00.000Z",
          "updatedBy": "manager",
          "createdDate": "2024-03-02T00:00:00.000Z",
          "createdBy": "reviewer",
        },
      };

      final result = IncomeSummaryResponseData.fromJson(json);

      expect(result.appRefNo, "APP999");
      expect(result.incomeSummaryDataList.length, 1);
      expect(result.incomeSummaryDataList.first.relationshipIncomeId, 1);
      expect(result.incomeSummaryDataList.first.custName, "Alice");

      expect(result.comment, isNotNull);
      expect(result.comment!.appRefNo, "APP999");
      expect(result.comment!.comment, "Approved");
      expect(result.comment!.reasonList, ["All good"]);
    });

    test("fromJson should use empty list when incomeSummaryDataList is null",
        () {
      final json = <String, dynamic>{
        "appRefNo": "APP1000",
        "incomeSummaryDataList": null,
        "comment": null,
      };

      final result = IncomeSummaryResponseData.fromJson(json);

      expect(result.appRefNo, "APP1000");
      expect(result.incomeSummaryDataList, isEmpty);
      expect(result.comment, isNull);
    });

    test("fromJson should handle empty incomeSummaryDataList", () {
      final json = <String, dynamic>{
        "appRefNo": "APP1001",
        "incomeSummaryDataList": <dynamic>[],
        "comment": null,
      };

      final result = IncomeSummaryResponseData.fromJson(json);

      expect(result.appRefNo, "APP1001");
      expect(result.incomeSummaryDataList, isEmpty);
      expect(result.comment, isNull);
    });

    test("toJson should serialize populated object correctly", () {
      final model = IncomeSummaryResponseData(
        appRefNo: "APP2000",
        incomeSummaryDataList: [
          IncomeSummary(
            relationshipIncomeId: 11,
            rimNo: 22,
            custName: "Bob",
            incomeNature: "Consulting",
            lastYearAmount: "15000",
            nextYearAmount: "18000",
            nextYear2Amount: "20000",
            lastYearProfitability: "15%",
            nextYearProfitability: "18%",
            nextYear2Profitability: "20%",
            createdBy: "creator",
            createdDate: DateTime.utc(2024, 4),
            updatedBy: "updater",
            updatedDate: DateTime.utc(2024, 4, 2),
          ),
        ],
        comment: IncomeComment(
          appRefNo: "APP2000",
          userId: "userX",
          userRole: 3,
          commentCategoryId: 7,
          comment: "Reviewed",
          reasonList: ["ok"],
          isDraft: 0,
          userAction: 1,
          updatedDate: DateTime.utc(2024, 4, 3),
          updatedBy: "upd",
          createdDate: DateTime.utc(2024, 4, 2),
          createdBy: "crt",
        ),
      );

      final json = model.toJson();

      expect(json["appRefNo"], "APP2000");
      expect(json["incomeSummaryDataList"], isA<List<dynamic>>());
      expect((json["incomeSummaryDataList"] as List).length, 1);

      final summaryJson =
          (json["incomeSummaryDataList"] as List).first as Map<String, dynamic>;
      expect(summaryJson["relationshipIncomeId"], 11);
      expect(summaryJson["custName"], "Bob");
      expect(summaryJson["createdDate"], "2024-04-01T00:00:00.000Z");
      expect(summaryJson["updatedDate"], "2024-04-02T00:00:00.000Z");

      final commentJson = json["comment"] as Map<String, dynamic>;
      expect(commentJson["appRefNo"], "APP2000");
      expect(commentJson["comment"], "Reviewed");
      expect(commentJson["updatedDate"], "2024-04-03T00:00:00.000Z");
      expect(commentJson["createdDate"], "2024-04-02T00:00:00.000Z");
    });

    test("toJson should serialize null comment and empty list correctly", () {
      final model = IncomeSummaryResponseData(
        appRefNo: "APP3000",
        incomeSummaryDataList: [],
      );

      final json = model.toJson();

      expect(json["appRefNo"], "APP3000");
      expect(json["incomeSummaryDataList"], isEmpty);
      expect(json["comment"], isNull);
    });
  });
}
