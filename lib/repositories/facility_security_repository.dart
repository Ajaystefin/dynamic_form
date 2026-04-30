import "dart:convert";

import "package:uuid/uuid.dart";

import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/borrower_facility.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_condition_list.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/facility_security/limit_facilities.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

class FacilitySecurityRepository {
  FacilitySecurityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = FacilitySecurityRepository();
  static FacilitySecurityRepository get instance => _singleton;

  final APIManager _apiManager;

  Future<List<Reference>> getcurrencyCode() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCurrencyCode, data);

    if (response.status != ResponseStatus.success) {
      AlertManager().showFailureToast(response.message);

      return <Reference>[]; // Return empty list on error instead of throwing
    }

    final dynamic raw = response.body["responseData"];

    if (raw is! List) {
      return <Reference>[];
    }

    // Map isoCode -> name, description -> reference4
    return raw
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

  Future<List<Section>> getSecurityDynamicForm({
    int? typeID,
    int? subTypeID,
  }) async {
    try {
      final Map<String, dynamic> data =
          BaseRequest.baseRequest({"typeID": typeID, "subTypeID": subTypeID});
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getSecurityDynamicForm,
        json.encode(data),
      );

      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      // List<dynamic> responses = response.body['responseData']['sectionList'];
      // List<dynamic> responses = response.body['responseData']['sectionList'];

      // List<Section> sections =
      //     responses.map((item) => Section.fromJson(item)).toList();

      final dynamic body = response.body;
      final Map<String, dynamic> responseData = (body is Map
              ? body["responseData"] as Map<String, dynamic>?
              : null) ??
          const {};
      final List<dynamic> responses = (responseData["sectionList"] is List)
          ? responseData["sectionList"] as List
          : const [];
      final List<Section> sections = responses
          .whereType<Map<String, dynamic>>()
          .map(Section.fromJson)
          .toList();

      //collect all the operation keys from all DynamicField objects
      final List<String> operationKeys = [];
      for (final Section section in sections) {
        for (final RowElement row in section.rows ?? []) {
          for (final DynamicField field in row.fields ?? []) {
            if (field.operationKey != null) {
              operationKeys.add(field.operationKey!);
            }
            if (Utils.checkRoles([UserRole.creditCommitteeProxy]) &&
                !field.isCMOUpdate) {
              field.isDisable = true;
            }
            if (field.key == "enterNonpanelValuatorName" ||
                field.key == "enterOtherNameOfZone") {
              field.inputFormatterPattern = r"^[a-zA-Z0-9 ]+$";
            }
          }
        }
      }
      // get reference data
      if (operationKeys.isNotEmpty) {
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService().getReferenceData(operationKeys);

        // for all fields where controlType is FieldType.refDataDropdown
        for (final Section section in sections) {
          for (final RowElement row in section.rows ?? []) {
            for (final DynamicField field in row.fields ?? []) {
              if (field.controlType == FieldType.refDataDropdown) {
                if (field.operationKey == ReferenceDataKeys.propertySubType ||
                    field.operationKey ==
                        ReferenceDataKeys.externalRatingAgencyValues) {
                  //Don't fill by default for this dropdown
                  continue;
                }
                // fill dependentList, each Reference should be a Option,
                // metaData should be reference item
                final List<Reference>? references =
                    referenceData[field.operationKey];

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
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getSecuritySummaryList, data);

    final baseResponse = response.body["baseResponse"];
    final status = baseResponse?["status"];
    final statusCode = status?["statusCode"];

    if (response.code == 200 && statusCode == "0") {
      final List<Security> securitySummaryList = [];
      response.message = status?["statusDescription"];

      final List<dynamic>? dataList =
          response.body["responseData"] as List<dynamic>?;

      if (dataList != null) {
        for (final item in dataList) {
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
    final Map<String, dynamic> data = BaseRequest.baseRequest(
      security?.toJson(securityCode),
    );
    final AppResponse response =
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
  /// Input format (grid-qualified): {"gridKey.columnKey@0": value1,
  /// "gridKey.columnKey@1": value2}
  /// Output format: {"gridKey": [{"columnKey": value1}, {"columnKey": value2}]}
  Map<String, dynamic> _transformGridDataForSerialization(
    Map<String, dynamic> document,
    List<Section> sections,
  ) {
    // Step 1: Build grid metadata from sections
    // Map: gridFieldKey -> List of column keys
    final Map<String, List<String>> gridMetadata = {};

    for (final Section section in sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
          if (field.controlType == FieldType.grid) {
            final String gridKey = field.key;
            final List<String> columnKeys = field.columnInfoList
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
    for (final MapEntry<String, List<String>> entry in gridMetadata.entries) {
      final String gridKey = entry.key;
      final List<String> columnKeys = entry.value;

      // Step 3: Extract grid data for this specific grid
      // Match grid-qualified keys: gridKey.columnKey@rowIndex
      final Map<int, Map<String, dynamic>> gridRowData = {};
      final List<String> keysToRemove = <String>[];

      // Pattern: gridKey.columnKey@rowIndex
      final gridQualifiedPattern = RegExp(r"^(.+)\.(.+)@(\d+)$");

      document.forEach((docKey, value) {
        final match = gridQualifiedPattern.firstMatch(docKey);
        if (match != null) {
          final docGridKey = match.group(1)!;
          final docColumnKey = match.group(2)!;
          final rowIndex = int.parse(match.group(3)!);

          // Only process if this key belongs to our current grid
          if (docGridKey == gridKey && columnKeys.contains(docColumnKey)) {
            gridRowData.putIfAbsent(rowIndex, () => {});
            gridRowData[rowIndex]![docColumnKey] = value;
            keysToRemove.add(docKey);
          }
        }
      });

      // Step 4: Convert to array format
      if (gridRowData.isNotEmpty) {
        final List<int> sortedIndices = gridRowData.keys.toList()..sort();
        final List<Map<String, dynamic>> rowsArray =
            sortedIndices.map((index) => gridRowData[index]!).toList();

        // Remove flattened keys
        for (final String key in keysToRemove) {
          transformed.remove(key);
        }

        // Add transformed array
        transformed[gridKey] = rowsArray;
      }
    }

    return transformed;
  }

  Map<String, dynamic> _removeIndexFromNestedAdditionalDetails({
    required Map<String, dynamic> additionalDetailsContainer,
  }) {
    final Map<String, dynamic> updated =
        Map<String, dynamic>.from(additionalDetailsContainer);

    // wrapper shape => { additionalDetails: "<json string>" }
    final dynamic innerRaw = updated["additionalDetails"];
    if (innerRaw is String && innerRaw.trim().isNotEmpty) {
      try {
        final Map<String, dynamic> innerJson =
            jsonDecode(innerRaw) as Map<String, dynamic>;
        final Map<String, dynamic> cleanedInnerJson =
            _removeIndexFromInnerDynamicDetails(innerJson);
        updated["additionalDetails"] = jsonEncode(cleanedInnerJson);
        return updated;
      } catch (_) {}
    }
    return _removeIndexFromInnerDynamicDetails(updated);
  }

  Map<String, dynamic> _removeIndexFromInnerDynamicDetails(
    Map<String, dynamic> innerJson,
  ) {
    final Map<String, dynamic> cleaned = Map<String, dynamic>.from(innerJson);

    // Remove from profitGrid[*].index (if present)
    final dynamic profitGrid = cleaned["profitGrid"];
    if (profitGrid is List) {
      for (int rowIndex = 0; rowIndex < profitGrid.length; rowIndex++) {
        final dynamic row = profitGrid[rowIndex];
        if (row is Map) {
          final Map<String, dynamic> rowMap = Map<String, dynamic>.from(row);
          rowMap.remove("index");
          profitGrid[rowIndex] = rowMap;
        }
      }
      cleaned["profitGrid"] = profitGrid;
    }

    // Remove from commission blocks: lcCommission / avCommission / lgCommission
    const List<String> commissionKeys = <String>[
      "lcCommission",
      "avCommission",
      "lgCommission",
    ];

    for (final String commissionKey in commissionKeys) {
      final dynamic commissionRows = cleaned[commissionKey];
      if (commissionRows is List) {
        for (int rowIndex = 0; rowIndex < commissionRows.length; rowIndex++) {
          final dynamic row = commissionRows[rowIndex];
          if (row is Map) {
            final Map<String, dynamic> rowMap = Map<String, dynamic>.from(row);
            if (rowMap.containsKey("indexLcLGCommision")) {
              rowMap["indexLcLGCommision"] = null;
            }

            commissionRows[rowIndex] = rowMap;
          }
        }
        cleaned[commissionKey] = commissionRows;
      }
    }

    return cleaned;
  }

  /// Parses and flattens additionalDetails JSON for dynamic form prefill
  ///
  /// This method transforms the backend format (with grid arrays) into the
  /// grid-qualified flattened key format required by the DynamicForm component.
  /// Multiselect arrays (arrays of primitives) are preserved as-is.
  ///
  /// Input format: {"gridKey": [{"col": "val1"}, {"col": "val2"}], "simpleKey":
  /// "value", "multiSelect": ["opt1", "opt2"]}
  /// Output format: {"gridKey.col@0": "val1", "gridKey.col@1": "val2",
  /// "simpleKey": "value", "multiSelect": ["opt1", "opt2"]}
  ///
  /// The grid-qualified format (gridKey.fieldKey@index) ensures unique keys
  /// when
  /// the same field name exists in multiple grids.
  static Map<String, dynamic> parseAndFlattenAdditionalDetails(
    dynamic additionalDetails,
  ) {
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
      logger.w("Failed to parse additionalDetails: $e");
      return {};
    }

    final flattened = <String, dynamic>{};

    // Step 2: Iterate over all keys and flatten grids (but preserve multiselect
    // arrays)
    parsed.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        // Check if this is a grid field (array of maps) or multiselect field
        // (array of primitives)
        final firstElement = value.first;

        if (firstElement is Map<String, dynamic>) {
          // This is a GRID field - flatten it with grid-qualified keys
          final String gridKey = key;
          for (int rowIndex = 0; rowIndex < value.length; rowIndex++) {
            final row = value[rowIndex];
            if (row is Map<String, dynamic>) {
              // Flatten each column in this row with grid-qualified key format
              row.forEach((columnKey, columnValue) {
                // Format: gridName.fieldKey@rowIndex
                final flattenedKey = "$gridKey.$columnKey@$rowIndex";
                flattened[flattenedKey] = columnValue;
              });
            }
          }
        } else {
          // This is a MULTISELECT field (or other array of primitives) -
          // preserve as-is
          flattened[key] = value;
        }
      } else {
        // Simple field - add directly
        flattened[key] = value;
      }
    });

    return flattened;
  }

  Future<List<Section>> getFacilitiesDynamicForm({
    int? typeID,
    int? subTypeID,
    List<String>? commitmentAccountNumbers,
  }) async {
    try {
      final Map<String, dynamic> data =
          BaseRequest.baseRequest({"typeID": typeID, "subTypeID": subTypeID});
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getSecurityDynamicForm,
        json.encode(data),
      );

      if (response.status == ResponseStatus.error) {
        AlertManager().showFailureToast(response.message);
        return [];
      }

      final dynamic body = response.body;
      final Map<String, dynamic> responseData = (body is Map
              ? body["responseData"] as Map<String, dynamic>?
              : null) ??
          const {};

      final dynamic rawList = responseData["sectionList"];
      final List<dynamic> sectionList = (rawList is List) ? rawList : const [];

      final List<Section> sections = <Section>[];
      for (final item in sectionList) {
        if (item is Map<String, dynamic>) {
          sections.add(Section.fromJson(item));
        }
      }

      for (final Section section in sections) {
        for (final RowElement row in section.rows ?? []) {
          for (final DynamicField field in row.fields ?? []) {
            if (field.key == "creditInsuranceCompanyName") {
              // Use * (not +) so users can clear the field while typing
              field.inputFormatterPattern = r"^[A-Za-z0-9 ]*$";
              field.defaultValue = "NA";
            }

            // facility_security_repository.dart → inside the sections/rows/fields loop
            if (field.controlType == FieldType.table &&
                field.key == "preferentialExchangeRate") {
              // Table-level
              field.isMandatory = false; // force optional at runtime
              field.required =
                  false; // defensive: some code paths read 'required'
              field.message = null; // avoid “mandatory” text from JSON

              // Column-level
              for (final col in field.columnInfoList ?? []) {
                final df = col.dynamicField;
                if (df.key == "exchangeRateCurrency" ||
                    df.key == "percentage") {
                  df.isMandatory = false;
                  df.required = false;
                  df.message = null; // no column-level mandatory message
                }
              }
            }

            // Apply business logic: disable currency dropdown for excessAmount
            // field
            if (field.key == "excessAmount" &&
                field.controlType == FieldType.currency) {
              field.disableDropdown = true;
            } else if (field.key == "acceptableInvoiceCurrencies") {
              // Create options from currency codes
              // final currencyOptions = (Globals.dynamicFormCurrencyCodes ??
              // [])
              //     .map((option) => Option(
              //           key: option.key,
              //           pairValue: option
              //               .key, // Use currency code as both key and pairValue
              //         ))
              //     .toList();
              final List<Option> currencyOptions =
                  Globals.dynamicFormCurrencyCodes ?? [];

              // Add "Other" option at the end
              currencyOptions.add(
                Option(
                  key: "Other",
                  pairValue: "Other",
                ),
              );

              field.optionList = currencyOptions;
              logger.i(
                "Populated acceptableInvoiceCurrencies "
                "with ${currencyOptions.length} options",
              );
            }
            //if grid, loop fields inside it
            else if (field.controlType == FieldType.grid) {
              for (final DynamicGridField gridField
                  in field.columnInfoList ?? []) {
                if (gridField.dynamicField.key == "from" ||
                    gridField.dynamicField.key == "to") {
                  gridField.dynamicField.controlType =
                      FieldType.editableDropdown;
                  gridField.dynamicField.optionList = List.generate(
                    100,
                    (index) => Option(
                      key: (index + 1).toString(),
                      pairValue: (index + 1).toString(),
                    ),
                  );
                }
              }
            } else if (field.key == "linkedAccountNumber" ||
                field.key == "settlementAccountNo") {
              final List<String> filtered = (commitmentAccountNumbers ?? [])
                  .where(
                    (String s) =>
                        s.startsWith("400") ||
                        s.startsWith("100") ||
                        s.toLowerCase() == "new",
                    // as per the requirment only numbsers
                    // starting with 100 or 400 should display
                  )
                  .toList();
              field.optionList = List.generate(
                (filtered).length,
                (index) => Option(
                  key: filtered[index],
                  pairValue: filtered[index],
                ),
              );
            }
          }
        }
      }

      //collect all the operation keys from all DynamicField objects
      final List<String> operationKeys = [];
      for (final Section section in sections) {
        for (final RowElement row in section.rows ?? []) {
          for (final DynamicField field in row.fields ?? []) {
            if (field.operationKey != null) {
              operationKeys.add(field.operationKey!);
            }
            if (field.controlType == FieldType.grid) {
              for (final DynamicGridField gridField
                  in field.columnInfoList ?? []) {
                if (gridField.dynamicField.operationKey != null) {
                  operationKeys.add(gridField.dynamicField.operationKey!);
                }
              }
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
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService().getReferenceData(operationKeys);

        // for all fields where controlType is FieldType.refDataDropdown
        for (final Section section in sections) {
          for (final RowElement row in section.rows ?? []) {
            for (final DynamicField field in row.fields ?? []) {
              if (field.controlType == FieldType.refDataDropdown) {
                if (field.operationKey == ReferenceDataKeys.propertySubType ||
                    field.operationKey ==
                        ReferenceDataKeys.externalRatingAgencyValues) {
                  //Don't fill by default for this dropdown
                  continue;
                }
                // fill dependentList, each Reference should be a Option,
                // metaData should be reference item
                final List<Reference>? references =
                    referenceData[field.operationKey];

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
              if (field.controlType == FieldType.grid) {
                for (final DynamicGridField gridField
                    in field.columnInfoList ?? []) {
                  if (gridField.dynamicField.controlType ==
                      FieldType.refDataDropdown) {
                    final List<Reference>? references =
                        referenceData[gridField.dynamicField.operationKey];

                    gridField.dynamicField.optionList = references
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
        }
      }

      return sections;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> saveFacilitiesDetails({required Facility? facility}) async {
    final Map data = {
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
      "requestData": facility?.toJson(),
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilitiesDetails, data);

    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteSecurityDetails(int? securityId) async {
    final Map<String, dynamic> data =
        BaseRequest.baseRequest({"securityId": securityId});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteSecurityDetails, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> saveFacilitySubLimit({
    int? rimNo,
    int? limitDescriptionID,
    String? limitCategory,
  }) async {
    final Map<String, dynamic> data = {
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
        "limitDescription": limitDescriptionID,
      },
    };

    final AppResponse response =
        await _apiManager.post(APIEndpoints.saveFacilitySubLimit, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<List<Reference>> getControllingLimitNoData() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getControllingLimitNoData, data);
    if (response.status == ResponseStatus.error) {
      throw response.message;
    }
    if (response.status == ResponseStatus.success) {
      final List<Reference> controllingLimitNumbers = [];

      for (final dynamic item in response.body["responseData"] as List) {
        final dynamic controllingLimitNo = item["controllingLimitNo"];
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
      final Map<String, dynamic> data = BaseRequest.baseRequest({});

      // Make the API call
      final AppResponse response = await _apiManager.post(
        APIEndpoints.getStandardConditions,
        json.encode(data),
      );

      // Handle error response
      if (response.status == ResponseStatus.error) {
        throw response.message;
      }

      // Parse the response
      final List<dynamic> responses =
          response.body["responseData"]["standardConditions"];

      // Convert to model list
      return responses.map((item) => StandardCondition.fromJson(item)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  ///-------------------------------//dev apis integration-------------------------
  Future<List<FacilitySummaryList>> getFacilitySummaryList() async {
    final bool isGroupOwner = Utils.isGroupOwnerApplication();

    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      if (isGroupOwner)
        "groupOwner": Globals.request?.groupOwner
      else
        "rimNo": Globals.request?.customerRimNo,
    });

    final AppResponse res = await _apiManager.post(
      APIEndpoints.getFacilitySummaryListPerRim,
      payload,
    );

    final List<dynamic> items =
        (res.body?["responseData"] as List?) ?? const [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => FacilitySummaryList.fromJson({
            "rims": [m],
          }),
        )
        .toList();
  }

  Future<ProjectListResponse> getProjectList({
    int? typeID,
    int? serialNumber,
    int? limitGroup,
    int? rimNo,
  }) async {
    final payload = BaseRequest.baseRequest({
      if (limitGroup != null) "limitGroup": limitGroup, // NEW
      if (rimNo != null) "rimNo": rimNo, // NE
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getProjectList, payload);

    if (response.status == ResponseStatus.success) {
      final body = response.body as Map<String, dynamic>?;
      if (body == null) throw StateError("Empty body");
      return ProjectListResponse.fromMap(body);
    } else {
      AlertManager().showFailureToast(response.message);
      return const ProjectListResponse([]);
    }
  }

  Future<List<LimitsResponse>> getLimitsandFacilities(int? rimNo) async {
    final payload = BaseRequest.baseRequest({"rimNo": rimNo});

    final AppResponse response = await _apiManager.post(
      APIEndpoints.getLimitsandFacilities,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      AlertManager().showFailureToast(response.message);
      return <LimitsResponse>[];
    }

    final body = response.body;
    final List<dynamic> rawList =
        body is List ? body : (body?["responseData"] as List<dynamic>? ?? []);

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
    List<Condition> condition = const [],
    List<Map<String, dynamic>> facilitySubLimits = const [],
  }) async {
    // Transform grid data before creating request (same pattern as
    // saveSecurityDetails)
    if (facilityDetails.additionalDetails != null &&
        facilityDetails.additionalDetails!.isNotEmpty) {
      facilityDetails.additionalDetails = _transformGridDataForSerialization(
        facilityDetails.additionalDetails!,
        sections,
      );
    }

    final String cleanedIndex = (facilityDetails.index ?? "").toString().trim();
    if (cleanedIndex.isEmpty && facilityDetails.additionalDetails != null) {
      facilityDetails.additionalDetails =
          _removeIndexFromNestedAdditionalDetails(
        additionalDetailsContainer: facilityDetails.additionalDetails!,
      );
    }

    final payload = BaseRequest.baseRequest({
      "facilityDetails": facilityDetails.toJson(),
      if (facilityBorrowerMap != null)
        "facilityBorrowerMap": facilityBorrowerMap.toJson(),
      "defacultFeeRates": defacultFeeRates.map((e) => e.toJson()).toList(),
      "conditions": condition.map((e) => e.toJson()).toList(),
      "additionalDetails": {
        "additionalDetails": facilityDetails.additionalDetails != null
            ? jsonEncode(facilityDetails.additionalDetails)
            : null,
        "remarks": facilityDetails.remarks,
        "facilitySecurityDetailId": facilityDetails.facilitySecurityDetailId,
        "type": facilityDetails.type,
        "facilitySecurityId": facilityDetails.facilitySecurityId,
      },
      if (facilitySubLimits.isNotEmpty) "facilitySubLimits": facilitySubLimits,
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
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};

    return LimitsFacilityResponse.fromJson(raw);
  }

  Future<LimitsFacilityResponse> saveFacilityDetailsNewSingleBorrower({
    required FacilityDetails facilityDetails,
  }) async {
    final payload = BaseRequest.baseRequest({
      "facilityDetails": facilityDetails.toSingleBorrowerJson(), // NEW
      "facilityBorrowerMap": <String, dynamic>{}, // empty object
      "defacultFeeRates": const [], // empty array
      "conditions": const [], // explicit empty
      "facilitySubLimits": const [], // explicit empty
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
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  Future<LimitsFacilityResponse> saveFacilityProject({
    required FacilityDetails facilityDetails,
  }) async {
    final payload = BaseRequest.baseRequest({
      "facilityDetails": facilityDetails.toSaveProjectJson(),
      "facilityBorrowerMap": <String, dynamic>{}, // empty object
      "defacultFeeRates": const [], // empty array
      "conditions": const [], // explicit empty
      "facilitySubLimits": const [], // explicit empty
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
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  Future<LimitsFacilityResponse> saveFacilityDetailsNewGroupBorrower({
    required FacilityDetails facilityDetails,
    required FacilityBorrowerMap facilityBorrowerMap,
  }) async {
    final payload = BaseRequest.baseRequest({
      "facilityDetails": facilityDetails.toGroupBorrowerJson(), // NEW
      "facilityBorrowerMap": facilityBorrowerMap.toCompanyBorrowerJson(), // NEW
      "conditions": const [],
      "defacultFeeRates": const [],
      "facilitySubLimits": const [],
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
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  Future<CurrencyRates> getCurrencyRates(Reference? selectedCurrency) async {
    final payload =
        BaseRequest.baseRequest({"isoCode": selectedCurrency?.name});

    final res = await _apiManager.post(APIEndpoints.getExchangeRate, payload);

    final Map<String, dynamic> data =
        (res.body?["responseData"] as Map<String, dynamic>?) ?? const {};

    return CurrencyRates.fromJson(data);
  }

  Future<Map<String, dynamic>> getFacilityDetails(
    int? existingFacilityId,
    int? rimNo, {
    int? groupId,
    int? limitCapType,
    int? facilityMasterId,
  }) async {
    final bool isGroupOwner = Utils.isGroupOwnerApplication();
    try {
      final Map<String, dynamic> data =
          BaseRequest.baseRequest(<String, dynamic>{
        "groupOwner": isGroupOwner ? Globals.request?.groupOwner : 0,
        "appRefNo": Globals.request?.applicationRefNo,
        "rimNo": rimNo,
        "facilityId": existingFacilityId,
        "groupId": groupId,
        "limitCapType": limitCapType,
        "facilityMasterId": facilityMasterId,
      });

      final AppResponse response = await _apiManager.post(
        APIEndpoints.getFacilityDetails,
        data,
      );

      if (response.status == ResponseStatus.error) {
        AlertManager().showFailureToast(response.message);
        return {};
      }

      // // Always set message from backend status if present
      // try {
      //   response.message = response.body?["baseResponse"]?["status"]
      //           ?["statusDescription"]
      //       ?.toString();
      // } catch (_) {
      //   // ignore
      // }

      // Safely read responseData (may be null or missing)
      final dynamic respnsedata = response.body?["responseData"];
      final Map<String, dynamic> responseData =
          (respnsedata is Map<String, dynamic>)
              ? respnsedata
              : <String, dynamic>{};

      // 1) facilityDetails may be null or empty
      final dynamic mainFacilityDyn = responseData["facilityDetails"];
      final bool hasMainFacility =
          (mainFacilityDyn is Map && mainFacilityDyn.isNotEmpty);

      final List<FacilityDetail> facilityDetails = <FacilityDetail>[];
      if (hasMainFacility) {
        facilityDetails.add(
          FacilityDetail.fromJson(Map<String, dynamic>.from(mainFacilityDyn)),
        );
      }

      // 2) fee rates list (default to [])
      final List<dynamic> feeRateResponses =
          (responseData["defacultFeeRates"] is List)
              ? (responseData["defacultFeeRates"] as List)
              : const <dynamic>[];
      final List<FeeRate> feeRates = feeRateResponses
          .map(
            (dynamic item) => FeeRate.fromJson(
              (item is Map<String, dynamic>)
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      // 3) conditions list (default to [])
      final List<dynamic> conditionResponses =
          (responseData["conditions"] is List)
              ? (responseData["conditions"] as List)
              : const <dynamic>[];
      final List<Condition> conditions = conditionResponses
          .map(
            (dynamic item) => Condition.fromJson(
              (item is Map<String, dynamic>)
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      // 4) borrower maps (default to empty lists)
      final dynamic fbm = responseData["facilityBorrowerMap"];
      final Map<String, dynamic> fbmMap =
          (fbm is Map<String, dynamic>) ? fbm : <String, dynamic>{};

      final List<dynamic> borrowerListDynamic = (fbmMap["borrowerList"] is List)
          ? fbmMap["borrowerList"] as List
          : const <dynamic>[];
      final List<dynamic> companyBorrowerListDynamic =
          (fbmMap["companyBorrowerList"] is List)
              ? fbmMap["companyBorrowerList"] as List
              : const <dynamic>[];

      // 5) Additional details: Only parse when we have a main facility to
      // attach them to
      if (facilityDetails.isNotEmpty) {
        final dynamic addlContainer = responseData["additionalDetails"];
        final Map<String, dynamic>? addlMap =
            (addlContainer is Map<String, dynamic>) ? addlContainer : null;

        final dynamic addlJsonRaw = addlMap?["additionalDetails"];
        // parseAndFlattenAdditionalDetails should accept Map or JSON string; if
        // null, it should handle gracefully.
        facilityDetails.first.additionalDetails =
            FacilitySecurityRepository.parseAndFlattenAdditionalDetails(
          addlJsonRaw,
        );
        facilityDetails.first.type = addlMap?["type"];
        facilityDetails.first.facilitySecurityDetailId =
            addlMap?["facilitySecurityDetailId"];
        facilityDetails.first.facilitySecurityId =
            addlMap?["facilitySecurityId"];
        facilityDetails.first.remarks = addlMap?["remarks"];
      }

      // 6) Enrich policyDeviation only if we actually have a facility and
      // non-empty policyDeviation
      if (facilityDetails.isNotEmpty &&
          facilityDetails.first.policyDeviation != null &&
          facilityDetails.first.policyDeviation!.isNotEmpty) {
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService().getReferenceData(<String>[
          ReferenceDataKeys.policyDeviation,
        ]);

        final List<Reference> policyDeviationList =
            referenceData[ReferenceDataKeys.policyDeviation] ?? <Reference>[];

        facilityDetails.first.policyDeviation =
            facilityDetails.first.policyDeviation!.map((Reference ref) {
          if (ref.id != null) {
            // Find the full reference data by ID
            return policyDeviationList.firstWhere(
              (Reference fullRef) => fullRef.id == ref.id,
              orElse: () => ref, // Keep original if not found
            );
          }
          return ref;
        }).toList();
      }

      // Final normalized payload, safe for both "data present" and "no data"
      // cases
      return <String, dynamic>{
        "facilityDetails": facilityDetails, // [] when no data
        "feeRates": feeRates, // [] when no data
        "conditions": conditions, // [] when no data
        "companyBorrowerList": companyBorrowerListDynamic, // [] when no data
        "facilityBorrowerMap": <String, dynamic>{
          "borrowerList": borrowerListDynamic, // [] when no data
          "companyBorrowerList": companyBorrowerListDynamic, // [] when no data
        },
      };
    } catch (e) {
      throw e.toString();
    }
  }

  Future<BorrowersMap> getBorrowersMap() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo,
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getBorrowersMap, data);

    if (response.status == ResponseStatus.success) {
      final body = response.body as Map<String, dynamic>?;
      if (body == null) throw StateError("Empty body");
      return BorrowersMap.fromMap(body);
    } else {
      throw response.message;
    }
  }

  Future<List<Borrower>> getBorrowers() async {
    final bool isGroupOwner = Utils.isGroupOwnerApplication();

    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      if (isGroupOwner)
        "groupOwner": Globals.request?.groupOwner
      else
        "rimNo": Globals.request?.customerRimNo,
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
    List<FacilitySummaryNew> edited,
  ) async {
    try {
      final List<Map<String, dynamic>> facilityList =
          edited.map((f) => f.toSaveJson()).toList();

      final Map<String, dynamic> payload = BaseRequest.baseRequest({
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
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      "groupId": Globals.request?.groupId,
      "rimNo": Globals.request?.customerRimNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getSecuritySummaryList, data);
    if (response.status == ResponseStatus.success) {
      final List<Security> securitySummaryList = [];
      for (final dynamic data in response.body["responseData"] as List) {
        securitySummaryList.add(Security.fromJson(data));
      }
      return securitySummaryList;
    } else {
      throw response.message;
    }
  }

  //getFacilitySummaryList api called on facilitySummary Page
  Future<List<Facility>> getLinkageFacility() async {
    final bool isGroupOwner = Utils.isGroupOwnerApplication();
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      if (isGroupOwner)
        "groupOwner": Globals.request?.groupOwner
      else
        "rimNo": Globals.request?.customerRimNo,
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilities, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw Exception(response.message);
    }
    final List raw = response.body["responseData"] as List;
    return raw
        .map((e) => Facility.fromJsonLinkage(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> saveSecurityFacilityLinkage(
    Security? securityItemDetails,
  ) async {
    final Map data = BaseRequest.baseRequest(
      securityItemDetails?.toSaveFacilityLinkageJson(),
    );
    final AppResponse response = await _apiManager.post(
      APIEndpoints.saveFacilitySecurityLinkDetails,
      data,
    );
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

    final dynamic body = response.body;
    final List<dynamic> rawList = body is List
        ? body
        : (body?["responseData"] as List<dynamic>? ?? const []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(FacilityCondition.fromJson)
        .toList();
  }
}
