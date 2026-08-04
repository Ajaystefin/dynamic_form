import "dart:async";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/models/request/group_information/facilities_other_banks.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/security_perfection.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// Repository responsible for handling request-related API operations.
///
/// Provides a singleton instance and allows override for testing.
class RequestRepository {
  /// Creates an instance of [RequestRepository].
  ///
  /// Optionally accepts an [APIManager] for dependency injectio
  RequestRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static RequestRepository _singleton = RequestRepository();

  /// Singleton instance of [RequestRepository].
  static RequestRepository get instance => _singleton;

  /// Overrides the singleton instance (used for testing or controlled scenarios).
  ///
  /// Use with caution as it replaces the global instance.
  // ignore: avoid_setters_without_getters
  static set overrideInstance(RequestRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  /// Fetches application details for the given [appRefNo].
  ///
  /// If [appRefNo] is not provided, it uses the value from [Globals.request].
  /// Returns [ApplicationDetails] on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches the last approved application details.
  ///
  /// Uses RIM number and group ID from [Globals.request].
  /// Returns an [ApplicationDetails] object if data is available.
  /// Returns an empty [ApplicationDetails] if no data is found.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches the list of application details eligible for reconsideration.
  ///
  /// Uses customer RIM number and group ID from [Globals.request].
  /// Returns a list of [ApplicationDetails] on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves customer request information based on the logged-in user's context.
  ///
  /// Includes role, session, and request metadata in the API call.
  /// Returns a list of [Response] objects on success.
  /// Throws [ApiException] if the API call fails or returns an error.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves pipeline request details for the current application context.
  ///
  /// Uses group ID and RIM number from [Globals.request].
  /// Returns a list of [Response] objects on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches security deferral details for the current application.
  ///
  /// Uses RIM number, group ID, and application reference number from [Globals.request].
  /// Returns a [SecurityPerfection] object on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves security, covenant, and condition deferral details.
  ///
  /// Accepts lists of deferral data and submits them to the backend.
  /// Returns a success message string on successful save.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the latest review comment for the current application.
  ///
  /// Fetches comments based on application reference and category,
  /// then sorts them by creation date to return the most recent comment.
  /// Returns a [Comment] object if available, or `null` if no comments exist
  /// or an error occurs.
  /// Throws [ApiException] if the API response indicates failure.
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
        logger.i("Raw commentList: $commentList");

        if (commentList == null || commentList.isEmpty) {
          return null;
        }

        // Sort by createdDate descending
        commentList.sort((a, b) {
          final dateA =
              DateTime.tryParse(a["createdDate"] ?? "") ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b["createdDate"] ?? "") ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        final latestCommentJson = commentList.first;
        logger.i("Latest comment JSON: $latestCommentJson");

        // - Manually map 'comment' to 'strategyComment' for UI use
        final latestComment = Comment.fromJson(latestCommentJson)
          ..strategyComment = latestCommentJson["comment"];

        logger.i("Parsed Comment: ${latestComment.strategyComment}");
        return latestComment;
      } else {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e, stackTrace) {
      logger
        ..i("Exception in getReviewCommentsResponse: $e")
        ..i("StackTrace: $stackTrace");
      return null;
    }
  }

  /// Updates the terminate status of the current application.
  ///
  /// Accepts a termination reason ID and optional remarks, and submits them
  /// to the backend for processing.
  /// Returns the status description message on success.
  /// Throws [ApiException] if the API call fails.
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
      return response.body?["baseResponse"]?["status"]?["statusDescription"] ??
          "No status description found";
    } else {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves certificate details for the specified application reference number.
  ///
  /// Sends user context and request metadata to the backend and parses the
  /// returned certification data list.
  /// Returns a list of [CertificationData] on success.
  /// Throws [ApiException] if the API call fails or returns an error.
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
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves certificate details for the specified application.
  ///
  /// Converts the provided [CertificationData] list into JSON format and
  /// submits it along with user and application context to the backend.
  /// Returns a success message string on successful save.
  /// Throws [ApiException] if the API call fails.
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
      return response.body["responseData"]["message"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves condition or covenant details for the current application.
  ///
  /// Accepts a [CovenantCondition] object, converts it to the required format,
  /// and submits it to the backend.
  /// Returns a status description message on successful save.
  /// Throws [ApiException] if the API call fails.
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
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves SIC code review data for the given customer RIM number.
  ///
  /// Uses the application reference number from [Globals.request] along with
  /// the provided RIM number to fetch review data from the backend.
  /// Returns a list of [SicCodeReview] objects on success.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves SIC code review details for the current application.
  ///
  /// Accepts a list of [SicCodeReview] objects, extracts minimal required fields,
  /// and submits them to the backend.
  /// Returns a success message string on successful save.
  /// Returns `null` if the input list is null or empty.
  /// Throws [ApiException] if the API call fails.
  Future<String?> saveSICcodeReview(List<SicCodeReview?>? sicCodeReview) async {
    if (sicCodeReview == null || sicCodeReview.isEmpty) {
      return null;
    }

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
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves detailed security information for a given security context.
  ///
  /// Determines whether the request is for creating or fetching an existing
  /// security, prepares the required payload, and enriches the response with
  /// reference data such as emirates, statuses, and countries.
  /// Returns a populated [Security] object on success.
  /// Throws [ApiException] if the API call or reference data retrieval fails.
  Future<Security?> getSecurityDetails({
    required List<Country> countries,
    Security? selectedSecurity,
  }) async {
    final String? rimStr = selectedSecurity?.securityProvidedRim;

    final String rimStringSource = (rimStr != null && rimStr.trim().isNotEmpty)
        ? rimStr
        : (Globals.request?.customerRimNo?.toString() ?? "");

    //  send groupId only for "create" flow (no securityId yet)
    final bool isCreate =
        selectedSecurity == null || selectedSecurity.securityId == null;
    final int? groupIdToSend = isCreate ? Globals.request?.groupId : null;

    if (!isCreate &&
        (selectedSecurity.securityNumber == null ||
            (selectedSecurity.securityNumber ?? "").trim().isEmpty ||
            selectedSecurity.securityType?.id == null)) {
      return Security();
    }

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
      } on Object catch (e) {
        throw ApiException("Error fetching reference data: $e");
      }
      return Security.fromJson(
        response.body["responseData"],
        emirates: emirates,
        statuses: statuses,
        countries: countries,
      )..dynamicFormDocument =
            FacilitySecurityRepository.parseAndFlattenAdditionalDetails(
          response.body["responseData"]["additionalDetails"],
        );
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves group facility details along with CBD strategy comments for an application.
  ///
  /// Constructs and submits request data including user context, application reference,
  /// strategy comment type, and comment details to the backend.
  /// Returns a success message string when the operation is successful.
  /// Throws [ApiException] if the API call fails.
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
      return response.body["responseData"]["message"];
    } else {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves facility details associated with other banks for the application.
  ///
  /// Sends user context and application reference to the backend and parses
  /// the response into a [FacilitiesOtherBanks] object.
  /// Returns the populated facility details on success.
  /// Throws [ApiException] if the API call fails.
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
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  // Currently this method is not in use
  // Future<RiskBureau> getFacilitiesCentralRiskBureau() async {
  //   final Map data = {
  //     "roleID": Globals.user?.currentRole?.id,
  //     "role": Globals.user?.currentRole?.name,
  //     "channelID": EnvConfig.channelID,
  //     "sessionID": const Uuid().v4(),
  //     "userID": Globals.user?.id ?? "WCASTSP01",
  //     "userName": Globals.user?.name ?? "wcastsp01",
  //     "pageId": 21,
  //     "appRefNo": ServerConstants.appRefNo,
  //     "rqUID": const Uuid().v4(),
  //     "mode": null,
  //     "requestData": {"appRefNo": ServerConstants.appRefNo},
  //   };
  //   final AppResponse response =
  //       await _apiManager.post(APIEndpoints.getShareofWalletDetails, data);
  //   if (response.status == ResponseStatus.success) {
  //     return RiskBureau.fromJson(response.body["responseData"]);
  //   } else {
  //     //throw Exception(response.message);
  //     throw ApiException(response.message);
  //   }
  // }

  /// Saves facility details associated with other banks for the application.
  ///
  /// Accepts a list of facility data in JSON format and submits it along with
  /// user and application context to the backend.
  /// Returns a success message string when the operation is successful.
  /// Throws [ApiException] if the API call fails.
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
      return response.body["responseData"]["message"];
    } else {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the list of borrowers associated with the current application.
  ///
  /// Sends user context and application reference to the backend and maps
  /// the response into a list of [Customer] objects.
  /// Returns the list of borrowers on success.
  /// Throws [ApiException] if the API call fails.
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
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the list of available currency codes from the backend.
  ///
  /// Parses the response data into a list of [Reference] objects, mapping
  /// ISO codes to name and descriptions appropriately.
  /// Returns an empty list if the response data is not in the expected format.
  /// Throws [ApiException] if the API call fails.
  Future<List<Reference>> getCurrencyCodes() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyRateList, data);

    if (response.status != ResponseStatus.success) {
      // throw Exception(response.message);
      throw ApiException(response.message);
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

  /// Cancels prior validation for the provided application customer information.
  ///
  /// Sends the cancellation request to the backend using the serialized
  /// [ApplicationCustomerInformation] data and returns the updated
  /// application details from the response.
  /// Throws [ApiException] if the API call fails.
  Future<ApplicationCustomerInformation> cancelPriorValidation(
    ApplicationCustomerInformation? applicationDetails,
  ) async {
    final Map data = BaseRequest.baseRequest(
      applicationDetails?.toCancelPriorValidationJson(),
    );
    final AppResponse response =
        await _apiManager.post(APIEndpoints.cancelPriorValidation, data);

    final responseData = response.body["responseData"];

    return ApplicationCustomerInformation.fromJson(responseData);
  }

  /// Saves application information to the backend.
  ///
  /// Serializes the provided [ApplicationDetails] and submits it in the request.
  /// Returns the generated application reference number on successful save.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves remark strategy data for a selected customer.
  ///
  /// Submits strategy comments associated with a specific customer (RIM)
  /// along with application context to the backend.
  /// Returns a status description message on successful save.
  /// Throws [ApiException] if the API call fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves remark strategy data for a selected customer.
  ///
  /// Fetches strategy comments based on the provided customer, remark type,
  /// and optional category, then filters and returns the relevant [Comment].
  /// Returns a [Comment] if found, or an empty/default comment if no matching data exists.
  /// Throws [ApiException] if the API call fails.
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

  /// Retrieves fee structure data for a specific customer.
  ///
  /// Uses the application reference number and customer RIM number to fetch
  /// fee-related details from the backend.
  /// Returns a list of [FeeStructure] objects on success, or an empty list if no data is available.
  /// Throws [ApiException] if the API call fails.
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

  /// Saves fee structure details for the current application.
  ///
  /// Converts the provided list of [FeeStructure] objects into JSON format
  /// and submits it to the backend.
  /// Returns a status description message on successful save.
  /// Throws [ApiException] if the API call fails.
  Future<String> saveFeeStructure(List<FeeStructure> feeRows) async {
    final List<Map<String, dynamic>> feeData =
        feeRows.map((element) => element.toJson()).toList();

    final Map<String, dynamic> data = BaseRequest.baseRequest(feeData);

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    }
    // throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Deletes a specific fee structure entry for the current application.
  ///
  /// Accepts a [FeeStructure] object, converts it to JSON, and sends a delete
  /// request to the backend.
  /// Returns a status description message on successful deletion.
  /// Throws [ApiException] if the API call fails.
  Future<String> deleteFeeStructureData(FeeStructure feeData) async {
    final Map<String, dynamic> data = BaseRequest.baseRequest(feeData.toJson());

    final AppResponse response =
        await _apiManager.delete(APIEndpoints.deleteFeeStructureData, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    }
    //throw Exception(response.message);
    throw ApiException(response.message);
  }
}
