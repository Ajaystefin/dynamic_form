import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';

class Project {
  String? code;
  String? name;
  String? ultimateOwner;
  String? ownerEntity;
  int? ownerRim;
  int? ownerEntityRim;
  double? projectValue;
  DateTime? period;
  int? completion;
  DateTime? liabilityEndDate;
  String? summary;
  String? initalProjectValue;
  String? currentProjectValue;
  List<Contract>? contract;

  Project(
      {this.code,
      this.name,
      this.ultimateOwner,
      this.ownerEntity,
      this.ownerRim,
      this.ownerEntityRim,
      this.projectValue,
      this.period,
      this.completion,
      this.liabilityEndDate,
      this.summary,
      this.initalProjectValue,
      this.currentProjectValue,
      this.contract});

  Project.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    ultimateOwner = json['ultimateOwner'];
    ownerEntity = json['ownerEntity'];
    ownerRim = json['ownerRim'];
    ownerEntityRim = json['ownerEntityRim'];
    projectValue = json['projectValue'];
    period = DateTimeUtils.intToDateTime(json['period']);
    completion = json['completion'];
    liabilityEndDate = DateTimeUtils.intToDateTime(json['liabilityEndDate']);
    summary = json['summary'];
    initalProjectValue = json['initalProjectValue'];
    currentProjectValue = json['currentProjectValue'];
    if (json['Contract'] != null) {
      contract = <Contract>[];
      json['Contract'].forEach((v) {
        contract!.add(Contract.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['ultimateOwner'] = ultimateOwner;
    data['ownerEntity'] = ownerEntity;
    data['ownerRim'] = ownerRim;
    data['ownerEntityRim'] = ownerEntityRim;
    data['projectValue'] = projectValue;
    data['period'] = DateTimeUtils.datetimeToInt(period);
    data['completion'] = completion;
    data['liabilityEndDate'] = DateTimeUtils.datetimeToInt(liabilityEndDate);
    data['summary'] = summary;
    data['initalProjectValue'] = initalProjectValue;
    data['currentProjectValue'] = currentProjectValue;
    if (contract != null) {
      data['Contract'] = contract!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
