import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/models/request/facility_security/exchange_rate.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_detail.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/facility_security/limit_facilities.dart';
import 'package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart';
import 'package:wcas_frontend/models/request/facility_security/project_list.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';

class FacilitySecurityRepository {
  static final _singleton = FacilitySecurityRepository();
  static FacilitySecurityRepository get instance => _singleton;

  final APIManager _apiManager;

  FacilitySecurityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  Future<List<Reference>> getcurrencyCode() async {
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
        await _apiManager.post(APIEndpoints.getCountryCode, data);
    if (response.status == ResponseStatus.success) {
      final forexList = response.body["RatesInqRs"]?["ForExQuoteRec"];

      if (forexList is List) {
        return forexList
            .map((element) {
              var code = element["BaseCurCode"]?["CurCodeValue"];
              var codeDesc = element["BaseCurCode"]?["CurCodeDesc"];
              if (code is String && codeDesc is String) {
                return Reference(name: code, reference4: codeDesc);
              }
              return null;
            })
            .whereType<Reference>()
            .toList();
      }

      return forexList;
    } else {
      throw response.message;
    }
  }

  Future<List<Section>> getSecurityDynamicForm(
      {int? typeID, int? subTypeID}) async {
    try {
      Map<String, dynamic> data =
          BaseRequest.baseRequest({"typeID": typeID, "subTypeID": subTypeID});
      AppResponse response = await _apiManager.post(
          APIEndpoints.getSecurityDynamicForm, json.encode(data));

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      List<dynamic> responses = response.body['responseData']['sectionList'];

      List<Section> sections =
          responses.map((item) => Section.fromJson(item)).toList();

      //collect all the operation keys from all DynamicField objects
      List<String> operationKeys = [];
      for (Section section in sections) {
        for (RowElement row in section.rows ?? []) {
          for (DynamicField field in row.fields ?? []) {
            if (field.operationKey != null) {
              operationKeys.add(field.operationKey!);
            }
          }
        }
      }
      // get reference data
      if (operationKeys.isNotEmpty) {
        Map<String, List<Reference>> referenceData =
            await ReferenceDataService().getReferenceData(operationKeys);

        // for all fields where controlType is FieldType.refDataDropdown
        for (Section section in sections) {
          for (RowElement row in section.rows ?? []) {
            for (DynamicField field in row.fields ?? []) {
              if (field.controlType == FieldType.refDataDropdown) {
                // fill dependentList, each Reference should be a Option, metaData should be reference item
                List<Reference>? references = referenceData[field.operationKey];

                //use map instead of for loop
                field.optionList = references
                    ?.map(
                      (reference) => Option(
                        key: reference.id.toString(),
                        pairValue: reference.id.toString(),
                        metaData: reference,
                      ),
                    )
                    .toList();
              }
            }
          }
        }
      }

      return sections;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Security>> getSecuritySummaryList() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": "201812APNAR000019", //Globals.request?.applicationRefNo,
      "groupId": 0, // Globals.request?.groupId,
      "rimNo": 72410
      // Globals.request?.customerRimNo
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getSecuritySummaryList, data);

    final baseResponse = response.body["baseResponse"];
    final status = baseResponse?["status"];
    final statusCode = status?["statusCode"];

    if (response.code == 200 && statusCode == "0") {
      List<Security> securitySummaryList = [];
      response.message = status?["statusDescription"];

      final List<dynamic>? dataList =
          response.body["responseData"] as List<dynamic>?;

      if (dataList != null) {
        for (var item in dataList) {
          securitySummaryList
              .add(Security.fromJson(item as Map<String, dynamic>));
        }
      }

      return securitySummaryList;
    } else {
      throw response.message;
    }
  }

  Future<List<Section>> getFacilitiesDynamicForm(
      {int? typeID, int? subTypeID}) async {
    try {
      Map<String, dynamic> data =
          BaseRequest.baseRequest({"typeID": typeID, "subTypeID": subTypeID});
      AppResponse response = await _apiManager.post(
          APIEndpoints.getFacilitiesDynamicForm, json.encode(data));

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      List responses = response.body['responseData']['sectionList'];
      List<Section> sections = [];
      for (int i = 0; i < responses.length; i++) {
        var section = Section.fromJson(responses[i]);
        sections.add(section);
      }
      return sections;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> saveFacilitiesDetails({required Facility? facility}) async {
    Map data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 4,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": facility?.toJson()
    };
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilitiesDetails, data);

    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteSecurityDetails(int? securityId) async {
    Map<String, dynamic> data =
        BaseRequest.baseRequest({"securityId": securityId});

    AppResponse response =
        await _apiManager.post(APIEndpoints.deleteSecurityDetails, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<Map<String, dynamic>> getFacilityDetails() async {
    try {
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "appRefNo": "201904APNIS000145",
        "rimNo": 1020548,
        "facilityId": "32800"
      });

      AppResponse response =
          await _apiManager.post(APIEndpoints.getFacilityDetails, data);

      if (response.code == 200) {
        response.message =
            response.body["baseResponse"]["status"]["statusDescription"];

        var responseData = response.body["responseData"];

        List<FacilityDetail> facilityDetails = [];
        var mainFacility = responseData["facilityDetails"];
        if (mainFacility is Map && mainFacility.isNotEmpty) {
          facilityDetails.add(
              FacilityDetail.fromJson(Map<String, dynamic>.from(mainFacility)));
        }

        List<dynamic> feeRateResponses = responseData['defacultFeeRates'] ?? [];
        List<FeeRate> feeRates =
            feeRateResponses.map((item) => FeeRate.fromJson(item)).toList();

        List<dynamic> conditionResponses = responseData['conditions'] ?? [];
        List<Condition> conditions =
            conditionResponses.map((item) => Condition.fromJson(item)).toList();

        return {
          "facilityDetails": facilityDetails,
          "feeRates": feeRates,
          "conditions": conditions,
        };
      } else {
        throw response.message;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> saveFacilityDetails(CustomerFacility customerFacility) async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 12,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": customerFacility.toJson()
    };
    AppResponse response = await _apiManager
        .get(APIEndpoints.saveFacilityDetails, queryParams: data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteFacilityDetails(
      {int? typeID, int? serialNumber}) async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 12,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "id": serialNumber,
        "type": typeID,
        "appRefNo": ServerConstants.appRefNo,
      }
    };

    AppResponse response =
        await _apiManager.post(APIEndpoints.deleteFacilityItem, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFacilitySubLimit(
      {int? rimNo, int? limitDescriptionID, String? limitCategory}) async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 12,
      "appRefNo": ServerConstants.appRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": rimNo,
        "groupId": Globals.request?.groupId,
        "limitCategory": limitCategory,
        "appRefNo": ServerConstants.appRefNo,
        "limitDescription": limitDescriptionID
      }
    };

    AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilitySubLimit, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getControllingLimitNoData() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      // TODO: remove static data after testing
      "rimNo": 759, // Globals.request?.customerRimNo
      "groupId": 578, // Globals.request?.groupId
      "appRefNo": "201902APNAR000035" // Globals.request?.applicationRefNo
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getControllingLimitNoData, data);

    if (response.code == 200) {
      List<Reference> controllingLimitNumbers = [];

      for (dynamic item in response.body["responseData"] as List) {
        dynamic controllingLimitNo = item["controllingLimitNo"];
        if (controllingLimitNo != null &&
            controllingLimitNo.toString().isNotEmpty) {
          controllingLimitNumbers
              .add(Reference(name: controllingLimitNo.toString()));
        }
      }

      return controllingLimitNumbers;
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getBorrowers() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      // TODO: remove static data after testing

      "groupId": 578, // Globals.request?.groupId
      "rimNo": 116320, // Globals.request?.customerRimNo
      "appRefNo": "202508APNAR027325" // Globals.request?.applicationRefNo
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getBorrowersMap, data);

    if (response.code == 200) {
      List<Reference> borrowers = [];

      for (dynamic item in response.body["responseData"] as List) {
        if (item != null && item.toString().isNotEmpty) {
          borrowers.add(Reference(name: item.toString()));
        }
      }

      return borrowers;
    } else {
      throw response.message;
    }
  }

  Future<List<StandardCondition>> getStandardConditions() async {
    try {
      // Prepare request payload if needed (can be empty or customized)
      Map<String, dynamic> data = BaseRequest.baseRequest({});

      // Make the API call
      AppResponse response = await _apiManager.post(
        APIEndpoints.getStandardConditions,
        json.encode(data),
      );

      // Handle error response
      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      // Parse the response
      List<dynamic> responses =
          response.body['responseData']['standardConditions'];

      // Convert to model list
      return responses.map((item) => StandardCondition.fromJson(item)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<FacilitySubTypes>> getFacilitySubTypes() async {
    try {
      Map<String, dynamic> data = BaseRequest.baseRequest({});

      AppResponse response = await _apiManager.post(
        APIEndpoints.getFacilitySubTypes,
        json.encode(data),
      );

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      List<dynamic> responses =
          response.body['responseData']['facilitySubTypes'];

      // Convert to model list
      return responses.map((item) => FacilitySubTypes.fromJson(item)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  ///-------------------------------//dev apis integration-------------------------
  Future<List<FacilitySummaryList>> getFacilitySummaryList() async {
    final payload = BaseRequest.baseRequest({
      "appRefNo": "202501APNIS026963", // Globals.request?.applicationRefNo,
      "groupOwner": "1023563" // Globals.request?.groupOwner,
    });
    final res =
        await _apiManager.post(APIEndpoints.getFacilitySummaryList, payload);

    final List<dynamic> items =
        (res.body?["responseData"] as List?) ?? const [];

    return items
        .whereType<Map<String, dynamic>>()
        .map((m) => FacilitySummaryList.fromJson({
              'rims': [m]
            }))
        .toList();
  }

  Future<ProjectListResponse> getProjectList(
      {int? typeID, int? serialNumber}) async {
    final payload = BaseRequest.baseRequest({});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getProjectList, payload);

    if (response.status == ResponseStatus.success) {
      final body = response.body as Map<String, dynamic>?;
      if (body == null) throw StateError('Empty body');
      return ProjectListResponse.fromMap(body);
    } else {
      throw response.message;
    }
  }

  Future<List<LimitsResponse>> getLimitsandFacilities() async {
    final payload = BaseRequest.baseRequest({"rimNo": 1020548});

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getLimitsandFacilities,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final body = response.body;
    final List<dynamic> rawList =
        body is List ? body : (body?['responseData'] as List<dynamic>? ?? []);

    return rawList
        .map((e) => LimitsResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LimitsFacilityResponse> saveFacilityDetailsNew({
    required FacilityDetails facilityDetails,
    FacilityBorrowerMap? facilityBorrowerMap,
  }) async {
    final Map<String, dynamic> requestData = {
      'facilityDetails': facilityDetails.toJson(),
      if (facilityBorrowerMap != null)
        'facilityBorrowerMap': facilityBorrowerMap.toJson(),
    };
    final payload = BaseRequest.baseRequest({
      'requestData': requestData,
    });

    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveFacilityDetailsNew,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final body = response.body;
    final Map<String, dynamic> raw = body is Map
        ? (body['responseData'] as Map<String, dynamic>? ?? const {})
        : const {};

    return LimitsFacilityResponse.fromJson(raw);
  }

  Future<CurrencyRates> getCurrencyRates(Reference? selectedCurrency) async {
    final payload =
        BaseRequest.baseRequest({"isoCode": selectedCurrency?.name});

    final res = await _apiManager.post(APIEndpoints.getExchangeRate, payload);

    final Map<String, dynamic> data =
        (res.body?['responseData'] as Map<String, dynamic>?) ?? const {};

    return CurrencyRates.fromJson(data);
  }

  Future<List<Facility>> getLinkageFacility() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId,
      "appRefNo": Globals.request?.applicationRefNo,
      "rimNo": Globals.request?.customerRimNo,
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilities, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw Exception(response.message);
    }
    final List raw = response.body['responseData'] as List;
    return raw
        .map((e) => Facility.fromJsonLinkage(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> saveSecurityFacilityLinkage(
      Security? securityItemDetails) async {
    Map data = BaseRequest.baseRequest(
        securityItemDetails?.toSaveFacilityLinkageJson());
    AppResponse response = await _apiManager.post(
        APIEndpoints.saveFacilitySecurityLinkDetails, data);
    if (response.status == ResponseStatus.success) {
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      throw response.message;
    }
  }
}
