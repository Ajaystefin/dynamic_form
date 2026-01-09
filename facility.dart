import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';

class Facility {
  int? facilityId;
  String? facilityTypeName;
  String? limitNumber;
  String? appRefNo;
  String? controllingLimitNumber;
  String? limitLabel;
  String? limitDescription;
  String? remarks;
  String? additionalDetails;
  String? facilityTitle;
  String? limitAllocation;
  String? limitAllocationCustomerRIM;
  String? facilityDetails;
  String? subFacilityDetails;
  String? applicablePricing;
  String? margin;
  DateTime? limitAvailabilityDate;
  String? limitAvailabilityPeriod;

  DateTime? limitExpireDate;
  int? limitGroup;
  int? limitCode;
  // int? limitGroup;
  Country? selectedCountry;
  List<Country>? countryRiskWith;

  int? sNo;
  int? rimNo;
  int? presentLimit;
  int? proposedLimit;
  int? proposedLimitAED;
  int? existingLimits;
  int? proposedLimits;
  int? outstanding;
  int? tenorDays;

  // Boolean flags
  bool isPolicyDeviation;
  bool isConditionsStandard;
  bool isCrossBoarderExposure;
  bool limitType;

  // Reference fields
  Reference? projectName;
  Reference? selectedCollateralDepantantValue;
  Reference? selectedProductTypeValue;
  Reference? selectedProjectFinanceRelatedActivityValue;
  Reference? selectedpromissoryNoteValue;
  Reference? selectedRegulatorySpecialisedLandingValue;
  Reference? commitmentAccountNumber;
  Reference? selectedLimitTypeValue;
  Reference? sharedLimit;
  Reference? sicCode;
  Reference? accountTypeValue;
  Reference? presentOutstandingCCValue;
  Reference? limitTypeValue;
  Reference? proposedLimitValue;
  Reference? presentLimitValue;
  Reference? originalLimitCCValue;
  Reference? seniorityValue;
  Reference? commitmentAccountNumberValue;
  Reference? purposeValue;
  Reference? propertyType;
  Reference? advanceTypeValue;
  Reference? purpose;
  // Reference? purpose;
  Reference? sector;
  Reference? facilityTypeSelectedValue;
  Reference? facilityDescription;
  Reference? borrowerValue;
  Reference? pastDues;
  Reference? limitAmount;
  Reference? outstandingAmount;
  Reference? proposedByCC;
  Reference? regulatorySpecification;
  Reference? promissoryNoteOptions;
  Reference? propertySubType;
  Reference? emirates;
  Reference? selectedSustanabilityValue;
  Reference? committedValues;
  String? countryOfRisk;
  String? currency;
  bool? isCommitted;
  bool? isMainLimit;

  List<Reference>? sustainabilityClassification;
  Reference? proposedFacilityAmtCurrency;
  List<Reference>? policyDeviation;

  Facility(
      {this.rimNo,
      this.committedValues,
      this.selectedSustanabilityValue,
      this.countryOfRisk,
      this.isCommitted,
      this.isMainLimit,
      this.sNo,
      this.facilityDetails,
      this.subFacilityDetails,
      this.sustainabilityClassification,
      this.existingLimits,
      this.proposedLimits,
      this.outstanding,
      this.tenorDays,
      this.applicablePricing,
      this.margin,
      this.limitAvailabilityPeriod,
      this.emirates,
      this.limitType = false,
      // this.limitType = false,
      this.limitNumber,
      this.appRefNo,
      this.controllingLimitNumber,
      this.limitLabel,
      this.limitDescription,
      this.presentLimit,
      this.limitGroup,
      this.limitCode,
      this.proposedLimit,
      this.proposedLimitAED,
      this.currency,
      this.facilityId,
      this.remarks,
      this.additionalDetails,
      this.isPolicyDeviation = false,
      this.policyDeviation,
      this.isConditionsStandard = false,
      this.isCrossBoarderExposure = false,
      this.projectName,
      this.selectedCollateralDepantantValue,
      this.selectedProductTypeValue,
      this.selectedProjectFinanceRelatedActivityValue,
      this.selectedpromissoryNoteValue,
      this.selectedRegulatorySpecialisedLandingValue,
      this.selectedCountry,
      this.commitmentAccountNumber,
      this.selectedLimitTypeValue,
      this.sharedLimit,
      this.sicCode,
      this.accountTypeValue,
      this.presentOutstandingCCValue,
      this.limitTypeValue,
      this.proposedLimitValue,
      this.presentLimitValue,
      this.originalLimitCCValue,
      this.seniorityValue,
      this.commitmentAccountNumberValue,
      this.purposeValue,
      this.propertyType,
      this.advanceTypeValue,
      this.proposedFacilityAmtCurrency,
      this.purpose,
      this.sector,
      this.facilityTypeSelectedValue,
      this.facilityDescription,
      this.borrowerValue,
      this.pastDues,
      this.limitAmount,
      this.outstandingAmount,
      this.proposedByCC,
      this.regulatorySpecification,
      this.promissoryNoteOptions,
      this.facilityTypeName,
      this.facilityTitle});

  Map<String, dynamic> toJson() {
    String? fetchValueFromReference(Reference? r) => r?.name;
    int? fetchIdFromReference(Reference? r) => r?.id;
    bool fetchBoolValue(Reference? r) => r?.id == ServerConstants.optionYESid;

    return {
      'rimNo': rimNo,
      'groupId': 0,
      'limitGroup': limitGroup,
      'limitCategory': fetchValueFromReference(limitTypeValue),
      'productCode': fetchValueFromReference(selectedProductTypeValue),
      'productType': fetchIdFromReference(selectedProductTypeValue),
      'promissoryNoteTaken': fetchBoolValue(selectedpromissoryNoteValue),
      'advanceType': fetchIdFromReference(advanceTypeValue),
      'purpose': fetchIdFromReference(purpose),
      'sharedLimit': fetchBoolValue(sharedLimit),
      'limitDescription': fetchIdFromReference(facilityDescription),
      "isCommitted": isCommitted,
      "isMainLimit": isMainLimit,
      "limitAvailabilityPeriod": limitAvailabilityPeriod,
      'proposedLimit': proposedLimit,
      'proposedLimitAED': proposedLimitAED,
      // 'limitNumber': limitNumber,
      'limitExpiryDate':
          limitExpireDate, // Add DateTime conversion if needed for backend
      'limitAvailabilityDate':
          limitAvailabilityDate, // Add DateTime conversion if needed for backend
      'financialActivity':
          fetchBoolValue(selectedProjectFinanceRelatedActivityValue),
      'limitLabel': limitLabel,
      'regulatorySpecialisedLending':
          fetchBoolValue(selectedRegulatorySpecialisedLandingValue),
      'regSpecializedLendingFinancialType':
          fetchValueFromReference(regulatorySpecification),
      'countryOfRisk': selectedCountry?.description,
      'committed': fetchBoolValue(commitmentAccountNumberValue),
      'seniority': fetchIdFromReference(seniorityValue),
      'accountType': accountTypeValue != null
          ? [fetchIdFromReference(accountTypeValue)]
          : [],
      'sectorDescription': fetchIdFromReference(sector),
      'sicCode': fetchIdFromReference(sicCode),
      'revolvingType': '',
      // "controllingLimitNo": json['controllingLimitNo'] as String?,
      'collateralDependent': fetchBoolValue(selectedCollateralDepantantValue),
      'commitmentAcctNo': fetchValueFromReference(commitmentAccountNumber),
      'conditions': '',
      'remarks': remarks,
      'forIslamicCust': [''],
      'propertyType': fetchValueFromReference(propertyType),
      'propertySubType': '',
      'emirates': fetchIdFromReference(emirates),
      // 'emirates': fetchIdFromReference(emirates),
      'outStandingAmount': fetchValueFromReference(presentOutstandingCCValue),
      'additionalDetails': additionalDetails,
      'draft': false,
      'limitNo': limitNumber,
      "facilityTypeName": facilityTypeName,
      "facilityTypeName": facilityTypeName,
      "projectName": projectName?.name,
      'policyDeviation': policyDeviation?.map((e) => e.name).join(', ')
    };
  }

  factory Facility.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Facility(
        rimNo: parseInt(json['rimNo']),
        limitGroup: parseInt(json['limitGroup']),
        limitCode: parseInt(json['limitCode']),
        limitNumber: (json['limitNumber'] ?? json['limitNo']) as String?,
        appRefNo: json['appRefNo'] as String?,
        controllingLimitNumber: json['controllingLimitNo'] as String?,
        limitLabel: json['limitLabel'] ?? json['projectName'] as String?,
        limitDescription:
            json['limitDescription'] ?? json['facilityTypeName'].toString(),
        countryOfRisk:
            (json['countryOfRisk'] ?? json['Country_of_Risk']) as String?,
        presentLimit: json['presentLimit'],
        proposedLimit: json['proposedLimit'],
        facilityId: json['facilityID'],
        remarks: json['remarks'] as String?,
        additionalDetails: json['additionalDetails'] as String?,
        sNo: json['S_No'],
        proposedFacilityAmtCurrency: Reference(name: json['currency']),
        facilityDetails: json['Facility_Details'],
        subFacilityDetails: json['Sub_Facility_Details'],
        sustainabilityClassification:
            (json['Sustainability_Classification'] as List?)
                    ?.map((e) => Reference(name: e.toString()))
                    .toList() ??
                [],
        policyDeviation: (json['policyDeviation'] as String?)
            ?.split(',')
            .where((e) => e.trim().isNotEmpty)
            .map((e) => Reference(name: e.trim()))
            .toList(),
        isMainLimit: json['isMainLimit'],
        existingLimits: json['Existing_Limits'],
        proposedLimits: json['Proposed_Limits'],
        outstanding: json['Outstanding'],
        tenorDays: json['Tenor_Days'],
        applicablePricing: json['Applicable_Pricing'],
        margin: json['Margin'],
        seniorityValue: Reference(id: json['seniority']),
        limitAvailabilityPeriod: json['limitAvailabilityPeriod'],
        projectName: (json['projectName'] != null)
            ? Reference(name: json["projectName"])
            : null,
        facilityTypeName: json['facilityTypeName']);
  }

  factory Facility.fromJsonLinkage(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value, {String defaultValue = ""}) {
      if (value == null) return defaultValue;

      if (value is String) return value.trim();
      if (value is int || value is double) return value.toString();

      return defaultValue;
    }

    return Facility(
        rimNo: parseInt(json['rimNo']),
        limitLabel: json['limitLabel'] ?? json['projectName'] as String?,
        limitNumber: (json['limitNumber'] ?? json['limitNo']),
        limitCode: parseInt(json['limitCode']),
        appRefNo: json['appRefNo'] as String?,
        controllingLimitNumber: json['controllingLimitNumber'],
        limitDescription: parseString(json['limitDescription']),
        proposedLimit: json['proposedLimit'],
        proposedLimitAED: json['proposedLimitAED'],
        currency: json['currency'],
        projectName: (json['projectName'] != null)
            ? Reference(name: json["projectName"])
            : null);
  }
}

class FacilitySubTypes {
  bool? subTypeSelected;
  String? subType;
  String? commitmentAccountNumber;
  int? currentOutstanding;
  int? pastDues;
  int? limitAmount;
  int? outstandingAmount;
  int? originalLimitCCValue;
  int? existingAmounts;
  int? proposedLimit;
  int? tenor;
  int? commission;

  FacilitySubTypes({
    this.subTypeSelected,
    this.subType,
    this.commitmentAccountNumber,
    this.currentOutstanding,
    this.pastDues,
    this.limitAmount,
    this.outstandingAmount,
    this.originalLimitCCValue,
    this.existingAmounts,
    this.proposedLimit,
    this.tenor,
    this.commission,
  });

  FacilitySubTypes.fromJson(Map<String, dynamic> json) {
    subTypeSelected = json['subTypeSelected'];
    subType = json['subType'];
    commitmentAccountNumber = json['commitmentAccountNumber'];
    currentOutstanding = json['currentOutstanding'];
    pastDues = json['pastDues'];
    limitAmount = json['limitAmount'];
    outstandingAmount = json['outstandingAmount'];
    originalLimitCCValue = json['originalLimit'];
    existingAmounts = json['existingAmounts'];
    proposedLimit = json['proposedLimit'];
    tenor = json['tenor'];
    commission = json['commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subTypeSelected'] = subTypeSelected;
    data['subType'] = subType;
    data['commitmentAccountNumber'] = commitmentAccountNumber;
    data['currentOutstanding'] = currentOutstanding;
    data['pastDues'] = pastDues;
    data['limitAmount'] = limitAmount;
    data['outstandingAmount'] = outstandingAmount;
    data['originalLimit'] = originalLimitCCValue;
    data['existingAmounts'] = existingAmounts;
    data['proposedLimit'] = proposedLimit;
    data['tenor'] = tenor;
    data['commission'] = commission;
    return data;
  }
}

class FeeDefaultRate {
  String? defaultRate;
  int? percentage, amount, feeID;
  List<String>? frequencies = [];
  String? comments, frequency;

  FeeDefaultRate(
      {this.defaultRate,
      this.amount,
      this.percentage,
      this.frequency,
      this.comments,
      this.frequencies,
      this.feeID});

  FeeDefaultRate.fromJson(Map<String, dynamic> json) {
    percentage = json['percentage'];
    frequency = json['frequency'];
    defaultRate = json['defaultRate'];
    amount = json['amount'];
    comments = json['comments'];
    // feeID = json['comments'];
    frequencies = (json['frequencies'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['percentage'] = percentage;
    data['frequency'] = frequency;
    data['defaultRate'] = defaultRate;
    data['amount'] = amount;
    data['comments'] = comments;
    return data;
  }
}

class StandardCondition {
  String? standardCondition;
  String? actions;
  StandardCondition({
    this.standardCondition,
    this.actions,
  });

  StandardCondition.fromJson(Map<String, dynamic> json) {
    standardCondition = json['standardCondition'];
    actions = json['actions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['standardCondition'] = standardCondition;
    data['actions'] = actions;

    return data;
  }
}

class CreateFacilityArgs {
  final int? facilityId; // or int?, depending on your data
  final Facility facility;
  final bool showCreateFacilityForm;

  const CreateFacilityArgs({
    this.facilityId,
    required this.facility,
    required this.showCreateFacilityForm,
  });
}
