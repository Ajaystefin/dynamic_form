import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:uuid/uuid.dart";

import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/models/request/group_information/facilities_other_banks.dart";
import "package:wcas_frontend/models/request/group_information/risk_bureau.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

class RequestRepository {
  RequestRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static RequestRepository _singleton = RequestRepository();
  static RequestRepository get instance => _singleton;

  static void overrideInstance(RequestRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  Future<ApplicationDetails?> getApplicationDetails({String? appRefNo}) async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getApplicationDetails, data);
    if (response.status == ResponseStatus.success) {
      Utils.setApplicationDetails(
        ApplicationDetails.fromJson(
          response.body["responseData"],
        ),
      );
      return Globals.applicationDetails;
    } else {
      throw response.message;
    }
  }

  Future<ApplicationDetails?> getLastApprovedApplication() async {
    final Map data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getLastApprovedApplications, data);
    if (response.status == ResponseStatus.success) {
      if (response.body["responseData"]["applicationInfoResponse"] != null) {
        return ApplicationDetails.fromJson(
          response.body["responseData"]["applicationInfoResponse"],
        );
      } else {
        // throw response.message;
        return ApplicationDetails();
      }
    } else {
      throw response.message;
    }
  }

  Future<List<ApplicationDetails>> applicationTypeReconsiderationData() async {
    final Map data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getApplicableReconApplication,
      data,
    );
    if (response.code == 200) {
      final List<ApplicationDetails> reconsideration = [];
      if (response.body["responseData"] != null &&
          response.body["responseData"]["applicationInfoListResponse"] !=
              null) {
        for (final dynamic data in response.body["responseData"]
            ["applicationInfoListResponse"] as List) {
          reconsideration.add(ApplicationDetails.fromJson(data));
        }
      }
      return reconsideration;
    } else {
      throw response.message;
    }
  }

  Future<List<Response>?> getCustomerRequestInfo() async {
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
      "requestData": {"rimNo": 50, "groupId": null},
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCustomerRequestInfo, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      final List<Response> customerReqInfo = [];
      response.message = response.body["status"]["statusDescription"];
      for (final dynamic data in response.body["responseData"] as List) {
        customerReqInfo.add(Response.fromJson(data));
      }
      return customerReqInfo;
    } else {
      throw response.message;
    }
  }

  Future<List<Response>?> getPipelineRequestDetails() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId ?? 0,
      "rimNo": Globals.request?.customerRimNo ?? "",
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getPipelineRequestDetails, data);

    if (response.code == 200) {
      final List<Response> pipelineRequestDetails = [];
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (final dynamic data in response.body["responseData"] as List) {
        pipelineRequestDetails.add(Response.fromJson(data));
      }
      return pipelineRequestDetails;
    } else {
      throw response.message;
    }
  }

  Future<SecurityPerfection> getSecurityDeferralDetails() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
      "appRefNo": Globals.request?.applicationRefNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getSecurityDeferral, data);

    if (response.code == 200) {
      final SecurityPerfection comments =
          SecurityPerfection.fromJson(response.body["responseData"]);
      return comments;
    } else {
      throw response.message;
    }
  }

  Future<String> saveSecurityDeferralDetails({
    required List<Map<String, dynamic>> securityDeferralList,
    required List<Map<String, dynamic>> covenantDeferralList,
    required List<Map<String, dynamic>> conditionDeferralList,
  }) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "securityDeferralList": securityDeferralList,
      "covenantDeferralList": covenantDeferralList,
      "conditionDeferralList": conditionDeferralList,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveSecurityDeferralDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      return response.message; //"Saved Successfully";
    } else {
      throw response.message;
    }
  }

  Future<Comment?> getReviewCommentsResponse() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request!.applicationRefNo,
      "commentCategoryId": ServerConstants.terminateCategoryID,
      "entityIdentifier": ServerConstants.terminateCategoryID,
    });

    try {
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getComments, data);

      final statusCode =
          response.body["baseResponse"]?["status"]?["statusCode"];
      if (response.code == 200 && statusCode == "0") {
        response.message =
            response.body["baseResponse"]?["status"]?["statusDescription"];

        final List<dynamic>? commentList =
            response.body["responseData"]?["commentList"];
        debugPrint("Raw commentList: $commentList");

        if (commentList == null || commentList.isEmpty) return null;

        // Sort by createdDate descending
        commentList.sort((a, b) {
          final dateA =
              DateTime.tryParse(a["createdDate"] ?? "") ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b["createdDate"] ?? "") ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        final latestCommentJson = commentList.first;
        debugPrint("Latest comment JSON: $latestCommentJson");

        final latestComment = Comment.fromJson(latestCommentJson);

        // - Manually map 'comment' to 'strategyComment' for UI use
        latestComment.strategyComment = latestCommentJson["comment"];

        debugPrint("Parsed Comment: ${latestComment.strategyComment}");
        return latestComment;
      } else {
        throw response.message;
      }
    } catch (e, stackTrace) {
      debugPrint("Exception in getReviewCommentsResponse: $e");
      debugPrint("StackTrace: $stackTrace");
      return null;
    }
  }

  Future<String?> updateTerminateStatus(
    String? reasonId,
    String? commentList,
  ) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "reason": int.parse(reasonId ?? "0"),
      "remarks": commentList,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.updateTerminatedStatus, data);

    if (response.status == ResponseStatus.success) {
      final statusDescription =
          response.body?["baseResponse"]?["status"]?["statusDescription"];
      response.message = statusDescription ?? "No status description found";
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<CertificationData>> getCertificateDetails(
    String? appRefNo,
  ) async {
    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 29,
      "appRefNo": appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": appRefNo, "role": "RM"},
    };

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCertificateDetails, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      List<CertificationData> certificateDetails = [];
      response.message = response.body["status"]["statusDescription"];
      final list = response.body["responseData"]["certificationsList"];

      if (list is List && list.isNotEmpty) {
        final certDataList = list[0]["certificationDataList"];
        certificateDetails = (certDataList as List)
            .map((e) => CertificationData.fromJson(e))
            .toList();
      }

      return certificateDetails;
    } else {
      throw response.message;
    }
  }

  // Method from HEAD: saveCertificateDetails
  Future<String?> saveCertificateDetails(
    String? appRefNo,
    List<CertificationData>? certificationDataList,
  ) async {
    final List<Map<String, dynamic>> certificationDataListJson =
        (certificationDataList ?? []).map((e) => e.toJson()).toList();

    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 29,
      "appRefNo": appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "certificationsList": [
          {
            "appRefNo": appRefNo,
            "role": Globals.user?.currentRole?.name,
            "certificationDataList": certificationDataListJson,
          }
        ],
      },
    };

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveApplicationStrategyDetails,
      data,
    );

    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String> saveConditionDetails(
    CovenantCondition? condition,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "conditionList": [condition?.toSaveJson()],
      "appRefNo": Globals.request?.applicationRefNo,
      "isCovenant": (condition?.isCovenant ?? false) ? 1 : 0,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveConditions, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

// Get SIC Code Review Data
  Future<List<SicCodeReview>> getSICcodeReviewData({
    String? customerRimNo,
  }) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": customerRimNo,

      // "appRefNo": "202504APNIS027301",
      // "rimNo": 114166, //-- -- use this for testing
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getSICCodeReview,
      data,
    );

    if (response.status == ResponseStatus.success) {
      final List<dynamic>? responseData = response.body["responseData"];

      if (responseData == null) {
        return [];
      }

      return responseData.map((json) => SicCodeReview.fromJson(json)).toList();
    } else {
      throw Exception(response.message);
    }
  }

// SAVE SICcode
  Future<String?> saveSICcodeReview(List<SicCodeReview?>? sicCodeReview) async {
    if (sicCodeReview == null || sicCodeReview.isEmpty) return null;

    Map<String, dynamic> minimalJson(SicCodeReview review) {
      return {
        "appRefNo": Globals.request?.applicationRefNo,
        "rimNo": review.rimNo,
        "proposedSicCode": review.proposedSicCode,
      };
    }

    final Map<String, dynamic> data = BaseRequest.baseRequest(
      sicCodeReview.map((e) => minimalJson(e!)).toList(),
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveSICcodeReview, data);

    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<Security?> getSecurityDetails({
    required List<Country> countries,
    Security? selectedSecurity,
  }) async {
    Security? security;

    final String? rimStr = selectedSecurity?.securityProvidedRim;

    final String rimStringSource = (rimStr != null && rimStr.trim().isNotEmpty)
        ? rimStr
        : (Globals.request?.customerRimNo?.toString() ?? "");

    //  send groupId only for "create" flow (no securityId yet)
    final bool isCreate =
        (selectedSecurity == null || selectedSecurity.securityId == null);
    final int? groupIdToSend = isCreate ? Globals.request?.groupId : null;

    final Map data = BaseRequest.baseRequest({
      "securityId": selectedSecurity?.securityId,
      "appRefNo": isCreate ? null : Globals.request?.applicationRefNo,
      "securityType": selectedSecurity?.securityType?.id,
      "securityNo": selectedSecurity?.securityNumber,
      "securityMasterId": selectedSecurity?.securityMasterId,
      "rimNo": int.tryParse(
        rimStringSource,
      ),
      "facilitySecurityMasterId":
          selectedSecurity?.facilitySecurityMasterLinkId,
      "groupId": groupIdToSend, // <- exactly as per API contract
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getSecurityDetails, data);
    // response.message = response.body["status"]["statusDescription"];
    if (response.status == ResponseStatus.success) {
      List<Reference> emirates = [];
      List<Reference> statuses = [];

      try {
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService().getReferenceData([
          ReferenceDataKeys.emiratesItems,
          ReferenceDataKeys.securityStatus,
        ]);
        emirates = referenceData[ReferenceDataKeys.emiratesItems] ?? [];
        statuses = referenceData[ReferenceDataKeys.securityStatus] ?? [];
      } catch (e) {
        throw "Error fetching reference data: $e";
      }
      security = Security.fromJson(
        response.body["responseData"],
        emirates: emirates,
        statuses: statuses,
        countries: countries,
      );

      // Parse and flatten additionalDetails for dynamic form prefill
      security.dynamicFormDocument =
          FacilitySecurityRepository.parseAndFlattenAdditionalDetails(
        response.body["responseData"]["additionalDetails"],
      );

      return security;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveGroupFacilitiesWithCbd(
    String? appRefNo,
    int? strategyCommentsType,
    String? comments,
  ) async {
    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "appRefNo": appRefNo,
        "strategyCommentsType": strategyCommentsType,
        "commentList": [
          {
            "appStrategyCommentsId": 0,
            "categoryId": ServerConstants.groupCategoryID,
            "categoryType": "Group Information",
            "strategyComment": comments,
          }
        ],
      },
    };
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveApplicationStrategyDetails,
      data,
    );
    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<FacilitiesOtherBanks> getFacilitiesOtherBanks() async {
    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo},
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      return FacilitiesOtherBanks.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo},
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
    if (response.status == ResponseStatus.success) {
      return RiskBureau.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFacilitiesWithOtherBank(
    List<Map<String, dynamic>> facilitiesListJson,
  ) async {
    final Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 21,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "facilitiesList": facilitiesListJson,
        "appRefNo": ServerConstants.appRefNo,
      },
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }

//Application Borrowers
  Future<List<Customer>> getApplicationBorrowers() async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"groupId": ServerConstants.appRefNo},
    };
    final AppResponse response = await _apiManager
        .get(APIEndpoints.getApplicationBorrowers, queryParams: data);
    if (response.status == ResponseStatus.success) {
      final List<dynamic> data = response.body["responseData"];
      return data.map((value) => Customer.fromJson(value)).toList();
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getCurrencyCodes() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyCode, data);

    if (response.status != ResponseStatus.success) {
      throw response.message;
    }

    final dynamic currencyList = response.body["responseData"];

    // Ensure it's a list
    if (currencyList is! List) {
      return <Reference>[];
    }

    // Map isoCode -> name, description -> reference4
    return currencyList
        .whereType<Map<String, dynamic>>() // keep only proper map entries
        .map((e) {
          final String iso = e["isoCode"];
          final String desc = e["description"];

          if (iso.trim().isNotEmpty) {
            return Reference(
              name: iso.trim(),
              reference4: desc.trim(),
            );
          }
          return null; // skip invalid rows
        })
        .whereType<Reference>()
        .toList();
  }

  Future<String> saveApplicationInformation(
    ApplicationDetails? applicationDetails,
  ) async {
    final Map data =
        BaseRequest.baseRequest(applicationDetails?.toSaveApplicationJson());
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveApplicationInformation, data);
    if (response.status == ResponseStatus.success) {
      return response.body["responseData"]["applicationRefNo"];
    } else {
      throw response.message;
    }
  }

  Future<String> saveRemarkStrategyData(
    Customer? selectedCustomer,
    Comment comment,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": comment.strategyCommentTypeId,
      "relationshipStrategyDataForRims": [
        {
          "rimNo": selectedCustomer?.customerRimNo,
          "customerName": selectedCustomer?.customerName,
          "commentList": [comment.toStrategyJson()],
        }
      ],
    });
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveRelationshipStrategyDetailsByRim,
      data,
    );
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      throw response.message;
    }
  }

  Future<Comment?> getRemarkStrategyData(
    Customer? selectedCustomer,
    int? remarksTabId, [
    int? categoryId,
  ]) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": remarksTabId,
      "rimNo": selectedCustomer?.customerRimNo,
    });
    Comment? comment = Comment();
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getRelationshipStrategyDetailsByRim,
      data,
    );
    if (response.status == ResponseStatus.success) {
      final customerCommentList = (response.body["responseData"]
              ["relationshipStrategyDataForRims"] as List)
          .where(
        (element) {
          return element["rimNo"] == selectedCustomer?.customerRimNo;
        },
      );

      // first["commentList"];
      if (customerCommentList.isNotEmpty) {
        final categoryCommentList =
            customerCommentList.first["commentList"].where(
          (element) => element["categoryId"] == categoryId,
        );

        if (categoryCommentList.isNotEmpty) {
          comment = Comment.fromJson(categoryCommentList.first);
        }
      }

      logger.d(response);
    }
    return comment;
  }

  Future<List<FeeStructure>> getFeeStructureData(int? customerRimNo) async {
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": customerRimNo,
    });
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFeeStructureData, data);
    final List<FeeStructure> feeData = [];
    if (response.status == ResponseStatus.success) {
      for (final dynamic element in (response.body["responseData"] as List)) {
        feeData.add(FeeStructure.fromJson(element));
      }
    }
    return feeData;
  }

  Future<String> saveFeeStructure(List<FeeStructure> feeRows) async {
    final List<Map<String, dynamic>> feeData =
        feeRows.map((element) => element.toJson()).toList();

    final Map<String, dynamic> data = BaseRequest.baseRequest(feeData);

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    }
    throw response.message;
  }

  Future<String> deleteFeeStructureData(FeeStructure feeData) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest(feeData.toJson());

    final AppResponse response =
        await _apiManager.delete(APIEndpoints.deleteFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    }
    throw response.message;
  }

  Future<List<User>> getUsersByRoles(List<String> roleCodes) async {
    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "roles": roleCodes.join(","),
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
}
