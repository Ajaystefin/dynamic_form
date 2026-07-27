import "dart:convert";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
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

/// Repository responsible for facility and security-related data
/// operations and API interactions.
class FacilitySecurityRepository {
  /// Creates a [FacilitySecurityRepository] instance.
  ///
  /// If no [apiManager] is provided, a default [APIManager] instance
  /// is used.
  FacilitySecurityRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static final _singleton = FacilitySecurityRepository();

  /// Returns the singleton instance of [FacilitySecurityRepository].
  static FacilitySecurityRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Retrieves the list of available currency codes.
  ///
  /// Returns a list of [Reference] objects where:
  /// - [Reference.name] contains the currency ISO code.
  /// - [Reference.reference4] contains the currency description.
  ///
  /// Returns an empty list if the request fails or the response data is
  /// not in the expected format.
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

  /// Retrieves the dynamic security form definition for the specified
  /// security type and subtype.
  ///
  /// Loads form sections, rows, and fields from the backend service,
  /// applies role-based field access rules, and populates reference-data
  /// dropdowns using the configured operation keys.
  ///
  /// Returns a list of [Section] objects representing the complete
  /// dynamic form structure.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// cannot be processed
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
        //throw Exception(response.message);
        throw ApiException(response.message);
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
            final bool isCmo = Utils.checkRoles([
                  UserRole.documentationChecker,
                  UserRole.documentationMaker,
                  UserRole.ccuChecker,
                  UserRole.ccuMaker,
                ]) &&
                ScreenAccessConditions.isAssignedToCurrentUser();
            if (isCmo && field.isCMOUpdate) {
              field.isDisable = false;
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
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Retrieves the security summary list for the current application.
  ///
  /// Returns a list of [Security] records containing the security
  /// details associated with the application, group, and customer.
  ///
  /// Throws an [ApiException] if the request fails or the service
  /// returns an error response.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves security details for the current application.
  ///
  /// Transforms dynamic form data, including grid field values, into the
  /// required request format before persisting the security information.
  /// Returns the saved [Security] object from the backend response.
  ///
  /// Throws an [ApiException] if the save operation fails.
  Future<Security?> saveSecurityDetails(
    Security? security,
    List<Section> sections,
    String? securityCode,
  ) async {
    // Transform grid data before creating request
    if (security?.dynamicFormDocument != null) {
      security!
        ..dynamicFormDocument = _seedDocumentWithNullKeys(
          security.dynamicFormDocument!,
          sections,
        )
        ..dynamicFormDocument = _transformGridDataForSerialization(
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Transforms flattened grid field values into nested row collections
  /// for API serialization.
  ///
  /// Converts keys in the format `gridKey.columnKey@rowIndex` into
  /// structured lists of row objects and removes the original flattened
  /// entries from the document payload.
  ///
  /// Also processes grid data that is not defined in the current form
  /// metadata to ensure all grid values are serialized correctly.
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
          // if (field.controlType == FieldType.grid) {
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
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

    // Second pass: convert any remaining gridKey.colKey@rowIndex keys that were
    // not covered by sections metadata (grids from other form contexts stored in
    // the same document, e.g. profitGrid / lcCommission on an LG facility form).
    final gridQualifiedPattern2 = RegExp(r"^(.+)\.(.+)@(\d+)$");
    final Map<String, Map<int, Map<String, dynamic>>> orphanGrids = {};
    final List<String> orphanKeysToRemove = [];

    transformed.forEach((docKey, value) {
      final match = gridQualifiedPattern2.firstMatch(docKey);
      if (match != null) {
        final String orphanGridKey = match.group(1)!;
        final String orphanColKey = match.group(2)!;
        final int rowIndex = int.parse(match.group(3)!);
        orphanGrids.putIfAbsent(orphanGridKey, () => {});
        orphanGrids[orphanGridKey]!.putIfAbsent(rowIndex, () => {});
        orphanGrids[orphanGridKey]![rowIndex]![orphanColKey] = value;
        orphanKeysToRemove.add(docKey);
      }
    });

    for (final String key in orphanKeysToRemove) {
      transformed.remove(key);
    }
    for (final MapEntry<String, Map<int, Map<String, dynamic>>> entry
        in orphanGrids.entries) {
      final List<int> sorted = entry.value.keys.toList()..sort();
      transformed[entry.key] = sorted.map((i) => entry.value[i]!).toList();
    }

    return transformed;
  }

  /// Ensures all form fields exist in the document payload before
  /// serialization.
  ///
  /// Adds missing field keys with default or null-equivalent values based
  /// on their control type. Existing values are preserved and never
  /// overwritten.
  ///
  /// Grid and table fields are processed separately by seeding their
  /// individual cell values rather than adding a top-level field entry.
  Map<String, dynamic> _seedDocumentWithNullKeys(
    Map<String, dynamic> document,
    List<Section> sections,
  ) {
    for (final Section section in sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
          // Skip layout-only field types that carry no backend data
          if (field.controlType == FieldType.sizedBox ||
              field.controlType == FieldType.label) {
            continue;
          }

          // Grid/table fields use qualified flattened keys per cell —
          // seed each cell individually rather than at the top-level key.
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
            _seedGridCells(document, field);
            continue;
          }

          // Never overwrite a key that already has a value
          if (document.containsKey(field.key)) {
            continue;
          }

          document[field.key] = _emptyCellValue(field.controlType);
        }
      }
    }
    return document;
  }

  /// Ensures that all grid cells exist in the document payload before
  /// serialization.
  ///
  /// Creates missing grid cell entries using default values based on the
  /// corresponding column field type. If no rows exist, an initial row
  /// is created to ensure the grid structure is preserved.
  ///
  /// Existing cell values are not overwritten.
  void _seedGridCells(Map<String, dynamic> document, DynamicField field) {
    final List<DynamicGridField> columns = field.columnInfoList ?? [];
    if (columns.isEmpty) {
      return;
    }

    // Find the highest existing row index for this grid in the document.
    int maxRowIndex = -1;
    for (final String docKey in document.keys) {
      for (final DynamicGridField col in columns) {
        final String prefix = "${field.key}.${col.dynamicField.key}@";
        if (docKey.startsWith(prefix)) {
          final int? idx = int.tryParse(docKey.substring(prefix.length));
          if (idx != null && idx > maxRowIndex) {
            maxRowIndex = idx;
          }
        }
      }
    }

    // Grid always shows at least 1 row; seed row 0 when none exist yet.
    final int rowCount = maxRowIndex >= 0 ? maxRowIndex + 1 : 1;

    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      for (final DynamicGridField col in columns) {
        final String cellKey = "${field.key}.${col.dynamicField.key}@$rowIndex";
        if (!document.containsKey(cellKey)) {
          document[cellKey] = _emptyCellValue(col.dynamicField.controlType);
        }
      }
    }
  }

  /// Returns the default empty value for the specified field type.
  ///
  /// Used when seeding document fields to ensure all expected keys are
  /// present in the payload before serialization. The returned value
  /// matches the structure required by each supported [FieldType].
  dynamic _emptyCellValue(FieldType? type) {
    switch (type) {
      case FieldType.currency:
        return <String, dynamic>{
          "fromCurrency": null,
          "fromVal": null,
          "aedEquivalent": null,
        };
      case FieldType.tenorControl:
        return <String, dynamic>{"tenorUnit": null, "tenorValue": null};
      case FieldType.datePicker:
        return <String, dynamic>{
          "date": null,
          "jsdate": null,
          "formatted": null,
          "epoc": null,
        };
      case FieldType.singleCheckBox:
        return false;
      case FieldType.multiSelect:
      case FieldType.checkbox:
        return <dynamic>[];
      default:
        return null;
    }
  }

  /// Removes index-based keys from nested additional details data.
  ///
  /// Handles both supported formats:
  /// - A wrapper containing an `additionalDetails` JSON string.
  /// - A direct additional details map.
  ///
  /// Returns a cleaned map with index values removed from the nested
  /// dynamic details structure.
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
      } on Object catch (_) {}
    }
    return _removeIndexFromInnerDynamicDetails(updated);
  }

  /// Removes technical index fields from nested dynamic details data.
  ///
  /// Cleans grid- and commission-related collections before persistence
  /// by removing non-business fields used only for UI rendering or row
  /// tracking. The resulting map contains only the data required by the
  /// backend service.
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
          profitGrid[rowIndex] = Map<String, dynamic>.from(row)
            ..remove("index");
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
            // if (rowMap.containsKey("indexLcLGCommision")) {
            //   rowMap["indexLcLGCommision"] = null;
            // }
            // DO NOT override value - preserve user selection
            // Only remove "index" type technical fields if needed

            commissionRows[rowIndex] = rowMap;
          }
        }
        cleaned[commissionKey] = commissionRows;
      }
    }

    return cleaned;
  }

  /// Parses and flattens additional details data into a key-value map.
  ///
  /// Supports both JSON string and map inputs. Grid-based data structures
  /// (lists of maps) are flattened using the format
  /// `gridName.fieldKey@rowIndex`, while multi-select values and other
  /// primitive lists are preserved in their original form.
  ///
  /// Returns an empty map if the input is null, invalid, or cannot be
  /// parsed.
  static Map<String, dynamic> parseAndFlattenAdditionalDetails(
    Object? additionalDetails,
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
    } on Object catch (e) {
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
                // BEGIN: Handle legacy application data where tenorUnit values may be
                // stored as 'plus'/'minus' instead of '+'/'-'.
                // Normalize values during parsing as follows:
                //   plus  -> +
                //   minus -> -
                //   +     -> +
                //   -     -> -
                // This ensures a consistent format is used across the UI.
                if (columnKey == "margin" &&
                    columnValue is Map<String, dynamic>) {
                  final normalizedMargin =
                      Map<String, dynamic>.from(columnValue);

                  final unit = normalizedMargin["tenorUnit"]
                      ?.toString()
                      .trim()
                      .toLowerCase();

                  normalizedMargin["tenorUnit"] = switch (unit) {
                    "plus" || "+" => "+",
                    "minus" || "-" => "-",
                    _ => normalizedMargin["tenorUnit"],
                  };

                  columnValue = normalizedMargin;
                }
                // END
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

  /// Retrieves the dynamic facility form configuration for the specified
  /// facility type and subtype.
  ///
  /// Loads facility form sections from the backend, applies runtime
  /// business rules, configures field behavior, populates dropdown
  /// options, and resolves reference-data values required by the form.
  ///
  /// Returns a list of [Section] objects representing the fully
  /// configured facility form.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// cannot be processed.
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
              field
                ..inputFormatterPattern = r"^[A-Za-z0-9 ]*$"
                ..defaultValue = "NA";
            }

            final int? shortTermLoanId =
                ServerConstants.facilityTypeId[FacilityType.shortTermLoan];

            if (field.key == "maximumTenor" && subTypeID == shortTermLoanId) {
              field.enableLimiterValidation = true;
            }

            final int? termLoanCommercialId =
                ServerConstants.facilityTypeId[FacilityType.termLoanCommercial];

            if (field.key == "maximumTenor" &&
                subTypeID == termLoanCommercialId) {
              field.inputFormatterPattern = r"^[0-9]*$";
            }

            // facility_security_repository.dart → inside the sections/rows/fields loop
            if (field.controlType == FieldType.table &&
                field.key == "preferentialExchangeRate") {
              // Table-level
              field
                ..isMandatory = false // force optional at runtime
                ..required = false // defensive: some code paths read 'required'
                ..message = null; // avoid “mandatory” text from JSON

              // Column-level
              for (final col in field.columnInfoList ?? []) {
                final df = col.dynamicField;
                if (df.key == "exchangeRateCurrency" ||
                    df.key == "percentage") {
                  df
                    ..isMandatory = false
                    ..required = false
                    ..message = null; // no column-level mandatory message
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
                  (Globals.dynamicFormCurrencyCodes ?? [])
                    ..add(
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
                filtered.length,
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
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Saves facility details for the current application.
  ///
  /// Persists the provided [Facility] information and returns the API
  /// response message when the operation completes successfully.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Deletes the specified security record.
  ///
  /// Sends a request to remove the security identified by [securityId]
  /// and returns the API response message when the operation succeeds.
  ///
  /// Throws an [ApiException] if the delete operation fails.
  Future<String?> deleteSecurityDetails(int? securityId) async {
    final Map<String, dynamic> data =
        BaseRequest.baseRequest({"securityId": securityId});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteSecurityDetails, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      // throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Saves a facility sub-limit for the current application.
  ///
  /// Creates or updates a facility sub-limit using the specified
  /// customer, limit description, and limit category information.
  /// Returns the API response message when the operation succeeds.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the list of controlling limit numbers for the current
  /// application.
  ///
  /// Returns a list of [Reference] objects containing available
  /// controlling limit numbers associated with the customer and group.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Reference>> getControllingLimitNoData() async {
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      "rimNo": Globals.request?.customerRimNo,
      "groupId": Globals.request?.groupId,
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getControllingLimitNoData, data);
    if (response.status == ResponseStatus.error) {
      // throw Exception(response.message);
      throw ApiException(response.message);
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves the list of standard conditions from the backend service.
  ///
  /// Returns a list of [StandardCondition] objects parsed from the API
  /// response.
  ///
  /// Throws an [ApiException] if the request fails or the response
  /// cannot be processed.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }

      // Parse the response
      final List<dynamic> responses =
          response.body["responseData"]["standardConditions"];

      // Convert to model list
      return responses.map((item) => StandardCondition.fromJson(item)).toList();
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///------------------------------ dev apis integration ------------------------------de

  /// Retrieves the facility summary list for the current application.
  ///
  /// Returns a list of [FacilitySummaryList] objects grouped by customer
  /// RIM or group owner, depending on the application type.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<FacilitySummaryList>> getFacilitySummaryList() async {
    final bool isGroupOwner = Utils.isGroupApplication();

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

  /// Retrieves the list of projects associated with the specified search
  /// criteria.
  ///
  /// Returns a [ProjectListResponse] containing the available projects
  /// for the provided limit group and customer RIM details.
  ///
  /// Throws a [StateError] if the response body is empty. Returns an
  /// empty [ProjectListResponse] when the request is unsuccessful.
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
      if (body == null) {
        throw StateError("Empty body");
      }
      return ProjectListResponse.fromMap(body);
    } else {
      AlertManager().showFailureToast(response.message);
      return ProjectListResponse([]);
    }
  }

  /// Retrieves limits and facilities associated with the specified
  /// customer RIM number.
  ///
  /// Returns a list of [LimitsResponse] objects parsed from the backend
  /// response. If the request fails, an empty list is returned after
  /// displaying an error notification.
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

  /// Saves facility details, borrower mappings, fee rates, conditions,
  /// and additional dynamic form data for the current application.
  ///
  /// Performs the required preprocessing of dynamic form fields,
  /// including seeding missing values, transforming grid data for
  /// serialization, and removing UI-specific index fields before
  /// submitting the request.
  ///
  /// Returns a [LimitsFacilityResponse] containing the saved facility
  /// details returned by the backend service.
  ///
  /// Throws an [ApiException] if the save operation fails.
  Future<LimitsFacilityResponse> saveFacilityDetailsNew({
    required FacilityDetails facilityDetails,
    FacilityBorrowerMap? facilityBorrowerMap,
    List<FeeRate> defacultFeeRates = const [],
    List<Section> sections = const [],
    List<Condition> condition = const [],
    List<Map<String, dynamic>> facilitySubLimits = const [],
  }) async {
    // Ensure additionalDetails is initialized
    facilityDetails.additionalDetails ??= {};

    facilityDetails
      ..additionalDetails = _seedDocumentWithNullKeys(
        facilityDetails.additionalDetails!,
        sections,
      )
      ..additionalDetails = _transformGridDataForSerialization(
        facilityDetails.additionalDetails!,
        sections,
      );

    final String cleanedIndex = (facilityDetails.index ?? "").trim();
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final body = response.body;
    final Map<String, dynamic> raw = body is Map
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};

    return LimitsFacilityResponse.fromJson(raw);
  }

  /// Saves facility details for a single borrower configuration.
  ///
  /// Submits facility information without borrower mappings, fee rates,
  /// conditions, or sub-limit details and returns the saved facility
  /// response from the backend service.
  ///
  /// Returns a [LimitsFacilityResponse] containing the persisted facility
  /// data.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final body = response.body;
    final Map<String, dynamic> raw = body is Map
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  /// Saves project-related facility details for the current application.
  ///
  /// Submits project facility information and returns the saved facility
  /// response received from the backend service.
  ///
  /// Returns a [LimitsFacilityResponse] containing the persisted project
  /// facility data.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final body = response.body;
    final Map<String, dynamic> raw = body is Map
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  /// Saves facility details for a group borrower configuration.
  ///
  /// Submits facility information together with borrower mapping details
  /// for a group borrower and returns the saved facility response from
  /// the backend service.
  ///
  /// Returns a [LimitsFacilityResponse] containing the persisted facility
  /// data.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
    final body = response.body;
    final Map<String, dynamic> raw = body is Map
        ? (body["responseData"] as Map<String, dynamic>? ?? const {})
        : const {};
    return LimitsFacilityResponse.fromJson(raw);
  }

  /// Retrieves exchange rate information for the specified currency.
  ///
  /// Returns a [CurrencyRates] object containing the exchange rate data
  /// associated with the selected currency. If no exchange rate data is
  /// available, an empty [CurrencyRates] model is returned.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<CurrencyRates> getCurrencyRates(Reference? selectedCurrency) async {
    final payload =
        BaseRequest.baseRequest({"isoCode": selectedCurrency?.name});

    final res = await _apiManager.post(APIEndpoints.getExchangeRate, payload);

    final Map<String, dynamic> data =
        (res.body?["responseData"] as Map<String, dynamic>?) ?? const {};

    return CurrencyRates.fromJson(data);
  }

  /// Retrieves detailed facility information for the specified facility
  /// and customer.
  ///
  /// Returns a normalized response containing facility details, fee
  /// rates, conditions, borrower mappings, additional details, and
  /// facility sub-limits. Dynamic additional details are parsed and
  /// flattened for form processing, and policy deviation references are
  /// enriched with reference data definitions.
  ///
  /// Returns an empty map when no facility data is available.
  ///
  /// Throws an [Exception] if the request fails or the response cannot
  /// be processed.
  Future<Map<String, dynamic>> getFacilityDetails(
    int? existingFacilityId,
    int? rimNo, {
    int? groupId,
    int? limitCapType,
    int? facilityMasterId,
  }) async {
    final bool isGroup = Utils.isGroupOwnerApplication();
    try {
      final Map<String, dynamic> data =
          BaseRequest.baseRequest(<String, dynamic>{
        "groupOwner": isGroup ? Globals.request?.groupOwner : 0,
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

      // Safely read responseData (may be null or missing)
      final dynamic respnsedata = response.body?["responseData"];
      final Map<String, dynamic> responseData =
          (respnsedata is Map<String, dynamic>)
              ? respnsedata
              : <String, dynamic>{};

      // 1) facilityDetails may be null or empty
      final dynamic mainFacilityDyn = responseData["facilityDetails"];
      final bool hasMainFacility =
          mainFacilityDyn is Map && mainFacilityDyn.isNotEmpty;

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
            (item) => FeeRate.fromJson(
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
            (item) => Condition.fromJson(
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
// for fetch and disply facility sublimits
      final List<dynamic> facilitySubLimits =
          (responseData["facilitySubLimits"] is List)
              ? (responseData["facilitySubLimits"] as List)
              : <dynamic>[];

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
        "facilitySubLimits": facilitySubLimits,
      };
    } on Object catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Retrieves borrower mapping information for the current application.
  ///
  /// Returns a [BorrowersMap] containing borrower relationships and
  /// mapping details associated with the application, group, and
  /// customer.
  ///
  /// Throws an [ApiException] if the request fails and a [StateError]
  /// if the response body is empty.
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
      if (body == null) {
        throw StateError("Empty body");
      }
      return BorrowersMap.fromMap(body);
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves borrowers associated with the current application.
  ///
  /// Returns a list of [Borrower] objects for the current customer or
  /// group owner application context.
  ///
  /// Returns an empty list when no borrower data is available.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Borrower>> getBorrowers() async {
    final bool isGroup = Utils.isGroupApplication();

    final Map<String, dynamic> payload = BaseRequest.baseRequest({
      "appRefNo": Globals.request?.applicationRefNo,
      if (isGroup)
        "groupOwner": Globals.request?.groupOwner
      else
        "rimNo": Globals.request?.customerRimNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getBorrowers, payload);

    if (response.code != 200) {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }

    final dynamic body = response.body;
    final List<dynamic>? list = body?["responseData"] as List<dynamic>?;

    if (list == null) {
      return [];
    }

    return list
        .where((e) => e != null)
        .map((e) => Borrower.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves updates made to the facility summary list.
  ///
  /// Persists the modified [FacilitySummaryNew] records and returns the
  /// API response message when the save operation completes
  /// successfully.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Deletes the specified facility record.
  ///
  /// Sends a request to remove the facility identified by [facilityId]
  /// and returns the API response message when the operation succeeds.
  ///
  /// Throws an [ApiException] if the delete operation fails.
  Future<String?> deleteFacilityDetails({required int facilityId}) async {
    try {
      final payload =
          BaseRequest.baseRequest({"facilityId": facilityId.toString()});

      final AppResponse response =
          await _apiManager.post(APIEndpoints.deleteFacilityItem, payload);

      if (response.status == ResponseStatus.success || response.code == 200) {
        return response.message;
      } else {
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Retrieves the security summary list used for facility-security
  /// linkage operations.
  ///
  /// Returns a list of [Security] records associated with the current
  /// application, customer, and group context.
  ///
  /// Throws an [ApiException] if the request fails.
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
      throw ApiException(response.message);
    }
  }

  /// Retrieves facilities available for facility-security linkage.
  ///
  /// Returns a list of [Facility] objects associated with the current
  /// application, customer, or group owner context.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Facility>> getLinkageFacility() async {
    final bool isGroup = Utils.isGroupApplication();
    final Map<String, dynamic> data = BaseRequest.baseRequest({
      if (isGroup)
        "groupOwner": Globals.request?.groupOwner
      else
        "rimNo": Globals.request?.customerRimNo,
      "appRefNo": Globals.request?.applicationRefNo,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFacilities, json.encode(data));
    if (response.status == ResponseStatus.error) {
      throw ApiException(response.message);
    }
    final List raw = response.body["responseData"] as List;
    return raw
        .map((e) => Facility.fromJsonLinkage(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves facility-security linkage details.
  ///
  /// Associates facilities with the specified security record and
  /// returns the status description from the API response when the
  /// operation succeeds.
  ///
  /// Throws an [ApiException] if the save operation fails.
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
      throw ApiException(response.message);
    }
  }

  /// Retrieves facility conditions based on the specified filter
  /// criteria.
  ///
  /// Returns a list of [FacilityCondition] objects matching the provided
  /// filter settings.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<FacilityCondition>> getFacilityConditionsList(
    FacilityConditionsFilter filter,
  ) async {
    final payload = BaseRequest.baseRequest(filter.toJson());
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getFacilityConditionsList,
      json.encode(payload),
    );

    if (response.status == ResponseStatus.error) {
      throw ApiException(response.message);
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

  /// Deletes the specified facility condition.
  ///
  /// If a valid facility condition identifier is provided, a delete
  /// request is sent to the backend service. Any errors encountered
  /// during the operation are displayed to the user through failure
  /// notifications.

  Future<void> deleteFacilityCondition(int? facilityConditionID) async {
    if (facilityConditionID == null) {
      return;
    }
    final Map<String, dynamic> payLoad = BaseRequest.baseRequest({
      "facilityConditionId": facilityConditionID,
    });
    try {
      final AppResponse response = await _apiManager.post(
        APIEndpoints.deleteFacilityCondition,
        json.encode(payLoad),
      );

      if (response.status == ResponseStatus.error) {
        AlertManager().showFailureToast(response.message);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
