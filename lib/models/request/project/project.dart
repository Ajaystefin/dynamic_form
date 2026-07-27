import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/request/project/contract.dart";

/// Represents project information and associated contracts.
class Project {
  /// Creates a [Project] instance.
  Project({
    // this.code,
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
    this.projectId,
    this.projectCode,
    this.projectName,
    this.projectOwnerRimNo,
    this.projectOwnerEntityRimNo,
    this.projectUltimateOwnerName,
    this.projectOwnerEntityName,
    this.projectValueCurrent,
    this.defectLiabilityEndDate,
    this.projectPeriod,
    this.projectCompletion,
    this.initialProjectValue,
    this.projectSummary,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.facilityId,
    this.contract,
  });

  /// Creates a [Project] instance from search result data.
  Project.fromSearchJson(Map<String, dynamic> json) {
    projectId = json["projectId"];
    projectCode = json["projectCode"];
    projectName = json["projectName"];
    projectOwnerRimNo = toIntOrNull(json["projectOwnerRimNo"]);
    projectOwnerEntityRimNo = toIntOrNull(json["projectOwnerEntityRimNo"]);
    projectUltimateOwnerName = json["projectUltimateOwnerName"];
    projectOwnerEntityName = json["projectOwnerEntityName"];
    projectValueCurrent =
        // ProjectContractNumericHelper.toDoubleOrNull(
        json["projectValueCurrent"] == null
            ? ""
            : "${json['projectValueCurrent']}";
    //);

    final rawId = json["defectLiabilityEndDate"];
    if (rawId is DateTime) {
      defectLiabilityEndDate = rawId;
    } else if (rawId is String) {
      defectLiabilityEndDate = DateTimeUtils.intToDateTime(rawId);
    }

    final projectPeriodId = json["projectPeriod"];
    if (projectPeriodId is DateTime) {
      projectPeriod = projectPeriodId;
    } else if (projectPeriodId is String) {
      projectPeriod = DateTimeUtils.intToDateTime(projectPeriodId);
    }

    projectValue =
        json["projectValue"] == null ? "" : "${json['projectValue']}";
    //projectCompletion = toIntOrNull(json['projectCompletion']);
    projectCompletion =
        ProjectContractNumericHelper.toDoubleOrNull(json["projectCompletion"]);
    initialProjectValue =
        // ProjectContractNumericHelper.toDoubleOrNull(
        json["initialProjectValue"] == null
            ? "Not Available"
            : "${json['initialProjectValue']}";
    //);
    projectSummary = json["projectSummary"];
    createdBy = json["createdBy"];
    createdDate = json["createdDate"];
    updatedBy = json["updatedBy"];
    updatedDate = json["updatedDate"];
    if (json["facilityId"] != null) {
      facilityId = toIntOrNull(json["facilityId"]);
    }
  }

  /// Creates a [Project] instance from a JSON map.
  Project.fromJson(Map<String, dynamic> json) {
    // code = json['code'];
    name = json["name"];
    ultimateOwner = json["ultimateOwner"];
    ownerEntity = json["ownerEntity"];
    ownerRim = json["ownerRim"];
    ownerEntityRim = json["ownerEntityRim"];
    projectValue = json["projectValue"] ?? "";
    period = DateTimeUtils.intToDateTime(json["period"]);
    completion = json["completion"];
    liabilityEndDate = DateTimeUtils.intToDateTime(json["liabilityEndDate"]);
    summary = json["summary"];
    initalProjectValue = json["initalProjectValue"];
    currentProjectValue = json["currentProjectValue"];
    if (json["Contract"] != null) {
      contract = <Contract>[];
      json["Contract"].forEach((v) {
        contract!.add(Contract.fromJson(v));
      });
    }
  }

  /// Project name.
  String? name;

  /// Ultimate project owner.
  String? ultimateOwner;

  /// Project owner entity.
  String? ownerEntity;

  /// Project owner RIM number.
  int? ownerRim;

  /// Project owner entity RIM number.
  int? ownerEntityRim;

  /// Project period.
  DateTime? period;

  /// Project completion percentage.
  int? completion;

  /// Defect liability end date.
  DateTime? liabilityEndDate;

  /// Project summary.
  String? summary;

  /// Initial project value.
  String? initalProjectValue;

  /// Current project value.
  String? currentProjectValue;

  /// Project identifier.
  int? projectId;

  /// Project code.
  String? projectCode;

  /// Project name.
  String? projectName;

  /// Project owner RIM number.
  int? projectOwnerRimNo;

  /// Project owner entity RIM number.
  int? projectOwnerEntityRimNo;

  /// Ultimate project owner name.
  String? projectUltimateOwnerName;

  /// Project owner entity name.
  String? projectOwnerEntityName;

  /// Current project value.
  String? projectValueCurrent;

  /// Defect liability end date.
  DateTime? defectLiabilityEndDate;

  /// Project value.
  String? projectValue;

  /// Project period.
  DateTime? projectPeriod;

  /// Project completion percentage.
  double? projectCompletion;

  /// Initial project value.
  String? initialProjectValue;

  /// Project summary.
  String? projectSummary;

  /// User who created the project.
  String? createdBy;

  /// Project creation date.
  String? createdDate;

  /// User who last updated the project.
  String? updatedBy;

  /// Project last update date.
  String? updatedDate;

  /// Facility identifier.
  int? facilityId;

  /// Contracts associated with the project.
  List<Contract>? contract;

  /// Converts this [Project] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['code'] = code;
    data["name"] = name;
    data["ultimateOwner"] = ultimateOwner;
    data["ownerEntity"] = ownerEntity;
    data["ownerRim"] = ownerRim;
    data["ownerEntityRim"] = ownerEntityRim;
    data["projectValue"] = projectValue;
    data["period"] = DateTimeUtils.datetimeToInt(period);
    data["completion"] = completion;
    data["liabilityEndDate"] = DateTimeUtils.datetimeToInt(liabilityEndDate);
    data["summary"] = summary;
    data["initalProjectValue"] = initalProjectValue;
    data["currentProjectValue"] = currentProjectValue;
    if (contract != null) {
      data["Contract"] = contract!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// Converts this [Project] instance to an API payload.
  Map<String, dynamic> toAPIJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["projectId"] = projectId;
    data["projectCode"] = projectCode;
    data["projectName"] = projectName;
    data["projectOwnerRimNo"] = projectOwnerRimNo;
    data["projectOwnerEntityRimNo"] = projectOwnerEntityRimNo;
    data["projectUltimateOwnerName"] = projectUltimateOwnerName;
    data["projectOwnerEntityName"] = projectOwnerEntityName;
    data["projectValueCurrent"] = projectValueCurrent;
    data["defectLiabilityEndDate"] = defectLiabilityEndDate;
    data["projectValue"] = projectValue;
    data["projectPeriod"] = projectPeriod;
    data["projectCompletion"] = projectCompletion;
    data["initialProjectValue"] = initialProjectValue;
    data["projectSummary"] = projectSummary;
    data["createdBy"] = createdBy;
    data["createdDate"] = createdDate;
    data["updatedBy"] = updatedBy;
    data["updatedDate"] = updatedDate;
    data["facilityId"] = facilityId;
    if (contract != null) {
      data["Contract"] = contract!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// Converts this [Project] instance to a project save payload.
  Map<String, dynamic> toSaveEditProjectJson({
    bool isCreateProject = false,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["projectCode"] = projectCode?.trim();
    data["projectName"] = projectName?.trim();
    data["projectUltimateOwnerName"] = projectUltimateOwnerName?.trim();
    data["projectOwnerEntityName"] = projectOwnerEntityName?.trim();
    data["projectOwnerRimNo"] = projectOwnerRimNo;
    data["projectOwnerEntityRimNo"] = projectOwnerEntityRimNo;
    data["projectValue"] = projectValue?.replaceAll(",", "");
    data["projectValueCurrent"] =
        (projectValue ?? projectValueCurrent)?.replaceAll(",", "");

    data["projectPeriod"] = projectPeriod != null
        ? DateTimeUtils.formatMonthYear(projectPeriod) // returns "MM/yyyy"
        : null;
    data["defectLiabilityEndDate"] = defectLiabilityEndDate != null
        ? DateTimeUtils.formatMonthYear(
            defectLiabilityEndDate,
          ) // returns "MM/yyyy"
        : null;

    data["projectCompletion"] = projectCompletion;
    data["projectSummary"] = projectSummary?.trim();

    if (isCreateProject) {
      data["initialProjectValue"] =
          (projectValue ?? initialProjectValue)?.replaceAll(",", "");
      data["facilityId"] = isCreateProject ? null : facilityId;
    }

    return data;
  }
}

/// Safely converts a nullable num (int/double) to int?
/// - If value is null => returns null
/// - If value is double => rounds or truncates based on [round]
/// - If value is already int => returns it as-is
int? toIntOrNull(num? value, {bool round = true}) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  // if (value is double) return int.tryParse(value.toString());
  // value is double
  return round ? value.round() : value.toInt();
}
