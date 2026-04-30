import "dart:convert";

import "package:uuid/uuid.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
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

class ProfitabilityRepository {
  ProfitabilityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static ProfitabilityRepository _singleton = ProfitabilityRepository();
  static ProfitabilityRepository get instance => _singleton;
  Comment? lastBusinessVolumeComment;

  static void overrideInstance(ProfitabilityRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

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
      throw response.message;
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
      throw response.message;
    }
    return response.status == ResponseStatus.success;
  }

  /// POST API method to get Share Of Wallet data.

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
            (dynamic json) =>
                ShareOfWallet.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    } catch (e) {
      return <ShareOfWallet>[];
    }
  }

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
          comment: null,
        );
      }

      final responseDataRaw = response.body?["responseData"];
      if (responseDataRaw == null || responseDataRaw is! Map<String, dynamic>) {
        // Invalid payload -> return empty normalized object
        return IncomeSummaryResponseData(
          incomeSummaryDataList: [],
          comment: null,
        );
      }

      // Parse safely; fromJson should also default missing lists to []
      return IncomeSummaryResponseData.fromJson(responseDataRaw);
    } catch (_) {
      // Network/parse/etc. -> return empty normalized object
      return IncomeSummaryResponseData(
        incomeSummaryDataList: [],
        comment: null,
      );
    }
  }

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
      throw response.message;
    }
  }

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
      throw response.message;
    }
  }

  // profitability_repository.dart
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
      throw response.message;
    }
  }

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
      throw response.message;
    }
    return response.body["responseData"]?["comment"];
    // return raw.map((e) => Comment.fromJson(e as Map<String,
    // dynamic>)).toList();
  }

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
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return businessDatas;
  }

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
    } catch (e) {
      logger.e("Error in saveBusinessVolumes: $e");
      throw "Failed to save business volumes: ${e.toString()}";
    }
  }

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
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return accountDatas;
  }

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
      throw response.message;
    }

    // Validate response data
    final responseDataRaw = response.body?["responseData"];
    if (responseDataRaw == null || responseDataRaw is! Map<String, dynamic>) {
      throw "Invalid response: responseData missing or not an object";
    }

    // Parse and return IncomeSummaryResponseData
    return RelationshipProfitabilitySummary.fromJson(
      response.body["responseData"],
    );
  }

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
    throw response.message;
  }
}
