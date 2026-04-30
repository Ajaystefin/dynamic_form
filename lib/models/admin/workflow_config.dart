class WorkflowConfig {
  // Active / Inactive

  WorkflowConfig({
    this.id,
    this.workflowType,
    this.applicationTypeName,
    this.customerSegment,
    this.applicationType,
    this.subType,
    this.approvalDoneBy,
    this.workflowTypeReference,
    this.newApplicationTypeName,
    this.isDocumentation,
    this.status,
  });

  factory WorkflowConfig.fromJson(Map<String, dynamic> json) {
    return WorkflowConfig(
      id: json["id"],
      workflowType: json["workflowType"],
      applicationTypeName: json["applicationTypeName"],
      customerSegment: json["reference1"],
      applicationType: json["reference2"],
      subType: json["reference3"],
      approvalDoneBy: json["reference4"],
      workflowTypeReference: json["reference5"],
      newApplicationTypeName: json["name"],
      isDocumentation: json["isDocumentation"],
      status: json["isActive"] == "1" ? "Active" : "Inactive",
    );
  }
  final int? id;
  final String? workflowType;
  final String? applicationTypeName;

  final String? customerSegment; // Reference1
  final String? applicationType; // Reference2: FULL or MEMO
  final String? subType; // Reference3: AR, MF, NW, etc.
  final String? approvalDoneBy; // Reference4
  final String? workflowTypeReference; // Reference5

  final String? newApplicationTypeName; // NAME column — new app type name
  final String? isDocumentation; // YES / NO
  // It's recevied only from api call
  final String? status;

  WorkflowConfig copyWith({
    int? id,
    String? workflowType,
    String? applicationTypeName,
    String? customerSegment,
    String? applicationType,
    String? subType,
    String? approvalDoneBy,
    String? workflowTypeReference,
    String? newApplicationTypeName,
    String? isDocumentation,
    String? status,
  }) {
    return WorkflowConfig(
      id: id ?? this.id,
      workflowType: workflowType ?? this.workflowType,
      applicationTypeName: applicationTypeName ?? this.applicationTypeName,
      customerSegment: customerSegment ?? this.customerSegment,
      applicationType: applicationType ?? this.applicationType,
      subType: subType ?? this.subType,
      approvalDoneBy: approvalDoneBy ?? this.approvalDoneBy,
      workflowTypeReference:
          workflowTypeReference ?? this.workflowTypeReference,
      newApplicationTypeName:
          newApplicationTypeName ?? this.newApplicationTypeName,
      isDocumentation: isDocumentation ?? this.isDocumentation,
      status: status ?? this.status,
    );
  }

  /// Key names match the DB column names in the reference data master.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": newApplicationTypeName, // NAME column
      "reference1": customerSegment, // Customer Segment
      "reference2": applicationType, // FULL / MEMO
      "reference3": subType, // Sub Type code
      "reference4": approvalDoneBy, // Approval done by
      "reference5": workflowTypeReference, // Workflow type label
      "isDocumentation": isDocumentation, // YES / NO
      "isActive": status == "Active" ? "1" : "0",
    };
  }
}
