class FacilitySummaryList {
  List<RimSummary>? rims;

  FacilitySummaryList({this.rims});

  FacilitySummaryList.fromJson(Map<String, dynamic> json) {
    if (json['rims'] != null) {
      rims = <RimSummary>[];
      for (var v in (json['rims'] as List)) {
        rims!.add(RimSummary.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (rims != null) {
      data['rims'] = rims!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RimSummary {
  String? rimName;
  int? rimNo;
  List<RimGroup>? groups;

  List<OverallTotalEntry>? overallTotals;

  RimSummary({this.rimName, this.rimNo, this.groups, this.overallTotals});

  RimSummary.fromJson(Map<String, dynamic> json) {
    rimName = json['rimName'];
    rimNo = _asInt(json['rimNo']);

    if (json['groups'] != null && json['groups'] is List) {
      groups = <RimGroup>[];
      for (var v in (json['groups'] as List)) {
        groups!.add(RimGroup.fromJson(v as Map<String, dynamic>));
      }
    }

    final Map<String, dynamic>? totalObj = json['total'] is Map<String, dynamic>
        ? (json['total'] as Map<String, dynamic>)
        : null;

    final dynamic totals =
        json['overallTotals'] ?? // ideal, if server sends root key
            json['OverallTotal'] ?? // some dumps show this at root
            json['overallTotal'] ?? // case variant
            totalObj?['OverallTotal'] ?? // nested: total.OverallTotal
            totalObj?['overallTotals'] ?? // nested: total.overallTotals
            totalObj?['overallTotal'] ?? // nested: case variant
            json['total OverallTotal']; // raw key seen in dump

    if (totals is List) {
      overallTotals = <OverallTotalEntry>[];
      for (var v in totals) {
        overallTotals!
            .add(OverallTotalEntry.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rimName'] = rimName;
    data['rimNo'] = rimNo;
    if (groups != null) {
      data['groups'] = groups!.map((v) => v.toJson()).toList();
    }
    if (overallTotals != null) {
      data['overallTotals'] = overallTotals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RimGroup {
  String? groupName;
  List<FacilityDis>? facilityLimits;
  GroupAmounts? amounts;

  RimGroup({this.groupName, this.facilityLimits, this.amounts});

  RimGroup.fromJson(Map<String, dynamic> json) {
    groupName = json['groupName'];
    if (json['facilityLimits'] != null) {
      facilityLimits = <FacilityDis>[];
      for (var v in (json['facilityLimits'] as List)) {
        facilityLimits!.add(FacilityDis.fromJson(v as Map<String, dynamic>));
      }
    }
    amounts =
        json['amounts'] != null ? GroupAmounts.fromJson(json['amounts']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['groupName'] = groupName;
    if (facilityLimits != null) {
      data['facilityLimits'] = facilityLimits!.map((v) => v.toJson()).toList();
    }
    if (amounts != null) data['amounts'] = amounts!.toJson();
    return data;
  }
}

class GroupAmounts {
  num? totalExistingLimit;
  num? totalProposedLimit;
  num? totalCurrentOutstanding;

  GroupAmounts({
    this.totalExistingLimit,
    this.totalProposedLimit,
    this.totalCurrentOutstanding,
  });

  GroupAmounts.fromJson(Map<String, dynamic> json) {
    totalExistingLimit = _asNum(json['totalExistingLimit']);
    totalProposedLimit = _asNum(json['totalProposedLimit']);
    totalCurrentOutstanding = _asNum(json['totalCurrentOutstanding']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalExistingLimit'] = totalExistingLimit;
    data['totalProposedLimit'] = totalProposedLimit;
    data['totalCurrentOutstanding'] = totalCurrentOutstanding;
    return data;
  }
}

class FacilityDis {
  String? order;
  FacilitySummaryNew? facility;

  FacilityDis({this.order, this.facility});

  FacilityDis.fromJson(Map<String, dynamic> json) {
    // Unwrap nested "facilityDis" if present; otherwise use the current map.
    final Map<String, dynamic> src =
        (json['facilityDis'] is Map<String, dynamic>)
            ? (json['facilityDis'] as Map<String, dynamic>)
            : json;

    order = src['order'];
    facility = src['facility'] != null
        ? FacilitySummaryNew.fromJson(src['facility'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['order'] = order;
    if (facility != null) data['facility'] = facility!.toJson();
    return data;
  }
}

class FacilitySummaryNew {
  bool? isEdited;
  int? facilityId;
  String? appRefNo;
  int? groupId;
  int? rimNo;

  String? limitNo;
  String? controllingLimitNo;
  String? wcasLimitNo;

  int? parentFacilityId;

  String? limitDescription;
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
  String? proposedByCc;
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

  FacilitySummaryNew({
    this.facilityId,
    this.appRefNo,
    this.groupId,
    this.rimNo,
    this.limitNo,
    this.controllingLimitNo,
    this.wcasLimitNo,
    this.parentFacilityId,
    this.limitDescription,
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
    facilityId = _asInt(json['facilityId']);
    appRefNo = json['appRefNo'];
    groupId = _asInt(json['groupId']);
    rimNo = _asInt(json['rimNo']);

    limitNo = json['limitNo'];
    controllingLimitNo = json['controllingLimitNo'];
    wcasLimitNo = json['wcasLimitNo'];

    parentFacilityId = _asInt(json['parentFacilityId']);

    // limitDescription = json['limitDescription'];
    limitCategory = json['limitCategory'];

    limitDescription = json['limitDescription']?.toString();
    sectorDescription = json['sectorDescription']?.toString();
    sicCode = json['sicCode']?.toString();

    advanceType = _asInt(json['advanceType']);

    isMainLimit = _asBool(json['isMainLimit']);
    isSharedLimit = _asBool(json['isSharedLimit']);
    isProjectFinActivity = _asBool(json['isProjectFinActivity']);
    isRegulatorySpecialisedLending =
        _asBool(json['isRegulatorySpecialisedLending']);

    regulatorySpecialisedLendingFinanceType =
        _asInt(json['regulatorySpecialisedLendingFinanceType']);

    projectName = json['projectName'];
    currency = json['currency'];

    presentLimit = _asNum(json['presentLimit']);
    presentLimitAED = _asNum(json['presentLimitAED']);
    presentOutstanding = _asNum(json['presentOutstanding']);

    originalLimit = _asNum(json['originalLimit']);

    proposedLimit = _asInt(json['proposedLimit']);
    proposedLimitAED = _asNum(json['proposedLimitAED']);

    limitExpiryDate = _asDate(json['limitExpiryDate']);
    limitAvailabilityDate = _asDate(json['limitAvailabilityDate']);

    isCommitted = _asBool(json['isCommitted']);

    seniority = _asInt(json['seniority']);
    countryOfRisk = json['countryOfRisk'];
    purpose = _asInt(json['purpose']);

    accountType = _asInt(json['accountType']);
    commitmentAccountNumber = json['commitmentAccountNumber'];

    promissoryNoteTaken = _asInt(json['promissoryNoteTaken']);
    isCollateralDependent = _asBool(json['isCollateralDependent']);

    revolvingType = _asInt(json['revolvingType']);
    isDraft = _asBool(json['isDraft']);

    forIslamic = _asInt(json['forIslamic']);
    emirates = _asInt(json['emirates']);

    propertyType = _asInt(json['propertyType']);
    propertySubType = _asInt(json['propertySubType']);

    recommendedOutstanding = _asNum(json['recommendedOutstanding']);
    recommendedPastdue = _asNum(json['recommendedPastdue']);
    recommendedOutstandingAed = _asNum(json['recommendedOutstandingAed']);
    recommendedPastdueAed = _asNum(json['recommendedPastdueAed']);

    sustainabilityClassification = json['sustainabilityClassification'];
    proposedByCc = json['proposedByCc'];
    facilityTitle = json['facilityTitle'];
    remarks = json['remarks'];
    policyDeviation = json['policyDeviation'];

    isCrossBoarderCorporateExposure =
        _asBool(json['isCrossBoarderCorporateExposure']);

    createdBy = json['createdBy'];
    createdDate = _asDate(json['createdDate']);
    updatedBy = json['updatedBy'];
    updatedDate = _asDate(json['updatedDate']);

    srcMigratedId = json['srcMigratedId'];

    limitAvailabilityPeriod = _asInt(json['limitAvailabilityPeriod']);
    tenorValue = _asInt(json['tenorValue']);
    tenorUnit = json['tenorUnit'];

    pastDues = _asNum(json['pastDues']);
    index = json['index'];
    marginSign = json['marginSign'];
    marginValue = _asNum(json['marginValue']);

    productCode = json['productCode'];
    projectCode = json['projectCode'];
    limitGroupName = json['limitGroupName'];
    limitGroup = _asInt(json['limitGroup']);

    canDelete = _asBool(json['canDelete']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['facilityId'] = facilityId;
    data['appRefNo'] = appRefNo;
    data['groupId'] = groupId;
    data['rimNo'] = rimNo;

    data['limitNo'] = limitNo;
    data['controllingLimitNo'] = controllingLimitNo;
    data['wcasLimitNo'] = wcasLimitNo;

    data['parentFacilityId'] = parentFacilityId;

    data['limitDescription'] = limitDescription;
    data['limitCategory'] = limitCategory;
    data['advanceType'] = advanceType;

    data['isMainLimit'] = isMainLimit;
    data['isSharedLimit'] = isSharedLimit;
    data['isProjectFinActivity'] = isProjectFinActivity;
    data['isRegulatorySpecialisedLending'] = isRegulatorySpecialisedLending;

    data['regulatorySpecialisedLendingFinanceType'] =
        regulatorySpecialisedLendingFinanceType;

    data['projectName'] = projectName;
    data['currency'] = currency;

    data['presentLimit'] = presentLimit;
    data['presentLimitAED'] = presentLimitAED;
    data['presentOutstanding'] = presentOutstanding;

    data['originalLimit'] = originalLimit;

    data['proposedLimit'] = proposedLimit;
    data['proposedLimitAED'] = proposedLimitAED;

    data['limitExpiryDate'] = _dateToIso(limitExpiryDate);
    data['limitAvailabilityDate'] = _dateToIso(limitAvailabilityDate);

    data['isCommitted'] = isCommitted;

    data['seniority'] = seniority;
    data['countryOfRisk'] = countryOfRisk;
    data['purpose'] = purpose;

    data['sectorDescription'] = sectorDescription;
    data['sicCode'] = sicCode;

    data['accountType'] = accountType;
    data['commitmentAccountNumber'] = commitmentAccountNumber;

    data['promissoryNoteTaken'] = promissoryNoteTaken;
    data['isCollateralDependent'] = isCollateralDependent;

    data['revolvingType'] = revolvingType;
    data['isDraft'] = isDraft;

    data['forIslamic'] = forIslamic;
    data['emirates'] = emirates;

    data['propertyType'] = propertyType;
    data['propertySubType'] = propertySubType;

    data['recommendedOutstanding'] = recommendedOutstanding;
    data['recommendedPastdue'] = recommendedPastdue;
    data['recommendedOutstandingAed'] = recommendedOutstandingAed;
    data['recommendedPastdueAed'] = recommendedPastdueAed;

    data['sustainabilityClassification'] = sustainabilityClassification;
    data['proposedByCc'] = proposedByCc;
    data['facilityTitle'] = facilityTitle;
    data['remarks'] = remarks;
    data['policyDeviation'] = policyDeviation;

    data['isCrossBoarderCorporateExposure'] = isCrossBoarderCorporateExposure;

    data['createdBy'] = createdBy;
    data['createdDate'] = _dateToIso(createdDate);
    data['updatedBy'] = updatedBy;
    data['updatedDate'] = _dateToIso(updatedDate);

    data['srcMigratedId'] = srcMigratedId;

    data['limitAvailabilityPeriod'] = limitAvailabilityPeriod;
    data['tenorValue'] = tenorValue;
    data['tenorUnit'] = tenorUnit;

    data['pastDues'] = pastDues;
    data['index'] = index;
    data['marginSign'] = marginSign;
    data['marginValue'] = marginValue;

    data['productCode'] = productCode;
    data['projectCode'] = projectCode;
    data['limitGroupName'] = limitGroupName;
    data['limitGroup'] = limitGroup;

    data['canDelete'] = canDelete;

    return data;
  }

  Map<String, dynamic> toSaveJson() {
    int? toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String? toStringOrNull(dynamic v) => v?.toString();

    int? toEpochSeconds(DateTime? dt) =>
        dt == null ? null : dt.toUtc().millisecondsSinceEpoch ~/ 1000;

    return {
      "facilityId": facilityId,
      "rimNo": rimNo,
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
      "presentOutstanding": presentOutstanding,
      "pastdues": pastDues, //request key spells "pastdues" (lowercase D)
      "isSharedLimit": isSharedLimit,
      "presentLimit": presentLimit,
      "proposedLimit": proposedLimit,
      "proposedByCc":
          toStringOrNull(proposedByCc) ?? toIntOrNull(proposedByCc),
      "controllingLimitNo": controllingLimitNo,
      "limitAvailabilityDate": toEpochSeconds(limitAvailabilityDate),
      "limitAvailabilityPeriod": limitAvailabilityPeriod,
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
    };
  }
}

class OverallTotalEntry {
  String? totalType;
  num? existingLimit;
  num? proposedLimit;
  String? differenceLabel;
  num? differenceValue;

  OverallTotalEntry({
    this.totalType,
    this.existingLimit,
    this.proposedLimit,
    this.differenceLabel,
    this.differenceValue,
  });

  OverallTotalEntry.fromJson(Map<String, dynamic> json) {
    totalType = json['totalType'];
    existingLimit = _asNum(json['existingLimit']);
    proposedLimit = _asNum(json['proposedLimit']);
    differenceLabel = json['difference'];
    differenceValue = _asNum(json['differenceValue']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalType'] = totalType;
    data['existingLimit'] = existingLimit;
    data['proposedLimit'] = proposedLimit;
    data['differenceLabel'] = differenceLabel;
    data['differenceValue'] = differenceValue;
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
    if (s == 'true' || s == 't' || s == 'yes' || s == 'y') return true;
    if (s == 'false' || s == 'f' || s == 'no' || s == 'n') return false;
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
