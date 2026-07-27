/// Represents workflow configuration details for an application type,
/// customer segment, subtype, approval flow, documentation flag, and status.
class WorkflowConfig {
  /// Creates a [WorkflowConfig] instance.
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

  /// Creates a [WorkflowConfig] instance from a JSON map.
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

  /// Unique identifier of the workflow configuration.
  final int? id;

  /// Type of the workflow.
  final String? workflowType;

  /// Existing application type name.
  final String? applicationTypeName;

  /// Customer segment mapped from `reference1`.
  final String? customerSegment;

  /// Application type mapped from `reference2`.
  final String? applicationType;

  /// Application subtype mapped from `reference3`.
  final String? subType;

  /// Approval owner or approver information mapped from `reference4`.
  final String? approvalDoneBy;

  /// Workflow type reference label mapped from `reference5`.
  final String? workflowTypeReference;

  /// New application type name mapped from the `name` field.
  final String? newApplicationTypeName;

  /// Documentation flag value.
  final String? isDocumentation;

  /// Active or inactive status received from the API.
  final String? status;

  /// Creates a copy of this [WorkflowConfig] with updated values.
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

  /// Converts this [WorkflowConfig] instance into a JSON map.
  ///
  /// Key names match the database column names in the reference data master.
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
