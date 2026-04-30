import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/home/home.dart";

void main() {
  group("AssignToDetail", () {
    test("constructor assigns provided values", () {
      final detail = AssignToDetail(
        mode: 5,
        userAction: 99,
        assingToRoles: "125,126",
        returnToUser: true,
        assignLinkName: "Assign",
      );

      expect(detail.mode, 5);
      expect(detail.userAction, 99);
      expect(detail.assingToRoles, "125,126");
      expect(detail.returnToUser, true);
      expect(detail.assignLinkName, "Assign");
    });

    test("fromJson returns defaults when json is null", () {
      final detail = AssignToDetail.fromJson(null);

      expect(detail.mode, 1);
      expect(detail.userAction, 2126);
      expect(detail.assingToRoles, null);
      expect(detail.returnToUser, false);
      expect(detail.assignLinkName, null);
    });

    test("fromJson returns defaults when keys are missing", () {
      final detail = AssignToDetail.fromJson({});

      expect(detail.mode, 1);
      expect(detail.userAction, 2126);
      expect(detail.assingToRoles, null);
      expect(detail.returnToUser, false);
      expect(detail.assignLinkName, null);
    });

    test("fromJson maps all provided fields", () {
      final detail = AssignToDetail.fromJson({
        "mode": 9,
        "userAction": 333,
        "assignToRoleList": "125,126",
        "returnToUser": true,
        "assignLinkName": "Go To Assign",
      });

      expect(detail.mode, 9);
      expect(detail.userAction, 333);
      expect(detail.assingToRoles, "125,126");
      expect(detail.returnToUser, true);
      expect(detail.assignLinkName, "Go To Assign");
    });

    test("fromJson uses defaults only for missing nullable/defaulted fields",
        () {
      final detail = AssignToDetail.fromJson({
        "assignToRoleList": "777",
      });

      expect(detail.mode, 1);
      expect(detail.userAction, 2126);
      expect(detail.assingToRoles, "777");
      expect(detail.returnToUser, false);
      expect(detail.assignLinkName, null);
    });
  });

  group("Summary.fromJson", () {
    test("empty list sets all summary maps to defaultMap {-1: null}", () {
      final summary = Summary.fromJson([]);

      expect(summary.pendingWithMe, {-1: null});
      expect(summary.pendingWithFP, {-1: null});
      expect(summary.pendingWithBusiness, {-1: null});
      expect(summary.pendingWithCredit, {-1: null});
      expect(summary.pendingWithApprovingAuthority, {-1: null});
      expect(summary.pendingWithDocumentation, {-1: null});
      expect(summary.pendingWithCreditControl, {-1: null});
      expect(summary.pendingWithSegment, {-1: null});
      expect(summary.requestEnabledByCA, {-1: null});
      expect(summary.requestEnabledByCCProxy, {-1: null});
      expect(summary.requestEnabledByBODProxy, {-1: null});
      expect(summary.recentApplications, {-1: null});
      expect(summary.applicationsOverdue, {-1: null});
      expect(summary.applicationsDueForReview, {-1: null});
      expect(summary.returnedToRM, {-1: null});
      expect(summary.pendingWithTheFPChecker, {-1: null});
      expect(summary.pendingWithPool, {-1: null});
      expect(summary.pendingWithTeam, {-1: null});
      expect(summary.assigningRequestToMaker, {-1: null});
      expect(summary.pendingWithCA, {-1: null});
      expect(summary.assignRequestToCA, {-1: null});
      expect(summary.requestToRecommended, {-1: null});
      expect(summary.assignRequestToMe, {-1: null});
      expect(summary.returnedRequestDocumentation, {-1: null});
      expect(summary.recommentedRequest, {-1: null});
      expect(summary.draftFolInitiated, {-1: null});
      expect(summary.draftFolGenerated, {-1: null});
      expect(summary.finalFolInitiated, {-1: null});
      expect(summary.finalFolGenerated, {-1: null});
      expect(summary.documentationSubmitted, {-1: null});
      expect(summary.documentationCompleted, {-1: null});
      expect(summary.folCancelled, {-1: null});
      expect(summary.returnedToRO, {-1: null});
      expect(summary.returnedToCAM, {-1: null});
      expect(summary.returnedToRMB, {-1: null});
      expect(summary.returnedToSHB, {-1: null});
      expect(summary.returnedToSHLvlB, {-1: null});
      expect(summary.returnedToTLB, {-1: null});
      expect(summary.returnedToCCUM, {-1: null});
      expect(summary.returnedToDC, {-1: null});
      expect(summary.returnedToCCOOD, {-1: null});
      expect(summary.returnedToDocumentation, {-1: null});
      expect(summary.returnedToPool, {-1: null});
      expect(summary.returnedToCA, {-1: null});
      expect(summary.returnedToTLD1, {-1: null});
      expect(summary.returnedToSHD, {-1: null});
      expect(summary.returnedToSHC, {-1: null});
      expect(summary.returnedToSHBHyphen, {-1: null});
      expect(summary.returnedToSHB1, {-1: null});
      expect(summary.returnedToCCP, {-1: null});
      expect(summary.returnedToCCPA, {-1: null});
      expect(summary.returnedToBDP, {-1: null});
      expect(summary.pendingWithRelationShipTeam, {-1: null});
      expect(summary.pendingWithBusinessTeam, {-1: null});
    });

    test("fromJson maps a normal entry", () {
      final summary = Summary.fromJson([
        {
          "key": "pendingWithMe",
          "count": 5,
          "assignToDetail": {
            "mode": 2,
            "userAction": 88,
            "assignToRoleList": "100,101",
            "returnToUser": true,
            "assignLinkName": "Test Link",
          },
        }
      ]);

      expect(summary.pendingWithMe, isNotNull);
      expect(summary.pendingWithMe!.containsKey(5), true);

      final detail = summary.pendingWithMe![5];
      expect(detail, isNotNull);
      expect(detail!.mode, 2);
      expect(detail.userAction, 88);
      expect(detail.assingToRoles, "100,101");
      expect(detail.returnToUser, true);
      expect(detail.assignLinkName, "Test Link");
    });

    test("fromJson ignores invalid items safely", () {
      final summary = Summary.fromJson([
        null,
        123,
        "bad item",
        {"key": null, "count": 1},
        {"key": "pendingWithMe"},
        {"count": 10},
      ]);

      expect(summary.pendingWithMe, {-1: null});
      expect(summary.pendingWithFP, {-1: null});
    });

    test("fromJson allows assignToDetail to be null", () {
      final summary = Summary.fromJson([
        {
          "key": "pendingWithBusiness",
          "count": 10,
          "assignToDetail": null,
        }
      ]);

      expect(summary.pendingWithBusiness, isNotNull);
      expect(summary.pendingWithBusiness!.containsKey(10), true);

      final detail = summary.pendingWithBusiness![10];
      expect(detail, isNotNull);
      expect(detail!.mode, 1);
      expect(detail.userAction, 2126);
      expect(detail.returnToUser, false);
    });

    test("requestToRecommended uses direct key when present", () {
      final summary = Summary.fromJson([
        {
          "key": "requestToRecommended",
          "count": 9,
          "assignToDetail": {"mode": 4},
        }
      ]);

      expect(summary.requestToRecommended, isNotNull);
      expect(summary.requestToRecommended!.containsKey(9), true);
      expect(summary.requestToRecommended![9]!.mode, 4);
    });

    test("requestToRecommended falls back to requestToRecommend alias", () {
      final summary = Summary.fromJson([
        {
          "key": "requestToRecommend",
          "count": 3,
          "assignToDetail": {"mode": 6},
        }
      ]);

      expect(summary.requestToRecommended, isNotNull);
      expect(summary.requestToRecommended!.containsKey(3), true);
      expect(summary.requestToRecommended![3]!.mode, 6);
    });

    test("fromJson maps hyphenated legacy/new keys correctly", () {
      final summary = Summary.fromJson([
        {
          "key": "returnedToSH-B",
          "count": 1,
          "assignToDetail": {"mode": 11},
        },
        {
          "key": "returnedToTL-D1",
          "count": 2,
          "assignToDetail": {"mode": 12},
        },
        {
          "key": "returnedToSH-D",
          "count": 3,
          "assignToDetail": {"mode": 13},
        },
        {
          "key": "returnedToSH-C",
          "count": 4,
          "assignToDetail": {"mode": 14},
        },
        {
          "key": "returnedToSH-B1",
          "count": 5,
          "assignToDetail": {"mode": 15},
        },
      ]);

      expect(summary.returnedToSHLvlB!.containsKey(1), true);
      expect(summary.returnedToSHLvlB![1]!.mode, 11);

      expect(summary.returnedToTLD1!.containsKey(2), true);
      expect(summary.returnedToTLD1![2]!.mode, 12);

      expect(summary.returnedToSHD!.containsKey(3), true);
      expect(summary.returnedToSHD![3]!.mode, 13);

      expect(summary.returnedToSHC!.containsKey(4), true);
      expect(summary.returnedToSHC![4]!.mode, 14);

      expect(summary.returnedToSHB1!.containsKey(5), true);
      expect(summary.returnedToSHB1![5]!.mode, 15);
    });

    test("fromJson maps new fields correctly", () {
      final summary = Summary.fromJson([
        {
          "key": "returnedToDocumentation",
          "count": 1,
          "assignToDetail": {"mode": 1},
        },
        {
          "key": "returnedToPool",
          "count": 2,
          "assignToDetail": {"mode": 2},
        },
        {
          "key": "returnedToCA",
          "count": 3,
          "assignToDetail": {"mode": 3},
        },
        {
          "key": "returnedToCCP",
          "count": 4,
          "assignToDetail": {"mode": 4},
        },
        {
          "key": "returnedToCCPA",
          "count": 5,
          "assignToDetail": {"mode": 5},
        },
        {
          "key": "returnedToBDP",
          "count": 6,
          "assignToDetail": {"mode": 6},
        },
        {
          "key": "pendingWithRelationShipTeam",
          "count": 7,
          "assignToDetail": {"mode": 7},
        },
        {
          "key": "pendingWithBusinessTeam",
          "count": 8,
          "assignToDetail": {"mode": 8},
        },
      ]);

      expect(summary.returnedToDocumentation![1]!.mode, 1);
      expect(summary.returnedToPool![2]!.mode, 2);
      expect(summary.returnedToCA![3]!.mode, 3);
      expect(summary.returnedToCCP![4]!.mode, 4);
      expect(summary.returnedToCCPA![5]!.mode, 5);
      expect(summary.returnedToBDP![6]!.mode, 6);
      expect(summary.pendingWithRelationShipTeam![7]!.mode, 7);
      expect(summary.pendingWithBusinessTeam![8]!.mode, 8);
    });

    test("fromJson maps multiple different fields in one payload", () {
      final summary = Summary.fromJson([
        {
          "key": "pendingWithMe",
          "count": 1,
          "assignToDetail": {"mode": 1},
        },
        {
          "key": "pendingWithCA",
          "count": 2,
          "assignToDetail": {"mode": 2},
        },
        {
          "key": "returnedToRM",
          "count": 3,
          "assignToDetail": {"mode": 3},
        },
      ]);

      expect(summary.pendingWithMe![1]!.mode, 1);
      expect(summary.pendingWithCA![2]!.mode, 2);
      expect(summary.returnedToRM![3]!.mode, 3);
    });
  });

  group("Summary.firstValidMap", () {
    test("returns null when all maps are null", () {
      final summary = Summary();
      expect(summary.firstValidMap(), isNull);
    });

    test("returns null when maps only contain -1 key", () {
      final summary = Summary(
        pendingWithMe: {-1: null},
        pendingWithFP: {-1: null},
      );

      expect(summary.firstValidMap(), isNull);
    });

    test("returns first valid map when one exists", () {
      final summary = Summary(
        pendingWithMe: {-1: null},
        pendingWithFP: {5: AssignToDetail(mode: 10)},
        pendingWithBusiness: {8: AssignToDetail(mode: 20)},
      );

      final result = summary.firstValidMap();

      expect(result, isNotNull);
      expect(result, summary.pendingWithFP);
      expect(result!.containsKey(5), true);
    });

    test("respects _allSummaries order", () {
      final summary = Summary(
        pendingWithBusiness: {9: AssignToDetail(mode: 99)},
        pendingWithMe: {1: AssignToDetail(mode: 11)},
      );

      final result = summary.firstValidMap();

      expect(result, summary.pendingWithMe);
      expect(result![1]!.mode, 11);
    });

    test("skips empty maps and finds later valid map", () {
      final summary = Summary(
        pendingWithMe: {},
        pendingWithFP: {-1: null},
        pendingWithBusiness: {3: AssignToDetail(mode: 30)},
      );

      final result = summary.firstValidMap();

      expect(result, summary.pendingWithBusiness);
      expect(result![3]!.mode, 30);
    });
  });

  group("Summary.toJson", () {
    test("toJson converts all populated old and new fields", () {
      final summary = Summary(
        pendingWithMe: {1: AssignToDetail()},
        pendingWithFP: {2: AssignToDetail()},
        pendingWithBusiness: {3: AssignToDetail()},
        pendingWithCredit: {4: AssignToDetail()},
        pendingWithApprovingAuthority: {5: AssignToDetail()},
        pendingWithDocumentation: {6: AssignToDetail()},
        pendingWithCreditControl: {7: AssignToDetail()},
        pendingWithSegment: {8: AssignToDetail()},
        requestEnabledByCA: {9: AssignToDetail()},
        requestEnabledByCCProxy: {10: AssignToDetail()},
        requestEnabledByBODProxy: {11: AssignToDetail()},
        recentApplications: {12: AssignToDetail()},
        applicationsOverdue: {13: AssignToDetail()},
        applicationsDueForReview: {14: AssignToDetail()},
        returnedToRM: {15: AssignToDetail()},
        pendingWithTheFPChecker: {16: AssignToDetail()},
        pendingWithPool: {17: AssignToDetail()},
        pendingWithTeam: {18: AssignToDetail()},
        assigningRequestToMaker: {19: AssignToDetail()},
        pendingWithCA: {20: AssignToDetail()},
        assignRequestToCA: {21: AssignToDetail()},
        requestToRecommended: {22: AssignToDetail()},
        assignRequestToMe: {23: AssignToDetail()},
        returnedRequestDocumentation: {24: AssignToDetail()},
        recommentedRequest: {25: AssignToDetail()},
        draftFolInitiated: {26: AssignToDetail()},
        draftFolGenerated: {27: AssignToDetail()},
        finalFolInitiated: {28: AssignToDetail()},
        finalFolGenerated: {29: AssignToDetail()},
        documentationSubmitted: {30: AssignToDetail()},
        documentationCompleted: {31: AssignToDetail()},
        folCancelled: {32: AssignToDetail()},
        returnedToRO: {33: AssignToDetail()},
        returnedToCAM: {34: AssignToDetail()},
        returnedToRMB: {35: AssignToDetail()},
        returnedToSHB: {36: AssignToDetail()},
        returnedToSHLvlB: {37: AssignToDetail()},
        returnedToTLB: {38: AssignToDetail()},
        returnedToCCUM: {39: AssignToDetail()},
        returnedToDC: {40: AssignToDetail()},
        returnedToCCOOD: {41: AssignToDetail()},
        returnedToDocumentation: {42: AssignToDetail()},
        returnedToPool: {43: AssignToDetail()},
        returnedToCA: {44: AssignToDetail()},
        returnedToTLD1: {45: AssignToDetail()},
        returnedToSHD: {46: AssignToDetail()},
        returnedToSHC: {47: AssignToDetail()},
        returnedToSHBHyphen: {48: AssignToDetail()},
        returnedToSHB1: {49: AssignToDetail()},
        returnedToCCP: {50: AssignToDetail()},
        returnedToCCPA: {51: AssignToDetail()},
        returnedToBDP: {52: AssignToDetail()},
      );

      final json = summary.toJson();

      expect(json["pendingWithMe"], {1: isA<AssignToDetail>()});
      expect(json["pendingWithFP"], {2: isA<AssignToDetail>()});
      expect(json["pendingWithBusiness"], {3: isA<AssignToDetail>()});
      expect(json["pendingWithCredit"], {4: isA<AssignToDetail>()});
      expect(json["pendingWithApprovingAuthority"], {5: isA<AssignToDetail>()});
      expect(json["pendingWithDocumentation"], {6: isA<AssignToDetail>()});
      expect(json["pendingWithCreditControl"], {7: isA<AssignToDetail>()});
      expect(json["pendingWithSegment"], {8: isA<AssignToDetail>()});
      expect(json["requestEnabledByCA"], {9: isA<AssignToDetail>()});
      expect(json["requestEnabledByCCProxy"], {10: isA<AssignToDetail>()});
      expect(json["requestEnabledByBODProxy"], {11: isA<AssignToDetail>()});
      expect(json["recentApplications"], {12: isA<AssignToDetail>()});
      expect(json["applicationsOverdue"], {13: isA<AssignToDetail>()});
      expect(json["applicationsDueForReview"], {14: isA<AssignToDetail>()});
      expect(json["returnedToRM"], {15: isA<AssignToDetail>()});
      expect(json["pendingWithTheFPChecker"], {16: isA<AssignToDetail>()});
      expect(json["pendingWithPool"], {17: isA<AssignToDetail>()});
      expect(json["pendingWithTeam"], {18: isA<AssignToDetail>()});
      expect(json["assigningRequestToMaker"], {19: isA<AssignToDetail>()});
      expect(json["pendingWithCA"], {20: isA<AssignToDetail>()});
      expect(json["assignRequestToCA"], {21: isA<AssignToDetail>()});
      expect(json["requestToRecommended"], {22: isA<AssignToDetail>()});
      expect(json["assignRequestToMe"], {23: isA<AssignToDetail>()});
      expect(json["returnedRequestDocumentation"], {24: isA<AssignToDetail>()});
      expect(json["recommentedRequest"], {25: isA<AssignToDetail>()});
      expect(json["draftFolInitiated"], {26: isA<AssignToDetail>()});
      expect(json["draftFolGenerated"], {27: isA<AssignToDetail>()});
      expect(json["finalFolInitiated"], {28: isA<AssignToDetail>()});
      expect(json["finalFolGenerated"], {29: isA<AssignToDetail>()});
      expect(json["documentationSubmitted"], {30: isA<AssignToDetail>()});
      expect(json["documentationCompleted"], {31: isA<AssignToDetail>()});
      expect(json["folCancelled"], {32: isA<AssignToDetail>()});
      expect(json["returnedToRO"], {33: isA<AssignToDetail>()});
      expect(json["returnedToCAM"], {34: isA<AssignToDetail>()});
      expect(json["returnedToRMB"], {35: isA<AssignToDetail>()});
      expect(json["returnedToSHB"], {36: isA<AssignToDetail>()});
      expect(json["returnedToSH-B"], {48: isA<AssignToDetail>()});
      expect(json["returnedToTLB"], {38: isA<AssignToDetail>()});
      expect(json["returnedToCCUM"], {39: isA<AssignToDetail>()});
      expect(json["returnedToDC"], {40: isA<AssignToDetail>()});
      expect(json["returnedToCCOOD"], {41: isA<AssignToDetail>()});

      expect(json["returnedToDocumentation"], {42: isA<AssignToDetail>()});
      expect(json["returnedToPool"], {43: isA<AssignToDetail>()});
      expect(json["returnedToCA"], {44: isA<AssignToDetail>()});
      expect(json["returnedToTL-D1"], {45: isA<AssignToDetail>()});
      expect(json["returnedToSH-D"], {46: isA<AssignToDetail>()});
      expect(json["returnedToSH-C"], {47: isA<AssignToDetail>()});
      expect(json["returnedToSH-B"], {48: isA<AssignToDetail>()});
      expect(json["returnedToSH-B1"], {49: isA<AssignToDetail>()});
      expect(json["returnedToCCP"], {50: isA<AssignToDetail>()});
      expect(json["returnedToCCPA"], {51: isA<AssignToDetail>()});
      expect(json["returnedToBDP"], {52: isA<AssignToDetail>()});
    });

    test("toJson handles null values correctly", () {
      final summary = Summary();
      final json = summary.toJson();

      expect(json["pendingWithMe"], null);
      expect(json["pendingWithFP"], null);
      expect(json["pendingWithBusiness"], null);
      expect(json["pendingWithCredit"], null);
      expect(json["pendingWithApprovingAuthority"], null);
      expect(json["pendingWithDocumentation"], null);
      expect(json["pendingWithCreditControl"], null);
      expect(json["pendingWithSegment"], null);
      expect(json["requestEnabledByCA"], null);
      expect(json["requestEnabledByCCProxy"], null);
      expect(json["requestEnabledByBODProxy"], null);
      expect(json["recentApplications"], null);
      expect(json["applicationsOverdue"], null);
      expect(json["applicationsDueForReview"], null);
      expect(json["returnedToRM"], null);
      expect(json["pendingWithTheFPChecker"], null);
      expect(json["pendingWithPool"], null);
      expect(json["pendingWithTeam"], null);
      expect(json["assigningRequestToMaker"], null);
      expect(json["pendingWithCA"], null);
      expect(json["assignRequestToCA"], null);
      expect(json["requestToRecommended"], null);
      expect(json["assignRequestToMe"], null);
      expect(json["returnedRequestDocumentation"], null);
      expect(json["recommentedRequest"], null);
      expect(json["draftFolInitiated"], null);
      expect(json["draftFolGenerated"], null);
      expect(json["finalFolInitiated"], null);
      expect(json["finalFolGenerated"], null);
      expect(json["documentationSubmitted"], null);
      expect(json["documentationCompleted"], null);
      expect(json["folCancelled"], null);
      expect(json["returnedToRO"], null);
      expect(json["returnedToCAM"], null);
      expect(json["returnedToRMB"], null);
      expect(json["returnedToSHB"], null);
      expect(json["returnedToSH-B"], null);
      expect(json["returnedToTLB"], null);
      expect(json["returnedToCCUM"], null);
      expect(json["returnedToDC"], null);
      expect(json["returnedToCCOOD"], null);

      expect(json["returnedToDocumentation"], null);
      expect(json["returnedToPool"], null);
      expect(json["returnedToCA"], null);
      expect(json["returnedToTL-D1"], null);
      expect(json["returnedToSH-D"], null);
      expect(json["returnedToSH-C"], null);
      expect(json["returnedToSH-B1"], null);
      expect(json["returnedToCCP"], null);
      expect(json["returnedToCCPA"], null);
      expect(json["returnedToBDP"], null);
    });
  });
}
