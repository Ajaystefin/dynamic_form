import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/information/customer_request_info.dart';
import 'package:wcas_frontend/models/request/application_details.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/certification_data.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_other_banks.dart';
import 'package:wcas_frontend/models/request/group_information/risk_bureau.dart';
import 'package:wcas_frontend/models/request/remarks/fee_structure.dart';
import 'package:wcas_frontend/models/request/security_perfection.dart';
import 'package:wcas_frontend/models/request/sic_code.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class RequestRepository {
  static final _singleton = RequestRepository();
  static RequestRepository get instance => _singleton;

  final APIManager _apiManager;

  RequestRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<ApplicationDetails?> getApplicationDetails({String? appRefNo}) async {
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getApplicationDetails, data);
    if (response.status == ResponseStatus.success) {
      return ApplicationDetails.fromJson(
        response.body["responseData"],
      );
    } else {
      throw response.message;
    }
  }

  Future<ApplicationDetails?> getLastApprovedApplication() async {
    Map data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId
    });

    AppResponse response =
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
    Map data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId
    });

    AppResponse response = await _apiManager.post(
        APIEndpoints.getApplicableReconApplication, data);
    if (response.code == 200) {
      List<ApplicationDetails> reconsideration = [];
      if (response.body["responseData"] != null &&
          response.body["responseData"]['applicationInfoListResponse'] !=
              null) {
        for (dynamic data in response.body["responseData"]
            ['applicationInfoListResponse'] as List) {
          reconsideration.add(ApplicationDetails.fromJson(data));
        }
      }
      return reconsideration;
    } else {
      throw response.message;
    }
  }

  Future<List<Response>?> getCustomerRequestInfo() async {
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
      "requestData": {"rimNo": 50, "groupId": null}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getCustomerRequestInfo, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      List<Response> customerReqInfo = [];
      response.message = response.body["status"]["statusDescription"];
      for (dynamic data in response.body["responseData"] as List) {
        customerReqInfo.add(Response.fromJson(data));
      }
      return customerReqInfo;
    } else {
      throw response.message;
    }
  }

  Future<List<Response>?> getPipelineRequestDetails() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo
    });
    AppResponse response =
        await _apiManager.post(APIEndpoints.getPipelineRequestDetails, data);

    if (response.code == 200) {
      List<Response> pipelineRequestDetails = [];
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (dynamic data in response.body["responseData"] as List) {
        pipelineRequestDetails.add(Response.fromJson(data));
      }
      return pipelineRequestDetails;
    } else {
      throw response.message;
    }
  }

  Future<SecurityPerfection> getSecurityDeferralDetails() async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": Globals.request?.customerRimNo,
        "groupId": Globals.request?.groupId,
        "appRefNo": Globals.request?.applicationRefNo
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getSecurityDeferral, data);

    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      SecurityPerfection comments =
          SecurityPerfection.fromJson(response.body["responseData"]);
      return comments;
    } else {
      throw response.message;
    }
  }

  Future<Comment?> getReviewCommentsResponse() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request!.applicationRefNo,
      "commentCategoryId": ServerConstants.terminateCategoryID,
      "entityIdentifier": ServerConstants.terminateCategoryID
    });

    try {
      AppResponse response =
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
              DateTime.tryParse(a["createdDate"] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b["createdDate"] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        final latestCommentJson = commentList.first;
        debugPrint("Latest comment JSON: $latestCommentJson");

        final latestComment = Comment.fromJson(latestCommentJson);

        // ✅ Manually map 'comment' to 'strategyComment' for UI use
        latestComment.strategyComment = latestCommentJson['comment'];

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
      String? reasonId, String? commentList) async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "reason": int.parse(reasonId ?? "0"),
      "remarks": commentList
    });

    AppResponse response =
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
      String? appRefNo) async {
    Map data = {
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
      "requestData": {"appRefNo": appRefNo, "role": "RM"}
    };

    AppResponse response =
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
    List<Map<String, dynamic>> certificationDataListJson =
        (certificationDataList ?? []).map((e) => e.toJson()).toList();

    Map data = {
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
            "certificationDataList": certificationDataListJson
          }
        ]
      }
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.saveApplicationStrategyDetails, data);

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
    Map data = BaseRequest.baseRequest({
      "conditionList": [condition?.toSaveJson()],
      "appRefNo": Globals.request?.applicationRefNo,
      "isCovenant": (condition?.isCovenant ?? false) ? 1 : 0
    });

    AppResponse response =
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
  Future<List<SicCodeReview>> getSICcodeReviewData() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": Globals.request?.customerRimNo

      // "appRefNo": "202504APNIS027301",
      // "rimNo": 114166, //-- -- use this for testing
    });

    AppResponse response = await _apiManager.post(
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
        'appRefNo': Globals.request?.applicationRefNo,
        'rimNo': review.rimNo,
        'proposedSicCode': review.proposedSicCode,
      };
    }

    Map<String, dynamic> data = BaseRequest.baseRequest(
      sicCodeReview.map((e) => minimalJson(e!)).toList(),
    );

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveSICcodeReview, data);

    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<Security>> getSecuritySummaryList() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getSecuritySummaryList, data);
    if (response.status == ResponseStatus.success) {
      List<Security> securitySummaryList = [];
      for (dynamic data in response.body["responseData"] as List) {
        securitySummaryList.add(Security.fromJson(data));
      }
      return securitySummaryList;
    } else {
      throw response.message;
    }
  }

  Future<Security?> getSecurityDetails({Security? security}) async {
    Map data = BaseRequest.baseRequest({
      "securityId": security?.securityId,
      "appRefNo": ServerConstants.appRefNo,
      "securityType": security?.securityType?.id,
      "securityNo": security?.securityNumber,
      "securityMasterId": security?.securityMasterId,
      "rimNo": security?.rim,
      "facilitySecurityMasterId": security?.facilitySecurityMasterLinkId
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getSecurityDetails, data);
    if (response.code == 200 && response.body["status"]["statusCode"] == 0) {
      response.message = response.body["status"]["statusDescription"];
      Security? security = Security.fromJson(response.body["responseData"]);
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
    Map data = {
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
            "strategyComment": comments
          }
        ]
      }
    };
    AppResponse response = await _apiManager.post(
        APIEndpoints.saveApplicationStrategyDetails, data);
    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<FacilitiesOtherBanks> getFacilitiesOtherBanks() async {
    Map data = {
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
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      return FacilitiesOtherBanks.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
    Map data = {
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
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
    if (response.status == ResponseStatus.success) {
      return RiskBureau.fromJson(response.body['responseData']);
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFacilitiesWithOtherBank(
      List<Map<String, dynamic>> facilitiesListJson) async {
    Map data = {
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
        "appRefNo": ServerConstants.appRefNo
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilityWithOtherBank, data);
    if (response.status == ResponseStatus.success) {
      response.message = response.body["responseData"]["message"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveSecurityDetails(Security? security) async {
    Map<String, dynamic> data = BaseRequest.baseRequest(
      security?.toJson(),
    );

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveSecurityDetails, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

//Application Borrowers
  Future<List<Customer>> getApplicationBorrowers() async {
    Map<String, dynamic> data = {
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
      "requestData": {"groupId": ServerConstants.appRefNo}
    };
    AppResponse response = await _apiManager
        .get(APIEndpoints.getApplicationBorrowers, queryParams: data);
    if (response.status == ResponseStatus.success) {
      List<dynamic> data = response.body['responseData'];
      return data.map((value) => Customer.fromJson(value)).toList();
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getCurrencyCodes() async {
    Map<String, dynamic> data = {
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
        "RatesInqRq": {
          "RqUID": "41cc4be8-d848-4f58-8d42-6ff482009113",
          "MsgRqHdr": {
            "SvcIdent": {
              "SvcProviderName": "WCAS",
              "SvcProviderId": "71",
              "SvcName": "RatesInq"
            }
          },
          "RatesSel": {"RateSel": "ExchangeRates"}
        }
      }
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.getRatesInq, data);
    if (response.status == ResponseStatus.success) {
      final forex = response.body["RatesInqRs"]?["ForExQuoteRec"];
      if (forex is List) {
        return forex
            .map((element) => element["BaseCurCode"]?["CurCodeValue"])
            .whereType<String>()
            .toSet()
            .map((code) => Reference(name: code))
            .toList();
      }
    }
    return [];
  }

  Future<String> saveApplicationInformation(
      ApplicationDetails? applicationDetails) async {
    Map data =
        BaseRequest.baseRequest(applicationDetails?.toSaveApplicationJson());
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveApplicationInformation, data);
    if (response.status == ResponseStatus.success) {
      return response.body["responseData"]['applicationRefNo'];
    } else {
      throw response.message;
    }
  }

  Future<String> saveRemarkStrategyData(
    Customer? selectedCustomer,
    Comment comment,
  ) async {
    Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": comment.strategyCommentTypeId,
      "relationshipStrategyDataForRims": [
        {
          "rimNo": selectedCustomer?.customerRimNo,
          "customerName": selectedCustomer?.customerName,
          "commentList": [comment.toStrategyJson()]
        }
      ]
    });
    AppResponse response = await _apiManager.post(
        APIEndpoints.saveRelationshipStrategyDetailsByRim, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      throw response.message;
    }
  }

  Future<Comment?> getRemarkStrategyData(
      Customer? selectedCustomer, int? remarksTabId,
      [int? categoryId]) async {
    Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": remarksTabId,
      "rimNo": selectedCustomer?.customerRimNo
    });
    Comment? comment = Comment();
    AppResponse response = await _apiManager.post(
        APIEndpoints.getRelationshipStrategyDetailsByRim, data);
    if (response.status == ResponseStatus.success) {
      var customerCommentList = (response.body['responseData']
              ['relationshipStrategyDataForRims'] as List)
          .where(
        (element) {
          return element["rimNo"] == selectedCustomer?.customerRimNo;
        },
      );

      // first["commentList"];
      if (customerCommentList.isNotEmpty) {
        var categoryCommentList =
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
    Map data = BaseRequest.baseRequest({
      "appRefNo": "201902APNAR000056", //Globals.request?.applicationRefNo,
      "rimNo": 9992 //customerRimNo
    });
    AppResponse response =
        await _apiManager.post(APIEndpoints.getFeeStructureData, data);
    List<FeeStructure> feeData = [];
    if (response.status == ResponseStatus.success) {
      for (var element in (response.body["responseData"] as List)) {
        feeData.add(FeeStructure.fromJson(element));
      }
    }
    return feeData;
  }

  Future<String> saveFeeStructure(List<FeeStructure> feeRows) async {
    List<Map<String, dynamic>> feeData =
        feeRows.map((element) => element.toJson()).toList();

    Map<String, dynamic> data = BaseRequest.baseRequest(feeData);

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]['status']['statusDescription'];
    }
    throw response.message;
  }

  Future<String> deleteFeeStructureData(FeeStructure feeData) async {
    Map<String, dynamic> data = BaseRequest.baseRequest(feeData.toJson());

    AppResponse response =
        await _apiManager.delete(APIEndpoints.deleteFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]['status']['statusDescription'];
    }
    throw response.message;
  }
}
