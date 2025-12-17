import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/services/file_download_service/service.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/home/aging_summary.dart';
import 'package:wcas_frontend/models/home/documentation_summary.dart';
import 'package:wcas_frontend/models/home/home.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

class DashboardRepository {
  static final _singleton = DashboardRepository();
  static DashboardRepository get instance => _singleton;

  final APIManager _apiManager;
  final ReferenceDataService _referenceDataService;

  DashboardRepository({
    APIManager? apiManager,
    ReferenceDataService? referenceDataService,
  })  : _apiManager = apiManager ?? APIManager(),
        _referenceDataService = referenceDataService ?? ReferenceDataService();

  Future<List<Role>> getUserList(List<String> roleCodes) async {
    try {
      Map data = {
        "roleID": Globals.user?.currentRole?.id,
        "role": Globals.user?.currentRole?.code,
        "channelID": EnvConfig.channelID,
        "sessionID": const Uuid().v4(),
        "userID": Globals.user?.id ?? "WCASTSP01",
        "userName": Globals.user?.name ?? "wcastsp01",
        "pageId": 3,
        "rqUID": const Uuid().v4(),
        "mode": null,
        "requestData": {"roles": roleCodes}
      };
      List<Role> users = [];
      AppResponse response = await _apiManager.post(
          EnvConfig.baseUrl + APIEndpoints.getUserByRole, data);
      if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
        for (var data
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
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "region": Globals.user?.regions?.join(','),
        "segment": Globals.user?.segments?.join(','),
      });

      AppResponse response =
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
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "type": summaryTypeRequestMap[summaryType],
        "region": Globals.user?.regions?.join(','),
        "segment": Globals.user?.segments?.join(','),
      });

      AppResponse response = await _apiManager.post(
          APIEndpoints.getDashboardAgeingCount, json.encode(data));
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

  Future<DocumentationSummary?> getDocumentationSummary(
      {required SummaryType? type, required DashboardAgeingType ageing}) async {
    try {
      DocumentationSummary? documentationSummary;
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "type": summaryTypeRequestMap[type],
        "ageing": dashboardFilterMap[ageing]
      });
      AppResponse response = await _apiManager.post(
          APIEndpoints.getDocumentationSummary, json.encode(data));
      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null) {
          documentationSummary = DocumentationSummary.fromJson(responseData);
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
    Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
    ]);

    Map data = {
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
          "customerName": null
        }
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getRequestDetailsWorkList, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      List<Request> getRequestWorkList = [];
      response.message = response.body["status"]["statusDescription"];

      List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];
      List<Reference> transactionType =
          referenceData[ReferenceDataKeys.transactionType] ?? [];
      List<Reference> requestType =
          referenceData[ReferenceDataKeys.requestType] ?? [];
      List<Reference> requestStatus =
          referenceData[ReferenceDataKeys.requestStatus] ?? [];
      for (dynamic data
          in response.body["responseData"]["requestSummary"] ?? []) {
        Request request = Request.fromCloseRequestJson(data);

        // Map request status
        Reference matchedStatus = requestStatus.firstWhere(
          (Reference value) =>
              value.name?.toLowerCase().trim() ==
              request.status?.toLowerCase().trim(),
          orElse: () => Reference(name: request.status),
        );
        request.requestStatus = matchedStatus;

        // Map request type
        Reference matchedType;
        bool isSubTypeEmpty =
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
            orElse: () => Reference(),
          );

          // If not found, try transactionType
          if (matchedType.reference1 == null) {
            matchedType = transactionType.firstWhere(
              (Reference value) =>
                  request.requestSubType?.reference1 == value.reference1,
              orElse: () => Reference(),
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
    Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
    ]);

    // Prepare request payload
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "workListKey": key,
      "region": Globals.user?.regions?.join(','),
      "segment": Globals.user?.segments?.join(','),
      "ageing": "0_7_days"
    });

    // API call
    AppResponse response = await _apiManager.post(
        APIEndpoints.getClosedRequestDetailsWorkList, data);

    // ✅ Validate response safely
    if (response.code == 200 &&
        response.body["baseResponse"]?["status"]?["statusCode"] == "0") {
      List<Request> getRequestWorkList = [];
      response.message =
          response.body["baseResponse"]?["status"]?["statusDescription"] ?? "";

      // Reference lists
      List<Reference> applicationType =
          referenceData[ReferenceDataKeys.applicationType] ?? [];
      List<Reference> transactionType =
          referenceData[ReferenceDataKeys.transactionType] ?? [];
      List<Reference> requestType =
          referenceData[ReferenceDataKeys.requestType] ?? [];
      List<Reference> requestStatus =
          referenceData[ReferenceDataKeys.requestStatus] ?? [];

      // ✅ Safely cast responseData to List
      final summaryList = response.body["responseData"] as List? ?? [];

      for (dynamic item in summaryList) {
        if (item is! Map) continue; // ✅ Skip invalid items

        String? rawStatus = item["requestStatus"];
        String? rawType = item["requestType"];
        String? rawSubType = item["requestSubType"];
        String? rawBusinessSegment = item["businessSegment"];

        // Map to Reference objects
        Reference matchedStatus = requestStatus.firstWhere(
          (value) =>
              value.name?.toLowerCase().trim() ==
              rawStatus?.toLowerCase().trim(),
          orElse: () => Reference(name: rawStatus),
        );

        Reference matchedType = requestType.firstWhere(
          (value) => value.name == rawType,
          orElse: () => Reference(name: rawType),
        );

        Reference matchedSubType = applicationType.firstWhere(
          (value) => value.reference1 == rawSubType,
          orElse: () => transactionType.firstWhere(
            (value) => value.reference1 == rawSubType,
            orElse: () => Reference(name: rawSubType),
          ),
        );

        Reference matchedBusinessSegment = Reference(name: rawBusinessSegment);

        // Build Request object
        Request request = Request()
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
      AppResponse response = await FileDownloadService.instance
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
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "userId": Globals.user?.id ?? "WCASTSP01",
        "userName": Globals.user?.name ?? "wcastsp01",
      });

      AppResponse response = await _apiManager.post(
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

  Future<List<User>> getUsersByRoles(List<String> roleCodes) async {
    try {
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": "RO-WCAS",
        "segment": Globals.user?.segments?.join(','),
        "region": Globals.user?.regions?.join(','),
      });
      AppResponse response = await _apiManager.post(
          APIEndpoints.getUsersByRoles, json.encode(data));

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          List<User> users = [];

          for (var role in responseData) {
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

  Future<void> assignUserToApplication({
    required String assignedTo,
  }) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "appRefNo": Globals.request!.applicationRefNo,
        "assignedTo": assignedTo,
        "assignedRole": Globals.user!.currentRole,
        "userAction": null
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.assignToUser,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        debugPrint("User assigned successfully.");
      } else if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      debugPrint("Error assigning user: $e");
      rethrow;
    }
  }

  Future<List<Request>> getWorklistSearchCriteria(
      {required String key,
      String? customerRim,
      String? applicationRefNo,
      String? segment,
      String? region,
      String? groupId,
      String? pendingWith,
      String? pendingUser,
      String? rmName}) async {
    List<Request> worklistResponse = [];

    try {
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "key": key.toLowerCase(),
        "filters": {
          "customerRim": customerRim,
          "applicationRefNo": applicationRefNo,
          "segment": segment,
          "region": region,
          "groupId": groupId,
          "pendingWith": pendingWith,
          "rmName": rmName,
          "filterPendingUser": pendingUser
        }
      });

      AppResponse response = await _apiManager.post(
        APIEndpoints.getWorklistForSearchCriteria,
        data,
      );

      if (response.status == ResponseStatus.success) {
        var list = response.body["responseData"]["requestSummary"] as List;
        worklistResponse = list.map((json) {
          return Request(
            customerRimNo:
                json['customerRim'] != null ? json['customerRim'] as int : null,
            applicationRefNo: json['applicationRefNo']?.toString(),
            customerName: json['customerName']?.toString(),
            groupId:
                json['groupId'] != null ? int.tryParse(json['groupId']) : null,
            groupName: json['groupName']?.toString(),
            requestedBy: json['requestedBy']?.toString(),
            purpose: json['purpose']?.toString(),
            terminatedReason: json['terminatedReason']?.toString() ?? "",
            createdDate: json['createdDate'] != null
                ? DateTime.tryParse(json['createdDate'].toString())
                : null,
            requestType: json['requestType'] != null
                ? Reference(name: json['requestType'].toString())
                : null,
            requestSubType: json['requestSubType'] != null
                ? Reference(name: json['requestSubType'].toString())
                : null,
            customerType: json['customerType'] != null
                ? Reference(name: json['customerType'].toString())
                : null,
            requestStatus: json['requestStatus'] != null
                ? Reference(name: json['requestStatus'].toString())
                : null,
            region: json['region']?.toString(),
            status: json['requestStatus']?.toString(),
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
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes,
        "region": Globals.user?.regions?.join(','),
        "segment": Globals.user?.segments?.join(','),
      });
      AppResponse response =
          await _apiManager.post(APIEndpoints.getUserByRole, json.encode(data));

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData is List) {
          List<User> users = [];

          for (var role in responseData) {
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

  Future<Request?> getApplicationDetails(
      {String? appRefNo,
      required List<Reference> requestStatuses,
      required List<Reference> bussinessSegments}) async {
    Map data = BaseRequest.baseRequest({"appRefNo": appRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getApplicationDetails, data);
    if (response.status == ResponseStatus.success) {
      return Request.fromJson(response.body["responseData"],
          requestStatuses: requestStatuses,
          bussinessSegments: bussinessSegments);
    } else {
      throw response.message;
    }
  }

  Future<void> openApplication(Request request) async {
    try {
      Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.requestStatus,
        ReferenceDataKeys.applicationSegment,
        ReferenceDataKeys.requestType,
        ReferenceDataKeys.applicationType,
      ]);
      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: request);
      Request? applicationDetails = await getApplicationDetails(
        appRefNo: request.applicationRefNo,
        requestStatuses: referenceData[ReferenceDataKeys.requestStatus] ?? [],
        bussinessSegments:
            referenceData[ReferenceDataKeys.applicationSegment] ?? [],
      );
      if (applicationDetails != null) {
        final applicationTypeList =
            referenceData[ReferenceDataKeys.applicationType] ?? [];
        final requestTypeList =
            referenceData[ReferenceDataKeys.requestType] ?? [];

        final selectedApplicationType = applicationTypeList.firstWhere(
          (element) =>
              element.reference1 ==
              applicationDetails.applicationType?.reference1,
          orElse: () => Reference(
              reference1: applicationDetails.applicationType?.reference1),
        );

        final selectedRequestType = requestTypeList.firstWhere(
          (element) =>
              element.reference1 == applicationDetails.requestType?.reference1,
          orElse: () =>
              Reference(reference1: applicationDetails.requestType?.reference1),
        );

        applicationDetails.applicationType = selectedApplicationType;
        applicationDetails.requestType = selectedRequestType;
        if (applicationDetails.groupOwner == null) {
          final customers = applicationDetails.customers;
          if (customers != null &&
              customers.isNotEmpty &&
              customers.first.groupOwner != null &&
              customers.first.groupOwner != 0) {
            applicationDetails.groupOwner = customers.first.groupOwner;
          }
        }
        Utils.setRequest(applicationDetails);
      }
      //route
      router.go(Routes.groupBorrowers);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Request>?> getWorkList(
      {required SummaryType summaryType,
      required DashboardAgeingType ageingType}) async {
    Map<String, List<Reference>> referenceData =
        await _referenceDataService.getReferenceData([
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.transactionType,
      ReferenceDataKeys.requestStatus,
    ]);
    List<Reference> applicationType =
        referenceData[ReferenceDataKeys.applicationType] ?? [];
    List<Reference> transactionType =
        referenceData[ReferenceDataKeys.transactionType] ?? [];
    List<Reference> requestType =
        referenceData[ReferenceDataKeys.requestType] ?? [];
    List<Reference> requestStatus =
        referenceData[ReferenceDataKeys.requestStatus] ?? [];

    Map<String, dynamic> data = BaseRequest.baseRequest({
      "workListKey": summaryTypeRequestMap[summaryType],
      "region": Globals.user?.regions?.join(','),
      "segment": Globals.user?.segments?.join(','),
      "ageing": dashboardFilterMap[ageingType]
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getRequestDetailsWorkList, data);

    if (response.status == ResponseStatus.success) {
      List<Request> getRequestWorkList = [];
      response.message =
          response.body['baseResponse']["status"]["statusDescription"];

      for (dynamic data in response.body["responseData"] ?? []) {
        Request request = Request.fromWorkList(data,
            applicationTypes: applicationType,
            requestStatuses: requestStatus,
            requestTypes: requestType,
            transactionTypes: transactionType);

        getRequestWorkList.add(request);
      }
      return getRequestWorkList;
    } else {
      throw response.message;
    }
  }
}
