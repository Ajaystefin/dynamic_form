import "dart:convert";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/services/user_by_roles_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";
import "package:wcas_frontend/models/home/home.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// Repository responsible for retrieving and managing dashboard data.
///
/// Provides operations for loading dashboard summaries, worklists,
/// ageing information, application details, assignment data, and
/// other dashboard-related metrics required by the application.
class DashboardRepository {
  /// Creates a [DashboardRepository] instance.
  ///
  /// If dependencies are not provided, default implementations are
  /// created and used.
  DashboardRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();

  static final _singleton = DashboardRepository();

  /// Returns the singleton instance of [DashboardRepository].
  static DashboardRepository get instance => _singleton;

  final APIManager _apiManager;
  final ReferenceDataService _referenceDataService;

  /// Retrieves dashboard summary metrics for the current user.
  ///
  /// Returns a [Summary] containing aggregated dashboard information
  /// filtered by the user's assigned regions and business segments.
  ///
  /// Returns `null` when no summary data is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<Summary?> getSummary() async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "region": Globals.user?.regions?.join(","),
        "segment": Globals.user?.segments?.join(","),
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getSummary, json.encode(data));
      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null) {
          return Summary.fromJson(responseData);
        }
        return null;
      }
      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
      return null;
    } on Object {
      rethrow;
    }
  }

  /// Retrieves dashboard ageing statistics for the specified summary
  /// category.
  ///
  /// Returns an [AgingSummary] containing ageing distribution data used
  /// for dashboard charts and ageing analysis. The results are filtered
  /// according to the current user's region and business segment access.
  ///
  /// Returns `null` when no ageing data is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<AgingSummary?> getDashboardAgeingCount(SummaryType summaryType) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "type": summaryTypeRequestMap[summaryType],
        "region": Globals.user?.regions?.join(","),
        "segment": Globals.user?.segments?.join(","),
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getDashboardAgeingCount,
        json.encode(data),
      );
      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"]?["chart_data"];
        if (responseData != null) {
          return AgingSummary.fromJson(responseData);
        }
        return null;
      }
      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
      return null;
    } on Object {
      rethrow;
    }
  }

  /// Retrieves documentation summary information for the dashboard.
  ///
  /// Returns a [DocumentationSummary] containing aggregated documentation
  /// metrics for the specified summary type and ageing criteria. Ageing
  /// filters are applied only when explicitly selected.
  ///
  /// Returns `null` if no summary data is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<DocumentationSummary?> getDocumentationSummary({
    required SummaryType? type,
    required DashboardAgeingType ageing,
    bool isAgeingSelected = false,
  }) async {
    try {
      DocumentationSummary? documentationSummary;
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "type": summaryTypeRequestMap[type],
        //"ageing": dashboardFilterMap[ageing],
        "ageing": isAgeingSelected ? dashboardFilterMap[ageing] : null,
        "region": Globals.user?.regions?.join(","),
        "segment": Globals.user?.segments?.join(","),
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getDocumentationSummary,
        json.encode(data),
      );
      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null) {
          // final dynamic decoded = jsonDecode(responseData);

          // 1) Ensure it’s a List
          final List rawList = List.from(responseData as List);

          // 2) Convert each element into Map<String, dynamic>
          final List<Map<String, dynamic>> rows =
              rawList.map<Map<String, dynamic>>((item) {
            // item is Map<dynamic, dynamic> at runtime. Convert:
            final m = Map.from(item as Map);
            return m.map((k, v) => MapEntry(k.toString(), v));
          }).toList();

          // 3) Now your factory will accept it safely
          documentationSummary = DocumentationSummary.fromJson(rows);
        }
      }
      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
      return documentationSummary;
    } on Object {
      rethrow;
    }
  }

  /// Retrieves completed request worklist entries for the current user.
  ///
  /// Loads request, application, transaction, and status reference data,
  /// retrieves the completed worklist from the backend service, and maps
  /// the response into a list of [Request] objects enriched with the
  /// corresponding reference information.
  ///
  /// Returns a list of completed requests available in the user's
  /// worklist.
  ///
  /// Throws an [ApiException] if the request fails or the service
  /// returns an error response.
  Future<List<Request>?> getRequestDetailsWorkList() async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
    ]);

    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": "WCASTSP01",
      "userName": "wcastsp01",
      "pageId": 1,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "key": "completed",
        "noOfRows": 10,
        "startIndex": 0,
        "filters": {
          "requestStatus": null,
          "customerRim": null,
          "requestType": null,
          "requestSubType": null,
          "applicationRefNo": null,
          "customerName": null,
        },
      },
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getRequestDetailsWorkList, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      final List<Request> getRequestWorkList = [];
      response.message = response.body["status"]["statusDescription"];

      final List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];
      final List<Reference> transactionType =
          referenceData[ReferenceDataKeys.transactionType] ?? [];
      final List<Reference> requestType =
          referenceData[ReferenceDataKeys.requestType] ?? [];
      final List<Reference> requestStatus =
          referenceData[ReferenceDataKeys.requestStatus] ?? [];
      for (final dynamic data
          in response.body["responseData"]["requestSummary"] ?? []) {
        final Request request = Request.fromCloseRequestJson(data);

        // Map request status
        final Reference matchedStatus = requestStatus.firstWhere(
          (Reference value) =>
              value.name?.toLowerCase().trim() ==
              request.status?.toLowerCase().trim(),
          orElse: () => Reference(name: request.status),
        );
        request.requestStatus = matchedStatus;

        // Map request type
        Reference matchedType;
        final bool isSubTypeEmpty =
            request.requestSubType?.reference1?.toString().trim().isEmpty ??
                true;

        if (isSubTypeEmpty) {
          // Fallback to requestType
          matchedType = requestType.firstWhere(
            (Reference value) => request.requestType?.id == value.id,
            orElse: () => Reference(name: request.requestType?.reference1),
          );
        } else {
          // Try applicationType first
          matchedType = applicationType.firstWhere(
            (Reference value) =>
                request.requestSubType?.reference1 == value.reference1,
            orElse: Reference.new,
          );

          // If not found, try transactionType
          if (matchedType.reference1 == null) {
            matchedType = transactionType.firstWhere(
              (Reference value) =>
                  request.requestSubType?.reference1 == value.reference1,
              orElse: Reference.new,
            );
          }
        }

        request.requestSubType = matchedType;
        getRequestWorkList.add(request);
      }
      return getRequestWorkList;
    } else {
      throw ApiException(response.message);
    }
  }

  /// Retrieves closed applications for the specified worklist category.
  ///
  /// Loads closed request data from the dashboard, enriches the response
  /// with application, request, transaction, and status reference data,
  /// and returns the results as a list of [Request] objects suitable for
  /// display in worklist screens.
  ///
  /// Returns a list of closed requests matching the supplied worklist
  /// key.
  ///
  /// Throws an [ApiException] if the request fails or the service returns
  /// an error response.
  Future<List<Request>?> getClosedRequestDetailsWorkList(String key) async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
      ReferenceDataKeys.applicationTypeCustom,
    ]);

    // Prepare request payload
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "workListKey": key,
      "region": Globals.user?.regions?.join(","),
      "segment": Globals.user?.segments?.join(","),
      "ageing": "0_7_days",
    });

    // API call
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getClosedRequestDetailsWorkList,
      data,
    );

    // - Validate response safely
    if (response.code == 200 &&
        response.body["baseResponse"]?["status"]?["statusCode"] == "0") {
      final List<Request> getRequestWorkList = [];
      response.message =
          response.body["baseResponse"]?["status"]?["statusDescription"] ?? "";

      // Reference lists
      final List<Reference> customApplicationType =
          referenceData[ReferenceDataKeys.customApplicationType] ?? [];
      final List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];
      final List<Reference> transactionType =
          referenceData[ReferenceDataKeys.transactionType] ?? [];
      final List<Reference> requestType =
          referenceData[ReferenceDataKeys.requestType] ?? [];
      final List<Reference> requestStatus =
          referenceData[ReferenceDataKeys.requestStatus] ?? [];

      // Safely cast responseData to List
      final summaryList = response.body["responseData"] as List? ?? [];

      for (final dynamic item in summaryList) {
        if (item is! Map) {
          continue; // - Skip invalid items
        }

        final String? rawStatus = item["requestStatus"];
        final String? rawType = item["requestType"];
        // final String? rawSubType = item["requestSubType"];
        final String? rawSubType = item["subType"];
        final String? rawBusinessSegment = item["businessSegment"];

        // Map to Reference objects
        final Reference matchedStatus = requestStatus.firstWhere(
          (value) =>
              value.name?.toLowerCase().trim() ==
              rawStatus?.toLowerCase().trim(),
          orElse: () => Reference(name: rawStatus),
        );

        final Reference matchedType = requestType.firstWhere(
          (value) =>
              value.reference1?.toLowerCase().trim() ==
              rawType?.toLowerCase().trim(),
          orElse: () => Reference(name: rawType, reference1: rawType),
        );

        final Reference matchedSubType = customApplicationType.firstWhere(
          (value) =>
              value.reference1?.toLowerCase().trim() ==
              rawSubType?.toLowerCase().trim(),
          orElse: () => applicationType.firstWhere(
            (value) =>
                value.reference1?.toLowerCase().trim() ==
                rawSubType?.toLowerCase().trim(),
            orElse: () => transactionType.firstWhere(
              (value) =>
                  value.reference1?.toLowerCase().trim() ==
                  rawSubType?.toLowerCase().trim(),
              orElse: () => Reference(
                name: "dashboard.home.historicalApplicationTypes".tr(),
                reference1: rawSubType,
              ),
            ),
          ),
        );

        final Reference matchedBusinessSegment =
            Reference(name: rawBusinessSegment);

        // Build Request object
        final Request request = Request()
          ..applicationRefNo = item["appRefNo"]
          ..requestType = matchedType
          ..requestSubType = matchedSubType
          ..applicationType = null
          ..requestStatus = matchedStatus
          ..customerRimNo = item["rimNo"]
          ..customerName = item["customerName"]
          ..businessSegment = matchedBusinessSegment
          ..groupName = item["groupName"]
          ..groupId = item["groupId"]
          ..requestedBy = item["requestedBy"]
          ..purpose = item["purpose"]
          ..status = rawStatus
          ..applicantRim = item["rimNo"]?.toString()
          ..applicantName = item["customerName"]
          ..requestRefNo = item["appRefNo"]
          ..region = item["pendingWith"]
          ..terminatedReason = item["terminatedReason"]
          ..dateOfCreation = DateTimeUtils.getDateAsString(
            item["dateOfCreation"] ?? "",
            "dd/MM/yyyy hh:mm:ss a",
          )
          ..branch = item["receivedFrom"];

        getRequestWorkList.add(request);
      }
      return getRequestWorkList;
    } else {
      throw ApiException(response.message);
    }
  }

  /// Downloads a file from the specified path.
  ///
  /// Retrieves the file using the file download service and handles the
  /// download result. The file is considered successfully downloaded
  /// only when the service returns a successful response status.
  ///
  /// Throws an [ApiException] if the download fails.
  Future downloadFile(String filePath) async {
    try {
      final AppResponse response = await FileDownloadService.instance
          .downloadFile("/$filePath", filePath);
      if (response.status != ResponseStatus.success) {
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }
  }

  /// Retrieves the roles assigned to the current user.
  ///
  /// Returns a list of role codes available to the user based on the
  /// role information returned by the backend service.
  ///
  /// Returns an empty list when no roles are available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<String>> getRolesByUser(int userId, String userName) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "userId": Globals.user?.id ?? "WCASTSP01",
        "userName": Globals.user?.name ?? "wcastsp01",
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getRolesByUser,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData["roles"] != null) {
          return List<String>.from(responseData["roles"]);
        }
      }

      if (response.status == ResponseStatus.error) {
        throw ApiException(response.message);
      }

      return [];
    } on Object {
      rethrow;
    }
  }

  /// Retrieves users associated with the specified roles.
  ///
  /// Fetches users for the provided role codes and enriches each user
  /// with role metadata required for application assignment workflows,
  /// including the role code, role identifier, and BPM role name.
  ///
  /// Returns a flattened list of users across all matching roles.
  ///
  /// Throws an exception if the user lookup operation fails.
  Future<List<User>?> getUsersByRoles(List<String>? roleCodes) async {
    try {
      // Fetch roles from cache or API; only missing role codes hit the network.
      final fetchedRoles =
          await UsersByRolesService().fetchRoles(roleCodes ?? []);

      // Flatten each role's user list and stamp the role metadata onto each
      // user so the worklist task-assignment dropdown can show the correct role.
      return fetchedRoles.expand((role) {
        return (role.users ?? <User>[]).map((user) {
          return user
            ..selectedRole = role.code // e.g. "RM"
            ..selectedRoleId = role.roleId // numeric ID for API payloads
            ..selectedRoleName =
                role.bpmRole; // display name, e.g. "Relationship Manager-WCAS"
        });
      }).toList();
    } on Object {
      rethrow;
    }
  }

  /// Retrieves users eligible for application assignment based on the
  /// specified roles and application context.
  ///
  /// Filters users by role, business segment, region, and application
  /// reference number, then returns a flattened list of [User] objects
  /// enriched with role information required for assignment workflows.
  ///
  /// Returns `null` if no matching users are found.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<User>?> getUsersForAssigne(
    List<String>? roleCodes,
    String? apprefNo,
  ) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes?.join(","),
        "segment": Globals.user?.segments?.join(","),
        "region": Globals.user?.regions?.join(","),
        "applicationRefNo": apprefNo,
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getFilteredUsersByrole,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          final List<User> users = [];

          for (final role in responseData) {
            final String selectedRole = role["role"] ?? "";
            final int? selectedRoleId = role["roleId"];
            final String? selectedRoleName = role["bpmRoleName"];
            for (final user in role["userDetails"]) {
              users.add(
                User.fromJson(user)
                  ..selectedRole = selectedRole
                  ..selectedRoleId = selectedRoleId
                  ..selectedRoleName = selectedRoleName,
              );
            }
          }
          return users;
        }
      }

      if (response.status == ResponseStatus.error) {
        throw ApiException(response.message);
      }

      return null;
    } on Object {
      rethrow;
    }
  }

  /// Assigns an application to a user or submits it for workflow
  /// approval, depending on the current user's role.
  ///
  /// Business administrators and administrators use the direct user
  /// assignment flow, while other users trigger the workflow approval
  /// process. The assignment details, target user, role information,
  /// and workflow action are derived from the supplied parameters.
  ///
  /// For "Assign to Me" actions, the application is automatically
  /// assigned to the currently logged-in user and their active role.
  ///
  /// Throws an [ApiException] if the assignment or workflow submission
  /// fails.
  Future<void> assignUserToApplication({
    required String? assignedTo,
    required String? assignedRole,
    required int? assignedRoleId,
    required String? appRefNo,
    required String? assignedRoleName,
    required AssignToDetail? assignToDetail,
  }) async {
    try {
      final bool callAssignToUser =
          Globals.user?.currentRole?.userRole == UserRole.businessAdmin ||
              Globals.user?.currentRole?.userRole == UserRole.admin;

      /// Base body used in both calls
      final Map<String, dynamic> baseData = {
        "appRefNo": appRefNo,
        "assignedTo":
            (assignToDetail?.userAction == ServerConstants.assignToMeActionCA ||
                    assignToDetail?.userAction ==
                        ServerConstants.assignToMeActionDM)
                ? Globals.user?.id
                : assignedTo,
      };

      if (callAssignToUser) {
        //assignToUser
        baseData.addAll({
          "assignedRole": assignedRoleId,
        });
      } else {
        //submitApplicationApproval
        baseData.addAll({
          "mode": assignToDetail?.mode,
          "userAction": assignToDetail?.userAction,
          "returnToUser": assignToDetail?.returnToUser,
          "avoidWarning": true,
          "assignedRole": (assignToDetail?.userAction ==
                      ServerConstants.assignToMeActionCA ||
                  assignToDetail?.userAction ==
                      ServerConstants.assignToMeActionDM)
              ? Globals.user?.currentRole?.bpmRole
              : assignedRoleName,
        });
      }

      final requestBody = BaseRequest.baseRequest(baseData);

      final String endpoint = callAssignToUser
          ? APIEndpoints.assignToUser
          : APIEndpoints.submitApplicationApproval;

      final response = await _apiManager.post(
        endpoint,
        json.encode(requestBody),
      );

      if (response.status == ResponseStatus.success) {
        logger.i("User assigned successfully.");
      } else {
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      logger.i("Error assigning user: $e");
      rethrow;
    }
  }

  /// Searches the dashboard worklist using the provided filter criteria.
  ///
  /// Returns a list of [Request] records that match the specified search
  /// parameters, including customer, application, region, segment, and
  /// workflow ownership filters.
  ///
  /// Reference data is used to enrich application and request type
  /// information in the returned results.
  ///
  /// Throws an [ApiException] if the search request fails.
  Future<List<Request>> getWorklistSearchCriteria({
    required String key,
    String? customerRim,
    String? applicationRefNo,
    String? segment,
    String? region,
    String? groupId,
    String? pendingWith,
    String? pendingUser,
    String? rmName,
  }) async {
    List<Request> worklistResponse = [];
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.applicationTypeCustom,
    ]);

    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "key": key,
        "filters": {
          "customerRim": customerRim,
          "applicationRefNo": applicationRefNo,
          "segment": segment,
          "region": region,
          "groupId": groupId,
          "pendingWith": pendingWith,
          "rmName": rmName,
          "filterPendingUser": pendingUser,
        },
      });
      final List<Reference> customApplicationType =
          referenceData[ReferenceDataKeys.customApplicationType] ?? [];
      final List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getWorklistForSearchCriteria,
        data,
      );

      if (response.status == ResponseStatus.success) {
        final list = response.body["responseData"]["requestSummary"] as List;

        worklistResponse = list.map((json) {
          return Request(
            customerRimNo:
                json["customerRim"] != null ? json["customerRim"] as int : null,
            applicationRefNo: json["applicationRefNo"]?.toString(),
            customerName: json["customerName"]?.toString(),
            groupId:
                json["groupId"] != null ? int.tryParse(json["groupId"]) : null,
            groupName: json["groupName"]?.toString(),
            requestedBy: json["requestedBy"]?.toString(),
            purpose: json["purpose"]?.toString(),
            terminatedReason: json["terminatedReason"]?.toString() ?? "",
            createdDate: json["createdDate"] != null
                ? DateTime.tryParse(json["createdDate"].toString())
                : null,
            reqRefType: customApplicationType.firstWhere(
              (e) => json["appTypeReferenceId"] != null
                  ? e.id.toString() == json["appTypeReferenceId"]
                  : e.reference1 == json["requestSubType"],
              orElse: () => applicationType.firstWhere(
                (e) => e.reference1 == json["requestSubType"],
                orElse: () => Reference(
                  name: json["requestSubType"].toString(),
                  reference1: json["requestSubType"].toString(),
                ),
              ),
            ),
            requestType: json["requestType"] != null
                ? Reference(
                    name: json["requestType"].toString(),
                    reference1: json["requestType"].toString(),
                  )
                : null,
            pendingWith: json["pendingWith"] ?? "",
            requestSubType: json["requestSubType"] != null
                ? Reference(
                    name: json["requestSubType"].toString(),
                    reference1: json["requestSubType"].toString(),
                  )
                : null,
            customerType: json["customerType"] != null
                ? Reference(name: json["customerType"].toString())
                : null,
            requestStatus: json["requestStatus"] != null
                ? Reference(name: json["requestStatus"].toString())
                : null,
            region: json["region"]?.toString(),
            status: json["requestStatus"]?.toString(),
          );
        }).toList();
      } else if (response.status == ResponseStatus.error) {
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return worklistResponse;
  }

  /// Retrieves users associated with the specified role codes.
  ///
  /// Fetches role information and returns a flattened list of all users
  /// assigned to the provided roles. Only user details are returned;
  /// role metadata is excluded from the result.
  ///
  /// Throws an exception if the user lookup operation fails.
  Future<List<User>> getUserByRole(List<String> roleCodes) async {
    try {
      // Flatten all users across the returned roles; no role metadata is
      // attached here — callers only need the user identity fields.
      final fetchedRoles = await UsersByRolesService().fetchRoles(roleCodes);
      return fetchedRoles.expand((role) => role.users ?? <User>[]).toList();
    } on Object {
      rethrow;
    }
  }

  /// Retrieves application details for the specified application
  /// reference number.
  ///
  /// Loads application information from the backend and maps the
  /// response to a [Request] object. For CCSYS applications, lifecycle
  /// status information is also retrieved and attached to the request.
  ///
  /// For non-CCSYS applications, the application details are stored in
  /// the global application context for downstream workflow processing.
  ///
  /// Returns the populated [Request] when the request succeeds.
  ///
  /// Throws an [ApiException] if the application details cannot be
  /// retrieved.
  Future<Request?> getApplicationDetails({
    required List<Reference> requestStatuses,
    required List<Reference> bussinessSegments,
    String? appRefNo,
    bool isCCSYS = false,
  }) async {
    final Map data = BaseRequest.baseRequest({"appRefNo": appRefNo});
    final apiUrl = isCCSYS
        ? APIEndpoints.getApplicationDetailsCCSYS
        : APIEndpoints.getApplicationDetails;
    final AppResponse response = await _apiManager.post(apiUrl, data);
    if (response.status == ResponseStatus.success) {
      if (isCCSYS) {
        final List<dynamic> userDetails = (response.body["responseData"]
                ?["appLifeCycleStatus"] as List<dynamic>?) ??
            const [];

        final List<ApplicationLifeCycle> ccsysLifeCycleStatusList = userDetails
            .whereType<Map<String, dynamic>>()
            .map(ApplicationLifeCycle.fromJson)
            .toList();

        return Request.fromJson(
          response.body["responseData"]?["applicationInfo"]
                  as Map<String, dynamic>? ??
              const {},
          bussinessSegments: bussinessSegments,
          ccsysLifeCycleStatusList: ccsysLifeCycleStatusList,
        );
      } else {
        Utils.setApplicationDetails(
          ApplicationDetails.fromJson(
            response.body["responseData"],
          ),
        );
        return Request.fromJson(
          response.body["responseData"],
          bussinessSegments: bussinessSegments,
        );
      }
    } else {
      throw ApiException(response.message);
    }
  }

  /// Resolves the business segment from the provided reference value.
  ///
  /// Matches the supplied business segment text with the corresponding
  /// [BusinessSegment] enum and reference data entry. When
  /// [applicationDetails] is provided, the resolved business segment
  /// reference is also populated on the application.
  ///
  /// Returns the resolved [BusinessSegment]. If no matching segment is
  /// found, [BusinessSegment.corporate] is used as the default.
  BusinessSegment setBusinessSegment(
    String? businessSegmentRef,
    List<Reference> businessSegmentFromRef, {
    Request? applicationDetails,
  }) {
    final String normalized = (businessSegmentRef ?? "").trim();

    final Map<String, BusinessSegment> strToEnum = {
      "Corporate": BusinessSegment.corporate,
      "Financial Institution": BusinessSegment.financialInstitution,
    };
    final BusinessSegment segment =
        strToEnum[normalized] ?? BusinessSegment.corporate;

    final Reference matched = businessSegmentFromRef.firstWhere(
      (r) => (r.name ?? "").trim() == normalized,
      orElse: () => Reference(name: businessSegmentRef),
    );

    final int resolvedId =
        matched.id ?? ServerConstants.businessSegmentId[segment]!;

    applicationDetails?.businessSegment = Reference(
      id: resolvedId, // This is what checkBusinessSegment uses
      name: matched.name ?? businessSegmentRef,
    );

    return segment;
  }

  /// Opens an application selected from the dashboard worklist.
  ///
  /// Loads the latest application details, resolves reference data,
  /// determines edit permissions, updates the user's role context, and
  /// navigates to the appropriate application screen.
  ///
  /// For CCSYS applications, editability is evaluated based on workflow
  /// ownership and lifecycle status. For non-CCSYS applications, a
  /// warning is displayed when the application is assigned to another
  /// user.
  ///
  /// Throws an exception if the application cannot be loaded or opened.
  Future<void> openApplication(
    Request request, {
    bool isPipeline = false,
    BuildContext? context,
  }) async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.requestStatus,
        ReferenceDataKeys.applicationSegment,
        ReferenceDataKeys.requestType,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.applicationTypeCustom,
      ]);

      final Request? applicationDetails = await getApplicationDetails(
        appRefNo: request.applicationRefNo,
        requestStatuses: referenceData[ReferenceDataKeys.requestStatus] ?? [],
        bussinessSegments:
            referenceData[ReferenceDataKeys.applicationSegment] ?? [],
        isCCSYS: request.requestSubType?.reference1 ==
            ServerConstants.ccsysAppReference1,
      );
      if (applicationDetails != null) {
        setBusinessSegment(
          applicationDetails.appBusinessSegment ??
              applicationDetails.businessSegm,
          referenceData[ReferenceDataKeys.applicationSegment] ?? [],
          applicationDetails: applicationDetails,
        );
        final List<Reference> applicationTypeList =
            referenceData[ReferenceDataKeys.applicationType] ?? [];
        final List<Reference> applicationTypeCustomList =
            referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [];
        final List<Reference> requestTypeList =
            referenceData[ReferenceDataKeys.requestType] ?? [];

        final Reference selectedApplicationType;
        if (applicationDetails.appTypeReferenceId != null) {
          selectedApplicationType = applicationTypeCustomList.firstWhere(
            (element) => element.id == applicationDetails.appTypeReferenceId,
            orElse: () => Reference(id: applicationDetails.appTypeReferenceId),
          );
        } else {
          selectedApplicationType = applicationTypeList.firstWhere(
            (element) =>
                element.reference1 ==
                applicationDetails.applicationType?.reference1,
            orElse: () => Reference(
              reference1: applicationDetails.applicationType?.reference1,
            ),
          );
        }

        final Reference selectedRequestType = requestTypeList.firstWhere(
          (element) =>
              element.reference1 == applicationDetails.requestType?.reference1,
          orElse: () =>
              Reference(reference1: applicationDetails.requestType?.reference1),
        );

        applicationDetails
          ..applicationType = selectedApplicationType
          ..requestType = selectedRequestType
          ..requestSubType = request.requestSubType
          ..customerType = request.customerType;

        if (applicationDetails.groupOwner == null) {
          final List<Customer> customers = applicationDetails.customers ?? [];
          if (customers.isNotEmpty && customers.first.groupOwner != null) {
            applicationDetails.groupOwner = customers.first.groupOwner;
          }
        }

        if (request.requestSubType?.reference1 ==
            ServerConstants.ccsysAppReference1) {
          final bool canEdit = computeCanEdit(
            applicationStatus:
                int.tryParse(applicationDetails.status.toString()), // int?
            enabledForView:
                applicationDetails.enabledForView, // can be bool? or 0/1
            lifeCycles: applicationDetails
                .ccsysLifeCycleStatus, // List<ApplicationLifeCycle>?
            validateUser: ValidateUser(
              bpmRole: Globals.user?.currentRole?.roleId
                  .toString(), // Globals.user?.currentRole?.bpmRole, //validateUser.bpmRole,
              userId: Globals.user?.id, //validateUser.userId,
            ),
          );

          applicationDetails.requestType?.reference1 =
              ServerConstants.ccsysAppReference2;
          applicationDetails.requestSubType?.reference1 =
              ServerConstants.ccsysAppReference1;

          // Then bind to your UI:
          applicationDetails.ccsysCanEditReadOnly =
              canEdit; // naming suggests "can edit"; true = can edit
        }

        Utils.request = applicationDetails;
      }
      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: request);

      if (isPipeline) {
        showAssignedUserWarning();
        await router.push(Routes.requestInformation);
      } else {
        //route
        if (request.requestSubType?.reference1 ==
            ServerConstants.ccsysAppReference1) {
          router.go(Routes.ccsysRequestInformation);
        } else {
          router.go(Routes.groupBorrowers);
        }

        showAssignedUserWarning();
      }
    } on Object {
      rethrow;
    }
  }

  void showAssignedUserWarning() {
    final ({String userId, String roleName})? assignedUser =
        getAssignedUserIfNotCurrentUser();

    if (assignedUser != null) {
      AlertManager().showWarningToast(
        "dashboard.home.assignedToAnotherUserWarning".tr(
          namedArgs: {
            "userId": assignedUser.userId,
            "roleName": assignedUser.roleName,
          },
        ),
      );
    }
  }

  /// Retrieves worklist requests for the dashboard based on the selected
  /// summary, ageing, and filtering criteria.
  ///
  /// Loads the required reference data, requests the corresponding
  /// worklist from the backend service, and maps the response into a
  /// collection of [Request] objects enriched with reference metadata.
  ///
  /// Supports both standard worklist and bar-graph data sources, as well
  /// as CCSYS-specific filtering and approval-stage filtering.
  ///
  /// Returns a list of matching [Request] records.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Request>?> getWorkList({
    required SummaryType summaryType,
    required DashboardAgeingType ageingType,
    required bool isBarGraph,
    bool isCCSYS = false,
    String? stage,
    String? crApprovalType,
    bool isInitialLoad = false,
    bool isAgeingSelected = false,
  }) async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
      ReferenceDataKeys.applicationTypeCustom,
      ReferenceDataKeys.roleType,
    ]);

    final List<Reference> applicationType =
        referenceData[ReferenceDataKeys.applicationType] ?? [];
    final List<Reference> customApplicationType =
        referenceData[ReferenceDataKeys.customApplicationType] ?? [];

    final List<Reference> transactionType =
        referenceData[ReferenceDataKeys.transactionType] ?? [];
    final List<Reference> requestType =
        referenceData[ReferenceDataKeys.requestType] ?? [];
    final List<Reference> requestStatus =
        referenceData[ReferenceDataKeys.requestStatus] ?? [];
    final List<Reference> roleType =
        referenceData[ReferenceDataKeys.roleType] ?? [];

    final Map<String, dynamic> requestData = {
      "workListKey": summaryTypeRequestMap[summaryType],
      "segment": Globals.user?.segments?.join(","),
      "region": Globals.user?.regions?.join(","),
      //"ageing": dashboardFilterMap[ageingType],

      "ageing": isInitialLoad || !isAgeingSelected
          ? null
          : dashboardFilterMap[ageingType],

      "subType": isCCSYS ? "CS" : "ALL",
    };

    if (stage != null) {
      requestData["stage"] = stage;
    }
    if (crApprovalType != null) {
      requestData["crApprovalType"] = crApprovalType;
    }

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      isBarGraph
          ? APIEndpoints.getWorklistForBarGraph
          : APIEndpoints.getRequestDetailsWorkList,
      data,
    );

    if (response.status == ResponseStatus.success) {
      final List<Request> getRequestWorkList = [];
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      for (final dynamic data in response.body["responseData"] ?? []) {
        final Request request = Request.fromWorkList(
          data,
          applicationTypes: applicationType,
          customApplicationType: customApplicationType,
          requestStatuses: requestStatus,
          requestTypes: requestType,
          transactionTypes: transactionType,
          roleTypes: roleType,
        );

        getRequestWorkList.add(request);
      }
      return getRequestWorkList;
    } else {
      throw ApiException(response.message);
    }
  }

  /// Converts the `enabledForView` value into a boolean.
  ///
  /// The backend may return this value in different formats, including
  /// `bool`, numeric values (`0` or `1`), or string values
  /// (`"true"`, `"false"`, `"1"`, `"0"`).
  ///
  /// Returns:
  /// - `true` when editing is enabled.
  /// - `false` when editing is disabled.
  /// - `null` when the value is missing or cannot be interpreted.
  bool? normalizeEnabledForView(Object? enabledForView) {
    if (enabledForView == null) {
      return null;
    }
    if (enabledForView is bool) {
      return enabledForView;
    }
    if (enabledForView is num) {
      return enabledForView != 0; // 0 -> false, 1 -> true
    }
    if (enabledForView is String) {
      final s = enabledForView.trim().toLowerCase();
      if (s == "0" || s == "false") {
        return false;
      }
      if (s == "1" || s == "true") {
        return true;
      }
    }
    return null; // unknown → treat as null
  }

  /// Determines whether the current user can edit the application.
  ///
  /// Edit access is granted based on the application status, assignment
  /// information, and the current user's role.
  ///
  /// The application is editable when:
  /// - The application is not in a read-only lifecycle status.
  /// - `enabledForView` is explicitly disabled.
  /// - Or the application is assigned to the current user, the assigned
  ///   role matches the user's BPM role, and the lifecycle status is
  ///   `waiting`.
  ///
  /// Returns `true` when the user is allowed to modify the application;
  /// otherwise returns `false`, indicating the application should be
  /// displayed in read-only mode.

  bool computeCanEdit({
    required int? applicationStatus,
    required Object? enabledForView, // bool? or 0/1
    required List<ApplicationLifeCycle>? lifeCycles,
    required ValidateUser validateUser,
  }) {
    // 1) Force read-only for terminal statuses
    if (applicationStatus != null &&
        ServerConstants.lifeCycleReadOnlyStatuses.contains(applicationStatus)) {
      return false; // read-only
    }

    final bool? efv = normalizeEnabledForView(enabledForView);

    // 2) enabledForView === 0 -> allow edit
    // If efv is null, we don't decide here; we continue to next rule.
    if (efv == false) {
      return true; // allow edit
    }

    // 3) enabledForView === 1 and lifecycle[0] matches role/user/waiting -> allow edit
    if (efv ?? false) {
      final ApplicationLifeCycle? first =
          (lifeCycles != null && lifeCycles.isNotEmpty)
              ? lifeCycles.first
              : null;
      // String activityName = (first?.activityName ?? '').trim();
      final String assignedToRole =
          (first?.assignedToRole.toString() ?? "").trim();
      final String assignedTo = (first?.assignedTo ?? "").trim();
      final String lStatus = (first?.status ?? "").trim().toLowerCase();

      final String bpmRole = (validateUser.bpmRole ?? "").trim();
      final String userId = validateUser.userId ?? "0";

      final bool matches = assignedToRole == bpmRole &&
          assignedTo == userId &&
          lStatus == ServerConstants.lifeCycleStatusWaiting;

      if (matches) {
        return true; // allow edit
      }
    }

    // 4) default → read-only
    return false;
  }

  /// Returns details of the user currently assigned to the application
  /// when the assignment belongs to someone other than the logged-in user.
  ///
  /// This method is used to identify the current owner of the application
  /// task and determine whether the application is assigned to a different
  /// user. The returned record contains the assigned user's identifier and
  /// BPM role name.
  ///
  /// Returns `null` when:
  /// - Application details or assignment information are unavailable.
  /// - The application is not assigned to any user.
  /// - The application is already assigned to the currently logged-in user.
  ({String userId, String roleName})? getAssignedUserIfNotCurrentUser() {
    // Guard: details or lifecycle unavailable.
    final ApplicationDetails? appDetails = Globals.applicationDetails;
    if (appDetails == null) {
      return null;
    }

    final ApplicationLifeCycle? lifeCycle = appDetails.applicationLifeCycle;
    if (lifeCycle == null) {
      return null;
    }

    // Resolve identifiers.
    final String assignedToUserId = (lifeCycle.assignedTo ?? "").trim();
    final int assignedToRole = lifeCycle.assignedToRole ?? 0;

    final String currentUserBpmRole =
        (Globals.user?.currentRole?.bpmRole ?? "").trim();
    final String currentUserId = Globals.user?.id ?? "0";

    // Step a: Resolve the current user's roleId from the bpmRole string.
    int currentUserRoleId = 0;
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      if (roleMap.containsKey(currentUserBpmRole) &&
          roleMap[currentUserBpmRole] != 0) {
        currentUserRoleId = roleMap[currentUserBpmRole]!;
        break;
      }
    }

    // Step b: Check ownership — task assigned to current user?
    final bool isAssignedToCurrentUser =
        (assignedToRole == currentUserRoleId) &&
            (assignedToUserId == currentUserId);

    if (isAssignedToCurrentUser || assignedToUserId.isEmpty) {
      return null;
    }

    // Step c: Reverse-lookup the role name (bpmRole string) for assignedToRole.
    // Globals.superBpmRolesId is List<Map<String, int>>; key = bpmRole, value =
    // roleId.
    String assignedRoleName = "";
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      for (final MapEntry<String, int> entry in roleMap.entries) {
        if (entry.value == assignedToRole && entry.value != 0) {
          assignedRoleName = entry.key;
          break;
        }
      }
      if (assignedRoleName.isNotEmpty) {
        break;
      }
    }

    return (userId: assignedToUserId, roleName: assignedRoleName);
  }
}

/// Represents a user validation request.
///
/// Holds the BPM role and user identifier used during validation
/// operations.
class ValidateUser {
  /// Creates a [ValidateUser] instance.
  const ValidateUser({
    this.bpmRole,
    this.userId,
  });

  /// BPM role associated with the user.
  final String? bpmRole;

  /// Unique identifier of the user.
  final String? userId;
}
