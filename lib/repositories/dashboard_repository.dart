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
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";
import "package:wcas_frontend/models/home/home.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class DashboardRepository {
  DashboardRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();
  static final _singleton = DashboardRepository();
  static DashboardRepository get instance => _singleton;

  final APIManager _apiManager;
  final ReferenceDataService _referenceDataService;

  Future<List<Role>> getUserList(List<String> roleCodes) async {
    try {
      final Map data = {
        "roleID": Globals.user?.currentRole?.id,
        "role": Globals.user?.currentRole?.code,
        "channelID": EnvConfig.channelID,
        "sessionID": const Uuid().v4(),
        "userID": Globals.user?.id ?? "WCASTSP01",
        "userName": Globals.user?.name ?? "wcastsp01",
        "pageId": 3,
        "rqUID": const Uuid().v4(),
        "mode": null,
        "requestData": {"roles": roleCodes},
      };
      final List<Role> users = [];
      final AppResponse response = await _apiManager.post(
        EnvConfig.baseUrl + APIEndpoints.getUserByRole,
        data,
      );
      if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
        for (final data
            in response.body["responseData"]["roleDetailsList"] as List) {
          users.add(Role.fromJson(data));
        }
      }

      return users;
    } catch (e) {
      rethrow;
    }
  }

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
        throw response.message;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

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
        throw response.message;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentationSummary?> getDocumentationSummary({
    required SummaryType? type,
    required DashboardAgeingType ageing,
  }) async {
    try {
      DocumentationSummary? documentationSummary;
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "type": summaryTypeRequestMap[type],
        "ageing": dashboardFilterMap[ageing],
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
        throw response.message;
      }
      return documentationSummary;
    } catch (e) {
      rethrow;
    }
  }

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
      throw response.message;
    }
  }

  Future<List<Request>?> getClosedRequestDetailsWorkList(String key) async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
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
      final List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];
      final List<Reference> transactionType =
          referenceData[ReferenceDataKeys.transactionType] ?? [];
      final List<Reference> requestType =
          referenceData[ReferenceDataKeys.requestType] ?? [];
      final List<Reference> requestStatus =
          referenceData[ReferenceDataKeys.requestStatus] ?? [];

      // ✅ Safely cast responseData to List
      final summaryList = response.body["responseData"] as List? ?? [];

      for (final dynamic item in summaryList) {
        if (item is! Map) continue; // - Skip invalid items

        final String? rawStatus = item["requestStatus"];
        final String? rawType = item["requestType"];
        final String? rawSubType = item["requestSubType"];
        final String? rawBusinessSegment = item["businessSegment"];

        // Map to Reference objects
        final Reference matchedStatus = requestStatus.firstWhere(
          (value) =>
              value.name?.toLowerCase().trim() ==
              rawStatus?.toLowerCase().trim(),
          orElse: () => Reference(name: rawStatus),
        );

        final Reference matchedType = requestType.firstWhere(
          (value) => value.name == rawType,
          orElse: () => Reference(name: rawType),
        );

        final Reference matchedSubType = applicationType.firstWhere(
          (value) => value.reference1 == rawSubType,
          orElse: () => transactionType.firstWhere(
            (value) => value.reference1 == rawSubType,
            orElse: () => Reference(name: rawSubType),
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
      throw response.message;
    }
  }

  Future downloadFile(String filePath) async {
    try {
      final AppResponse response = await FileDownloadService.instance
          .downloadFile("/$filePath", filePath);
      if (response.status != ResponseStatus.success) {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }
  }

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
        throw response.message;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>?> getUsersByRoles(List<String>? roleCodes) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes?.join(","),
        "segment": Globals.user?.segments?.join(","),
        "region": Globals.user?.regions?.join(","),
      });
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getUsersByRoles,
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
                User.fromJson(
                  user,
                  selectedRole: selectedRole,
                  selectedRoleId: selectedRoleId,
                  selectedRoleName: selectedRoleName,
                )
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
        throw response.message;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

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
            (assignToDetail?.userAction == ServerConstants.assignToMeAction)
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
          "assignedRole":
              (assignToDetail?.userAction == ServerConstants.assignToMeAction)
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
        debugPrint("User assigned successfully.");
      } else {
        throw response.message;
      }
    } catch (e) {
      debugPrint("Error assigning user: $e");
      rethrow;
    }
  }

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
              (e) => e.reference1 == json["requestSubType"],
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
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return worklistResponse;
  }

  Future<List<User>> getUserByRole(List<String> roleCodes) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles":
            (roleCodes.isNotEmpty) ? [roleCodes.map((e) => e).join(",")] : null,
        "region": Globals.user?.regions?.join(","),
        "segment": Globals.user?.segments?.join(","),
      });
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getUserByRole, json.encode(data));

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          final List<User> users = [];

          for (final role in responseData) {
            final userDetails = role["userDetails"] as List<dynamic>;
            users.addAll(userDetails.map((e) => User.fromJson(e)).toList());
          }
          debugPrint(users.first.id);

          debugPrint(users.first.name);
          return users;
        }
        return [];
      }

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

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
          requestStatuses: requestStatuses,
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
          requestStatuses: requestStatuses,
          bussinessSegments: bussinessSegments,
        );
      }
    } else {
      throw response.message;
    }
  }

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

  Future<void> openApplication(Request request) async {
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
          final customers = applicationDetails.customers;
          if (customers != null &&
              customers.isNotEmpty &&
              customers.first.groupOwner != null &&
              customers.first.groupOwner != 0) {
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

        Utils.setRequest(applicationDetails);
      }
      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: request);

      //route
      if (request.requestSubType?.reference1 ==
          ServerConstants.ccsysAppReference1) {
        router.go(Routes.ccsysRequestInformation);
      } else {
        router.go(Routes.groupBorrowers);
      }

      // Warning: alert when the application is assigned to another user.
      // Only applies to the non-CCSYS path (Globals.applicationDetails is
      // only populated there). CCSYS editability is handled via computeCanEdit.
      final ({String userId, String roleName})? assignedUser =
          _getAssignedUserIfNotCurrentUser();
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
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Request>?> getWorkList({
    required SummaryType summaryType,
    required DashboardAgeingType ageingType,
    required bool isBarGraph,
    bool isCCSYS = false,
    String? stage,
    String? crApprovalType,
  }) async {
    final Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
      ReferenceDataKeys.applicationTypeCustom,
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

    final Map<String, dynamic> requestData = {
      "workListKey": summaryTypeRequestMap[summaryType],
      "segment": Globals.user?.segments?.join(","),
      "region": Globals.user?.regions?.join(","),
      "ageing": dashboardFilterMap[ageingType],
      "subType": isCCSYS ? "CS" : "ALL",
    };

    if (stage != null) requestData["stage"] = stage;
    if (crApprovalType != null) requestData["crApprovalType"] = crApprovalType;

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
        );

        getRequestWorkList.add(request);
      }
      return getRequestWorkList;
    } else {
      throw response.message;
    }
  }

  ///###### for CCSYS ###############
  /// Normalize enabledForView which may arrive as bool? or int? (0/1).
  bool? normalizeEnabledForView(dynamic enabledForView) {
    if (enabledForView == null) return null;
    if (enabledForView is bool) return enabledForView;
    if (enabledForView is num) {
      return enabledForView != 0; // 0 -> false, 1 -> true
    }
    if (enabledForView is String) {
      final s = enabledForView.trim().toLowerCase();
      if (s == "0" || s == "false") return false;
      if (s == "1" || s == "true") return true;
    }
    return null; // unknown → treat as null
  }

  /// Returns true -> can edit; false -> read-only.
  bool computeCanEdit({
    required int? applicationStatus,
    required dynamic enabledForView, // bool? or 0/1
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
    if (efv == true) {
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
          assignedTo == userId.toString() &&
          lStatus == ServerConstants.lifeCycleStatusWaiting;

      if (matches) return true; // allow edit
    }

    // 4) default → read-only
    return false;
  }

  /// Returns a record of (userId, roleName) for the person the current
  /// application is assigned to, only when that person is NOT the currently
  /// logged-in user.
  ///
  /// Returns `null` if:
  ///   - Application details or lifecycle are unavailable.
  ///   - `enabledForView` is not explicitly `true`.
  ///   - The task IS assigned to the current user.
  ///   - The `assignedTo` user ID is empty.
  ({String userId, String roleName})? _getAssignedUserIfNotCurrentUser() {
    // Guard: details or lifecycle unavailable.
    final ApplicationDetails? appDetails = Globals.applicationDetails;
    if (appDetails == null) return null;

    final ApplicationLifeCycle? lifeCycle = appDetails.applicationLifeCycle;
    if (lifeCycle == null) return null;

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

    if (isAssignedToCurrentUser || assignedToUserId.isEmpty) return null;

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
      if (assignedRoleName.isNotEmpty) break;
    }

    return (userId: assignedToUserId, roleName: assignedRoleName);
  }
}

class ValidateUser {
  const ValidateUser({this.bpmRole, this.userId});
  final String? bpmRole;
  final String? userId;
}
