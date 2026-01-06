import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/facility_security/borrower_facility.dart';
import 'package:wcas_frontend/models/request/facility_security/exchange_rate.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_condition_list.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_detail.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/facility_security/limit_facilities.dart';
import 'package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart';
import 'package:wcas_frontend/models/request/facility_security/project_list.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/core/utils/logger.dart';

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
      "appRefNo": Globals.request?.applicationRefNo,
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
            if (Utils.checkRoles([UserRole.creditCommitteeProxy]) &&
                !field.isCMOUpdate) {
              field.isDisable = true;
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
                if (field.operationKey == ReferenceDataKeys.propertySubType ||
                    field.operationKey ==
                        ReferenceDataKeys.externalRatingAgencyValues) {
                  //Don't fill by default for this dropdown
                  continue;
                }
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
      "appRefNo": Globals.request?.applicationRefNo,
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo
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

  Future<Security?> saveSecurityDetails(
    Security? security,
    List<Section> sections,
    String? securityCode,
  ) async {
    // Transform grid data before creating request
    if (security?.dynamicFormDocument != null) {
      security!.dynamicFormDocument = _transformGridDataForSerialization(
        security.dynamicFormDocument!,
        sections,
      );
    }
    Map<String, dynamic> data = BaseRequest.baseRequest(
      security?.toJson(securityCode),
    );
    AppResponse response =
        await _apiManager.post(APIEndpoints.saveSecurityDetails, data);
    if (response.status == ResponseStatus.success) {
      return Security.fromJson(response.body["responseData"]);
    } else {
      throw response.message;
    }
  }

  /// Transforms grid data from flattened key format to array of row objects
  ///
  /// This method:
  /// 1. Scans sections to identify all grid fields and their columns
  /// 2. Groups flattened grid data by grid field and row index
  /// 3. Transforms each grid into an array of row objects
  ///
  /// Input format: {"columnKey@0": value1, "columnKey@1": value2}
  /// Output format: {"gridKey": [{"columnKey": value1}, {"columnKey": value2}]}
  Map<String, dynamic> _transformGridDataForSerialization(
    Map<String, dynamic> document,
    List<Section> sections,
  ) {
    // Step 1: Build grid metadata from sections
    // Map: gridFieldKey -> List of column keys
    Map<String, List<String>> gridMetadata = {};

    for (Section section in sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          if (field.controlType == FieldType.grid) {
            String gridKey = field.key;
            List<String> columnKeys = field.columnInfoList
                    ?.map((col) => col.dynamicField.key)
                    .toList() ??
                [];
            gridMetadata[gridKey] = columnKeys;
          }
        }
      }
    }

    if (gridMetadata.isEmpty) {
      // No grids in this form, return as-is
      return document;
    }

    final transformed = Map<String, dynamic>.from(document);

    // Step 2: Process each grid field
    for (MapEntry<String, List<String>> entry in gridMetadata.entries) {
      String gridKey = entry.key;
      List<String> columnKeys = entry.value;

      // Step 3: Extract grid data for this specific grid
      Map<int, Map<String, dynamic>> gridRowData = {};
      List<String> keysToRemove = <String>[];

      for (String columnKey in columnKeys) {
        // Find all entries for this column across all rows
        document.forEach((docKey, value) {
          if (docKey.startsWith('$columnKey@')) {
            List<String> parts = docKey.split('@');
            if (parts.length == 2) {
              int? rowIndex = int.tryParse(parts[1]);
              if (rowIndex != null) {
                gridRowData.putIfAbsent(rowIndex, () => {});
                gridRowData[rowIndex]![columnKey] = value;
                keysToRemove.add(docKey);
              }
            }
          }
        });
      }

      // Step 4: Convert to array format
      if (gridRowData.isNotEmpty) {
        List<int> sortedIndices = gridRowData.keys.toList()..sort();
        List<Map<String, dynamic>> rowsArray =
            sortedIndices.map((index) => gridRowData[index]!).toList();

        // Remove flattened keys
        for (String key in keysToRemove) {
          transformed.remove(key);
        }

        // Add transformed array
        transformed[gridKey] = rowsArray;
      }
    }

    return transformed;
  }

  /// Parses and flattens additionalDetails JSON for dynamic form prefill
  ///
  /// This method transforms the backend format (with grid arrays) into the
  /// flattened key format required by the DynamicForm component.
  ///
  /// Input format: {"gridKey": [{"col": "val1"}, {"col": "val2"}], "simpleKey": "value"}
  /// Output format: {"col@0": "val1", "col@1": "val2", "simpleKey": "value"}
  static Map<String, dynamic> parseAndFlattenAdditionalDetails(
      dynamic additionalDetails) {
    if (additionalDetails == null) {
      return {};
    }

    Map<String, dynamic> parsed;

    // Step 1: Parse JSON string if needed
    try {
      if (additionalDetails is String && additionalDetails.isNotEmpty) {
        parsed = jsonDecode(additionalDetails) as Map<String, dynamic>;
      } else if (additionalDetails is Map<String, dynamic>) {
        parsed = additionalDetails;
      } else {
        return {};
      }
    } catch (e) {
      logger.w('Failed to parse additionalDetails: $e');
      return {};
    }

    final flattened = <String, dynamic>{};

    // Step 2: Iterate over all keys and flatten grids
    parsed.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        // This is a grid field - flatten it
        for (int rowIndex = 0; rowIndex < value.length; rowIndex++) {
          final row = value[rowIndex];
          if (row is Map<String, dynamic>) {
            // Flatten each column in this row
            row.forEach((columnKey, columnValue) {
              final flattenedKey = '$columnKey@$rowIndex';
              flattened[flattenedKey] = columnValue;
            });
          }
        }
      } else {
        // Simple field - add directly
        flattened[key] = value;
      }
    });

    return flattened;
  }

  Future<List<Section>> getFacilitiesDynamicForm(
      {int? typeID, int? subTypeID}) async {
    try {
      Map<String, dynamic> data =
          BaseRequest.baseRequest({"typeID": typeID, "subTypeID": subTypeID});
      AppResponse response = await _apiManager.post(
          APIEndpoints.getSecurityDynamicForm, json.encode(data));

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
      "appRefNo": Globals.request?.applicationRefNo,
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

  Future<String?> saveFacilityDetails(CustomerFacility customerFacility) async {
    Map<String, dynamic> data = {
      "roleID": Globals.user?.currentRole?.id,
      "role": Globals.user?.currentRole?.name,
      "channelID": EnvConfig.channelID,
      "sessionID": const Uuid().v4(),
      "userID": Globals.user?.id ?? "WCASTSP01",
      "userName": Globals.user?.name ?? "wcastsp01",
      "pageId": 12,
      "appRefNo": Globals.request?.applicationRefNo,
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
      "appRefNo": Globals.request?.applicationRefNo,
      "rqUID": const Uuid().v4(),
      "mode": null,
      "requestData": {
        "rimNo": rimNo,
        "groupId": Globals.request?.groupId,
        "limitCategory": limitCategory,
        "appRefNo": Globals.request?.applicationRefNo,
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
    final bool isGroupOwner = Utils.isGroupOwnerApplication();

    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
      if (isGroupOwner)
        'groupOwner': Globals.request?.groupOwner
      else
        'rimNo': Globals.request?.customerRimNo
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

  Future<ProjectListResponse> getProjectList(int? existingFacilityId,
      {int? typeID, int? serialNumber}) async {
    final payload = BaseRequest.baseRequest({"facilityId": existingFacilityId});

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

  Future<List<LimitsResponse>> getLimitsandFacilities(int? rimNo) async {
    final payload = BaseRequest.baseRequest({"rimNo": rimNo});

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

  //rim no click onsummary list
  Future<LimitsFacilityResponse> saveFacilityDetailsNew({
    required FacilityDetails facilityDetails,
    FacilityBorrowerMap? facilityBorrowerMap,
    List<FeeRate> defacultFeeRates = const [],
    List<Section> sections = const [],
  }) async {
    // Transform grid data before creating request (same pattern as saveSecurityDetails)
    if (facilityDetails.additionalDetails != null &&
        facilityDetails.additionalDetails!.isNotEmpty) {
      facilityDetails.additionalDetails = _transformGridDataForSerialization(
        facilityDetails.additionalDetails!,
        sections,
      );
    }

    final payload = BaseRequest.baseRequest({
      'facilityDetails': facilityDetails.toJson(),
      if (facilityBorrowerMap != null)
        'facilityBorrowerMap': facilityBorrowerMap.toJson(),
      'defacultFeeRates': defacultFeeRates.map((e) => e.toJson()).toList(),
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

  Future<Map<String, dynamic>> getFacilityDetails(
      int existingFacilityId, int rimNo) async {
    try {
      Map<String, dynamic> data = BaseRequest.baseRequest({
        "appRefNo": Globals.request?.applicationRefNo,
        "rimNo": rimNo,
        "facilityId": existingFacilityId.toString()
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

  Future<BorrowersMap> getBorrowersMap() async {
    Map<String, dynamic> data = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo,
      "appRefNo": Globals.request?.applicationRefNo
    });

    AppResponse response =
        await _apiManager.post(APIEndpoints.getBorrowersMap, data);

    if (response.status == ResponseStatus.success) {
      final body = response.body as Map<String, dynamic>?;
      if (body == null) throw StateError('Empty body');
      return BorrowersMap.fromMap(body);
    } else {
      throw response.message;
    }
  }

  Future<List<Borrower>> getBorrowers() async {
    final bool isGroupOwner = Utils.isGroupOwnerApplication();

    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      'appRefNo': Globals.request?.applicationRefNo,
      if (isGroupOwner)
        'groupOwner': Globals.request?.groupOwner
      else
        'rimNo': Globals.request?.customerRimNo
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getBorrowers, payload);

    if (response.code != 200) {
      throw response.message;
    }

    final dynamic body = response.body;
    final List<dynamic>? list = body?["responseData"] as List<dynamic>?;

    if (list == null) return [];

    return list
        .where((e) => e != null)
        .map((e) => Borrower.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> saveFacilitySummaryListEdited(
      List<FacilitySummaryNew> edited) async {
    try {
      final facilityList = edited.map((f) => f.toSaveJson()).toList();

      final payload = BaseRequest.baseRequest({
        "facilityList": facilityList,
      });

      final AppResponse response =
          await _apiManager.post(APIEndpoints.saveFacilitySummaryList, payload);

      if (response.status == ResponseStatus.success || response.code == 200) {
        return response.message;
      } else {
        throw response.message;
      }
    } catch (e) {
      throw e.toString();
    }
  }

// In FacilitySecurityRepository (same place you have other API methods)
  Future<String?> deleteFacilityDetails({required int facilityId}) async {
    try {
      final payload =
          BaseRequest.baseRequest({"facilityId": facilityId.toString()});

      final AppResponse response =
          await _apiManager.post(APIEndpoints.deleteFacilityItem, payload);

      if (response.status == ResponseStatus.success || response.code == 200) {
        return response.message;
      } else {
        throw response.message;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Security>> getLinkageSecuritySummaryList() async {
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

  Future<List<FacilityCondition>> getFacilityConditionsList(
    FacilityConditionsFilter filter,
  ) async {
    final payload = BaseRequest.baseRequest(filter.toJson());
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getFacilityConditionsList,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw response.message;
    }

    final body = response.body;
    final List<dynamic> rawList = body is List
        ? body
        : (body?['responseData'] as List<dynamic>? ?? const []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => FacilityCondition.fromJson(e))
        .toList();
  }
}
