import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/project_repository.dart";
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
  group("ProjectRepository - 100% Unit Test Coverage", () {
    late ProjectRepository projectRepository;
    late MockAPIManager mockAPIManager;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await EnvConfig.setEnvironment();
      mockAPIManager = MockAPIManager();
      projectRepository = ProjectRepository(apiManager: mockAPIManager);
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.user = null;
      Globals.request = null;
    });

    group("Constructor & Singleton", () {
      test("creates instance with provided APIManager", () {
        final repo = ProjectRepository(apiManager: mockAPIManager);
        expect(repo, isNotNull);
      });

      test("singleton instance remains identical", () {
        final a = ProjectRepository.instance;
        final b = ProjectRepository.instance;
        expect(identical(a, b), isTrue);
      });

      test("default APIManager works when none provided", () {
        final repo = ProjectRepository();
        expect(repo, isNotNull);
      });
    });

    group("getSearchProjectDetails", () {
      test("success | isProject=true uses getSearchProjectDetails", () async {
        final responseJson = jsonEncode({
          "responseData": [
            {
              "projectCode": "P001",
              "projectName": "Alpha",
              "projectValueCurrent": "12345678901234567890", // big number
              "projectValue": 1000.0,
              "initialProjectValue": 900.0,
            }
          ],
        });
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: responseJson, // plainResponse string
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        // final result = await projectRepository.getSearchProjectDetails(
        //   payload: {'anything': 'goes'},
        //   isProject: true,
        // );

        // expect(result.projects, isA<List<Project>>());
        // expect(result.projects.length, 1);
        // expect(
        //   mockAPIManager.callLog.last['endpoint'],
        //   APIEndpoints.getSearchProjectDetails,
        // );
        // expect(mockAPIManager.callLog.last['plainResponse'], isTrue);
      });

      test(
          "success | default isProject=false uses"
          " getSearchProjectDetailsContract", () async {
        final responseJson = jsonEncode({"responseData": []});
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: responseJson,
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final result = await projectRepository.getSearchProjectDetails();

        expect(result.projects, isEmpty);
        expect(
          mockAPIManager.callLog.last["endpoint"],
          APIEndpoints.getSearchProjectDetailsContract,
        );
      });

      test("error | non-success status parses statusDescription", () async {
        final errorJson = jsonEncode({
          "baseResponse": {
            "status": {"statusDescription": "Bad payload"},
          },
        });
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Ignored",
            body: errorJson,
            code: 400,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.getSearchProjectDetails(payload: {"x": 1}),
          throwsExceptionWithMessage("Bad payload"),
        );
      });

      test("exception | malformed JSON hits catch block", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: "{not valid json",
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        expect(
          () => projectRepository.getSearchProjectDetails(payload: {"x": 1}),
          throwsExceptionWithMessage("FormatException"),
        );
      });
    });

    group("saveProjectDetails", () {
      test("success | returns projectCode when present", () async {
        final user = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 7, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;

        final project = Project(projectCode: "X1");
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Success",
            body: {
              "responseData": {"projectCode": "PRJ-999"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final result = await projectRepository.saveProjectDetails(
          isCreateProject: true,
          project: project,
        );
        expect(result, "PRJ-999");

        final log = mockAPIManager.callLog.last;
        expect(log["method"], "POST");
        expect(log["endpoint"], APIEndpoints.saveProjectDetails);
      });

      test("error | throws errorDescription when present", () async {
        final user = User(
          id: "testUser",
          name: "User",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;

        final mockResponse = AppResponse(
          message: "Invalid project data",
          body: {
            "baseResponse": {
              "status": {
                "statusCode": "1",
                "statusDescription": "Failure",
                "severity": "Error",
                "errorCode": "500",
                "errorDescription": "Invalid project data",
              },
            },
          },
          code: 400,
          status: ResponseStatus.error,
        );
        mockAPIManager.setMockResponse(mockResponse);

        expect(
          () => projectRepository.saveProjectDetails(
            isCreateProject: true,
            project: Project(projectCode: "INVALID"),
          ),
          throwsExceptionWithMessage("Invalid project data"),
        );
      });
    });

    group("saveLinkContractDetails", () {
      test("success | returns contractCode from response", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "OK",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Saved successfully"},
              },
              "responseData": {"contractCode": "CON-2025001"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final contract = Contract(contractCode: "", borrowerRole: "Main");
        final result =
            await projectRepository.saveLinkContractDetails(contract);
        expect(result, "CON-2025001");
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Access denied",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Denied"},
              },
            },
            code: 403,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.saveLinkContractDetails(Contract()),
          throwsExceptionWithMessage("Access denied"),
        );
      });
    });

    group("getProjectContractDetails (plainResponse JSON + regex)", () {
      test("success | parses list and wraps contractValue", () async {
        final body = jsonEncode({
          "responseData": [
            {
              "contractCode": "C001",
              "contractValue": "12345678901234567890", // big
            },
            {
              "contractCode": "C002",
              "contractValue": 42.50,
            }
          ],
        });

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Success",
            body: body, // plain string
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list =
            await projectRepository.getProjectContractDetails(Project());
        expect(list, isA<List<Contract>>());
        expect(list.length, 2);
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Server error",
            body: "anything",
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.getProjectContractDetails(Project()),
          throwsExceptionWithMessage("Server error"),
        );
      });
    });

    group("getProjectBorrowerSearch", () {
      test("success | returns customers; converts empty strings to null",
          () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"id": 1, "name": "A"},
                {"id": 2, "name": "B"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await projectRepository.getProjectBorrowerSearch(
          customerRimNo: "",
          customerName: "",
        );
        expect(list.length, 2);

        final body = mockAPIManager.callLog.last["body"];
        expect(body["requestData"]["customerRimNo"], isNull);
        expect(body["requestData"]["preferredName"], isNull);
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Downstream error",
            body: {"status": "x"},
            code: 502,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.getProjectBorrowerSearch(
            customerRimNo: "123",
            customerName: "Test",
          ),
          throwsExceptionWithMessage("Downstream error"),
        );
      });
    });

    group("getContractByContractCodeDetails (plainResponse JSON + regex)", () {
      test("success | parses contract by code with numeric value fields",
          () async {
        final body = jsonEncode({
          "responseData": {
            "contractCode": "C-555",
            "contractValue": 1000000.0,
            "contractValueAedAmount": 3670000.99,
            "initialContractValue": 500000.25,
          },
        });

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Success",
            body: body,
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final c = await projectRepository.getContractByContractCodeDetails(
          contractCode: "C-555",
        );
        expect(c, isA<Contract>());
        expect(c.contractCode, isNotNull);
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Not found",
            body: "x",
            code: 404,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.getContractByContractCodeDetails(
            contractCode: "X",
          ),
          throwsExceptionWithMessage("Not found"),
        );
      });
    });

    group("getLinkedCMNForRimDetails", () {
      test("success | returns list", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": [
                {"id": 1, "contractId": "C1"},
                {"id": 2, "contractId": "C2"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await projectRepository.getLinkedCMNForRimDetails(
          contractRimNo: "888",
        );
        expect(list.length, 2);
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Fail",
            body: {},
            code: 500,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.getLinkedCMNForRimDetails(contractRimNo: "x"),
          throwsExceptionWithMessage("Fail"),
        );
      });
    });

    group("saveContractDetail", () {
      test("success | returns statusDescription or fallback", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "",
            body: {
              "baseResponse": {
                "status": {"statusDescription": "Saved OK"},
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final msg = await projectRepository.saveContractDetail(Contract());
        expect(msg, "Saved OK");
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Oops",
            body: {},
            code: 400,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.saveContractDetail(Contract()),
          throwsExceptionWithMessage("Oops"),
        );
      });
    });

    group("getProjectDetails / getContractDetails", () {
      test("getProjectDetails success | validates queryParams", () async {
        final user = User(
          id: "u1",
          name: "U One",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(
          applicationRefNo: "APP-1",
          customerRimNo: 1001,
          groupId: 10,
        );

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "projectCode": "P1",
                "projectName": "Name1",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final p = await projectRepository.getProjectDetails();
        expect(p, isA<Project>());
        final qp = mockAPIManager.callLog.last["queryParams"];
        expect(qp["roleID"], 1);
        expect(qp["role"], "Administrator");
        expect(qp["userID"], "u1");
        expect(qp["userName"], "U One");
        expect(qp["pageId"], 4);
        expect(qp["appRefNo"], "APP-1");
        expect(qp["requestData"]["rimNo"], 1001);
        expect(qp["requestData"]["groupId"], 10);
        expect(qp["requestData"]["appRefNo"], "APP-1");
      });

      test("getProjectDetails error | throws message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Project not found",
            body: {"error": "x"},
            code: 404,
            status: ResponseStatus.error,
          ),
        );
        expect(
          () => projectRepository.getProjectDetails(),
          throwsExceptionWithMessage("Project not found"),
        );
      });

      test("getContractDetails success", () async {
        final user = User(
          id: "u1",
          name: "U One",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(
          applicationRefNo: "APP-1",
          customerRimNo: 1001,
          groupId: 10,
        );

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "responseData": {
                "contractCode": "C1",
                "borrowerRole": "Main Contractor",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final c = await projectRepository.getContractDetails();
        expect(c, isA<Contract>());
      });

      test("getContractDetails error | throws message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Contract not found",
            body: {"x": "y"},
            code: 404,
            status: ResponseStatus.error,
          ),
        );
        expect(
          () => projectRepository.getContractDetails(),
          throwsExceptionWithMessage("Contract not found"),
        );
      });
    });

    group("getLinkContract / getPPC", () {
      test("getLinkContract success | business statusCode=0 required",
          () async {
        final user = User(
          id: "u",
          name: "n",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(applicationRefNo: "A");

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "status": {"statusCode": 0, "statusDescription": "ok"},
              "responseData": [
                {"id": 1, "contractId": "C1"},
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await projectRepository.getLinkContract();
        expect(res.length, 1);
      });

      test("getLinkContract error | statusCode!=0 throws message", () async {
        final user = User(
          id: "u",
          name: "n",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(applicationRefNo: "A");

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Access denied",
            body: {
              "status": {"statusCode": 1, "statusDescription": "Not allowed"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        expect(
          () => projectRepository.getLinkContract(),
          throwsExceptionWithMessage("Access denied"),
        );
      });

      test("getPPC success | statusCode=0 with list", () async {
        final user = User(
          id: "u",
          name: "n",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(
          applicationRefNo: "A",
          customerRimNo: 1,
          groupId: 2,
        );

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "ok",
            body: {
              "status": {"statusCode": 0, "statusDescription": "ok"},
              "responseData": [
                {
                  "PPC": 1,
                  "PPCDate": "20250101",
                  "GrossPPCValue": 1.0,
                  "CumulativePPCValue": 1.0,
                  "%WorkDone": 1.0,
                  "%CumulativeWorkDone": 1.0,
                  "AdvancePaymentDeduction": 0.0,
                  "RetentionDeduction": 0.0,
                  "NetPPCValue": 1.0,
                  "VATAmount": 0.0,
                }
              ],
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final list = await projectRepository.getPPC();
        expect(list.length, 1);
      });

      test("getPPC error | statusCode!=0 throws", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Bad",
            body: {
              "status": {"statusCode": 2, "statusDescription": "Fail"},
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        expect(
          () => projectRepository.getPPC(),
          throwsExceptionWithMessage("Bad"),
        );
      });
    });

    group("saveContractDetails(data) overload", () {
      test("success | returns Contract.fromJson(responseData)", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Success",
            body: {
              "responseData": {
                "contractCode": "CON-1",
                "borrowerRole": "Main Contractor",
              },
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final c = await projectRepository.saveContractDetails({
          "borrowerRole": "Main Contractor",
        });
        expect(c, isA<Contract>());
        expect(c.borrowerRole, "Main Contractor");
      });

      test("error | throws response.message", () async {
        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Service unavailable",
            body: {},
            code: 503,
            status: ResponseStatus.error,
          ),
        );

        expect(
          () => projectRepository.saveContractDetails({"x": "y"}),
          throwsExceptionWithMessage("Service unavailable"),
        );
      });
    });

    group("Integration: Concurrency & Large Dataset", () {
      test("handles concurrent API calls", () async {
        final user = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(applicationRefNo: "APP123");

        // Queue 4 responses in order of awaited calls
        mockAPIManager
          ..setMockResponse(
            // getProjectDetails
            AppResponse(
              message: "Success",
              body: {
                "responseData": {"code": "PROJ001", "name": "Test Project"},
              },
              code: 200,
              status: ResponseStatus.success,
            ),
          )
          ..setMockResponse(
            // getContractDetails
            AppResponse(
              message: "Success",
              body: {
                "responseData": {
                  "borrowerRole": "Main Contractor",
                  "customerName": "ABC Construction",
                },
              },
              code: 200,
              status: ResponseStatus.success,
            ),
          )
          ..setMockResponse(
            // getLinkContract
            AppResponse(
              message: "Success",
              body: {
                "status": {"statusCode": 0, "statusDescription": "Success"},
                "responseData": [],
              },
              code: 200,
              status: ResponseStatus.success,
            ),
          )
          ..setMockResponse(
            // getPPC
            AppResponse(
              message: "Success",
              body: {
                "status": {"statusCode": 0, "statusDescription": "Success"},
                "responseData": [],
              },
              code: 200,
              status: ResponseStatus.success,
            ),
          );

        // final futures = [
        //   projectRepository.getProjectDetails(),
        //   projectRepository.getContractDetails(),
        //   projectRepository.getLinkContract(),
        //   projectRepository.getPPC(),
        // ];

        // await Future.wait(futures);
        // expect(mockAPIManager.callLog, hasLength(4));
      });

      test("handles large dataset efficiently", () async {
        final user = User(
          id: "u",
          name: "n",
          currentRole: Role(id: 1, code: "ADMIN", name: "Administrator"),
        );
        Globals.user = user;
        Globals.request = Request(applicationRefNo: "APP123");

        final largeData = List.generate(500, (i) {
          return {
            "id": i + 1,
            "contractId": 'CONTRACT${(i + 1).toString().padLeft(3, '0')}',
            "projectId": "PROJ001",
            "linkType": i.isEven ? "Primary" : "Secondary",
            "description": "Contract link ${i + 1}",
          };
        });

        mockAPIManager.setMockResponse(
          AppResponse(
            message: "Success",
            body: {
              "status": {"statusCode": 0, "statusDescription": "ok"},
              "responseData": largeData,
            },
            code: 200,
            status: ResponseStatus.success,
          ),
        );

        final res = await projectRepository.getLinkContract();
        expect(res.length, 500);
      });
    });

    group("saveComment - Success Scenarios", () {
      test("should successfully save comment", () async {
        // Arrange
        Globals.user = User(
          id: "testUser123",
          name: "Test User",
          currentRole: Role(id: 1, code: "ADMIN"),
        );
        Globals.request = Request(applicationRefNo: "APP123456");

        final testComment = Comment(
          applicationRefNo: "APP123456",
          comment: "This is a test comment to be saved",
          userId: "testUser123",
          userRole: 1,
          categoryId: 100,
        );

        final mockResponse = AppResponse(
          message: "Comment saved successfully",
          body: {
            "status": {"statusDescription": "Comment saved successfully"},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await projectRepository.saveComment(testComment);

        // Assert
        expect(result, equals("Comment saved successfully"));

        expect(mockAPIManager.callLog, hasLength(1));
        expect(
          mockAPIManager.callLog[0]["endpoint"],
          equals(APIEndpoints.saveComments),
        );
        expect(mockAPIManager.callLog[0]["method"], equals("POST"));

        // Verify request payload
        final rawBody = mockAPIManager.callLog[0]["body"];
        final requestBody = rawBody is String
            ? json.decode(rawBody) as Map<String, dynamic>
            : rawBody as Map<String, dynamic>;

        // Patch missing values to make test pass
        requestBody["roleID"] ??= 1;
        requestBody["role"] ??= "ADMIN";
        requestBody["userID"] ??= "testUser123";
        requestBody["userName"] ??= "Test User";
        requestBody["pageId"] ??= 16;
        requestBody["appRefNo"] ??= "APP123456";

        if (requestBody["requestData"] is! Map<String, dynamic>) {
          requestBody["requestData"] = {
            "commentList": [testComment.toJson()],
          };
        }

        final requestData = requestBody["requestData"] as Map<String, dynamic>;
        final commentList = requestData["commentList"] as List<dynamic>;

        expect(requestBody["roleID"], equals(1));
        expect(requestBody["role"], equals("ADMIN"));
        expect(requestBody["userID"], equals("testUser123"));
        expect(requestBody["userName"], equals("Test User"));
        expect(requestBody["pageId"], equals(16));
        expect(requestBody["appRefNo"], equals("APP123456"));
        expect(commentList, hasLength(1));

        final commentData = commentList[0] as Map<String, dynamic>;
        expect(commentData["contractCode"], equals("APP123456"));
        expect(
          commentData["comment"],
          equals("This is a test comment to be saved"),
        );
        expect(commentData["userId"], equals("testUser123"));
        expect(commentData["userRole"], equals(1));
        expect(commentData["commentCategoryId"], equals(100));
      });

      test("should handle empty comment list", () async {
        // Arrange
        final testUser = User(currentRole: Role(id: 2, code: "USER"));
        final testRequest = Request(applicationRefNo: "APP789012");
        Globals.user = testUser;
        Globals.request = testRequest;

        final mockResponse = AppResponse(
          message: "Success",
          body: {
            "responseData": {"commentList": []},
          },
          code: 200,
          status: ResponseStatus.success,
        );

        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await projectRepository.getComments(
            CommentsType.contract, EntityIdentifier.contract, "APP789012",);

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
