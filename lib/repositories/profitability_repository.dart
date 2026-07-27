import "dart:convert";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";
import "package:wcas_frontend/models/request/profitability/income_summary.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";
import "package:wcas_frontend/models/request/profitability/strategies_comments.dart";

/// Repository responsible for profitability-related operations,
/// including API interactions and comment management.
class ProfitabilityRepository {
  /// Creates a [ProfitabilityRepository] instance.
  ///
  /// If no [apiManager] is provided, a default [APIManager]
  /// instance is used.
  ProfitabilityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static ProfitabilityRepository _singleton = ProfitabilityRepository();

  /// Returns the singleton instance of [ProfitabilityRepository].
  static ProfitabilityRepository get instance => _singleton;

  /// Stores the most recently saved business volume comment.
  Comment? lastBusinessVolumeComment;

  /// Replaces the singleton repository instance.
  ///
  /// Intended for testing or controlled override scenarios.
  // ignore: avoid_setters_without_getters
  static set overrideInstance(ProfitabilityRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  /// Retrieves application strategy details and associated comments.
  ///
  /// Fetches strategy comments for the specified comment [type] and
  /// [entityIdentifier], transforms the response into a
  /// [StrategiesComments] model, and returns the result.
  ///
  /// Throws an [ApiException] if the API request fai
  Future<StrategiesComments> getStrategiesAndComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier],
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getApplicationStrategyDetails,
      requestPayload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final responseData = response.body["responseData"] ?? {};
    final commentList = responseData["commentList"] as List<dynamic>? ?? [];

    String findComment(int categoryId) {
      final item = commentList.firstWhere(
        (c) => c["categoryId"] == categoryId,
        orElse: () => {"strategyComment": ""},
      );
      return item["strategyComment"] ?? "";
    }

    // Transform into flat map for your model
    final transformedJson = {
      "relationshipStrategy":
          findComment(ServerConstants.relationshipStrategyCommentCategoryId),
      "depositStrategy":
          findComment(ServerConstants.depositsStrategyCommentCategoryId),
      "transactionBankingComments":
          findComment(ServerConstants.transactionalBankingCommentCategoryId),
      "tradeFinanceComments":
          findComment(ServerConstants.tradeFinanceCommentCategoryId),
      "treasuryComments":
          findComment(ServerConstants.treasuryCommentCategoryId),
    };

    return StrategiesComments.fromJson(transformedJson);
  }

  /// Saves application strategy details for the specified comment type.
  ///
  /// Submits the provided strategy comments to the backend service and
  /// returns `true` when the operation completes successfully.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<bool> saveApplicationStrategyDetailsDynamic({
    required CommentsType type,
    required List<Map<String, dynamic>> commentList,
    String? appRefNo,
  }) async {
    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo ?? appRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "commentList": commentList, // <-- dynamic list directly
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveApplicationStrategyDetails,
      payload,
    );

    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    return response.status == ResponseStatus.success;
  }

  /// Retrieves share-of-wallet information for the current application.
  ///
  /// Returns a list of [ShareOfWallet] records when data is available.
  /// Returns an empty list if no data is found or if the request fails.
  ///
  /// This method gracefully handles API and parsing errors by returning
  /// an empty list instead of throwing an exception
  Future<List<ShareOfWallet>> getShareOfWallet() async {
    try {
      final Map<dynamic, dynamic> requestPayload = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });
      final AppResponse response =
          await _apiManager.post(APIEndpoints.getShareofWallet, requestPayload);

      if (response.status == ResponseStatus.error) {
        return <ShareOfWallet>[];
      }

      final dynamic responseData = response.body?["responseData"];

      if (responseData is! List || responseData.isEmpty) {
        return <ShareOfWallet>[];
      }

      return responseData
          .map<ShareOfWallet>(
            (json) =>
                ShareOfWallet.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    } on Object {
      return <ShareOfWallet>[];
    }
  }

  /// Retrieves the income summary for the current application.
  ///
  /// Returns an [IncomeSummaryResponseData] object populated with income
  /// summary details when available.
  ///
  /// If the API request fails, the response payload is invalid, or an
  /// exception occurs during processing, an empty
  /// [IncomeSummaryResponseData] object is returne
  Future<IncomeSummaryResponseData> getIncomeSummary() async {
    try {
      final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getIncomeSummary, requestPayload);

      // If API marks error, return empty normalized object
      if (response.status == ResponseStatus.error) {
        return IncomeSummaryResponseData(
          incomeSummaryDataList: [],
        );
      }

      final responseDataRaw = response.body?["responseData"];
      if (responseDataRaw == null || responseDataRaw is! Map<String, dynamic>) {
        // Invalid payload -> return empty normalized object
        return IncomeSummaryResponseData(
          incomeSummaryDataList: [],
        );
      }

      // Parse safely; fromJson should also default missing lists to []
      return IncomeSummaryResponseData.fromJson(responseDataRaw);
    } on Object catch (_) {
      // Network/parse/etc. -> return empty normalized object
      return IncomeSummaryResponseData(
        incomeSummaryDataList: [],
      );
    }
  }

  /// Saves income summary details and associated comments for the current
  /// application.
  ///
  /// Persists the provided income summary records along with an optional
  /// comment and returns the status description from the API response on
  /// successful completion.
  ///
  /// Throws an [ApiException] if the save operation fails
  Future<String> saveIncomeSummary(
    List<IncomeSummary> incomeSummaryDataList,
    String? commentText,
  ) async {
    final String? appRefNo = Globals.request?.applicationRefNo;

    // Convert income summary list to JSON using toJson()
    final List<Map<String, dynamic>> incomeSummaryDtoList =
        incomeSummaryDataList.map((summary) => summary.toJson()).toList();

    // Build the Comment instance
    final Comment incomeComment = Comment(
      applicationRefNo: appRefNo,
      userId: Globals.user?.id,
      userRole: Globals.user?.currentRole!.roleId,
      comment: commentText ?? "",
      categoryId: ServerConstants.commentTypeId[CommentsType.incomeSummary],
    );

    final Map<String, dynamic> commentPayload = {
      ...incomeComment.toSaveJson(),
      "isDraft": 0,
      "userAction": 0,
    };

    // Prepare requestData
    final Map<String, dynamic> requestData = {
      "appRefNo": appRefNo,
      "incomeSummaryDataList": incomeSummaryDtoList,
      "comment": commentPayload, // <-- pass JSON, not the object
    };

    // Wrap with baseRequest
    final Map<String, dynamic> payload = BaseRequest.baseRequest(requestData);

    // Call API
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveIncomeSummary,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.success) {
      return response.body["status"]?["statusDescription"] ?? "Success";
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves account conduct data for the current application.
  ///
  /// Fetches account conduct information from the backend service and
  /// returns an [AccountConductResponseData] object when the request is
  /// successful.
  ///
  /// Certain numeric response fields are normalized to strings before
  /// deserialization to ensure compatibility with the data model.
  ///
  /// Returns `null` if the request is unsuccessful.
  Future<AccountConductResponseData?> getAccountConductData() async {
    final data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response = await _apiManager
        .post(APIEndpoints.getAccountConductData, data, plainResponse: true);

    if (response.status == ResponseStatus.success) {
      final String modifiedJson = response.body.replaceAllMapped(
        RegExp(
          r'("passDueOrExcesses"|"pastDueOrExcesses"|"chequeReturns"|"turnoverInAcc"|"odHardcore"|"unusualTransactions"|"transparencyDisclosureLevels")\s*:\s*([\d.]+)',
        ),
        (match) => '${match.group(1)}:"${match.group(2)}"',
      );

      final dynamic data = jsonDecode(modifiedJson)["responseData"];
      final AccountConductResponseData contract =
          AccountConductResponseData.fromJson(data);
      return contract;
    } else {
      return null;
    }

//     final Map<String, dynamic> data = BaseRequest.baseRequest({
//       "appRefNo": Globals.request?.applicationRefNo,
//     });
// sds
//     final AppResponse response = await _apiManager.post(
//       APIEndpoints.getAccountConductData,
//       json.encode(data),
//     );

//     // Defensive: ensure we pass a Map even if responseData is null
//     final Map<String, dynamic> responseData =
//         (response.body?['responseData'] as Map<String, dynamic>?) ??
//             <String, dynamic>{};

//     return AccountConductResponseData.fromJson(responseData);
  }

  /// Saves account conduct information for the current application.
  ///
  /// Persists account conduct summary details for all available RIM
  /// records and returns the status description from the API response
  /// when the operation is successful.
  ///
  /// Throws an [ApiException] if the save request fails.
  Future<String> postAccountConductData(
    AccountConductResponseData accountStat,
  ) async {
    // Build only the required fields for 'requestData'
    final Map<String, dynamic> requestData = {
      "appRefNo": Globals.request?.applicationRefNo,
      "accountConductDtoList": (accountStat.accountConductDtoList ?? [])
          .map(
            (dto) => {
              // summary-only fields required by the save API
              "rimNo": dto.rimNo,
              "pastDueOrExcesses": dto.passDueOrExcesses,
              "chequeReturns": dto.chequeReturns,
              "turnoverInAcc": dto.turnoverInAcc,
              "odHardcore": dto.odHardcore,
              "unusualTransactions": dto.unusualTransactions,
              "transparencyDisclosureLevels": dto.transparencyDisclosureLevels,
              // intentionally NOT sending:
              // "custName", "accountConductDetailsList"
            },
          )
          .toList(),
    };

    // Let BaseRequest.baseRequest wrap into { baseRequest, requestData }
    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    logger.i(data); // log the actual payload being sent

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveAccountConductData,
      json.encode(data),
    );

    if (response.status == ResponseStatus.success) {
      final String? statusDesc =
          response.body?["status"]?["statusDescription"] as String?;
      return statusDesc ?? "Success";
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves relationship utilization details for the current application.
  ///
  /// Returns a list of [RelationshipUtilization] records populated from
  /// the backend response. If the request fails or no data is available,
  /// an empty list is returned.
  Future<List<RelationshipUtilization>> getRelationshipUtilizationData() async {
    final List<RelationshipUtilization> relationUtilize = [];
    final data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getRelationshipUtilization,
      data,
    );

    if (response.status == ResponseStatus.success) {
      // final String modifiedJson = response.body.replaceAllMapped(
      //   RegExp(
      //       r'("clientTurnover"|"throughputToCbdPercentage"|"turnoverInCbdCua")\s*:\s*("?)(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)(?<!")'),
      //   (match) => '${match.group(1)}:"${match.group(3)}"',
      // );

      // final decoded = jsonDecode(modifiedJson);

      for (final dynamic item in response.body["responseData"]) {
        relationUtilize.add(RelationshipUtilization.fromJson(item));
      }

      return relationUtilize;
    } else {
      return relationUtilize;
    }
  }

  /// Saves relationship utilization details for the current application.
  ///
  /// Persists relationship utilization data, including revenue detail
  /// records, and returns the status description from the API response
  /// when the operation succeeds.
  ///
  /// Throws an [ApiException] if the save request fails.
  Future<String> postRelationshipUtilizationData(
    List<RelationshipUtilization> relationshipUtilization,
  ) async {
    if (relationshipUtilization.isEmpty) {
      return "";
    }

    final first = relationshipUtilization.first;

    final Map<String, dynamic> requestData = {
      "appRefNo": Globals.request?.applicationRefNo ?? "",
      "rim": first.rim,
      "clientTurnover": first.clientTurnover,
      "throughputToCbdPercentage": first.throughputToCbdPercentage,
      // "turnoverInCbdCua": first.turnoverInCbdCua,
      "relationShipRevenueDetails":
          (first.relationshipRevenueDetails ?? []).map((d) {
        return {
          "product": d.product,
          "accountCommitmentNumber": d.accountCommitmentNumber,
          "accountLimit": d.accountLimit,
          "averageUtilization": d.averageUtilization,
          "utilizationPercent": d.utilizationPercent,
        };
      }).toList(),
    };

    final Map<String, dynamic> payload = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveRelationshipUtilization,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.success) {
      // If your test expects an empty string, keep this:
      // return "";
      // Otherwise, return the backend message:
      return response.body?["status"]?["statusDescription"] ?? "Success";
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves detailed relationship profitability information for the
  /// current application.
  ///
  /// Returns a list of [RelationshipProfitabilityDetailed] objects
  /// populated from the income summary data returned by the backend.
  ///
  /// Returns an empty list if the request fails or no data is available.
  Future<List<RelationshipProfitabilityDetailed>>
      getRelationProfitDetData() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request?.applicationRefNo},
    );

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getRelationshipProfitabilityDetailed,
      json.encode(data),
    );

    final List<RelationshipProfitabilityDetailed> raw = [];

    if (response.status == ResponseStatus.success) {
      for (final dynamic data
          in response.body["responseData"]["incomeSummaryDataList"] as List) {
        raw.add(RelationshipProfitabilityDetailed.fromJson(data));
      }
      return raw;
    } else {
      //throw response.message
      return raw;
    }
  }

  /// Retrieves relationship profitability comments for the current
  /// application.
  ///
  /// Returns the saved comment text from the backend response.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future getComments() async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 17,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "appRefNo": ServerConstants.appRefNo,
        "commentCategory": 216,
        "entityIdentifier": 216,
      },
    };

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getRelProfitDetComments,
      json.encode(data),
    );
    if (response.status == ResponseStatus.error) {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
    return response.body["responseData"]?["comment"];
    // return raw.map((e) => Comment.fromJson(e as Map<String,
    // dynamic>)).toList();
  }

  /// Retrieves business volume details for the current application.
  ///
  /// Returns a map where the key is a [Customer] and the value is the
  /// corresponding list of [BusinessVolume] records.
  ///
  /// The method also captures and stores the latest business volume
  /// comment in [lastBusinessVolumeComment] when available.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<Map<Customer, List<BusinessVolume>>> getBusinessVolumes() async {
    final Map<Customer, List<BusinessVolume>> businessDatas = {};

    try {
      final Map<String, dynamic> data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
      });

      final AppResponse response = await _apiManager
          .post(APIEndpoints.getBussinessVolume, data, plainResponse: true);

      if (response.status == ResponseStatus.success) {
        final dynamic responseData = jsonDecode(response.body)["responseData"];

        // also capture the comment from the same payload
        if (responseData != null && responseData["comment"] != null) {
          lastBusinessVolumeComment = Comment.fromJson(responseData["comment"]);
        } else {
          lastBusinessVolumeComment = null;
        }

        final List<dynamic> businessVolumeDtoList =
            responseData["businessVolumeDtoList"] as List;

        for (final dynamic customerData in businessVolumeDtoList) {
          // Create Customer object
          final Customer customer = Customer(
            customerRimNo: customerData["rimNo"],
            customerName: customerData["customerName"],
          );

          // Map businessVolumeDetailsList to BusinessVolume objects
          final List<BusinessVolume> volumes = [];
          if (customerData["businessVolumeDetailsList"] != null) {
            for (final dynamic volumeData
                in customerData["businessVolumeDetailsList"]) {
              volumes.add(BusinessVolume.fromJson(volumeData));
            }
          }

          businessDatas[customer] = volumes;
        }
        // }
      } else {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return businessDatas;
  }

  /// Saves business volume details and comment information for the
  /// current application.
  ///
  /// Persists customer-wise business volume data and returns the API
  /// status description when the save operation succeeds.
  ///
  /// Throws an [ApiException] if the save operation fails.
  Future<String> saveBusinessVolumes(
    Map<Customer, List<BusinessVolume>> customerWiseBusinessVolume,
    String? commentText,
  ) async {
    try {
      final List<Map<String, dynamic>> businessVolumeDtoList = [];

      customerWiseBusinessVolume.forEach((customer, volumes) {
        businessVolumeDtoList.add({
          "rimNo": customer.customerRimNo,
          "customerName": customer.customerName,
          "businessVolumeDetailsList": volumes
              .map(
                (v) => {
                  "businessVolumeId": v.businessVolumeId,
                  "natureOfBusiness": v.natureOfBusiness,
                  "previousYear": v.previousYear,
                  "currentYearYtd": v.currentYearYtd,
                  "estimatesForNextYear": v.estimatesForNextYear,
                },
              )
              .toList(),
        });
      });

      final Map<String, dynamic> requestData = {
        "appRefNo": Globals.request?.applicationRefNo,
        "businessVolumeDtoList": businessVolumeDtoList,
        "comment": {
          "appRefNo": Globals.request?.applicationRefNo,
          "userId": Globals.user?.id,
          "userRole": Globals.user?.currentRole?.roleId,
          "commentCategoryId": 1186,
          "comment": commentText ?? "",
          "isDraft": 0,
          "userAction": 0,
        },
      };

      final Map<String, dynamic> payload = BaseRequest.baseRequest(requestData);

      final AppResponse response = await _apiManager.post(
        APIEndpoints.saveBussinessVolume,
        json.encode(payload),
      );

      // Safe response handling
      if (response.status == ResponseStatus.success) {
        final dynamic status = response.body["status"];
        if (status != null && status["statusDescription"] != null) {
          return status["statusDescription"];
        }
        return "Success"; // Fallback if statusDescription missing
      } else {
        final dynamic status = response.body["status"];
        throw status != null && status["statusDescription"] != null
            ? status["statusDescription"]
            : "Unexpected error occurred";
      }
    } on Object catch (e) {
      logger.e("Error in saveBusinessVolumes: $e");
      throw ApiException("Failed to save business volumes: $e");
    }
  }

  /// Retrieves account statistics for the current application.
  ///
  /// Returns a map where each [Customer] is associated with a list of
  /// [AccountStat] records obtained from the backend service.
  ///
  /// Throws an [ApiException] if the API request fails.
  Future<Map<Customer, List<AccountStat>>> getAccountStats() async {
    final Map<Customer, List<AccountStat>> accountDatas = {};

    try {
      final Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo},
      );

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getAccountStats,
        json.encode(data),
      );
      if (response.status == ResponseStatus.success) {
        (response.body["responseData"] as List).map((mapData) {
          final List<AccountStat> accountStats = [];
          (mapData["accStatData"] as List).map((element) {
            accountStats.add(AccountStat.fromJson(element));
          }).toList();
          accountDatas[Customer.fromJson(mapData)] = accountStats;
          logger.i(accountDatas.entries.first.key.toJson());
        }).toList();
      }
      if (response.status == ResponseStatus.error) {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
      rethrow;
    }

    return accountDatas;
  }

  /// Retrieves relationship profitability summary data for the current
  /// application.
  ///
  /// Returns a [RelationshipProfitabilitySummary] populated with the
  /// profitability summary information returned by the backend service.
  ///
  /// Throws an [ApiException] if the API request fails or if the response
  /// payload is invalid.
  Future<RelationshipProfitabilitySummary>
      getRelationshipProfitabilitySummaryData() async {
    // Prepare request payload
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });

    // Call API
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getrelationshipProfitabilitySummary,
      requestPayload,
    );

    // Handle error response
    if (response.status == ResponseStatus.error) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    // Validate response data
    final responseDataRaw = response.body?["responseData"];
    if (responseDataRaw == null || responseDataRaw is! Map<String, dynamic>) {
      const errorMessage =
          "Invalid response: responseData missing or not an object";
      throw ApiException(errorMessage);
    }

    // Parse and return IncomeSummaryResponseData
    return RelationshipProfitabilitySummary.fromJson(
      response.body["responseData"],
    );
  }

  /// Saves relationship profitability summary data for the current
  /// application.
  ///
  /// Persists RAROC information and relationship profitability details,
  /// and returns a success message when the operation completes
  /// successfully.
  ///
  /// Throws an [ApiException] if the save request fails.
  Future<String> postRelationshipProfitabilitySummaryData(
    RelationshipProfitabilitySummary? summary,
  ) async {
    // Build requestData with mandatory appRefNo
    final Map<String, dynamic> requestData = {
      "appRefNo": Globals.request?.applicationRefNo,
    };

    // Optional: rarocInformation (list)
    if (summary?.rarocInformation != null &&
        summary!.rarocInformation!.isNotEmpty) {
      requestData["rarocInformation"] =
          summary.rarocInformation!.map((item) => item.toJson()).toList();
    }

    // Optional: relationshipProfitability (list)
    if (summary?.relationshipProfitability != null &&
        summary!.relationshipProfitability!.isNotEmpty) {
      requestData["relationshipProfitability"] = summary
          .relationshipProfitability!
          .map((item) => item.toJson())
          .toList();
    }

    // Final payload
    final Map<String, dynamic> payload = BaseRequest.baseRequest(requestData);

    final AppResponse response = await _apiManager.post(
      APIEndpoints.postRelationshipProfitabilitySummary,
      json.encode(payload),
    );

    // Assuming the API returns: { "status": { "statusDescription": "...",
    // "code": ... } }
    if (response.status == ResponseStatus.success) {
      return "Success"; // Fallback if statusDescription missing
    }

    // Bubble up API error description
    // throw Exception(response.message);
    throw ApiException(response.message);
  }
}
