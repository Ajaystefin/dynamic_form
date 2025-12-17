import 'dart:convert';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/profitability/account_stat.dart';
import 'package:wcas_frontend/models/request/profitability/business_volume.dart';
import 'package:wcas_frontend/models/request/profitability/income_summary.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_utilization.dart';
import 'package:wcas_frontend/models/request/profitability/share_of_wallet.dart';
import 'package:wcas_frontend/models/request/profitability/strategies_comments.dart';
import 'package:uuid/uuid.dart';

class ProfitabilityRepository {
  static ProfitabilityRepository _singleton = ProfitabilityRepository();
  static ProfitabilityRepository get instance => _singleton;

  static void overrideInstance(ProfitabilityRepository newInstance) {
    _singleton = newInstance;
  }

  final APIManager _apiManager;

  ProfitabilityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<StrategiesComments> getStrategiesAndComments(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "entityIdentifier": ServerConstants.entityId[entityIdentifier]
    });

    AppResponse response = await _apiManager.post(
        APIEndpoints.getApplicationStrategyDetails, requestPayload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final responseData = response.body['responseData'] ?? {};
    final commentList = responseData['commentList'] as List<dynamic>? ?? [];

    String findComment(int categoryId) {
      final item = commentList.firstWhere((c) => c['categoryId'] == categoryId,
          orElse: () => {'strategyComment': ''});
      return item['strategyComment'] ?? '';
    }

    // Transform into flat map for your model
    final transformedJson = {
      'relationshipStrategy':
          findComment(ServerConstants.relationshipStrategyCommentCategoryId),
      'depositStrategy':
          findComment(ServerConstants.depositsStrategyCommentCategoryId),
      'transactionBankingComments':
          findComment(ServerConstants.transactionalBankingCommentCategoryId),
      'tradeFinanceComments':
          findComment(ServerConstants.tradeFinanceCommentCategoryId),
      'treasuryComments':
          findComment(ServerConstants.treasuryCommentCategoryId),
    };

    return StrategiesComments.fromJson(transformedJson);
  }

  /// POST API method to update or edit strategies comments.
  Future<bool> updateStrategiesComments(
      CommentsType type, StrategiesComments strategiesComments,
      {String? appRefNo}) async {
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "strategyCommentsType": ServerConstants.commentTypeId[type],
      "commentList": [
        {
          "appStrategyCommentsId": 0,
          "categoryId": ServerConstants.transactionalBankingCommentCategoryId,
          "strategyComment": strategiesComments.transactionBankingComments,
          "categoryType":
              ServerConstants.transactionalBankingCommentCategoryType
        },
        {
          "appStrategyCommentsId": 0,
          "categoryId": ServerConstants.tradeFinanceCommentCategoryId,
          "strategyComment": strategiesComments.tradeFinanceComments,
          "categoryType": ServerConstants.tradeFinanceCommentCategoryType
        },
        {
          "appStrategyCommentsId": 0,
          "categoryId": ServerConstants.treasuryCommentCategoryId,
          "strategyComment": strategiesComments.treasuryComments,
          "categoryType": ServerConstants.treasuryCommentCategoryId
        },
        {
          "appStrategyCommentsId": 0,
          "categoryId": ServerConstants.relationshipStrategyCommentCategoryId,
          "categoryType":
              ServerConstants.relationshipStrategyCommentCategoryType,
          "strategyComment": strategiesComments.relationshipStrategy,
        },
        {
          "appStrategyCommentsId": 0,
          "categoryId": ServerConstants.depositsStrategyCommentCategoryId,
          "categoryType": ServerConstants.depositsStrategyCommentCategoryType,
          "strategyComment": strategiesComments.depositStrategy,
        },
      ]
    });

    AppResponse response = await _apiManager.post(
        APIEndpoints.saveApplicationStrategyDetails, requestPayload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    return response.status == ResponseStatus.success;
  }

  /// POST API method to get Share Of Wallet data.
  Future<List<ShareOfWallet>> getShareOfWallet() async {
    Map<dynamic, dynamic> requestPayload = BaseRequest.baseRequest(
        {"appRefNo": Globals.request?.applicationRefNo});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getShareofWallet, requestPayload);

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> data = response.body['responseData'];
    return data
        .map((json) => ShareOfWallet.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<IncomeSummaryResponseData> getIncomeSummary() async {
    // Prepare request payload
    final Map<String, dynamic> requestPayload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
    });

    // Call API
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getIncomeSummary, requestPayload);

    // Handle error response
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    // Validate response data
    final responseDataRaw = response.body?['responseData'];
    if (responseDataRaw == null || responseDataRaw is! Map<String, dynamic>) {
      throw 'Invalid response: responseData missing or not an object';
    }

    // Parse and return IncomeSummaryResponseData
    return IncomeSummaryResponseData.fromJson(responseDataRaw);
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
      userRole: Globals.user?.currentRole?.roleId,
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

  Future getAccountConductData() async {
    final Map<String, dynamic> data = {
      "PartyAcctStatInqRq": {
        "RqUID": const Uuid().v4(),
        "MsgRqHdr": {
          "SvcIdent": {
            "SvcProviderName": "WCAS",
            "SvcProviderId": "71",
            "SvcName": "PartyAcctStatInq-getAccountConductData"
          }
        },
        "PartyAcctStatSel": {
          "PartyKeys": {"PartyIdList": "932140"},
          "DtRange": "2022-08-03+04:00"
        }
      }
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getAccountConductData, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    final List<dynamic> raw = response.body['responseData'] as List;
    return raw
        .map((e) => AccountStatType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future postAccountConductData(List<AccountStatType> accountStat) async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "appRefNo": ServerConstants.appRefNo,
        "accountConduct":
            jsonEncode(accountStat.map((e) => e.toJson()).toList())
      }
    };

    logger.i(accountStat);
    AppResponse response = await _apiManager.post(
        APIEndpoints.getAccountConductData, json.encode(data));
    if (response.status == ResponseStatus.success) {
      response.message = response.body["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<RelationshipUtilization>> getRelationshipUtilizationData() async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": Globals.request?.applicationRefNo}
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getRelationshipUtilization, json.encode(data));

    List<RelationshipUtilization> raw = [];

    if (response.status == ResponseStatus.success) {
      for (dynamic data in response.body["responseData"] as List) {
        raw.add(RelationshipUtilization.fromJson(data));
      }
      return raw;
    } else {
      //throw response.message
      return raw;
    }
  }

  Future postRelationshipUtilizationData(
      List<RelationshipUtilization> relationshipUtilization) async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "appRefNo": Globals.request?.applicationRefNo,
        "relationshipUtilization":
            jsonEncode(relationshipUtilization.map((e) => e.toJson()).toList())
      }
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getAccountConductData, json.encode(data));
    if (response.status == ResponseStatus.success) {
      response.message = response.body["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<RelationshipProfitabilityDetailed>>
      getRelationProfitDetData() async {
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getRelationshipProfitabilityDetailed, json.encode(data));

    List<RelationshipProfitabilityDetailed> raw = [];

    if (response.status == ResponseStatus.success) {
      for (dynamic data in response.body["responseData"] as List) {
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
        "entityIdentifier": 216
      }
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getRelProfitDetComments, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    return response.body['responseData']?['comment'];
    // return raw.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<Customer, List<BusinessVolume>>> getBusinessVolumes() async {
    Map<Customer, List<BusinessVolume>> businessDatas = {};

    try {
      Map<String, dynamic> data = BaseRequest.baseRequest(
          {"appRefNo": Globals.request?.applicationRefNo});

      AppResponse response = await _apiManager.post(
        APIEndpoints.getBussinessVolume,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        final businessVolumeDtoList =
            responseData["businessVolumeDtoList"] as List;

        for (var customerData in businessVolumeDtoList) {
          // Create Customer object
          Customer customer = Customer(
            customerRimNo: customerData["rimNo"],
            customerName: customerData["customerName"],
          );

          // Map businessVolumeDetailsList to BusinessVolume objects
          List<BusinessVolume> volumes = [];
          if (customerData["businessVolumeDetailsList"] != null) {
            for (var volumeData in customerData["businessVolumeDetailsList"]) {
              volumes.add(BusinessVolume.fromJson(volumeData));
            }
          }

          businessDatas[customer] = volumes;
        }
      } else {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return businessDatas;
  }

  Future<Comment?> getBusinessVolumeComment() async {
    try {
      Map<String, dynamic> data = BaseRequest.baseRequest(
          {"appRefNo": Globals.request?.applicationRefNo});

      AppResponse response = await _apiManager.post(
        APIEndpoints.getBussinessVolume,
        json.encode(data),
      );

      if (response.status == ResponseStatus.success) {
        final responseData = response.body["responseData"];
        if (responseData != null && responseData["comment"] != null) {
          return Comment.fromJson(responseData["comment"]);
        }
      } else {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    }

    return null;
  }

  Future<String> saveBusinessVolumes(
    Map<Customer, List<BusinessVolume>> customerWiseBusinessVolume,
    String? commentText,
  ) async {
    try {
      List<Map<String, dynamic>> businessVolumeDtoList = [];

      customerWiseBusinessVolume.forEach((customer, volumes) {
        businessVolumeDtoList.add({
          "rimNo": customer.customerRimNo,
          "customerName": customer.customerName,
          "businessVolumeDetailsList": volumes
              .map((v) => {
                    "businessVolumeId": v.businessVolumeId,
                    "estimatesForNextYear": v.estimatesForNextYear
                  })
              .toList()
        });
      });

      Map<String, dynamic> requestData = {
        "appRefNo": Globals.request?.applicationRefNo,
        "businessVolumeDtoList": businessVolumeDtoList,
        "comment": {
          "appRefNo": Globals.request?.applicationRefNo,
          "userId": Globals.user?.id,
          "userRole": Globals.user?.currentRole?.roleId,
          "commentCategoryId": 1186,
          "comment": commentText ?? "",
          "isDraft": 0,
          "userAction": 0
        }
      };

      Map<String, dynamic> payload = BaseRequest.baseRequest(requestData);

      AppResponse response = await _apiManager.post(
        APIEndpoints.saveBussinessVolume,
        json.encode(payload),
      );

      // Safe response handling
      if (response.status == ResponseStatus.success) {
        final status = response.body["status"];
        if (status != null && status["statusDescription"] != null) {
          return status["statusDescription"];
        }
        return "Success"; // Fallback if statusDescription missing
      } else {
        final status = response.body["status"];
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
    Map<Customer, List<AccountStat>> accountDatas = {};

    try {
      Map data = BaseRequest.baseRequest(
          {"appRefNo": Globals.request?.applicationRefNo});

      AppResponse response = await _apiManager.post(
          APIEndpoints.getAccountStats, json.encode(data));
      if (response.status == ResponseStatus.success) {
        (response.body["responseData"] as List).map((mapData) {
          List<AccountStat> accountStats = [];
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
    final Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {"appRefNo": ServerConstants.appRefNo}
    };

    AppResponse response = await _apiManager.post(
        APIEndpoints.getrelationshipProfitabilitySummary, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    return RelationshipProfitabilitySummary.fromJson(
        response.body['responseData']);
  }

  Future<String> postRelationshipProfitabilitySummaryData(
    RelationshipProfitabilitySummary? relationshipProfitabilitySummaryData,
  ) async {
    //requestData payload with the required appRefNo.
    final Map<String, dynamic> requestData = {
      "appRefNo": ServerConstants.appRefNo,
    };

    if (relationshipProfitabilitySummaryData?.relationshipProfitability !=
        null) {
      requestData["relationshipProfitability"] =
          relationshipProfitabilitySummaryData!.relationshipProfitability!
              .map((data) => data.toJson())
              .toList();
    }

    final Map<String, dynamic> payload = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.code,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 3,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": requestData,
    };

    final AppResponse response = await _apiManager.post(
      APIEndpoints.postRelationshipProfitabilitySummary,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.success) {
      return response.body["status"]["statusDescription"];
    }
    throw response.body["status"]["statusDescription"];
  }
}
