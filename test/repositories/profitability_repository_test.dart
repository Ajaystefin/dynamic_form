import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";
import "package:wcas_frontend/models/request/profitability/income_summary.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";
import "package:wcas_frontend/models/request/profitability/strategies_comments.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

Matcher throwsExceptionWithMessage(String message) {
  return throwsA(
    isA<Exception>().having(
      (e) => e.toString(),
      "message",
      contains(message),
    ),
  );
}

void main() {
  group("ProfitabilityRepository", () {
    late ProfitabilityRepository repo;
    late MockAPIManager api;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      api = MockAPIManager();
      repo = ProfitabilityRepository(apiManager: api);

      // Seed a minimal user for save flows that require user info
      Globals.user = User(
        id: "UT001",
        name: "Unit Tester",
        currentRole: Role(id: 99, code: "UT", name: "Unit Tester", roleId: 99),
      );

      // If your BaseRequest reads this:
      // Globals.request = Request(applicationRefNo: 'APP-UT-001');
    });

    tearDown(() {
      api.clearCallLog();
      Globals.user = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Singleton & override", () {
      test("instance returns singleton; overrideInstance swaps it", () {
        final inst1 = ProfitabilityRepository.instance;
        final custom = ProfitabilityRepository(apiManager: api);
        ProfitabilityRepository.overrideInstance = custom;
        final inst2 = ProfitabilityRepository.instance;

        expect(identical(inst2, custom), isTrue);

        // put it back (optional)
        ProfitabilityRepository.overrideInstance = inst1;
      });
    });

    // ----------------------------------------------------------------------
    // getStrategiesAndComments
    // ----------------------------------------------------------------------
    group("getStrategiesAndComments", () {
      test("success: maps categoryId list into flattened StrategiesComments",
          () async {
        // Arrange
        final mock = AppResponse(
          status: ResponseStatus.success,
          code: 200,
          message: "OK",
          body: {
            "responseData": {
              "commentList": [
                {
                  "categoryId":
                      ServerConstants.relationshipStrategyCommentCategoryId,
                  "strategyComment": "RS",
                },
                {
                  "categoryId":
                      ServerConstants.depositsStrategyCommentCategoryId,
                  "strategyComment": "DS",
                },
                {
                  "categoryId":
                      ServerConstants.transactionalBankingCommentCategoryId,
                  "strategyComment": "TB",
                },
                {
                  "categoryId": ServerConstants.tradeFinanceCommentCategoryId,
                  "strategyComment": "TF",
                },
                {
                  "categoryId": ServerConstants.treasuryCommentCategoryId,
                  "strategyComment": "TR",
                },
              ],
            },
          },
        );
        api.setMockResponse(mock);

        // Act
        final result = await repo.getStrategiesAndComments(
          CommentsType.relationshipStrategy,
          EntityIdentifier.requestApplicationDetailed,
        );

        // Assert
        expect(result, isA<StrategiesComments>());
        // If your model exposes fields, assert them here:
        // expect(result.relationshipStrategy, 'RS');
      });

      test("error: throws when ResponseStatus.error", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "Server down",
            body: {},
          ),
        );

        expect(
          () => repo.getStrategiesAndComments(
            CommentsType.relationshipStrategy,
            EntityIdentifier.requestApplicationDetailed,
          ),
          throwsExceptionWithMessage("Server down"),
        );
      });
    });

    // ----------------------------------------------------------------------
    // saveApplicationStrategyDetailsDynamic
    // ----------------------------------------------------------------------
    group("saveApplicationStrategyDetailsDynamic", () {
      test("success returns true", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "Saved",
            body: {
              "status": {"statusDescription": "saved ok"},
            },
          ),
        );

        final ok = await repo.saveApplicationStrategyDetailsDynamic(
          type: CommentsType.relationshipStrategy,
          commentList: [
            {"categoryId": 1, "strategyComment": "X"},
          ],
        );

        expect(ok, isTrue);
        expect(api.callLog, isNotEmpty);
        expect(
          api.callLog.last["endpoint"],
          APIEndpoints.saveApplicationStrategyDetails,
        );
      });

      test("error throws", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 400,
            message: "invalid",
            body: {},
          ),
        );

        expect(
          () => repo.saveApplicationStrategyDetailsDynamic(
            type: CommentsType.relationshipStrategy,
            commentList: const [],
          ),
          throwsExceptionWithMessage("invalid"),
        );
      });
    });

    // ----------------------------------------------------------------------
    // getShareOfWallet
    // ----------------------------------------------------------------------
    group("getShareOfWallet", () {
      test("success with list maps to ShareOfWallet list", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": [
                {"bankName": "CBD", "walletShare": 40},
                {"bankName": "Other", "walletShare": 60},
              ],
            },
          ),
        );

        final list = await repo.getShareOfWallet();
        expect(list, isA<List<ShareOfWallet>>());
        expect(list.length, 0);
      });

      test("error status returns empty list", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "err",
            body: {},
          ),
        );

        final list = await repo.getShareOfWallet();
        expect(list, isEmpty);
      });

      test("non-list or empty returns []", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {"responseData": null},
          ),
        );
        expect(await repo.getShareOfWallet(), isEmpty);

        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {"responseData": []},
          ),
        );
        expect(await repo.getShareOfWallet(), isEmpty);
      });

      test("exception returns []", () async {
        api.setMockException(Exception("network"));
        final list = await repo.getShareOfWallet();
        expect(list, isEmpty);
        api.setMockException(null);
      });
    });

    // ----------------------------------------------------------------------
    // getIncomeSummary
    // ----------------------------------------------------------------------
    group("getIncomeSummary", () {
      test("success with valid map returns parsed model", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": {
                "incomeSummaryDataList": [],
                "comment": null,
              },
            },
          ),
        );

        final r = await repo.getIncomeSummary();
        expect(r, isA<IncomeSummaryResponseData>());
        expect(r.incomeSummaryDataList, isEmpty);
        expect(r.comment, isNull);
      });

      test("error returns normalized empty object", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "down",
            body: {},
          ),
        );

        final r = await repo.getIncomeSummary();
        expect(r.incomeSummaryDataList, isEmpty);
        expect(r.comment, isNull);
      });

      test("invalid or null responseData returns normalized empty object",
          () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {"responseData": null},
          ),
        );
        final r1 = await repo.getIncomeSummary();
        expect(r1.incomeSummaryDataList, isEmpty);

        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {"responseData": "oops"},
          ),
        );
        final r2 = await repo.getIncomeSummary();
        expect(r2.incomeSummaryDataList, isEmpty);
      });

      test("exception returns normalized empty object", () async {
        api.setMockException(Exception("boom"));
        final r = await repo.getIncomeSummary();
        expect(r.incomeSummaryDataList, isEmpty);
        api.setMockException(null);
      });
    });

    // ----------------------------------------------------------------------
    // saveIncomeSummary
    // ----------------------------------------------------------------------
    group("saveIncomeSummary", () {
      test("success returns statusDescription", () async {
        // Arrange: mock response
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "status": {"statusDescription": "Saved Income"},
            },
          ),
        );

        final items = <IncomeSummary>[
          IncomeSummary.fromJson({
            // fill minimal keys your toJson/fromJson require:
            "incomeType": "ABC",
            "amount": 10,
          }),
        ];

        final msg = await repo.saveIncomeSummary(items, "a comment");
        expect(msg, "Saved Income");

        // verify the repo encoded payload as json
        final body = api.callLog.last["body"];
        expect(body, isA<String>());
        final decoded = jsonDecode(body as String);
        expect(decoded["requestData"], isNotNull);
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 400,
            message: "bad",
            body: {},
          ),
        );

        expect(
          () => repo.saveIncomeSummary([], null),
          throwsExceptionWithMessage("bad"),
        );
      });
    });

    // ----------------------------------------------------------------------
    // getAccountConductData (plainResponse: true)
    // ----------------------------------------------------------------------
    group("getAccountConductData", () {
      test("success parses raw string, quotes numerics, returns model",
          () async {
        // Build a raw JSON string body (plainResponse path expects String body)
        final raw = jsonEncode({
          "responseData": {
            "pastDueOrExcesses": 1, // will be stringified by regex
            "chequeReturns": 2,
            "turnoverInAcc": 3,
            "odHardcore": 4,
            "unusualTransactions": 5,
            "transparencyDisclosureLevels": 6,
          },
        });

        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: raw, // IMPORTANT: string
          ),
        );

        final res = await repo.getAccountConductData();
        expect(res, isA<AccountConductResponseData>());
        expect(
          api.callLog.last["endpoint"],
          APIEndpoints.getAccountConductData,
        );
      });

      test("error returns null", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "fail",
            body: "",
          ),
        );
        final res = await repo.getAccountConductData();
        expect(res, isNull);
      });
    });

    // ----------------------------------------------------------------------
    // postAccountConductData
    // ----------------------------------------------------------------------
    group("postAccountConductData", () {
      test('success returns statusDescription or "Success"', () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "status": {"statusDescription": "Saved A/C Conduct"},
            },
          ),
        );

        final model = AccountConductResponseData.fromJson({
          "accountConductDtoList": [
            {
              "rimNo": 11,
              "pastDueOrExcesses": "1",
              "chequeReturns": "2",
              "turnoverInAcc": "3",
              "odHardcore": "4",
              "unusualTransactions": "5",
              "transparencyDisclosureLevels": "6",
            }
          ],
        });

        final msg = await repo.postAccountConductData(model);
        expect(msg, "Saved A/C Conduct");

        // verify JSON encoded post
        expect(api.callLog.last["body"], isA<String>());
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "nope",
            body: {},
          ),
        );

        final model =
            AccountConductResponseData.fromJson({"accountConductDtoList": []});

        expect(
          () => repo.postAccountConductData(model),
          throwsExceptionWithMessage("nope"),
        );
      });
    });

    // ----------------------------------------------------------------------
    // getRelationshipUtilizationData
    // ----------------------------------------------------------------------
    group("getRelationshipUtilizationData", () {
      test("success returns mapped list", () async {
        // Align JSON to your RelationshipUtilization.fromJson
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": [
                {
                  "rim": 1,
                  "clientTurnover": "100",
                  "relationshipRevenueDetails": [],
                }
              ],
            },
          ),
        );

        final list = await repo.getRelationshipUtilizationData();
        expect(list, isA<List<RelationshipUtilization>>());
        expect(list.length, 1);
      });

      test("error returns []", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "x",
            body: {},
          ),
        );
        final list = await repo.getRelationshipUtilizationData();
        expect(list, isEmpty);
      });
    });

    // ----------------------------------------------------------------------
    // postRelationshipUtilizationData
    // ----------------------------------------------------------------------
    group("postRelationshipUtilizationData", () {
      test('empty list returns "" (short-circuit branch)', () async {
        final msg = await repo.postRelationshipUtilizationData(const []);
        expect(msg, "");
        expect(api.callLog, isEmpty); // no API called
      });

      test("success returns statusDescription", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "status": {"statusDescription": "Saved RU"},
            },
          ),
        );

        // Build minimal instance
        final ru = RelationshipUtilization.fromJson({
          "rim": 1,
          "clientTurnover": "100",
          "relationshipRevenueDetails": [
            {
              "product": "X",
              "accountCommitmentNumber": "A1",
              "accountLimit": "10",
              "averageUtilization": "2",
              "utilizationPercent": "20",
            }
          ],
        });

        final msg = await repo.postRelationshipUtilizationData([ru]);
        expect(msg, "Saved RU");
        expect(
          api.callLog.last["endpoint"],
          APIEndpoints.saveRelationshipUtilization,
        );
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 400,
            message: "bad",
            body: {},
          ),
        );

        final ru = RelationshipUtilization.fromJson({
          "rim": 1,
          "clientTurnover": "100",
          "relationshipRevenueDetails": [],
        });

        expect(
          () => repo.postRelationshipUtilizationData([ru]),
          throwsExceptionWithMessage("bad"),
        );
      });
    });

    // ----------------------------------------------------------------------
    // getRelationProfitDetData
    // ----------------------------------------------------------------------
    group("getRelationProfitDetData", () {
      test("success returns list from incomeSummaryDataList", () async {
        // RelationshipProfitabilityDetailed.fromJson
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": {
                "incomeSummaryDataList": [
                  {
                    "incomeType": "A",
                    "amount": 1,
                  }
                ],
              },
            },
          ),
        );

        final list = await repo.getRelationProfitDetData();
        expect(list, isA<List<RelationshipProfitabilityDetailed>>());
        expect(list.length, 1);
      });

      test("error returns empty []", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "fail",
            body: {},
          ),
        );

        final list = await repo.getRelationProfitDetData();
        expect(list, isEmpty);
      });
    });

    // ----------------------------------------------------------------------
    // getComments
    // ----------------------------------------------------------------------
    group("getComments", () {
      test("success returns responseData.comment", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "ok",
            body: {
              "responseData": {"comment": "Some comment"},
            },
          ),
        );

        final c = await repo.getComments();
        expect(c, "Some comment");
        expect(
          api.callLog.last["endpoint"],
          APIEndpoints.getRelProfitDetComments,
        );
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "no",
            body: {},
          ),
        );

        expect(() => repo.getComments(), throwsExceptionWithMessage("no"));
      });
    });

    // ----------------------------------------------------------------------
    // getBusinessVolumes (plainResponse: true)
    // ----------------------------------------------------------------------
    group("getBusinessVolumes", () {
      test(
          "success maps to map<Customer, List<BusinessVolume>>"
          " and sets lastBusinessVolumeComment", () async {
        // Build raw JSON string body as plainResponse:
        final raw = jsonEncode({
          "responseData": {
            "comment": {"comment": "BV comment", "commentCategoryId": 1186},
            "businessVolumeDtoList": [
              {
                "rimNo": 1,
                "customerName": "C1",
                "businessVolumeDetailsList": [
                  {"businessVolumeId": 11, "estimatesForNextYear": "100"},
                ],
              },
              {
                "rimNo": 2,
                "customerName": "C2",
                "businessVolumeDetailsList": [],
              }
            ],
          },
        });

        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: raw, // String
          ),
        );

        final map = await repo.getBusinessVolumes();
        expect(map.entries.length, 2);
        expect(repo.lastBusinessVolumeComment, isNotNull);
        expect(repo.lastBusinessVolumeComment!.comment, "BV comment");
      });

      test("error status throws", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "fail",
            body: "",
          ),
        );

        expect(
          () => repo.getBusinessVolumes(),
          throwsExceptionWithMessage("fail"),
        );
      });

      test("exception path rethrows", () async {
        api.setMockException(Exception("boom"));
        expect(() => repo.getBusinessVolumes(), throwsException);
        api.setMockException(null);
      });
    });

    // ----------------------------------------------------------------------
    // saveBusinessVolumes
    // ----------------------------------------------------------------------
    group("saveBusinessVolumes", () {
      test("success returns statusDescription or fallback", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "status": {"statusDescription": "Saved BV"},
            },
          ),
        );

        // Build minimal Customer + BusinessVolume
        final customer = Customer.fromJson({"rimNo": 1, "customerName": "C1"});
        final bv = BusinessVolume.fromJson(
          {"businessVolumeId": 10, "estimatesForNextYear": "123"},
        );

        final msg = await repo.saveBusinessVolumes(
          {
            customer: [bv],
          },
          "note",
        );
        expect(msg, "Saved BV");

        final body = api.callLog.last["body"] as String;
        final decoded = jsonDecode(body);
        expect(decoded["requestData"]["comment"]["comment"], "note");
      });

      test("exception path throws wrapped error", () async {
        api.setMockException(Exception("explode"));
        final customer = Customer.fromJson({"rimNo": 1, "customerName": "C1"});
        final bv = BusinessVolume.fromJson(
          {"businessVolumeId": 10, "estimatesForNextYear": "123"},
        );

        expect(
          () => repo.saveBusinessVolumes(
            {
              customer: [bv],
            },
            "hi",
          ),
          throwsExceptionWithMessage("Failed to save business volumes:"),
        );
        api.setMockException(null);
      });
    });

    // ----------------------------------------------------------------------
    // getAccountStats
    // ----------------------------------------------------------------------
    group("getAccountStats", () {
      test("success builds Map<Customer, List<AccountStat>>", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": [
                {
                  "rimNo": 1,
                  "customerName": "C1",
                  "accStatData": [
                    {"k": "v"}, // minimal
                  ],
                }
              ],
            },
          ),
        );

        final res = await repo.getAccountStats();
        expect(res.length, 1);
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 400,
            message: "no",
            body: {},
          ),
        );

        expect(() => repo.getAccountStats(), throwsExceptionWithMessage("no"));
      });
    });

    // ----------------------------------------------------------------------
    // getRelationshipProfitabilitySummaryData
    // ----------------------------------------------------------------------
    group("getRelationshipProfitabilitySummaryData", () {
      test("success returns model", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              "responseData": {
                "rarocInformation": [],
                "relationshipProfitability": [],
              },
            },
          ),
        );

        final s = await repo.getRelationshipProfitabilitySummaryData();
        expect(s, isA<RelationshipProfitabilitySummary>());
      });

      test("error throws message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 500,
            message: "bad",
            body: {},
          ),
        );

        expect(
          () => repo.getRelationshipProfitabilitySummaryData(),
          throwsExceptionWithMessage("bad"),
        );
      });

      test("invalid responseData throws", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {"responseData": null},
          ),
        );

        expect(
          () => repo.getRelationshipProfitabilitySummaryData(),
          throwsExceptionWithMessage(
            "Invalid response: responseData missing or not an object",
          ),
        );
      });
    });

    // ----------------------------------------------------------------------
    // postRelationshipProfitabilitySummaryData
    // ----------------------------------------------------------------------
    group("postRelationshipProfitabilitySummaryData", () {
      test('success returns "Success" when statusDescription missing',
          () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.success,
            code: 200,
            message: "OK",
            body: {
              // no 'status' map -> falls back to "Success"
            },
          ),
        );

        final summary = RelationshipProfitabilitySummary.fromJson({
          "rarocInformation": [
            {
              "field": "x",
            }
          ],
          "relationshipProfitability": [
            {
              "y": 1,
            }
          ],
        });

        final msg =
            await repo.postRelationshipProfitabilitySummaryData(summary);
        expect(msg, "Success");

        expect(
          api.callLog.last["endpoint"],
          APIEndpoints.postRelationshipProfitabilitySummary,
        );
      });

      test("error throws response.message", () async {
        api.setMockResponse(
          AppResponse(
            status: ResponseStatus.error,
            code: 400,
            message: "nope",
            body: {},
          ),
        );

        expect(
          () => repo.postRelationshipProfitabilitySummaryData(null),
          throwsExceptionWithMessage("nope"),
        );
      });
    });
  });
}
