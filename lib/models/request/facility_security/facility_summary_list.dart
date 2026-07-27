import "dart:convert";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Models used by the Facilities Summary screen.
///
/// These models represent the response returned by the
/// `getFacilitySummaryListPerRim` service and its nested facility
/// hierarchy.
///
/// Response hierarchy:
/// ```text
/// FacilitySummaryList
/// └── rims[]
///     └── groups[]
///         └── facilityLimits[]
///             └── facilityDis
///                 ├── facility
///                 └── additionalDetails
/// ```
///
/// BUSINESS TERMINOLOGY
/// --------------------
/// - RIM (Relationship Information Management) identifies a customer.
/// - A RIM can contain multiple facility groups.
/// - A facility group contains one or more credit facilities/limits.
/// - Each facility stores both core limit information and
///   facility-specific configuration details.
///
/// ADDITIONAL DETAILS STRUCTURE
/// ----------------------------
/// The backend stores facility-specific configuration inside an
/// `additionalDetails` wrapper object.
///
/// The wrapper contains audit and persistence metadata such as:
/// - facilitySecurityDetailId
/// - facilitySecurityId
/// - type
/// - createdBy
/// - createdDate
///
/// The actual business data is stored inside the wrapper's
/// `additionalDetails` property as a JSON-encoded string.
///
/// Example:
/// ```json
/// {
///   "facilitySecurityDetailId": 1,
///   "facilitySecurityId": 10,
///   "additionalDetails": "{...json string...}"
/// }
/// ```
///
/// The inner JSON may contain facility-specific structures such as:
/// - tenor
/// - periodOfFinance
/// - maximumTenor
/// - profitGrid
/// - lcCommission
/// - avCommission
/// - lgCommission
///
/// PARSING STRATEGY
/// ----------------
/// To safely support read/edit/save operations, both representations
/// are preserved:
///
/// - `additionalDetailsContainer`
///   Stores the wrapper exactly as received from the API.
///
/// - `additionalDetailsParsed`
///   Stores the decoded inner JSON object for easy access and updates.
///
/// This allows UI logic to modify only business fields while preserving
/// backend identifiers and audit information.
///
/// SAVE BEHAVIOR
/// -------------
/// During save operations:
///
/// 1. The original wrapper is preserved.
/// 2. The inner JSON string is decoded.
/// 3. Only user-modified fields are updated.
/// 4. The inner JSON is encoded back into a string.
/// 5. The original API payload structure is retained.
///
/// PRESERVED FIELDS
/// ----------------
/// Common editable values extracted from the inner JSON include:
/// - tenorUnit
/// - tenorValue
/// - index
/// - marginSign
/// - marginValue
/// - commission values
///
/// This approach prevents accidental loss of backend-managed fields
/// and supports facility-specific payload variations without requiring
/// schema changes in the client application.

/// Represents the complete facility summary response returned by
/// the facility limits API.
///
/// This is the root container of the facility summary hierarchy.
///
/// Structure:
/// - [rims] → Borrowers/RIMs
///   - [RimSummary.groups] → Limit groups
///     - [RimGroup.facilityLimits] → Facilities
///
/// The model is primarily used to populate facility summary,
/// limit cap, and exposure review screens where facilities are
/// displayed grouped by borrower and limit group.
class FacilitySummaryList {
  /// Creates a [FacilitySummaryList] instance.
  FacilitySummaryList({
    this.rims,
  });

  /// Creates a [FacilitySummaryList] instance from a JSON map.
  ///
  /// Parses all borrower-level summaries returned by the API.
  FacilitySummaryList.fromJson(Map<String, dynamic> json) {
    if (json["rims"] != null) {
      rims = <RimSummary>[];
      for (final v in (json["rims"] as List)) {
        rims!.add(RimSummary.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  /// Collection of borrower/RIM summaries included in the response.
  ///
  /// Each item contains its own facility groups, facility records,
  /// and aggregated exposure totals.
  List<RimSummary>? rims;

  /// Converts this [FacilitySummaryList] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rims != null) {
      data["rims"] = rims!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Represents facility summary information for a specific borrower RIM.
///
/// A RIM summary is the top-level grouping returned by the facility
/// summary API and contains:
/// - Borrower identification information.
/// - Facility groups associated with the borrower.
/// - Overall calculated totals across all facility groups.
///
/// The model supports multiple backend response formats when reading
/// overall totals, as different services may return the totals under
/// different key names or nesting structures.
///
/// The overall totals section contains aggregated figures such as:
/// - Existing limits.
/// - Proposed limits.
/// - Variance calculations.
///
/// These values are used by dashboards, approval summaries,
/// and limit exposure review screens.
class RimSummary {
  /// Creates a [RimSummary] instance.
  RimSummary({
    this.rimName,
    this.rimNo,
    this.groups,
    this.overallTotals,
    this.type,
  });

  /// Creates a [RimSummary] instance from a JSON map.
  RimSummary.fromJson(Map<String, dynamic> json) {
    rimName = json["rimName"];
    rimNo = _asInt(json["rimNo"]);

    if (json["groups"] != null && json["groups"] is List) {
      groups = <RimGroup>[];
      for (final v in (json["groups"] as List)) {
        groups!.add(RimGroup.fromJson(v as Map<String, dynamic>));
      }
    }

    type = customerTypeFromJson(json["rimType"]); // converts safely

    final Map<String, dynamic>? totalObj = json["total"] is Map<String, dynamic>
        ? (json["total"] as Map<String, dynamic>)
        : null;

    final dynamic totals =
        json["overallTotals"] ?? // ideal, if server sends root key
            json["OverallTotal"] ?? // some dumps show this at root
            json["overallTotal"] ?? // case variant
            totalObj?["OverallTotal"] ?? // nested: total.OverallTotal
            totalObj?["overallTotals"] ?? // nested: total.overallTotals
            totalObj?["overallTotal"] ?? // nested: case variant
            json["total OverallTotal"]; // raw key seen in dump

    if (totals is List) {
      overallTotals = <OverallTotalEntry>[];
      for (final v in totals) {
        overallTotals!
            .add(OverallTotalEntry.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  /// Borrower or customer name associated with the RIM.
  String? rimName;

  /// Customer RIM number.
  int? rimNo;

  /// Facility groups belonging to the borrower.
  List<RimGroup>? groups;

  /// Customer type associated with the borrower.
  CustomerType? type;

  /// Aggregated totals across all facility groups.
  List<OverallTotalEntry>? overallTotals;

  /// Converts this [RimSummary] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["rimName"] = rimName;
    data["rimNo"] = rimNo;
    if (groups != null) {
      data["groups"] = groups!.map((v) => v.toJson()).toList();
    }
    if (overallTotals != null) {
      data["overallTotals"] = overallTotals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Represents a limit group within the facility summary response.
///
/// A group contains all facilities that belong to the same logical
/// limit grouping together with their aggregated financial totals.
///
/// The backend typically returns:
/// - Group information ([groupName]).
/// - Facility records belonging to the group ([facilityLimits]).
/// - Calculated summary values ([amounts]).
///
/// The summary values are usually pre-calculated by the backend and
/// include totals such as:
/// - Existing limits.
/// - Proposed limits.
/// - Current outstanding amounts.
///
/// This model acts as the parent container used by the UI to display
/// facilities under a specific group along with their combined figures.
class RimGroup {
  /// Creates a [RimGroup] instance.
  RimGroup({
    this.groupName,
    this.facilityLimits,
    this.amounts,
  });

  /// Creates a [RimGroup] instance from a JSON map.
  RimGroup.fromJson(Map<String, dynamic> json) {
    groupName = json["groupName"];
    if (json["facilityLimits"] != null) {
      facilityLimits = <FacilityDis>[];
      for (final v in (json["facilityLimits"] as List)) {
        facilityLimits!.add(FacilityDis.fromJson(v as Map<String, dynamic>));
      }
    }
    amounts =
        json["amounts"] != null ? GroupAmounts.fromJson(json["amounts"]) : null;
  }

  /// Name of the limit group.
  String? groupName;

  /// Facilities belonging to this group.
  List<FacilityDis>? facilityLimits;

  /// Aggregated financial totals for the group.
  GroupAmounts? amounts;

  /// Converts this [RimGroup] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["groupName"] = groupName;
    if (facilityLimits != null) {
      data["facilityLimits"] = facilityLimits!.map((v) => v.toJson()).toList();
    }
    if (amounts != null) {
      data["amounts"] = amounts!.toJson();
    }
    return data;
  }
}

/// Represents aggregated limit and outstanding figures calculated
/// at the borrower, group, or portfolio level.
///
/// This model is typically used for summary sections where only the
/// overall financial exposure values are required rather than the
/// underlying facility details.
///
/// The amounts include:
/// - Total existing approved limits.
/// - Total proposed limits under assessment.
/// - Total current outstanding utilization.
///
/// All values are optional because summary APIs may omit individual
/// fields depending on the calculation context.
class GroupAmounts {
  /// Creates a [GroupAmounts] instance.
  GroupAmounts({
    this.totalExistingLimit,
    this.totalProposedLimit,
    this.totalCurrentOutstanding,
  });

  /// Creates a [GroupAmounts] instance from a JSON map.
  GroupAmounts.fromJson(Map<String, dynamic> json) {
    totalExistingLimit = _asNum(json["totalExistingLimit"]);
    totalProposedLimit = _asNum(json["totalProposedLimit"]);
    totalCurrentOutstanding = _asNum(json["totalCurrentOutstanding"]);
  }

  /// Total existing sanctioned limit amount.
  num? totalExistingLimit;

  /// Total proposed limit amount.
  num? totalProposedLimit;

  /// Total current outstanding amount.
  num? totalCurrentOutstanding;

  /// Converts this [GroupAmounts] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["totalExistingLimit"] = totalExistingLimit;
    data["totalProposedLimit"] = totalProposedLimit;
    data["totalCurrentOutstanding"] = totalCurrentOutstanding;
    return data;
  }
}

/// Represents a facility distribution row returned by the
/// facility summary/distribution API.
///
/// A row contains:
/// - Facility master information ([facility])
/// - UI initialization values ([facilityInitFields])
/// - Raw additional facility configuration ([additionalDetails])
///
/// API RESPONSE VARIATIONS
/// -----------------------
/// The backend is not fully consistent and may return the row in
/// one of two formats:
///
/// Wrapped:
/// ```json
/// {
///   "facilityDis": {
///     "order": "...",
///     "facility": {...},
///     "additionalDetails": {...}
///   }
/// }
/// ```
///
/// Unwrapped:
/// ```json
/// {
///   "order": "...",
///   "facility": {...},
///   "additionalDetails": {...}
/// }
/// ```
///
/// This model transparently supports both formats by automatically
/// unwrapping the `facilityDis` node when present.
///
/// ADDITIONAL DETAILS PROCESSING
/// -----------------------------
/// The backend stores facility-specific configuration inside the
/// `additionalDetails` payload, where the actual content is often
/// embedded as a JSON string.
///
/// During deserialization this class:
/// - Decodes the nested JSON structure.
/// - Preserves the original wrapper payload for future save operations.
/// - Extracts important UI fields from the decoded structure.
/// - Hydrates facility values that may not exist in top-level fields.
///
/// Extracted values include:
/// - Tenor unit and tenor value.
/// - Index information.
/// - Margin sign and margin value.
/// - Commission-related settings.
///
/// BUSINESS RULES
/// --------------
/// The source of index and margin information depends on the
/// facility limit category.
///
/// For Funded facilities (`limitCategory = "F"`):
/// - `profitGrid` is treated as the primary source.
/// - Commission blocks act only as fallbacks.
/// - Margin values should come from `profitGrid.margin`.
///
/// For Non-Funded facilities (`limitCategory = "N"`):
/// - Commission blocks are treated as the primary source.
/// - `profitGrid` must not override commission values.
/// - Margin values should come from:
///   - `lcCommission`
///   - `avCommission`
///   - `lgCommission`
///
/// This prioritization is required because backend payloads may
/// contain both `profitGrid` and commission structures simultaneously,
/// and selecting the wrong source can result in UI values that differ
/// from the values expected by downstream save APIs.
class FacilityDis {
  /// Creates a [FacilityDis] instance.
  FacilityDis({
    this.order,
    this.facility,
    this.facilityInitFields,
    this.additionalDetails,
  });

  /// Creates a [FacilityDis] instance from a JSON map.
  FacilityDis.fromJson(Map<String, dynamic> json) {
    // Unwrap nested "facilityDis" if present; otherwise use the current map.
    final Map<String, dynamic> src =
        (json["facilityDis"] is Map<String, dynamic>)
            ? (json["facilityDis"] as Map<String, dynamic>)
            : json;

    order = src["order"];
    facilityInitFields = src["facilityInitFields"] != null
        ? FacilityInitFields.fromJson(
            src["facilityInitFields"] as Map<String, dynamic>,
          )
        : null;
    facility = src["facility"] != null
        ? FacilitySummaryNew.fromJson(src["facility"] as Map<String, dynamic>)
        : null;

    final bool isF =
        (facility?.limitCategory ?? "").trim().toUpperCase() == "F";

    final dynamic ad = src["additionalDetails"];
    if (ad != null && facility != null) {
      String? raw;
      if (ad is Map && ad["additionalDetails"] != null) {
        // API sends { additionalDetails: "<json string>" }
        raw = ad["additionalDetails"]?.toString();
      } else if (ad is String) {
        raw = ad;
      }

      Map<String, dynamic>? parsed;
      try {
        if (raw != null && raw.trim().isNotEmpty) {
          parsed = jsonDecode(raw) as Map<String, dynamic>?;
        } else if (ad is Map<String, dynamic>) {
          parsed = ad;
        }
      } on Object catch (_) {
        // swallow decode errors silently to avoid breaking parsing
        parsed = null;
      }

      facility!.additionalDetailsContainer =
          (ad is Map<String, dynamic>) ? Map<String, dynamic>.from(ad) : null;
      facility!.additionalDetailsParsed = parsed;

      if (parsed != null) {
        // 1) Tenor: prefer "tenor", then "periodOfFinance", then "maximumTenor"
        Map<String, dynamic>? tenorBlock;
        for (final k in const ["tenor", "periodOfFinance", "maximumTenor"]) {
          final v = parsed[k];
          if (v is Map<String, dynamic>) {
            tenorBlock = v;
            break;
          }
        }

        // facility_summary_list.dart → FacilityDis.fromJson(...)
        if (tenorBlock != null) {
          final String? unit = tenorBlock["tenorUnit"]?.toString();
          final dynamic value = tenorBlock["tenorValue"];
          final normalizedUnit = normalizeTenorUnit(unit);

          // Prefer additionalDetails tenor over top-level
          if (normalizedUnit.isNotEmpty) {
            facility!.tenorUnit = normalizedUnit;
          }

          final int? parsedVal = (value is num)
              ? value.toInt()
              : (value is String ? int.tryParse(value) : null);
          if (parsedVal != null) {
            facility!.tenorValue = parsedVal; // keep top-level if inner missing
          }
        }

        // 2) Profit grid (keep your existing logic)
        final dynamic grid = parsed["profitGrid"];
        if (grid is List && grid.isNotEmpty && grid.first is Map) {
          final Map first = grid.first as Map;
          final dynamic idx = first["index"];
          if ((facility!.index == null || facility!.index!.isEmpty) &&
              idx != null) {
            facility!.index = idx.toString();
          }
          final dynamic margin = first["margin"];
          if (margin is Map) {
            final String? sign = margin["tenorUnit"]?.toString();
            final dynamic mv = margin["tenorValue"];
            if ((facility!.marginSign == null ||
                    facility!.marginSign!.trim().isEmpty) &&
                sign != null) {
              facility!.marginSign = sign;
            }

            // only take marginValue from profitGrid if this is Funded (F)
            if (isF) {
              facility!.marginValue ??=
                  (mv is num) ? mv : (mv is String ? num.tryParse(mv) : null);
            }
          }
        }

        // if profitGrid not present (or empty) but lcCommission exists,
        // show lcCommission[0].indexLcLGCommision in Index and gridCommission
        // in Margin.

        // 3) Commission blocks: lcCommission / avCommission / lgCommission
        // Use first non-empty list among them
        // ---------------------------
        final List<String> commissionKeys = <String>[
          "lcCommission",
          "avCommission",
          "lgCommission",
        ];

        Map<dynamic, dynamic>? firstCommissionRow;
        for (final String key in commissionKeys) {
          final dynamic arr = parsed[key];
          if (arr is List && arr.isNotEmpty && arr.first is Map) {
            firstCommissionRow = arr.first as Map<dynamic, dynamic>;
            break;
          }
        }

        if (firstCommissionRow != null) {
          // index
          final dynamic idxLc = firstCommissionRow["indexLcLGCommision"];
          if ((facility!.index == null || facility!.index!.isEmpty) &&
              idxLc != null) {
            facility!.index = idxLc.toString(); // e.g., "fixedCommision"
          }

          // marginValue
          //  For N -> ALWAYS prefer commission (override profitGrid value)
          //  For F -> keep existing behavior (only fill if null)
          final dynamic gc = firstCommissionRow["gridCommission"];

          if (gc != null && (!isF || facility?.marginValue == null)) {
            facility!.marginValue =
                (gc is num) ? gc : num.tryParse(gc.toString()); //important fix
            facility!.marginSign ??= "+"; // defensive default
          }
        }
      }
    }
  }

  /// Display order of the facility.
  String? order;

  /// Facility summary details.
  FacilitySummaryNew? facility;

  /// Facility initialization values.
  FacilityInitFields? facilityInitFields;

  /// Additional facility details.
  Map<String, dynamic>? additionalDetails;

  /// Normalizes tenor unit values received from the API.
  ///
  /// Supported values include:
  /// - Days
  /// - Months
  /// - Years
  /// - On Demand
  ///
  /// Returns a title-cased fallback value for unrecognized inputs.
  String normalizeTenorUnit(String? raw) {
    if (raw == null) {
      return "";
    }
    final s = raw.trim().toLowerCase();

    // Collapse spaces/hyphens/underscores
    final compact = s.replaceAll(RegExp(r"[\s\-_]+"), "");

    // Accept many variants from API: names, abbreviations, single/plural
    if (compact == "d" || compact == "day" || compact == "days") {
      return "Days";
    }
    if (compact == "m" || compact == "month" || compact == "months") {
      return "Months";
    }
    if (compact == "y" ||
        compact == "yr" ||
        compact == "year" ||
        compact == "years") {
      return "Years";
    }

    if (compact == "ondemand" ||
        compact == "on_demand" ||
        compact == "on-demand") {
      return "On Demand";
    }

    // Fallback: title-case original string
    return raw.isEmpty ? "" : raw[0].toUpperCase() + raw.substring(1);
  }

  /// Converts this [FacilityDis] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["order"] = order;
    if (facility != null) {
      data["facility"] = facility!.toJson();
    }

    // (Optional) If you want to include back:
    if (additionalDetails != null) {
      data["additionalDetails"] = additionalDetails;
    }

    return data;
  }
}

/// Represents facility summary information used for
/// facility management and limit processing.
class FacilitySummaryNew {
  /// Creates a [FacilitySummaryNew] instance.
  FacilitySummaryNew({
    this.facilityId,
    this.appRefNo,
    this.groupId,
    this.rimNo,
    this.limitNo,
    this.controllingLimitNo,
    this.wcasLimitNo,
    this.parentFacilityId,
    this.facilityMasterId,
    this.limitDescription,
    this.limitCapType,
    this.limitCategory,
    this.advanceType,
    this.isMainLimit,
    this.isSharedLimit,
    this.isProjectFinActivity,
    this.isRegulatorySpecialisedLending,
    this.regulatorySpecialisedLendingFinanceType,
    this.projectName,
    this.currency,
    this.presentLimit,
    this.presentLimitAED,
    this.presentOutstanding,
    this.originalLimit,
    this.limitAvailabilityDateNow,
    this.proposedLimit,
    this.proposedLimitAED,
    this.limitExpiryDate,
    this.limitAvailabilityDate,
    this.isCommitted,
    this.seniority,
    this.countryOfRisk,
    this.purpose,
    this.sectorDescription,
    this.sicCode,
    this.accountType,
    this.commitmentAccountNumber,
    this.promissoryNoteTaken,
    this.isCollateralDependent,
    this.revolvingType,
    this.isDraft,
    this.forIslamic,
    this.emirates,
    this.presentOutstandingAED,
    this.propertyType,
    this.propertySubType,
    this.recommendedOutstanding,
    this.recommendedPastdue,
    this.recommendedOutstandingAed,
    this.recommendedPastdueAed,
    this.sustainabilityClassification,
    this.proposedByCc,
    this.facilityTitle,
    this.remarks,
    this.policyDeviation,
    this.isCrossBoarderCorporateExposure,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.srcMigratedId,
    this.limitAvailabilityPeriod,
    this.tenorValue,
    this.tenorUnit,
    this.pastDues,
    this.index,
    this.marginSign,
    this.marginValue,
    this.productCode,
    this.projectCode,
    this.limitGroupName,
    this.limitGroup,
    this.canDelete,
  });

  /// Creates a [FacilitySummaryNew] instance from a JSON map.
  FacilitySummaryNew.fromJson(Map<String, dynamic> json) {
    facilityId = _asInt(json["facilityId"]);
    facilityMasterId = _asInt(json["facilityMasterId"]);
    appRefNo = json["appRefNo"];
    groupId = _asInt(json["groupId"]);
    rimNo = _asInt(json["rimNo"]);

    limitNo = json["limitNo"];
    controllingLimitNo = json["controllingLimitNo"];
    wcasLimitNo = json["wcasLimitNo"];

    parentFacilityId = _asInt(json["parentFacilityId"]);
    limitCategory = json["limitCategory"];

    limitDescription = json["limitDescription"]?.toString();
    limitCapType = json["limitCapType"]?.toString();
    sectorDescription = json["sectorDescription"]?.toString();
    sicCode = json["sicCode"]?.toString();

    advanceType = _asInt(json["advanceType"]);

    isMainLimit = _asBool(json["isMainLimit"]);
    isSharedLimit = _asBool(json["isSharedLimit"]);
    isProjectFinActivity = _asBool(json["isProjectFinActivity"]);
    isRegulatorySpecialisedLending =
        _asBool(json["isRegulatorySpecialisedLending"]);

    regulatorySpecialisedLendingFinanceType =
        _asInt(json["regulatorySpecialisedLendingFinanceType"]);

    projectName = json["projectName"];
    currency = json["currency"];

    presentLimit = _asNum(json["presentLimit"]);
    presentLimitAED = _asNum(json["presentLimitAED"]);
    presentOutstanding = _asNum(json["presentOutstanding"]);
    presentOutstandingAED = _asNum(json["presentOutstandingAED"]);
    originalLimit = _asNum(json["originalLimit"]);

    proposedLimit = _asInt(json["proposedLimit"]);
    proposedLimitAED = _asNum(json["proposedLimitAED"]);

    limitExpiryDate = _asDate(json["limitExpiryDate"]);
    limitAvailabilityDate = _asDate(json["limitAvailabilityDate"]);
    limitAvailabilityDateNow = json["limitAvailabilityDate"]?.toString();

    limitAvailabilityDateRaw = json["limitAvailabilityDate"]; //  NEW

    isCommitted = _asBool(json["isCommitted"]);

    seniority = _asInt(json["seniority"]);
    countryOfRisk = json["countryOfRisk"];
    purpose = _asInt(json["purpose"]);

    accountType = _asInt(json["accountType"]);
    commitmentAccountNumber = json["commitmentAccountNumber"];

    promissoryNoteTaken = _asInt(json["promissoryNoteTaken"]);
    isCollateralDependent = _asBool(json["isCollateralDependent"]);

    revolvingType = _asInt(json["revolvingType"]);
    isDraft = _asBool(json["isDraft"]);

    forIslamic = json["forIslamic"]?.toString();
    emirates = _asInt(json["emirates"]);

    propertyType = _asInt(json["propertyType"]);
    propertySubType = _asInt(json["propertySubType"]);

    recommendedOutstanding = _asNum(json["recommendedOutstanding"]);
    recommendedPastdue = _asNum(json["recommendedPastdue"]);
    recommendedOutstandingAed = _asNum(json["recommendedOutstandingAed"]);
    recommendedPastdueAed = _asNum(json["recommendedPastdueAed"]);

    sustainabilityClassification = json["sustainabilityClassification"];
    proposedByCc = json["proposedByCc"];
    facilityTitle = json["facilityTitle"];
    remarks = json["remarks"];
    policyDeviation = json["policyDeviation"];

    isCrossBoarderCorporateExposure =
        _asBool(json["isCrossBoarderCorporateExposure"]);

    createdBy = json["createdBy"];
    createdDate = _asDate(json["createdDate"]);
    updatedBy = json["updatedBy"];
    updatedDate = _asDate(json["updatedDate"]);

    srcMigratedId = json["srcMigratedId"];

    limitAvailabilityPeriod = _asInt(json["limitAvailabilityPeriod"]);
    tenorValue = _asInt(json["tenorValue"]);
    tenorUnit = json["tenorUnit"];

    pastDues = _asNum(json["pastDues"]);
    index = json["index"];
    marginSign = json["marginSign"];
    marginValue = _asNum(json["marginValue"]);

    productCode = json["productCode"];
    projectCode = json["projectCode"];
    limitGroupName = json["limitGroupName"];
    limitGroup = _asInt(json["limitGroup"]);

    canDelete = _asBool(json["canDelete"]);
  }

  /// Tenor validation error message.
  String? tenorError;

  /// Index validation error message.
  String? indexError;

  /// Margin validation error message.
  String? marginError;

  /// Indicates whether the facility has been modified.
  bool? isEdited;

  /// Facility identifier.
  int? facilityId;

  /// Facility master identifier.
  int? facilityMasterId;

  /// Application reference number.
  String? appRefNo;

  /// Group identifier.
  int? groupId;

  /// Customer RIM number.
  int? rimNo;

  /// Limit number.
  String? limitNo;

  /// Limit availability date as received from the API.
  String? limitAvailabilityDateNow;

  /// Raw limit availability date value.
  dynamic limitAvailabilityDateRaw;

  /// Controlling limit number.
  String? controllingLimitNo;

  /// WCAS limit number.
  String? wcasLimitNo;

  /// Parent facility identifier.
  int? parentFacilityId;

  /// Limit description.
  String? limitDescription;

  /// Limit cap type.
  String? limitCapType;

  /// Limit category.
  String? limitCategory;

  /// Advance type.
  int? advanceType;

  /// Indicates whether this is the main limit.
  bool? isMainLimit;

  /// Indicates whether the limit is shared.
  bool? isSharedLimit;

  /// Indicates whether this is a project finance activity.
  bool? isProjectFinActivity;

  /// Indicates whether regulatory specialised lending applies.
  bool? isRegulatorySpecialisedLending;

  /// Regulatory specialised lending finance type.
  int? regulatorySpecialisedLendingFinanceType;

  /// Project name.
  String? projectName;

  /// Currency.
  String? currency;

  /// Present limit.
  num? presentLimit;

  /// Present limit in AED.
  num? presentLimitAED;

  /// Present outstanding amount.
  num? presentOutstanding;

  /// Present outstanding amount in AED.
  num? presentOutstandingAED;

  /// Original limit.
  num? originalLimit;

  /// Proposed limit.
  int? proposedLimit;

  /// Proposed limit in AED.
  num? proposedLimitAED;

  /// Limit expiry date.
  DateTime? limitExpiryDate; // expects ISO-8601 string

  /// Limit availability date.
  DateTime? limitAvailabilityDate; // expects ISO-8601 string

  /// Indicates whether the facility is committed.
  bool? isCommitted;

  /// Seniority.
  int? seniority;

  /// Country of risk.
  String? countryOfRisk;

  /// Purpose identifier.
  int? purpose;

  /// Sector description.
  String? sectorDescription;

  /// SIC code.
  String? sicCode;

  /// Account type.
  int? accountType;

  /// Commitment account number.
  String? commitmentAccountNumber;

  /// Promissory note taken indicator.
  int? promissoryNoteTaken;

  /// Indicates whether the facility is collateral dependent.
  bool? isCollateralDependent;

  /// Revolving type.
  int? revolvingType;

  /// Draft indicator.
  bool? isDraft;

  /// Islamic facility flag.
  String? forIslamic;

  /// Emirates identifier.
  int? emirates;

  /// Property type.
  int? propertyType;

  /// Property subtype.
  int? propertySubType;

  /// Recommended outstanding amount.
  num? recommendedOutstanding;

  /// Recommended past due amount.
  num? recommendedPastdue;

  /// Recommended outstanding amount in AED.
  num? recommendedOutstandingAed;

  /// Recommended past due amount in AED.
  num? recommendedPastdueAed;

  /// Sustainability classification.
  String? sustainabilityClassification;

  /// Proposed amount by CC.
  int? proposedByCc;

  /// Facility title.
  String? facilityTitle;

  /// Remarks.
  String? remarks;

  /// Policy deviation information.
  String? policyDeviation;

  /// Indicates whether the exposure is cross-border.
  bool? isCrossBoarderCorporateExposure;

  /// User who created the record.
  String? createdBy;

  /// Record creation date.
  DateTime? createdDate; // expects ISO-8601 string

  /// User who last updated the record.
  String? updatedBy;

  /// Record last update date.
  DateTime? updatedDate; // expects ISO-8601 string

  /// Source migrated identifier.
  String? srcMigratedId;

  /// Limit availability period.
  int? limitAvailabilityPeriod;

  /// Tenor value.
  int? tenorValue;

  /// Tenor unit.
  String? tenorUnit;

  /// Past dues amount.
  num? pastDues;

  /// Index value.
  String? index;

  /// Margin sign.
  String? marginSign;

  /// Margin value.
  num? marginValue;

  /// Product code.
  String? productCode;

  /// Project code.
  String? projectCode;

  /// Limit group name.
  String? limitGroupName;

  /// Limit group identifier.
  int? limitGroup;

  /// Indicates whether the record can be deleted.
  bool? canDelete;

  // Store the additionalDetails container as received from API (has ids, dates,
  // etc.)
  Map<String, dynamic>? additionalDetailsContainer;
  // Store the decoded inner JSON (the string inside
  // container.additionalDetails)
  Map<String, dynamic>? additionalDetailsParsed;

  /// Builds the `additionalDetails` wrapper for SAVE payload.
  ///
  /// Backend format:
  /// additionalDetails (wrapper object) contains:
  ///   - facilitySecurityDetailId, type, facilitySecurityId, createdBy...
  ///   - additionalDetails: "JSON STRING"  <-- inner JSON stored as string
  ///
  /// Steps:
  /// 1) Start from original wrapper (`additionalDetailsContainer`) to preserve ids.
  /// 2) Parse existing inner JSON string into `inner`.
  /// 3) Apply only user changes (tenor/index/margin/commission) based on limitCategory.
  /// 4) Encode inner back to JSON string and put it into wrapper.
  /// 5) Return wrapper.
  ///
  /// We do NOT want to lose unknown keys in inner JSON
  /// (because additionalDetails differs per facility type)
  Map<String, dynamic>? _buildAdditionalDetailsForSave() {
    // If the API never sent a container, skip sending additionalDetails.
    if (additionalDetailsContainer == null) {
      return null;
    }

    // Clone the container to avoid side-effects
    final Map<String, dynamic> container =
        Map<String, dynamic>.from(additionalDetailsContainer!);

    // Start from the inner JSON (string) if available; else from parsed map;
    // else empty.
    Map<String, dynamic> inner = {};
    final String? raw = container["additionalDetails"]?.toString();
    try {
      if (raw != null && raw.trim().isNotEmpty) {
        inner = jsonDecode(raw) as Map<String, dynamic>;
      } else if (additionalDetailsParsed != null) {
        inner = Map<String, dynamic>.from(additionalDetailsParsed!);
      }
    } on Object catch (_) {
      // keep inner as {}
    }

    // Determine limitCategory behavior:
    // - F => existing behavior (profitGrid + commission mirror)
    // - N => update ONLY commission block (do not touch profitGrid / do not overwrite indexLcLGCommision)
    final bool isF = (limitCategory ?? "").trim().toUpperCase() == "F";

    // --- update tenor from current UI/edit values ---
    // keep your existing logic (do not break anything)
    if (tenorUnit != null || tenorValue != null) {
      inner["tenor"] = {
        "tenorUnit": tenorUnit,
        "tenorValue": tenorValue?.toString(),
      };
    }

    // =========================
    // F CASE: KEEP EXISTING FLOW
    // =========================
    if (isF) {
      // --- update profitGrid[0] with current margin and index ---
      final Map<String, dynamic> firstRow = <String, dynamic>{};

      if (marginSign != null || marginValue != null) {
        firstRow["margin"] = {
          "tenorUnit": marginSign, // "+" or "-"
          "tenorValue":
              marginValue?.toString(), // keep as string in nested JSON
        };
      }

      if (index != null && index!.isNotEmpty) {
        firstRow["index"] = index;
      }

      // ensure profitGrid exists and merge first row (unchanged behavior)
      List<dynamic> grid = (inner["profitGrid"] is List)
          ? List<dynamic>.from(inner["profitGrid"])
          : <dynamic>[];
      if (grid.isEmpty) {
        grid = <dynamic>[firstRow];
      } else {
        grid[0] = ((grid.first is Map)
            ? Map<String, dynamic>.from(grid.first as Map)
            : <String, dynamic>{})
          ..addAll(firstRow);
      }
      inner["profitGrid"] = grid;

      // --- also mirror to LC Commission if that structure is in use ---
      // If API originally uses lcCommission for these values, keep it updated.
      final dynamic lc0 = inner["lcCommission"];
      List<dynamic> lc = (lc0 is List) ? List<dynamic>.from(lc0) : <dynamic>[];

      if (index != null || marginValue != null) {
        final Map<String, dynamic> lcFirst = (lc.isNotEmpty && lc.first is Map)
            ? Map<String, dynamic>.from(lc.first as Map)
            : <String, dynamic>{};

        // keep existing behavior for F: update index + gridCommission
        if (index != null && index!.isNotEmpty) {
          lcFirst["indexLcLGCommision"] = index; // e.g., "fixedCommision"
        }
        if (marginValue != null) {
          lcFirst["gridCommission"] =
              (marginValue is num) ? marginValue : marginValue?.toString();
        }

        if (lc.isEmpty) {
          lc = <dynamic>[lcFirst];
        } else {
          lc[0] = lcFirst;
        }
        inner["lcCommission"] = lc;
      }
    }

    // =========================
    // N CASE: UPDATE ONLY COMMISSION BLOCK
    // =========================
    else {
      // For N we must NOT touch/create profitGrid, and must NOT overwrite indexLcLGCommision.
      // Update ONLY "gridCommission" in whichever commission block exists first,
      // following the same key preference order you already use in parsing.
      const List<String> commissionKeys = <String>[
        "lcCommission",
        "avCommission",
        "lgCommission",
      ];

      if ((index != null && index!.isNotEmpty) || marginValue != null) {
        for (final String key in commissionKeys) {
          final dynamic block = inner[key];

          if (block is List && block.isNotEmpty && block.first is Map) {
            final List<dynamic> rows = List<dynamic>.from(block);
            final Map<String, dynamic> first =
                Map<String, dynamic>.from(rows.first as Map);

            //  persist index selection for N
            if (index != null && index!.isNotEmpty) {
              first["indexLcLGCommision"] = index;
            }

            // persist commission value if changed
            if (marginValue != null) {
              first["gridCommission"] =
                  (marginValue is num) ? marginValue : marginValue.toString();
            }

            rows[0] = first;
            inner[key] = rows;
            break;
          }
        }
      }
    }

    // Put back as a JSON **string** exactly like the API expects
    container["additionalDetails"] = jsonEncode(inner);
    return container;
  }

  /// Converts this [FacilitySummaryNew] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["facilityId"] = facilityId;
    data["facilityMasterId"] = facilityMasterId;
    data["appRefNo"] = appRefNo;
    data["groupId"] = groupId;
    data["rimNo"] = rimNo;

    data["limitNo"] = limitNo;
    data["controllingLimitNo"] = controllingLimitNo;
    data["wcasLimitNo"] = wcasLimitNo;

    data["parentFacilityId"] = parentFacilityId;

    data["limitDescription"] = limitDescription;
    data["limitCategory"] = limitCategory;
    data["advanceType"] = advanceType;

    data["isMainLimit"] = isMainLimit;
    data["isSharedLimit"] = isSharedLimit;
    data["isProjectFinActivity"] = isProjectFinActivity;
    data["isRegulatorySpecialisedLending"] = isRegulatorySpecialisedLending;

    data["regulatorySpecialisedLendingFinanceType"] =
        regulatorySpecialisedLendingFinanceType;

    data["projectName"] = projectName;
    data["currency"] = currency;

    data["presentLimit"] = presentLimit;
    data["presentLimitAED"] = presentLimitAED;
    data["presentOutstanding"] = presentOutstanding;
    data["presentOutstandingAED"] = presentOutstandingAED;
    data["originalLimit"] = originalLimit;

    data["proposedLimit"] = proposedLimit;
    data["proposedLimitAED"] = proposedLimitAED;

    data["limitExpiryDate"] = _dateToIso(limitExpiryDate);
    data["limitAvailabilityDate"] = _dateToIso(limitAvailabilityDate);

    data["isCommitted"] = isCommitted;

    data["seniority"] = seniority;
    data["countryOfRisk"] = countryOfRisk;
    data["purpose"] = purpose;

    data["sectorDescription"] = sectorDescription;
    data["sicCode"] = sicCode;

    data["accountType"] = accountType;
    data["commitmentAccountNumber"] = commitmentAccountNumber;

    data["promissoryNoteTaken"] = promissoryNoteTaken;
    data["isCollateralDependent"] = isCollateralDependent;

    data["revolvingType"] = revolvingType;
    data["isDraft"] = isDraft ?? false;

    data["forIslamic"] = forIslamic;
    data["emirates"] = emirates;

    data["propertyType"] = propertyType;
    data["propertySubType"] = propertySubType;

    data["recommendedOutstanding"] = recommendedOutstanding;
    data["recommendedPastdue"] = recommendedPastdue;
    data["recommendedOutstandingAed"] = recommendedOutstandingAed;
    data["recommendedPastdueAed"] = recommendedPastdueAed;

    data["sustainabilityClassification"] = sustainabilityClassification;
    data["proposedByCc"] = proposedByCc;
    data["facilityTitle"] = facilityTitle;
    data["remarks"] = remarks;
    data["policyDeviation"] = policyDeviation;

    data["isCrossBoarderCorporateExposure"] = isCrossBoarderCorporateExposure;

    data["createdBy"] = createdBy;
    data["createdDate"] = _dateToIso(createdDate);
    data["updatedBy"] = updatedBy;
    data["updatedDate"] = _dateToIso(updatedDate);

    data["srcMigratedId"] = srcMigratedId;

    data["limitAvailabilityPeriod"] = limitAvailabilityPeriod;
    data["tenorValue"] = tenorValue;
    data["tenorUnit"] = tenorUnit;

    data["pastDues"] = pastDues;
    data["index"] = index;
    data["marginSign"] = marginSign;
    data["marginValue"] = marginValue;

    data["productCode"] = productCode;
    data["projectCode"] = projectCode;
    data["limitGroupName"] = limitGroupName;
    data["limitGroup"] = limitGroup;

    data["canDelete"] = canDelete;

    final addl = _buildAdditionalDetailsForSave();
    if (addl != null) {
      data["additionalDetails"] = addl;
    }

    return data;
  }

  /// Converts this [FacilitySummaryNew] instance to a save request payload.
  Map<String, dynamic> toSaveJson() {
    int? toIntOrNull(value) {
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value.toString());
    }

    String? toStringOrNull(value) => value?.toString();

    final Map<String, Object?> map = {
      "groupOwner": Globals.request?.groupOwner,
      "limitNo": limitNo,
      "facilityId": facilityId,
      "rimNo": rimNo,
      "limitCapType": limitCapType,
      "groupId": groupId,
      "limitCategory": limitCategory, // for facilities it cant be null
      "productCode": productCode ?? "ODAS",
      "appRefNo": appRefNo,
      "forIslamic": forIslamic,
      "limitDescription":
          toIntOrNull(limitDescription), // our model keeps it as String?
      "facilityTitle": facilityTitle,
      "sustainabilityClassification":
          sustainabilityClassification, // e.g. "11318, 11319"
      "advanceType": advanceType,
      "proposedLimitAED": proposedLimitAED,
      "presentOutstanding": presentOutstanding,
      "presentOutstandingAED": presentOutstandingAED,
      "pastdues": pastDues, //request key spells "pastdues" (lowercase D)
      "isSharedLimit": isSharedLimit,
      "presentLimit": presentLimit,
      "proposedLimit": proposedLimit,
      "proposedByCc": toStringOrNull(proposedByCc) ?? toIntOrNull(proposedByCc),
      "controllingLimitNo": controllingLimitNo,
      "isProjectFinActivity": isProjectFinActivity,
      "projectName": projectName,
      "purpose": purpose,
      "propertyType": propertyType,
      "propertySubType": propertySubType,
      "emirates": emirates,
      "isRegulatorySpecialisedLending": isRegulatorySpecialisedLending,
      "regulatorySpecialisedLendingFinanceType":
          regulatorySpecialisedLendingFinanceType,
      "countryOfRisk": countryOfRisk,
      "isCrossBoarderCorporateExposure": isCrossBoarderCorporateExposure,
      "isCommitted": isCommitted,
      "seniority": seniority,
      "accountType": accountType,
      "sectorDescription": sectorDescription,
      "sicCode": sicCode,
      "promissoryNoteTaken": promissoryNoteTaken,
      "isCollateralDependent": isCollateralDependent,
      "commitmentAccountNumber": commitmentAccountNumber,
      "policyDeviation": policyDeviation,
      "isMainLimit": isMainLimit,
      "currency": currency,
      "tenorUnit": tenorUnit,
      "tenorValue": tenorValue,
      "index": index,
      "marginSign": marginSign,
      "marginValue": marginValue, // keep numeric or string as is
      "projectCode": projectCode,
      "limitGroupName": limitGroupName,
      "limitGroup": limitGroup,
      "limitAvailabilityDate":
          _dateToEpochSeconds(limitAvailabilityDateRaw, limitAvailabilityDate),
      "facilityMasterId": facilityMasterId,
      "parentFacilityId": parentFacilityId,
      "wcasLimitNo": wcasLimitNo,
      "originalLimit": originalLimit,
      "presentLimitAED": presentLimitAED,
      "recommendedOutstanding": recommendedOutstanding,
      "recommendedPastdue": recommendedPastdue,
      "recommendedOutstandingAed": recommendedOutstandingAed,
      "recommendedPastdueAed": recommendedPastdueAed,
      "isDraft": isDraft,
      "remarks": remarks,
      "limitAvailabilityPeriod": limitAvailabilityPeriod,
      "limitExpiryDate": _dateToIso(limitExpiryDate),
      "createdBy": createdBy,
      "createdDate": _dateToIso(createdDate),
      "updatedBy": updatedBy,
      "updatedDate": _dateToIso(updatedDate),
      "srcMigratedId": srcMigratedId,
      "canDelete": canDelete,
    };

    final Map<String, dynamic>? dditionalDetails =
        _buildAdditionalDetailsForSave();
    if (dditionalDetails != null) {
      map["additionalDetails"] = dditionalDetails;
    }

    return map;
  }
}

/// Represents initialization values used when creating
/// or editing a facility.
class FacilityInitFields {
  /// Creates a [FacilityInitFields] instance.
  FacilityInitFields({
    this.proposedLimitAED,
    this.tenorUnit,
    this.tenorValue,
    this.index,
    this.marginSign,
    this.marginValue,
  });

  /// Creates a [FacilityInitFields] instance from a JSON map.
  FacilityInitFields.fromJson(Map<String, dynamic> json) {
    proposedLimitAED = _asStringList(json["proposedLimitAED"]);
    tenorUnit = _asStringList(json["tenorUnit"]);
    tenorValue = _asStringList(json["tenorValue"]);
    index = _asStringList(json["index"]);
    marginSign = _asStringList(json["marginSign"]);
    marginValue = _asStringList(json["marginValue"]);
  }

  /// Proposed limit values in AED.
  List<String>? proposedLimitAED;

  /// Tenor units.
  List<String>? tenorUnit;

  /// Tenor values.
  List<String>? tenorValue;

  /// Index values.
  List<String>? index;

  /// Margin signs.
  List<String>? marginSign;

  /// Margin values.
  List<String>? marginValue;

  /// Converts this [FacilityInitFields] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["proposedLimitAED"] = proposedLimitAED;
    data["tenorUnit"] = tenorUnit;
    data["tenorValue"] = tenorValue;
    data["index"] = index;
    data["marginSign"] = marginSign;
    data["marginValue"] = marginValue;
    return data;
  }

  /// Returns the most recent proposed limit in AED.
  String? get lastproposedLimitAED =>
      proposedLimitAED != null && proposedLimitAED!.isNotEmpty
          ? proposedLimitAED!.last
          : null;

  /// Returns the most recent tenor unit.
  String? get lastTenorUnit =>
      tenorUnit != null && tenorUnit!.isNotEmpty ? tenorUnit!.last : null;

  /// Returns the most recent tenor value.
  String? get lastTenorValue =>
      tenorValue != null && tenorValue!.isNotEmpty ? tenorValue!.last : null;

  /// Returns the most recent index value.
  String? get lastIndex =>
      index != null && index!.isNotEmpty ? index!.last : null;

  /// Returns the most recent margin sign.
  String? get lastMarginSign =>
      marginSign != null && marginSign!.isNotEmpty ? marginSign!.last : null;

  /// Returns the most recent margin value.
  String? get lastMarginValue =>
      marginValue != null && marginValue!.isNotEmpty ? marginValue!.last : null;
}

/// Converts a value to a list of strings if possible.
///
/// Returns `null` if the value is not a list.
List<String>? _asStringList(v) {
  if (v == null) {
    return null;
  }

  if (v is List) {
    return v.where((e) => e != null).map((e) => e.toString()).toList();
  }

  return null;
}

/// Converts a date value to Unix epoch seconds.
///
/// If the source value is already numeric, it is returned as an integer.
/// If the source value is a date string or a [DateTime], it is converted
/// to epoch seconds. Returns `null` when conversion is not possible.
int? _dateToEpochSeconds(raw, DateTime? dt) {
  // If API already gave a number, keep it (already Long-compatible)
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }

  // If raw is a string date, convert it to epoch seconds
  if (dt != null) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  // If dt is null but raw is string, try parse
  if (raw is String && raw.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed.millisecondsSinceEpoch ~/ 1000;
    }
  }
  return null;
}

/// Represents an overall total summary entry,
/// including existing, proposed, and difference values.
class OverallTotalEntry {
  /// Creates an [OverallTotalEntry] instance.
  OverallTotalEntry({
    this.totalType,
    this.existingLimit,
    this.proposedLimit,
    this.differenceLabel,
    this.differenceValue,
  });

  /// Creates an [OverallTotalEntry] instance from a JSON map.
  OverallTotalEntry.fromJson(Map<String, dynamic> json) {
    totalType = json["totalType"];
    existingLimit = _asNum(json["existingLimit"]);
    proposedLimit = _asNum(json["proposedLimit"]);
    differenceLabel = json["difference"];
    differenceValue = _asNum(json["differenceValue"]);
  }

  /// Total type.
  String? totalType;

  /// Existing limit value.
  num? existingLimit;

  /// Proposed limit value.
  num? proposedLimit;

  /// Difference label.
  String? differenceLabel;

  /// Difference value.
  num? differenceValue;

  /// Converts this [OverallTotalEntry] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["totalType"] = totalType;
    data["existingLimit"] = existingLimit;
    data["proposedLimit"] = proposedLimit;
    data["differenceLabel"] = differenceLabel;
    data["differenceValue"] = differenceValue;
    return data;
  }
}

/// Converts a value to an integer if possible.
///
/// Returns `null` if the value cannot be converted.
int? _asInt(v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  if (v is String && v.trim().isNotEmpty) {
    return int.tryParse(v);
  }
  return null;
}

/// Converts a value to a numeric type if possible.
///
/// Returns `null` if the value cannot be converted.
num? _asNum(v) {
  if (v == null) {
    return null;
  }
  if (v is num) {
    return v;
  }
  if (v is String && v.trim().isNotEmpty) {
    return num.tryParse(v);
  }
  return null;
}

/// Converts a value to a boolean if possible.
///
/// Supports boolean, numeric, and common string representations.
/// Returns `null` if the value cannot be converted.
bool? _asBool(v) {
  if (v == null) {
    return null;
  }
  if (v is bool) {
    return v;
  }
  if (v is num) {
    return v != 0;
  }
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == "true" || s == "t" || s == "yes" || s == "y") {
      return true;
    }
    if (s == "false" || s == "f" || s == "no" || s == "n") {
      return false;
    }
    final n = num.tryParse(s);
    if (n != null) {
      return n != 0;
    }
  }
  return null;
}

/// Converts a value to a [DateTime] if possible.
///
/// Supports [DateTime], ISO-8601 strings,
/// and Unix timestamps in milliseconds.
DateTime? _asDate(v) {
  if (v == null) {
    return null;
  }
  if (v is DateTime) {
    return v;
  }
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v);
  }
  if (v is int) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(v);
    } on Object catch (_) {}
  }
  return null;
}

/// Converts a [DateTime] value to an ISO-8601 string.
String? _dateToIso(DateTime? dt) => dt?.toIso8601String();
