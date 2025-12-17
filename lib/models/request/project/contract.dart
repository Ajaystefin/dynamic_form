import 'dart:convert';

import 'package:wcas_frontend/core/utils/date_time_utils.dart';

class Contract {
  String? contractName;
  String? guarantees;
  String? segment;
  int? total;
  String? type;
  DateTime? completion;
  final String? contractCode;
  final String? projectName;
  String? borrowerRole;
  String? customerName;
  final int? rimNo;
  String? paymasterName;
  double? contractorValue;
  double? initialContractorValue;
  final int? initialContractorVarient;
  final int? originalCompletionVarient;
  String? projectTenor;
  DateTime? expectedStartDate;
  DateTime? expectedCompletionDate;
  final DateTime? originalCompletionDate;
  String? contractorScope;
  String? projectCode;
  String? projectUltimateOwner;
  String? projectOwnerEntity;
  int? projectOwnerRim;
  int? projectOwnerEntityRim;
  int? customerRimNo;
  int? originalValue;

  Contract(
      {this.contractName,
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
      this.contractorValue,
      this.initialContractorValue,
      this.initialContractorVarient,
      this.originalCompletionVarient,
      this.projectTenor,
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
      this.originalValue});

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      contractName: json['contractName'] ?? json['projectName'],
      completion: DateTimeUtils.intToDateTime(json['completion']),
      guarantees: json['guarantees'],
      segment: json['segment'],
      total: json['total'],
      type: json['type'],
      contractCode: json['contractCode'],
      projectName: json['projectName'],
      borrowerRole: json['borrowerRole'] ?? json['borrowerRole'],
      customerName: json['customerName'],
      rimNo: json['rimNo'] ?? json['rim'],
      paymasterName: json['paymasterName'],
      contractorValue: (json['contractorValue'] as num?)?.toDouble() ??
          json['contractValue'],
      initialContractorValue:
          (json['initialContractorValue'] as num?)?.toDouble(),
      initialContractorVarient: json['initialContractorVarient'],
      originalCompletionVarient: json['originalCompletionVarient'],
      projectTenor: json['projectTenor'],
      expectedStartDate: DateTimeUtils.intToDateTime(json['expectedStartDate']),
      expectedCompletionDate:
          DateTimeUtils.intToDateTime(json['expectedCompletionDate']),
      originalCompletionDate:
          DateTimeUtils.intToDateTime(json['originalCompletionDate']),
      contractorScope: json['contractorScope'],
      projectCode: json['projectCode'],
      projectUltimateOwner: json['projectUltimateOwner'],
      projectOwnerEntity: json['projectOwnerEntity'],
      projectOwnerRim: json['projectOwnerRim'],
      projectOwnerEntityRim: json['projectOwnerEntityRim'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contractName'] = contractName;
    data['completion'] = completion;
    data['guarantees'] = guarantees;
    data['segment'] = segment;
    data['total'] = total;
    data['type'] = type;
    data['contractCode'] = contractCode;
    data['projectCode'] = projectCode;
    data['projectName'] = projectName;
    data['projectUltimateOwner'] = projectUltimateOwner;
    data['projectOwnerEntity'] = projectOwnerEntity;
    data['projectOwnerRim'] = projectOwnerRim;
    data['projectOwnerEntityRim'] = projectOwnerEntityRim;
    data['borrowerRole'] = borrowerRole;
    data['expectedCompletionDate'] =
        DateTimeUtils.datetimeToInt(expectedCompletionDate);
    data['expectedStartDate'] = DateTimeUtils.datetimeToInt(expectedStartDate);
    data['paymasterName'] = paymasterName;
    data['projectTenor'] = projectTenor;
    data['contractorScope'] = contractorScope;
    data['contractorValue'] = contractorValue;
    data['customerName'] = customerName;
    data['rimNo'] = customerRimNo;
    // ignore: avoid_print
    print('-------contract son-------');
    // ignore: avoid_print
    print(json);
    return data;
  }
}
