import "dart:convert";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";

/// Represents contract information associated with a project,
/// including contract values, timelines, contractors, and collections.
class Contract {
  /// Creates a [Contract] instance.
  Contract({
    this.contractName,
    this.guarantees,
    this.completion,
    this.segment,
    this.total,
    this.type,
    this.contractCode,
    this.projectName,
    this.borrowerRole,
    this.customerName,
    this.rimNo,
    this.paymasterName,
    this.initialContractorVarient,
    this.originalCompletionVarient,
    this.projectTenor,
    this.contractAmount,
    this.expectedStartDate,
    this.expectedCompletionDate,
    this.originalCompletionDate,
    this.contractorScope,
    this.projectCode,
    this.projectUltimateOwner,
    this.projectOwnerEntity,
    this.projectOwnerRim,
    this.projectOwnerEntityRim,
    this.customerRimNo,
    this.originalValue,
    this.contractorId,
    this.contractorType,
    this.contractValue,
    this.completionPercentage,
    this.paymaster,
    this.cbdExposureGuarantees,
    this.cbdExposureTotal,
    this.appReffNo,
    this.isMainContractor,
    this.projectId,
    this.contractId,
    // this.contractCode,
    // this.projectId,
    // this.contractName,
    // this.rimNo,
    // this.borrowerRole,
    this.contractCurrency,
    // this.contractValue,
    // this.projectTenor,
    this.initialContractValue,
    this.contractValueAedAmount,
    // this.paymasterName,
    this.contractScope,
    // this.expectedStartDate,
    this.expectedEndDate,
    // this.completionPercentage,
    this.lastCompletionPercentage,
    this.variationAmount,
    this.originalStartDate,
    this.originalEndDate,
    this.variationPercent,
    this.projectCollectionAccount,
    // this.isMainContractor,
    this.linkCommitmentNumberWith,
    this.appRefNo,
    this.guarantee,
    this.ppcList,
    this.variationCompletionDate,
    this.variationContractValue,
  });

  /// Creates a [Contract] instance from project contract data.
  factory Contract.fromProjectContractJson(Map<String, dynamic> json) {
    return Contract(
      rimNo: (json["rimNo"] ?? "").toString(),
      contractName: json["contractorName"] ?? "",
      contractorId: json["contractorId"] ?? 0,
      segment: json["segment"] ?? "",
      contractorType: json["contractorType"] ?? "",
      contractCode: json["contractCode"] ?? "",
      contractValue: "${json['contractValue']}",
      //parseDouble(json['contractValue'] ?? 0),
      completionPercentage: ProjectContractNumericHelper.toDoubleOrNull(
        json["completionPercentage"] ?? 0,
      ),
      paymaster: json["paymaster"] ?? "",
      cbdExposureGuarantees: parseDouble(json["cbdExposureGuarantees"] ?? 0),
      cbdExposureTotal: parseDouble(json["cbdExposureTotal"] ?? 0),
    );
  }

  /// Creates a [Contract] instance from a JSON map.
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractName: json["contractorName"] ?? json["projectName"],
      completion: DateTimeUtils.intToDateTime(json["completion"]),
      guarantees: json["guarantees"],
      segment: json["segment"],
      total: json["total"],
      type: json["type"],
      contractCode: json["contractCode"],
      projectName: json["projectName"],
      borrowerRole: json["borrowerRole"] ?? json["borrowerRole"],
      customerName: json["contractorName"],
      rimNo: json["rimNo"] ?? json["rim"],
      paymasterName: json["paymasterName"],
      contractValue: (json["contractorValue"] as num?)?.toDouble() ??
          json["contractValue"],
      initialContractValue: json["initialContractValue"],
      initialContractorVarient: json["initialContractorVarient"],
      originalCompletionVarient: json["originalCompletionVarient"],
      projectTenor: json["projectTenor"],
      expectedStartDate: DateTimeUtils.intToDateTime(json["expectedStartDate"]),
      expectedCompletionDate:
          DateTimeUtils.intToDateTime(json["expectedCompletionDate"]),
      originalCompletionDate:
          DateTimeUtils.intToDateTime(json["originalCompletionDate"]),
      contractorScope: json["contractorScope"],
      projectCode: json["projectCode"],
      projectUltimateOwner: json["projectUltimateOwner"],
      projectOwnerEntity: json["projectOwnerEntity"],
      projectOwnerRim: json["projectOwnerRim"],
      projectOwnerEntityRim: json["projectOwnerEntityRim"],
    );
  }

  /// Creates a [Contract] instance from contract code data.
  factory Contract.fromContractByContractCodeJson(
    Map<String, dynamic> json,
  ) {
    return Contract(
      contractId: json["contractId"],
      contractCode: json["contractCode"],
      projectId: json["projectId"],
      contractName: json["contractName"],
      rimNo: json["rimNo"],
      borrowerRole: json["borrowerRole"],
      contractCurrency: json["contractCurrency"],
      contractValue:
          // ProjectContractNumericHelper.toDoubleOrNull(
          "${json['contractValue']}",
      //?? 0),
      initialContractValue: "${json['initialContractValue']}",
      //  ProjectContractNumericHelper.toDoubleOrNull(
      // json['initialContractValue'] ?? 0),
      projectTenor: json["projectTenor"],
      contractValueAedAmount:
          // ProjectContractNumericHelper.toDoubleOrNull(
          "${json['contractValueAedAmount']}",
      // ),
      paymasterName: json["paymasterName"],
      contractScope: json["contractScope"],
      variationCompletionDate: json["variationCompletionDate"],

      // If your model uses DateTime for these, see the DateTime parsing variant
      // below.

      expectedStartDate: DateTimeUtils.intToDateTime(json["expectedStartDate"]),
      expectedEndDate: DateTimeUtils.intToDateTime(json["expectedEndDate"]),

      originalStartDate: DateTimeUtils.intToDateTime(json["originalStartDate"]),
      originalEndDate: DateTimeUtils.intToDateTime(json["originalEndDate"]),
      originalCompletionDate:
          DateTimeUtils.intToDateTime(json["originalCompletionDate"]),

      variationContractValue: ProjectContractNumericHelper.toDoubleOrNull(
        json["variationContractValue"],
      ),

      completionPercentage: ProjectContractNumericHelper.toDoubleOrNull(
        json["completionPercentage"],
      ),
      lastCompletionPercentage: ProjectContractNumericHelper.toDoubleOrNull(
        json["lastCompletionPercentage"],
      ),
      variationAmount: json["variationAmount"],

      variationPercent: json["variationPercent"],
      isMainContractor: json["isMainContractor"],
      appRefNo: json["appRefNo"],
      // guarantee: json['guarantee'],

      // Parse projectCollectionAccount into Country list if present
      // projectCollectionAccount: json['projectCollectionAccount'],
      linkCommitmentNumberWith: (json["projectCollectionAccount"] is String)
          ? (json["projectCollectionAccount"] as String)
              .split(",")
              .map(
                (e) => LinkCommitmentNumber(projectAllocationAccount: e.trim()),
              )
              .toList()
          : [],

      //  Parse ppcList safely (null-safe and type-safe)
      ppcList: (json["ppcList"] as List<dynamic>?)
          ?.map((v) => PPC.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Name of the contract.
  String? contractName;

  /// Guarantees associated with the contract.
  String? guarantees;

  /// Customer segment.
  String? segment;

  /// Total contract count or value.
  int? total;

  /// Contract type.
  String? type;

  /// Contract completion date.
  DateTime? completion;

  /// Unique contract code.
  String? contractCode;

  /// Project name.
  String? projectName;

  /// Borrower role associated with the contract.
  String? borrowerRole;

  /// Customer name.
  String? customerName;

  /// Customer RIM number.
  String? rimNo;

  /// Name of the paymaster.
  String? paymasterName;

  /// Variation completion date.
  int? variationCompletionDate;

  /// Variation contract value.
  double? variationContractValue;

  /// Initial contractor variation value.
  int? initialContractorVarient;

  /// Original completion variation value.
  int? originalCompletionVarient;

  /// Project tenor.
  int? projectTenor;

  /// Expected project start date.
  DateTime? expectedStartDate;

  /// Expected project completion date.
  DateTime? expectedCompletionDate;

  /// Original project completion date.
  DateTime? originalCompletionDate;

  /// Scope of work performed by the contractor.
  String? contractorScope;

  /// Project code.
  String? projectCode;

  /// Ultimate project owner.
  String? projectUltimateOwner;

  /// Project owner entity.
  String? projectOwnerEntity;

  /// Application reference number.
  String? appReffNo;

  /// Project owner RIM number.
  int? projectOwnerRim;

  /// Project owner entity RIM number.
  int? projectOwnerEntityRim;

  /// Customer RIM number.
  int? customerRimNo;

  /// Original contract value.
  int? originalValue;

  /// Contractor identifier.
  int? contractorId;

  /// Type of contractor.
  String? contractorType;

  /// Contract value.
  String? contractValue;

  /// Contract completion percentage.
  double? completionPercentage;

  /// Paymaster identifier.
  String? paymaster;

  /// CBD exposure guarantees amount.
  double? cbdExposureGuarantees;

  /// Total CBD exposure amount.
  double? cbdExposureTotal;

  /// Contract amount.
  String? contractAmount;

  /// Indicates whether the contractor is the main contractor.
  bool? isMainContractor = false;

  /// Project identifier.
  String? projectId;

  /// Contract identifier.
  String? contractId;

  /// Contract currency.
  String? contractCurrency;

  /// Initial contract value.
  String? initialContractValue;

  /// Contract value in AED.
  String? contractValueAedAmount;

  /// Contract scope.
  String? contractScope;

  /// Expected contract end date.
  DateTime? expectedEndDate;

  /// Previous completion percentage.
  double? lastCompletionPercentage;

  /// Contract variation amount.
  double? variationAmount;

  /// Original project start date.
  DateTime? originalStartDate;

  /// Original project end date.
  DateTime? originalEndDate;

  /// Contract variation percentage.
  double? variationPercent;

  /// Project collection account amount.
  double? projectCollectionAccount;

  /// Application reference number.
  String? appRefNo;

  /// Guarantee amount.
  double? guarantee;

  /// Linked commitment numbers associated with the contract.
  List<LinkCommitmentNumber>? linkCommitmentNumberWith;

  /// Progress payment certificate records.
  List<PPC>? ppcList;

  String? paymasterRimSearch;
  bool? hasRim = false;

  /// Converts this [Contract] instance to a project contract JSON payload.
  Map<String, dynamic> toProjectContractJson() {
    return {
      "rimNo": rimNo,
      "contractorId": contractorId,
      "segment": segment,
      "contractorType": contractorType,
      "contractCode": contractCode,
      "contractValue": contractValue,
      "completionPercentage": completionPercentage,
      "paymaster": paymaster,
      "cbdExposureGuarantees": cbdExposureGuarantees,
      "cbdExposureTotal": cbdExposureTotal,
    };
  }

  /// Converts this [Contract] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["contractName"] = contractName;
    data["completion"] = completion;
    data["guarantees"] = guarantees;
    data["segment"] = segment;
    data["total"] = total;
    data["type"] = type;
    data["contractCode"] = contractCode;
    data["projectCode"] = projectCode;
    data["projectName"] = projectName;
    data["projectUltimateOwner"] = projectUltimateOwner;
    data["projectOwnerEntity"] = projectOwnerEntity;
    data["projectOwnerRim"] = projectOwnerRim;
    data["projectOwnerEntityRim"] = projectOwnerEntityRim;
    data["borrowerRole"] = borrowerRole;
    data["expectedCompletionDate"] =
        DateTimeUtils.datetimeToInt(expectedCompletionDate);
    data["expectedStartDate"] = DateTimeUtils.datetimeToInt(expectedStartDate);
    data["paymasterName"] = paymasterName;
    data["projectTenor"] = projectTenor;
    data["contractorScope"] = contractorScope;
    data["contractValue"] = contractValue;
    data["customerName"] = customerName;
    data["rimNo"] = customerRimNo;
    logger..i("-------contract son-------")
    ..i(" $json");
    return data;
  }

  /// Converts this [Contract] instance to a contract save JSON payload.
  Map<String, dynamic> toSaveContractJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["projectCode"] = projectCode;
    data["projectName"] = projectName;
    data["projectId"] = projectId;

    data["contractName"] = contractName;
    data["rimNo"] = rimNo;
    data["borrowerRole"] = borrowerRole;
    data["contractCode"] = contractCode;

    data["paymasterName"] = paymasterName;
    data["projectTenor"] = projectTenor;
    data["contractValue"] = contractAmount ?? contractValue;
    // data['contractValueAedAmount'] =
    //     contractCurrency != ServerConstants.aedCurrency
    //         ? contractValueAedAmount
    //         : contractAmount ?? contractValue;
    data["contractValueAedAmount"] =
        ((contractCurrency ?? ServerConstants.aedCurrency) !=
                    ServerConstants.aedCurrency
                ? contractValueAedAmount
                : contractAmount)
            ?.replaceAll(",", "");
    data["initialContractValue"] = initialContractValue;
    data["appRefNo"] = appReffNo;
    data["isMainContractor"] = isMainContractor;

    data["contractCurrency"] = contractCurrency ?? ServerConstants.aedCurrency;

    data["contractScope"] = contractScope;
    data["completionPercentage"] = completionPercentage;

    data["variationCompletionDate"] =
        (variationCompletionDate.toString() == "NA")
            ? 0
            : variationCompletionDate;
    data["variationContractValue"] = (variationContractValue.toString() == "NA")
        ? 0
        : variationContractValue;

    // data['guarantee'] = guarantee;
    data["lastCompletionPercentage"] = lastCompletionPercentage;
    if (linkCommitmentNumberWith != null &&
        linkCommitmentNumberWith!.isNotEmpty) {
      data["projectCollectionAccount"] = linkCommitmentNumberWith!
          .map((e) => e.projectAllocationAccount)
          .join(", ");
    }

    data["expectedEndDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedEndDate),
    );
    data["expectedStartDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedStartDate),
    );

    data["originalCompletionDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(originalCompletionDate),
    );
    data["originalStartDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(originalStartDate),
    );
    data["originalEndDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(originalEndDate),
    );

    // data['ppcList'] = ppcList ?? [];
    data["ppcList"] = (ppcList ?? const <PPC>[])
        .map(
          (ppcItem) => PPC(
            ppcId: ppcItem.ppcId,
            ppcNo: ppcItem.ppcNo,
            ppcDate: ppcItem.ppcDate,
            grossValue: ppcItem.grossValue,
            cumulativeValue: ppcItem.cumulativeValue,
            workDone: ppcItem.workDone,
            cumulativeWorkDone: ppcItem.cumulativeWorkDone,
            netValue: ppcItem.netValue,
            vatAmount: ppcItem.vatAmount,
            otherPayment: ppcItem.otherPayment,
            totalWithVat: ppcItem.totalWithVat,
            actualPaymentReceived: ppcItem.actualPaymentReceived,
            advancePaymentDeduction: ppcItem.advancePaymentDeduction,
            retentionDeduction: ppcItem.retentionDeduction,
            datePaymentReceived: ppcItem.datePaymentReceived,
            comments: ppcItem.comments,
          ).toJson(),
        )
        .toList();

    logger.i("$json");
    return data;
  }

  /// Converts this [Contract] instance to a linked contract JSON payload.
  Map<String, dynamic> toSaveLinkJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["projectCode"] = projectCode;
    data["projectName"] = projectName;
    data["projectId"] = projectId;

    data["contractName"] = contractName;
    data["rimNo"] = customerRimNo;
    data["borrowerRole"] = borrowerRole;
    data["contractCode"] = contractCode;
    data["contractCurrency"] = contractCurrency ?? ServerConstants.aedCurrency;
    data["paymasterName"] = paymasterName;
    data["projectTenor"] = projectTenor ??= 0;
    data["contractValue"] = contractAmount ?? contractValue;
    data["initialContractValue"] =
        ((contractCurrency ?? ServerConstants.aedCurrency) !=
                    ServerConstants.aedCurrency
                ? contractValueAedAmount
                : contractAmount ?? initialContractValue)
            ?.replaceAll(",", "");
    data["contractValueAedAmount"] =
        ((contractCurrency ?? ServerConstants.aedCurrency) !=
                    ServerConstants.aedCurrency
                ? contractValueAedAmount
                : contractAmount ?? contractValueAedAmount)
            ?.replaceAll(",", "");
    data["appRefNo"] = appReffNo;
    data["isMainContractor"] = isMainContractor;
    data["expectedEndDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedCompletionDate),
    );
    data["expectedStartDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedStartDate),
    );
    data["ppcList"] = [];

    data["contractScope"] = contractScope;
    data["completionPercentage"] = completionPercentage;
    data["originalStartDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedStartDate),
    );
    data["originalCompletionDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedCompletionDate),
    );
    data["originalEndDate"] = DateTimeUtils.getDateAsString(
      DateTimeUtils.formatDateForSubmission(expectedCompletionDate),
    );

    // data['guarantee'] = completion;
    // data['lastCompletionPercentage'] = completion;
    // data['projectCollectionAccount'] = completion;
    // data['originalCompletionDate'] = completion;
    // data['originalStartDate'] = completion;
    // data['originalEndDate'] = completion;

    logger.i("$json");
    return data;
  }

  /// Converts this [Contract] instance to a contract-by-code JSON payload.
  Map<String, dynamic> toContractByContractCodeJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["contractId"] = contractId;
    data["contractCode"] = contractCode;
    data["projectId"] = projectId;
    data["contractName"] = contractName;
    data["rimNo"] = rimNo;
    data["borrowerRole"] = borrowerRole;
    data["contractCurrency"] = contractCurrency;
    data["contractValue"] = contractValue;
    data["projectTenor"] = projectTenor;
    data["initialContractValue"] = initialContractValue;
    data["contractValueAedAmount"] = contractValueAedAmount;
    data["paymasterName"] = paymasterName;
    data["contractScope"] = contractScope;
    data["expectedStartDate"] = expectedStartDate;
    data["expectedEndDate"] = expectedEndDate;
    data["completionPercentage"] = completionPercentage;
    data["lastCompletionPercentage"] = lastCompletionPercentage;
    data["variationAmount"] = variationAmount;
    data["originalStartDate"] = originalStartDate;
    data["originalEndDate"] = originalEndDate;
    data["variationPercent"] = variationPercent;
    data["projectCollectionAccount"] = projectCollectionAccount;
    data["isMainContractor"] = isMainContractor;
    data["appRefNo"] = appRefNo;
    // data['guarantee'] = guarantee;

    if (ppcList != null) {
      data["ppcList"] = ppcList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Safely parse an integer from dynamic.
/// Accepts int, double, numeric strings (e.g., "123", "123.0"), or null.
/// Returns null if it can't parse.
int? parseInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.truncate(); // or round if you prefer
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final v = value.trim();
    if (v.isEmpty) {
      return null;
    }
    // Remove commas or spaces in formatted numbers "1,234"
    final normalized = v.replaceAll(",", "");
    final asInt = int.tryParse(normalized);
    if (asInt != null) {
      return asInt;
    }

    // Sometimes "123.0" should be treated as 123
    final asDouble = double.tryParse(normalized);
    return asDouble?.truncate();
  }
  return null;
}

/// Safely parse a double from dynamic.
/// Accepts double, int, numeric strings, or null.
/// Returns null if it can't parse.
double? parseDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final v = value.trim();
    if (v.isEmpty) {
      return null;
    }
    final normalized = v.replaceAll(",", "");
    return double.tryParse(normalized);
  }
  return null;
}
