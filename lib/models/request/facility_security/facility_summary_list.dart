import "dart:convert";

import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

class FacilitySummaryList {
  FacilitySummaryList({this.rims});

  FacilitySummaryList.fromJson(Map<String, dynamic> json) {
    if (json["rims"] != null) {
      rims = <RimSummary>[];
      for (final v in (json["rims"] as List)) {
        rims!.add(RimSummary.fromJson(v as Map<String, dynamic>));
      }
    }
  }
  List<RimSummary>? rims;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rims != null) {
      data["rims"] = rims!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RimSummary {
  RimSummary({
    this.rimName,
    this.rimNo,
    this.groups,
    this.overallTotals,
    this.type,
  });

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
  String? rimName;
  int? rimNo;
  List<RimGroup>? groups;
  CustomerType? type;
  List<OverallTotalEntry>? overallTotals;

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

class RimGroup {
  RimGroup({this.groupName, this.facilityLimits, this.amounts});

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
  String? groupName;
  List<FacilityDis>? facilityLimits;
  GroupAmounts? amounts;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["groupName"] = groupName;
    if (facilityLimits != null) {
      data["facilityLimits"] = facilityLimits!.map((v) => v.toJson()).toList();
    }
    if (amounts != null) data["amounts"] = amounts!.toJson();
    return data;
  }
}

class GroupAmounts {
  GroupAmounts({
    this.totalExistingLimit,
    this.totalProposedLimit,
    this.totalCurrentOutstanding,
  });

  GroupAmounts.fromJson(Map<String, dynamic> json) {
    totalExistingLimit = _asNum(json["totalExistingLimit"]);
    totalProposedLimit = _asNum(json["totalProposedLimit"]);
    totalCurrentOutstanding = _asNum(json["totalCurrentOutstanding"]);
  }
  num? totalExistingLimit;
  num? totalProposedLimit;
  num? totalCurrentOutstanding;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["totalExistingLimit"] = totalExistingLimit;
    data["totalProposedLimit"] = totalProposedLimit;
    data["totalCurrentOutstanding"] = totalCurrentOutstanding;
    return data;
  }
}

class FacilityDis {
  // <-- ADD THIS

  FacilityDis({this.order, this.facility});

  FacilityDis.fromJson(Map<String, dynamic> json) {
    // Unwrap nested "facilityDis" if present; otherwise use the current map.
    final Map<String, dynamic> src =
        (json["facilityDis"] is Map<String, dynamic>)
            ? (json["facilityDis"] as Map<String, dynamic>)
            : json;

    order = src["order"];
    facility = src["facility"] != null
        ? FacilitySummaryNew.fromJson(src["facility"] as Map<String, dynamic>)
        : null;

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
      } catch (_) {
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
            facility!.marginValue ??=
                (mv is num) ? mv : (mv is String ? num.tryParse(mv) : null);
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
          final dynamic gc = firstCommissionRow["gridCommission"];
          if (gc != null && facility!.marginValue == null) {
            facility!.marginValue = num.tryParse(gc);
            // Provide a default sign so UI validation doesn't fail
            facility!.marginSign ??= "+";
          }
        }
      }
    }
  }
  //TODO this model class needs to be remove
  String? order;
  FacilitySummaryNew? facility;

  Map<String, dynamic>? additionalDetails;

  String normalizeTenorUnit(String? raw) {
    if (raw == null) return "";
    final s = raw.trim().toLowerCase();

    // Collapse spaces/hyphens/underscores
    final compact = s.replaceAll(RegExp(r"[\s\-_]+"), "");

    // Accept many variants from API: names, abbreviations, single/plural
    if (compact == "d" || compact == "day" || compact == "days") return "Days";
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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["order"] = order;
    if (facility != null) data["facility"] = facility!.toJson();

// (Optional) If you want to include back:
    if (additionalDetails != null) {
      data["additionalDetails"] = additionalDetails;
    }

    return data;
  }
}

class FacilitySummaryNew {
  // <— NEW

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

    originalLimit = _asNum(json["originalLimit"]);

    proposedLimit = _asInt(json["proposedLimit"]);
    proposedLimitAED = _asNum(json["proposedLimitAED"]);

    limitExpiryDate = _asDate(json["limitExpiryDate"]);
    limitAvailabilityDate = _asDate(json["limitAvailabilityDate"]);
    limitAvailabilityDateNow = json["limitAvailabilityDate"]?.toString();

    limitAvailabilityDateRaw = json["limitAvailabilityDate"]; // ✅ NEW

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

    forIslamic = _asInt(json["forIslamic"]);
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
  String? tenorError;
  String?
      // TODO this model class need to
      //  remove and replace with Facility modelclass
      indexError;
  String? marginError;

  bool? isEdited;
  int? facilityId;
  int? facilityMasterId;
  String? appRefNo;
  int? groupId;
  int? rimNo;

  String? limitNo;
  String? limitAvailabilityDateNow;
  dynamic limitAvailabilityDateRaw;

  String? controllingLimitNo;
  String? wcasLimitNo;

  int? parentFacilityId;

  String? limitDescription;
  String? limitCapType;
  String? limitCategory;
  int? advanceType;

  bool? isMainLimit;
  bool? isSharedLimit;
  bool? isProjectFinActivity;
  bool? isRegulatorySpecialisedLending;

  int? regulatorySpecialisedLendingFinanceType;

  String? projectName;
  String? currency;

  num? presentLimit;
  num? presentLimitAED;
  num? presentOutstanding;

  num? originalLimit;

  int? proposedLimit;
  num? proposedLimitAED;

  DateTime? limitExpiryDate; // expects ISO-8601 string
  DateTime? limitAvailabilityDate; // expects ISO-8601 string
  bool? isCommitted;

  int? seniority;
  String? countryOfRisk;
  int? purpose;

  String? sectorDescription;
  String? sicCode;

  int? accountType;
  String? commitmentAccountNumber;

  int? promissoryNoteTaken;
  bool? isCollateralDependent;

  int? revolvingType;
  bool? isDraft;
  int? forIslamic;
  int? emirates;

  int? propertyType;
  int? propertySubType;

  num? recommendedOutstanding;
  num? recommendedPastdue;
  num? recommendedOutstandingAed;
  num? recommendedPastdueAed;

  String? sustainabilityClassification;
  int? proposedByCc;
  String? facilityTitle;
  String? remarks;
  String? policyDeviation;

  bool? isCrossBoarderCorporateExposure;

  String? createdBy;
  DateTime? createdDate; // expects ISO-8601 string
  String? updatedBy;
  DateTime? updatedDate; // expects ISO-8601 string

  String? srcMigratedId;

  int? limitAvailabilityPeriod;
  int? tenorValue;
  String? tenorUnit;

  num? pastDues;
  String? index;
  String? marginSign;
  num? marginValue;

  String? productCode;
  String? projectCode;
  String? limitGroupName;
  int? limitGroup;

  bool? canDelete;

  // Store the additionalDetails container as received from API (has ids, dates,
  // etc.)
  Map<String, dynamic>? additionalDetailsContainer; // <— NEW
  // Store the decoded inner JSON (the string inside
  // container.additionalDetails)
  Map<String, dynamic>? additionalDetailsParsed;

  Map<String, dynamic>? _buildAdditionalDetailsForSave() {
    // If the API never sent a container, skip sending additionalDetails.
    if (additionalDetailsContainer == null) return null;

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
    } catch (_) {
      // keep inner as {}
    }

    // --- update tenor from current UI/edit values ---
    if (tenorUnit != null || tenorValue != null) {
      inner["tenor"] = {
        "tenorUnit": tenorUnit,
        "tenorValue": tenorValue?.toString(),
      };
    }

    // --- update profitGrid[0] with current margin and index ---
    final Map<String, dynamic> firstRow = <String, dynamic>{};
    if (marginSign != null || marginValue != null) {
      firstRow["margin"] = {
        "tenorUnit": marginSign, // "+" or "-"
        "tenorValue": marginValue?.toString(), // keep as string in nested JSON
      };
    }
    if (index != null && index!.isNotEmpty) {
      firstRow["index"] = index;
    }

    // ensure profitGrid exists and merge first row
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

    // Put back as a JSON **string** exactly like the API expects
    container["additionalDetails"] = jsonEncode(inner);
    return container;
  }

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

  Map<String, dynamic> toSaveJson() {
    int? toIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    String? toStringOrNull(dynamic value) => value?.toString();

    final Map<String, Object?> map = {
      "groupOwner": Globals.request?.groupOwner,
      "limitNo": limitNo,
      "facilityId": facilityId,
      "rimNo": rimNo,
      "limitCapType": limitCapType,
      "groupId": groupId,
      "limitCategory": limitCategory ?? "F",
      "productCode": productCode ?? "ODAS",
      "appRefNo": appRefNo,
      "forIslamic":
          toStringOrNull(forIslamic) ?? "Yes", // if required as string
      "limitDescription":
          toIntOrNull(limitDescription), // our model keeps it as String?
      "facilityTitle": facilityTitle,
      "sustainabilityClassification":
          sustainabilityClassification, // e.g. "11318, 11319"
      "advanceType": advanceType,
      "proposedLimitAED": proposedLimitAED,
      "presentOutstanding": presentOutstanding,
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
    };

    final Map<String, dynamic>? dditionalDetails =
        _buildAdditionalDetailsForSave();
    if (dditionalDetails != null) {
      map["additionalDetails"] = dditionalDetails;
    }

    return map;
  }
}

int? _dateToEpochSeconds(dynamic raw, DateTime? dt) {
  // If API already gave a number, keep it (already Long-compatible)
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();

  // If raw is a string date, convert it to epoch seconds
  if (dt != null) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  // If dt is null but raw is string, try parse
  if (raw is String && raw.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed.millisecondsSinceEpoch ~/ 1000;
  }
  return null;
}

class OverallTotalEntry {
  OverallTotalEntry({
    this.totalType,
    this.existingLimit,
    this.proposedLimit,
    this.differenceLabel,
    this.differenceValue,
  });

  OverallTotalEntry.fromJson(Map<String, dynamic> json) {
    totalType = json["totalType"];
    existingLimit = _asNum(json["existingLimit"]);
    proposedLimit = _asNum(json["proposedLimit"]);
    differenceLabel = json["difference"];
    differenceValue = _asNum(json["differenceValue"]);
  }
  String? totalType;
  num? existingLimit;
  num? proposedLimit;
  String? differenceLabel;
  num? differenceValue;

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

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String && v.trim().isNotEmpty) {
    return int.tryParse(v);
  }
  return null;
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String && v.trim().isNotEmpty) {
    return num.tryParse(v);
  }
  return null;
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == "true" || s == "t" || s == "yes" || s == "y") return true;
    if (s == "false" || s == "f" || s == "no" || s == "n") return false;
    final n = num.tryParse(s);
    if (n != null) return n != 0;
  }
  return null;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v);
  }
  if (v is int) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(v);
    } catch (_) {}
  }
  return null;
}

String? _dateToIso(DateTime? dt) => dt?.toIso8601String();
