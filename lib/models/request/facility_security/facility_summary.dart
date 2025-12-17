import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

class CustomerFacility {
  int? rimNo;
  String? custName;
  FacilityGroup? generalWorkingCapitalLimits;
  FacilityGroup? loans;
  FacilityGroup? ppeLimits;
  FacilityGroup? projectStandbyLimits;
  ProjectSpecificLimit? projectSpecificLimit;
  OverallTotal? overallTotal;
  Reference? limitType;
  Reference? subLimitType;

  CustomerFacility({
    this.rimNo,
    this.custName,
    this.generalWorkingCapitalLimits,
    this.loans,
    this.ppeLimits,
    this.projectStandbyLimits,
    this.projectSpecificLimit,
    this.overallTotal,
    this.limitType,
    this.subLimitType,
  });

  factory CustomerFacility.fromJson(Map<String, dynamic> json) {
    return CustomerFacility(
      rimNo: json['rim_no'],
      custName: json['cust_name'],
      generalWorkingCapitalLimits:
          json['General_Working_Capital_Limits'] != null
              ? FacilityGroup.fromJson(json['General_Working_Capital_Limits'],
                  'total_working_capital_limits')
              : null,
      loans: json['Loans'] != null
          ? FacilityGroup.fromJson(json['Loans'], 'total_loans')
          : null,
      ppeLimits: json['PPE_Limits'] != null
          ? FacilityGroup.fromJson(json['PPE_Limits'], 'total_ppe_limits')
          : null,
      projectStandbyLimits: json['Project_Standby_Limits'] != null
          ? FacilityGroup.fromJson(
              json['Project_Standby_Limits'], 'total_project_standby_limits')
          : null,
      projectSpecificLimit: json['Project_Specific_Limit'] != null
          ? ProjectSpecificLimit.fromJson(json['Project_Specific_Limit'])
          : null,
      overallTotal: json['overallTotal'] != null
          ? OverallTotal.fromJson(json['overallTotal'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'rim_no': rimNo,
        'cust_name': custName,
        'General_Working_Capital_Limits':
            generalWorkingCapitalLimits?.toJson('total_working_capital_limits'),
        'Loans': loans?.toJson('total_loans'),
        'PPE_Limits': ppeLimits?.toJson('total_ppe_limits'),
        'Project_Standby_Limits':
            projectStandbyLimits?.toJson('total_project_standby_limits'),
        'Project_Specific_Limit': projectSpecificLimit?.toJson(),
        'overallTotal': overallTotal?.toJson(),
      };
}

class FacilityGroup {
  int? total;
  int? typeId;
  List<Facility>? facilities;

  FacilityGroup({this.total, this.typeId, this.facilities});

  factory FacilityGroup.fromJson(Map<String, dynamic> json, String totalKey) {
    return FacilityGroup(
      total: json[totalKey],
      typeId: json['type_id'],
      facilities: (json['facilities'] as List?)
              ?.map((e) => Facility.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson(String totalKey) => {
        totalKey: total,
        'type_id': typeId,
        'facilities': facilities?.map((f) => f.toJson()).toList(),
      };
}

class ProjectSpecificLimit {
  Project? project;
  int? typeId;

  ProjectSpecificLimit({this.project, this.typeId});

  factory ProjectSpecificLimit.fromJson(Map<String, dynamic> json) =>
      ProjectSpecificLimit(
        project:
            json['Project'] != null ? Project.fromJson(json['Project']) : null,
        typeId: json['type_id'],
      );

  Map<String, dynamic> toJson() => {
        'Project': project?.toJson(),
        'type_id': typeId,
      };
}

class Project {
  String? projectName;
  int? totalProjectStandbyLimits;
  List<Facility>? facilities;

  Project({this.projectName, this.totalProjectStandbyLimits, this.facilities});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        projectName: json['project_name'],
        totalProjectStandbyLimits: json['total_project_standby_limits'],
        facilities: (json['facilities'] as List?)
                ?.map((e) => Facility.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'project_name': projectName,
        'total_project_standby_limits': totalProjectStandbyLimits,
        'facilities': facilities?.map((f) => f.toJson()).toList(),
      };
}

class OverallTotal {
  String? title;
  List<Limits>? limits;

  OverallTotal({this.title, this.limits});

  factory OverallTotal.fromJson(Map<String, dynamic> json) => OverallTotal(
        title: json['title'],
        limits: (json['limits'] as List?)
                ?.map((e) => Limits.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'limits': limits?.map((e) => e.toJson()).toList(),
      };
}

class Limits {
  String? description;
  int? existingLimit;
  int? proposedLimit;
  String? remark;

  Limits(
      {this.description, this.existingLimit, this.proposedLimit, this.remark});

  factory Limits.fromJson(Map<String, dynamic> json) => Limits(
        description: json['description'],
        existingLimit: json['existingLimit'],
        proposedLimit: json['proposedLimit'],
        remark: json['remark'],
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'existingLimit': existingLimit,
        'proposedLimit': proposedLimit,
        'remark': remark,
      };
}
